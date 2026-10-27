import re
import threading
from typing import Iterator, List, Dict, Any, Optional
import torch
from transformers import AutoTokenizer, AutoModelForCausalLM, TextIteratorStreamer

from intent_router import QueryIntent

DEFAULT_MODEL_ID = "Qwen/Qwen2.5-1.5B-Instruct"

PROMPTS = {
    QueryIntent.CONVERSATIONAL: (
        "You are PocketLLM, an expert AI tutor for Indian students (CBSE, ICSE, JEE, NEET, and College/University).\n"
        "Greet the student warmly and politely. Inform them that you can help explain concepts, "
        "summarize study notes, or solve assignments from their uploaded PDFs. Ask what topic or assignment they would like to work on."
    ),
    QueryIntent.DOCUMENT_SUMMARY: (
        "You are PocketLLM, an academic study assistant for Indian students.\n"
        "Provide a clear, well-structured executive summary of the provided Study Notes Context.\n"
        "Highlight the primary topics, key formulas, and major concepts using organized bullet points.\n"
        "Do not invent test answers, quizzes, or irrelevant multiple-choice options."
    ),
    QueryIntent.ALL_QUESTIONS: (
        "You are PocketLLM, an expert academic tutor for Indian students.\n"
        "CRITICAL INSTRUCTION: The student wants solutions for the questions in the Study Notes Context.\n"
        "Answer EVERY question sequentially from Question 1 to Question N without skipping any questions or stopping prematurely.\n"
        "Format each answer cleanly:\n"
        "**Question X:**\n"
        "- **Correct Answer:** (Option letter and/or text)\n"
        "- **Explanation:** (Step-by-step mathematical proof or conceptual reasoning from the notes)\n"
        "Do not stop after answering only one question."
    ),
    QueryIntent.CONTINUATION: (
        "You are PocketLLM, an expert academic tutor for Indian students.\n"
        "CRITICAL INSTRUCTION: The student wants the remaining questions from the Study Notes Context.\n"
        "Continue sequentially from where the previous response left off. Do not repeat previously answered questions.\n"
        "Format each clearly with Question number, Correct Answer, and Explanation."
    ),
    QueryIntent.SPECIFIC_QA: (
        "You are PocketLLM, an expert AI tutor for Indian students.\n"
        "CRITICAL RULES:\n"
        "1. DIRECT ANSWERS ONLY: Directly deliver the solution or explanation immediately. Never echo the student's question.\n"
        "2. STRICT DOCUMENT GROUNDING: Answer strictly based on the Study Notes Context. If the information is not present, state so clearly.\n"
        "3. TEXTBOOK FORMULA FORMATTING: Use LaTeX brackets: \\[ equation \\] and \\( variable \\)."
    )
}

DEFAULT_SYSTEM_PROMPT = PROMPTS[QueryIntent.SPECIFIC_QA]


