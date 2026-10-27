import sys
import os
sys.path.insert(0, 'd:/PocketLLM/backend')

from rag_engine import RAGEngine
from llm_engine import LLMEngine
from app import _resolve_rag_context, ChatRequest

rag = RAGEngine()
llm = LLMEngine()

test_cases = [
    ("hello", "Assignment_1.pdf"),
    ("summarize", "DWDM_7th_QB.pdf"),
    ("help me", "DWDM_7th_QB.pdf")
]

for query, doc in test_cases:
    req = ChatRequest(message=query, active_document=doc, use_rag=True)
    chunks, sources = _resolve_rag_context(req, query)
    context_str = "\n\n".join(chunks) if chunks else None
    msgs = llm.build_prompt_messages(query=query, context=context_str)
    prompt_text = llm.tokenizer.apply_chat_template(msgs, tokenize=False, add_generation_prompt=True)
    
    print(f"\n==========================================")
    print(f"QUERY: '{query}', DOC: '{doc}'")
    print(f"Sources resolved: {sources}")
    print(f"Chunks count: {len(chunks)}")
    print(f"Prompt length (chars): {len(prompt_text)}")
    print(f"--- Prompt head (300 chars) ---")
    print(prompt_text[:300])
    print(f"--- Prompt tail (400 chars) ---")
    print(prompt_text[-400:])
    
    # Generate
    inputs = llm.tokenizer([prompt_text], return_tensors="pt").to(llm.device)
    outputs = llm.model.generate(
        **inputs,
        max_new_tokens=64,
        temperature=0.2,
        do_sample=True,
        pad_token_id=llm.tokenizer.eos_token_id
    )
    resp = llm.tokenizer.decode(outputs[0][inputs['input_ids'].shape[1]:], skip_special_tokens=True)
    print(f"--- RESPONSE ---")
    print(resp.encode('ascii', errors='replace').decode())

