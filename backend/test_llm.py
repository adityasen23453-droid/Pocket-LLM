import os
import sys
import unittest
import time

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from llm_engine import LLMEngine

class TestLLMEngine(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        print("\n[Test] Initializing LLM Engine for test suite...")
        cls.engine = LLMEngine()

    def test_01_device_and_model(self):
        self.assertIsNotNone(self.engine.model)
        self.assertIsNotNone(self.engine.tokenizer)
        print(f"\n[Test] LLM Engine running on: {self.engine.device}")

    def test_02_sync_generation(self):
        prompt = "Define velocity in 1 short sentence."
        start = time.time()
        response = self.engine.generate(prompt, max_new_tokens=40)
        elapsed = time.time() - start
        
        self.assertTrue(len(response.strip()) > 0, "Response must not be empty")
        print(f"\n[Test] Sync Generation ({elapsed:.2f}s):\n  Prompt: {prompt}\n  Response: {response.strip()}")

    def test_03_streaming_generation(self):
        prompt = "Name 3 primary colors."
        stream = self.engine.generate_stream(prompt, max_new_tokens=30)
        tokens = []
        for token in stream:
            tokens.append(token)
            
        full_text = "".join(tokens)
        self.assertGreater(len(tokens), 1, "Streaming must yield more than 1 chunk")
        self.assertTrue(len(full_text.strip()) > 0, "Accumulated text must not be empty")
        print(f"\n[Test] Streaming yielded {len(tokens)} chunks. Full output: {full_text.strip()}")

    def test_04_rag_grounded_generation(self):
        context = "PocketLLM is created for college students across India to make AI study assistance completely offline."
        query = "What is PocketLLM designed for?"
        
        response = self.engine.generate(query=query, context=context, max_new_tokens=50)
        print(f"\n[Test] RAG Grounded Output: {response.strip()}")
        self.assertTrue("PocketLLM" in response or "offline" in response or "student" in response.lower())

if __name__ == "__main__":
    unittest.main()