class LLMEngine:
    """
    Local LLM Inference Engine with real-time token streaming.
    Runs Qwen2.5 on NVIDIA GPU (CUDA float16) or CPU fallback.
    """
    def __init__(self, model_id: str = DEFAULT_MODEL_ID, device: Optional[str] = None):
        self.model_id = model_id
        
        # Determine optimal device
        if device:
            self.device = device
        elif torch.cuda.is_available():
            self.device = "cuda"
        else:
            self.device = "cpu"
            
        print(f"[LLM] Loading tokenizer for {self.model_id}...")
        self.tokenizer = AutoTokenizer.from_pretrained(self.model_id)
        
        print(f"[LLM] Loading weights for {self.model_id} on {self.device}...")
        torch_dtype = torch.float16 if self.device == "cuda" else torch.float32
        
        self.model = AutoModelForCausalLM.from_pretrained(
            self.model_id,
            dtype=torch_dtype,
            device_map=self.device
        )
        print(f"[LLM] Engine initialized successfully on {self.device.upper()}!")

    def build_prompt_messages(
        self,
        query: str,
        context: Optional[str] = None,
        chat_history: Optional[List[Dict[str, str]]] = None,
        system_prompt: Optional[str] = None,
        intent: Optional[QueryIntent] = None
    ) -> List[Dict[str, str]]:
        """Constructs chat template message list with intent-tailored system instructions and sanitized context."""
        effective_intent = intent or (QueryIntent.SPECIFIC_QA if context else QueryIntent.CONVERSATIONAL)
        sys_msg = system_prompt or PROMPTS.get(effective_intent, DEFAULT_SYSTEM_PROMPT)
        
        if context and context.strip() and effective_intent != QueryIntent.CONVERSATIONAL:
            user_content = (
                f"### Study Notes Context:\n{context.strip()}\n\n"
                f"### Student Instruction:\n{query.strip()}\n\n"
                f"Instructions: Directly provide the answer or summary from the Study Notes Context above."
            )
        else:
            user_content = query.strip()
            
        messages = [{"role": "system", "content": sys_msg}]
        
        # Append prior conversation turns if provided (sanitizing echo headers and repetitive loops)
        if chat_history and effective_intent != QueryIntent.CONVERSATIONAL:
            for turn in chat_history[-4:]:  # Keep recent context window compact
                role = turn.get("role")
                content = (turn.get("content") or "").strip()
                if role in ["user", "assistant"] and content:
                    if role == "assistant":
                        # Strip repetitive prefix hallucination headers
                        content = re.sub(
                            r'^(PDF Summary in Hinglish|Certainly! Here\'s a summary of the student\'s question:?|### Student Questions:?)\s*',
                            '',
                            content,
                            flags=re.IGNORECASE
                        ).strip()
                    if content:
                        messages.append({"role": role, "content": content})
                    
        messages.append({"role": "user", "content": user_content})
        return messages

    def generate_stream(
        self,
        query: str,
        context: Optional[str] = None,
        chat_history: Optional[List[Dict[str, str]]] = None,
        system_prompt: Optional[str] = None,
        intent: Optional[QueryIntent] = None,
        max_new_tokens: int = 1280,
        temperature: float = 0.2,
        top_p: float = 0.9,
        repetition_penalty: float = 1.15,
        no_repeat_ngram_size: int = 4
    ) -> Iterator[str]:
        """
        Yields generated response tokens one by one in real-time using TextIteratorStreamer.
        Non-blocking generation executed via background worker thread with anti-repetition controls.
        """
        messages = self.build_prompt_messages(
            query=query,
            context=context,
            chat_history=chat_history,
            system_prompt=system_prompt,
            intent=intent
        )
        
        prompt_text = self.tokenizer.apply_chat_template(
            messages,
            tokenize=False,
            add_generation_prompt=True
        )
        
        inputs = self.tokenizer([prompt_text], return_tensors="pt").to(self.device)
        
        streamer = TextIteratorStreamer(
            self.tokenizer,
            skip_prompt=True,
            skip_special_tokens=True
        )
        
        generation_kwargs = dict(
            **inputs,
            streamer=streamer,
            max_new_tokens=max_new_tokens,
            temperature=temperature,
            top_p=top_p,
            repetition_penalty=repetition_penalty,
            no_repeat_ngram_size=no_repeat_ngram_size,
            do_sample=temperature > 0.0,
            pad_token_id=self.tokenizer.eos_token_id
        )
        
        # Run generation on background thread so caller can stream tokens immediately
        thread = threading.Thread(target=self.model.generate, kwargs=generation_kwargs)
        thread.start()
        
        for token in streamer:
            yield token
            
        thread.join()

    def generate(
        self,
        query: str,
        context: Optional[str] = None,
        chat_history: Optional[List[Dict[str, str]]] = None,
        system_prompt: Optional[str] = None,
        intent: Optional[QueryIntent] = None,
        max_new_tokens: int = 1280,
        temperature: float = 0.2,
        repetition_penalty: float = 1.15,
        no_repeat_ngram_size: int = 4
    ) -> str:
        """Synchronous complete text generation with anti-repetition penalty."""
        return "".join(self.generate_stream(
            query=query,
            context=context,
            chat_history=chat_history,
            system_prompt=system_prompt,
            intent=intent,
            max_new_tokens=max_new_tokens,
            temperature=temperature,
            repetition_penalty=repetition_penalty,
            no_repeat_ngram_size=no_repeat_ngram_size
        ))
