import os
import sys
import unittest

# Add backend directory to sys.path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from rag_engine import RAGEngine

class TestRAGEngine(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        test_db_dir = "./backend/test_chroma_db"
        cls.engine = RAGEngine(
            persist_directory=test_db_dir,
            collection_name="test_student_notes"
        )
        cls.engine.clear()

    def test_01_chunking_with_overlap(self):
        sample_text = (
            "Newton's First Law states that an object at rest stays at rest unless acted upon by an external force. "
            "Newton's Second Law states that force equals mass times acceleration (F = ma). "
            "Newton's Third Law states that for every action, there is an equal and opposite reaction. "
            "These three laws form the foundation of classical Newtonian mechanics."
        )
        chunks = self.engine.chunk_text(sample_text, chunk_size=120, chunk_overlap=30)
        self.assertGreater(len(chunks), 1, "Text should be split into multiple chunks")
        print(f"\n[Test] Chunking created {len(chunks)} chunks.")
        for idx, chunk in enumerate(chunks):
            print(f"  Chunk {idx}: {chunk[:60]}... ({len(chunk)} chars)")

    def test_02_add_and_retrieve_document(self):
        # Create a sample study note file
        sample_file = "./backend/sample_physics_notes.txt"
        with open(sample_file, "w", encoding="utf-8") as f:
            f.write(
                "Chapter 5: Laws of Motion\n\n"
                "1. Newton's First Law of Motion (Law of Inertia):\n"
                "A body continues in its state of rest or uniform motion in a straight line unless compelled to change that state by an external force applied to it.\n\n"
                "2. Newton's Second Law of Motion:\n"
                "The rate of change of linear momentum of a body is directly proportional to the applied force and takes place in the direction in which the force acts.\n"
                "Equation: F = dp/dt = m * a (Force equals mass into acceleration).\n\n"
                "3. Newton's Third Law of Motion:\n"
                "To every action, there is always an equal and opposite reaction. Action and reaction forces act on different bodies and occur simultaneously.\n\n"
                "4. Friction:\n"
                "Frictional force is a contact force that opposes relative motion between two surfaces. Static friction self-adjusts up to its limiting value.\n"
            )

        try:
            num_chunks = self.engine.add_document(sample_file)
            self.assertGreater(num_chunks, 0, "Document should be chunked and indexed into ChromaDB")

            # Query 1: Third law
            results = self.engine.retrieve("What is Newton's third law of action and reaction?", top_k=2)
            self.assertGreater(len(results), 0, "Should retrieve at least 1 relevant chunk")
            found_third_law = any("Third Law" in r["text"] for r in results)
            self.assertTrue(found_third_law, "Retrieved top-k context must contain Third Law")
            self.assertGreater(results[0]["similarity"], 0.4, "Similarity score should be significant")

            # Query 2: Friction
            results_friction = self.engine.retrieve("How does frictional force oppose motion?", top_k=1)
            self.assertIn("Friction", results_friction[0]["text"], "Top retrieved chunk must contain Friction")
            print(f"  Friction Query Match Similarity: {results_friction[0]['similarity']}")

        finally:
            if os.path.exists(sample_file):
                os.remove(sample_file)

    def test_03_document_scoped_filtering(self):
        # Create two separate document files
        doc_a_path = "./backend/test_doc_chemistry.txt"
        doc_b_path = "./backend/test_doc_history.txt"

        with open(doc_a_path, "w", encoding="utf-8") as f:
            f.write("Periodic Table Chapter: Gold symbol is Au, atomic number 79. Sodium symbol is Na.")

        with open(doc_b_path, "w", encoding="utf-8") as f:
            f.write("Indian History: The Indus Valley Civilisation flourished around 2500 BCE along the Indus River basin.")

        try:
            self.engine.add_document(doc_a_path)
            self.engine.add_document(doc_b_path)

            # Query chemistry with filter for chemistry doc
            chem_results = self.engine.retrieve("atomic symbol", top_k=3, document_filter="test_doc_chemistry.txt")
            self.assertGreater(len(chem_results), 0)
            for r in chem_results:
                self.assertEqual(r["source"], "test_doc_chemistry.txt", "Must strictly contain only doc A")

            # Query history with filter for history doc
            hist_results = self.engine.retrieve("Civilisation", top_k=3, document_filter="test_doc_history.txt")
            self.assertGreater(len(hist_results), 0)
            for r in hist_results:
                self.assertEqual(r["source"], "test_doc_history.txt", "Must strictly contain only doc B")

            # Verify cross-isolation: chemistry query filtered to history doc returns no chemistry chunks
            isolated = self.engine.retrieve("atomic symbol for Gold Au", top_k=3, document_filter="test_doc_history.txt")
            for r in isolated:
                self.assertNotIn("Gold symbol is Au", r["text"], "Doc B must never contain Doc A text")

        finally:
            if os.path.exists(doc_a_path):
                os.remove(doc_a_path)
            if os.path.exists(doc_b_path):
                os.remove(doc_b_path)

    def test_04_get_document_chunks_for_summary(self):
        summary_doc = "./backend/test_doc_summary.txt"
        with open(summary_doc, "w", encoding="utf-8") as f:
            f.write("Section 1: Overview\n\nSection 2: Methodology\n\nSection 3: Key Results\n\nSection 4: Conclusion")

        try:
            self.engine.add_document(summary_doc)
            seq_chunks = self.engine.get_document_chunks("test_doc_summary.txt", max_chunks=10)
            self.assertGreater(len(seq_chunks), 0)
            self.assertEqual(seq_chunks[0]["chunk_index"], 0)
            for chunk in seq_chunks:
                self.assertEqual(chunk["source"], "test_doc_summary.txt")
        finally:
            if os.path.exists(summary_doc):
                os.remove(summary_doc)

    @classmethod
    def tearDownClass(cls):
        # Clean up test DB
        try:
            cls.engine.clear()
        except Exception:
            pass

if __name__ == "__main__":
    unittest.main()
