import os
import sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from rag_engine import RAGEngine
from llm_engine import LLMEngine

rag = RAGEngine()
doc = 'Assignment_8__Theory_and_Practice_of_Modern_Cryptography_.pdf'
chunks = rag.get_document_chunks(doc, max_chunks=35)
print(f'Total chunks for Assignment 8: {len(chunks)}')

ctx_list = []
for c in chunks:
    src = c.get('source')
    pg = c.get('page')
    txt = c.get('text')
    ctx_list.append(f"[{src} - Page {pg}]: {txt}")
ctx = "\n\n".join(ctx_list)

llm = LLMEngine()

custom_prompt = (
    "You are PocketLLM, an expert AI tutor for Indian students.\n"
    "CRITICAL RULES:\n"
    "1. COMPLETE ASSIGNMENT SOLUTIONS:\n"
    "   - When asked for questions/answers of an assignment or notes, solve and list ALL questions present in the context in sequential order (Question 1, Question 2, ..., Question N).\n"
    "   - Format each question clearly:\n"
    "     **Question [Number]: [Topic or brief question]**\n"
    "     - **Answer:** [Option and text]\n"
    "     - **Explanation:** [Concise reasoning directly from the notes]\n"
    "   - NEVER stop after only one question. You must systematically answer every question found in the context.\n"
    "2. STRICT TRUTH: Answer strictly based on the provided Study Notes Context."
)

print('\n--- GENERATING WITH COMPLETE MULTI-QUESTION TEMPLATE ---')
resp = llm.generate(
    query='All 10 questions of assignment 8 cryptography pdf',
    context=ctx,
    system_prompt=custom_prompt,
    max_new_tokens=1024
)

print('\n--- MODEL OUTPUT ---')
print(resp.encode('ascii', errors='replace').decode())

