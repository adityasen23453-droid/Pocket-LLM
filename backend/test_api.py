import os
import sys
import unittest
import io
import json

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from fastapi.testclient import TestClient
from app import app

class TestPocketLLMAPI(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        print("\n[Test] Initializing FastAPI TestClient...")
        cls.client = TestClient(app)
        # Trigger lifespan startup
        cls.client.__enter__()

    @classmethod
    def tearDownClass(cls):
        cls.client.__exit__(None, None, None)

    def test_01_health_check(self):
        response = self.client.get("/api/health")
        self.assertEqual(response.status_code, 200)
        data = response.json()
        print(f"\n[Test] Health Check Data: {data}")
        self.assertEqual(data["status"], "online")
        self.assertEqual(data["device"], "cuda")
        self.assertIn("Qwen2.5", data["model"])

    def test_02_upload_document(self):
        sample_content = (
            "Ohm's Law: The electric current flowing through a conductor is directly proportional "
            "to the potential difference across its two ends, provided temperature and other physical conditions remain constant. "
            "Mathematical formulation: V = I * R, where V is voltage (in Volts), I is electric current (in Amperes), and R is resistance (in Ohms)."
        )
        file_bytes = io.BytesIO(sample_content.encode("utf-8"))
        
        response = self.client.post(
            "/api/upload",
            files={"file": ("ohms_law_notes.txt", file_bytes, "text/plain")}
        )
        self.assertEqual(response.status_code, 200)
        data = response.json()
        print(f"\n[Test] Upload Result: {data}")
        self.assertTrue(data["success"])
        self.assertGreater(data["chunks_added"], 0)

    def test_03_chat_sync_rag(self):
        query_payload = {
            "message": "What is the formula of Ohm's law and what does V stand for?",
            "use_rag": True,
            "top_k": 2
        }
        response = self.client.post("/api/chat/sync", json=query_payload)
        self.assertEqual(response.status_code, 200)
        data = response.json()
        print(f"\n[Test] Sync Chat RAG Response:\n{data['response']}")
        print(f"  Sources: {data['sources']}")
        self.assertTrue(data["used_rag"])
        self.assertTrue(len(data["response"]) > 0)
        self.assertIn("ohms_law_notes.txt", data["sources"])

    def test_03b_active_document_scoping(self):
        # Upload a secondary document
        secondary_content = "Biology Chapter 1: Photosynthesis is the process by which green plants synthesize nutrients using sunlight and chlorophyll."
        file_bytes = io.BytesIO(secondary_content.encode("utf-8"))
        self.client.post(
            "/api/upload",
            files={"file": ("biology_notes.txt", file_bytes, "text/plain")}
        )

        # Scoped query: asking about biology with active_document strictly set to biology_notes.txt
        query_payload = {
            "message": "Explain photosynthesis and chlorophyll.",
            "use_rag": True,
            "top_k": 3,
            "active_document": "biology_notes.txt"
        }
        response = self.client.post("/api/chat/sync", json=query_payload)
        self.assertEqual(response.status_code, 200)
        data = response.json()
        print(f"\n[Test] Scoped Query Sources: {data['sources']}")
        self.assertEqual(data["sources"], ["biology_notes.txt"])
        self.assertNotIn("ohms_law_notes.txt", data["sources"])

    def test_04_chat_streaming(self):
        query_payload = {
            "message": "State Ohm's law briefly in one sentence.",
            "use_rag": True,
            "top_k": 1
        }
        response = self.client.post("/api/chat", json=query_payload)
        self.assertEqual(response.status_code, 200)
        
        # Read streaming lines
        lines = response.text.split("\n\n")
        tokens = []
        sources = []
        for line in lines:
            if line.startswith("data: "):
                try:
                    payload = json.loads(line[6:])
                    if payload.get("type") == "token":
                        tokens.append(payload.get("content", ""))
                    elif payload.get("type") == "sources":
                        sources = payload.get("sources", [])
                except json.JSONDecodeError:
                    pass
                    
        accumulated = "".join(tokens)
        print(f"\n[Test] Streamed {len(tokens)} tokens:\n{accumulated}")
        self.assertGreater(len(tokens), 2)
        self.assertTrue(len(accumulated) > 0)

    def test_05_clear_vector_store(self):
        response = self.client.post("/api/clear")
        self.assertEqual(response.status_code, 200)
        self.assertTrue(response.json()["success"])
        
        # Verify chunks count is now 0
        docs_res = self.client.get("/api/documents")
        self.assertEqual(docs_res.json()["total_chunks"], 0)
        print("\n[Test] Vector store successfully cleared and confirmed 0 chunks.")

if __name__ == "__main__":
    unittest.main()

