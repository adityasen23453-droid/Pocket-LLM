import os
import sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from rag_engine import RAGEngine
from llm_engine import LLMEngine
import torch

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

# Test generation with repetition_penalty and no_repeat_ngram_size
messages = llm.build_prompt_messages(
    query='All 10 questions of assignment 8 cryptography pdf. Solve each question 1 to 10 in order.',
    context=ctx
)
prompt_text = llm.tokenizer.apply_chat_template(messages, tokenize=False, add_generation_prompt=True)
inputs = llm.tokenizer([prompt_text], return_tensors="pt").to(llm.device)

print('Input tokens:', inputs['input_ids'].shape)

outputs = llm.model.generate(
    **inputs,
    max_new_tokens=1024,
    temperature=0.3,
    top_p=0.9,
    repetition_penalty=1.15,
    no_repeat_ngram_size=4,
    do_sample=True,
    pad_token_id=llm.tokenizer.eos_token_id
)

resp = llm.tokenizer.decode(outputs[0][inputs['input_ids'].shape[1]:], skip_special_tokens=True)
print('\n--- MODEL OUTPUT WITH REPETITION PENALTY ---')
print(resp.encode('ascii', errors='replace').decode())

