import os
import re
from typing import List, Dict, Any, Optional

try:
    import pymupdf  # PyMuPDF for high-fidelity text, table & formula extraction
    HAS_PYMUPDF = True
except ImportError:
    HAS_PYMUPDF = False

import pypdf
from sentence_transformers import SentenceTransformer
import chromadb
from chromadb.config import Settings

DEFAULT_CHROMA_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "chroma_db")

class RAGEngine:
    """
    High-Fidelity RAG pipeline for PocketLLM Student Assistant.
    Features:
    - High-fidelity PDF extraction via PyMuPDF (preserves math symbols, tables, reading order)
    - Semantic boundary chunking with page number tracking
    - Document-scoped filtering (eliminates cross-document pollution)
    - Full-document sequential retrieval for comprehensive summaries
    """
    def __init__(
        self,
        persist_directory: Optional[str] = None,
        embedding_model_name: str = "all-MiniLM-L6-v2",
        collection_name: str = "student_notes"
    ):
        self.persist_directory = persist_directory or DEFAULT_CHROMA_DIR
        self.embedding_model_name = embedding_model_name
        self.collection_name = collection_name
        self.latest_uploaded_document: Optional[str] = None
        
        os.makedirs(self.persist_directory, exist_ok=True)
        
        print(f"[RAG] Loading embedding model: {self.embedding_model_name}...")
        self.embedder = SentenceTransformer(self.embedding_model_name)
        
        print(f"[RAG] Initializing ChromaDB vector store at {self.persist_directory}...")
        self.client = chromadb.PersistentClient(path=self.persist_directory)
        self.collection = self.client.get_or_create_collection(
            name=self.collection_name,
            metadata={"hnsw:space": "cosine"}
        )
        print(f"[RAG] Ready! Collection '{self.collection_name}' currently has {self.collection.count()} chunks.")


    def extract_text_from_file(self, file_path: str) -> List[Dict[str, Any]]:
        """
        Extract text from PDF, TXT, or Markdown documents.
        Returns a list of page dicts: [{'page': 1, 'text': '...'}]
        """
        if not os.path.exists(file_path):
            raise FileNotFoundError(f"File not found: {file_path}")
            
        ext = os.path.splitext(file_path)[1].lower()
        pages_content = []

        if ext == ".pdf":
            if HAS_PYMUPDF:
                try:
                    doc = pymupdf.open(file_path)
                    for page_idx, page in enumerate(doc):
                        # Extract text with block preservation (headings, columns, tables)
                        page_text = page.get_text("text").strip()
                        if page_text:
                            pages_content.append({
                                "page": page_idx + 1,
                                "text": page_text
                            })
                    doc.close()
                except Exception as e:
                    print(f"[RAG] PyMuPDF extraction failed: {e}. Falling back to pypdf.")
                    pages_content = []

            # Fallback to pypdf if PyMuPDF wasn't used or failed
            if not pages_content:
                reader = pypdf.PdfReader(file_path)
                for page_idx, page in enumerate(reader.pages):
                    page_text = (page.extract_text() or "").strip()
                    if page_text:
                        pages_content.append({
                            "page": page_idx + 1,
                            "text": page_text
                        })

        elif ext in [".txt", ".md", ".json", ".py", ".csv"]:
            with open(file_path, "r", encoding="utf-8", errors="ignore") as f:
                raw_text = f.read().strip()
                if raw_text:
                    pages_content.append({
                        "page": 1,
                        "text": raw_text
                    })
        else:
            raise ValueError(f"Unsupported file extension: {ext}")

        return pages_content

    def chunk_document(
        self,
        pages_content: List[Dict[str, Any]],
        chunk_size: int = 800,
        chunk_overlap: int = 120
    ) -> List[Dict[str, Any]]:
        """
        Semantic chunker that preserves page numbers, paragraph boundaries, and formula blocks.
        Returns list of chunks with metadata: [{'text': str, 'page': int}]
        """
        all_chunks = []

        for p_info in pages_content:
            page_num = p_info["page"]
            text = p_info["text"]

            # Normalize line endings
            text = re.sub(r'\r\n', '\n', text)
            text = re.sub(r'\n{3,}', '\n\n', text)

            start = 0
            text_len = len(text)

            while start < text_len:
                end = min(start + chunk_size, text_len)

                if end < text_len:
                    # Priority 1: Double newline (paragraph / problem break)
                    para_break = text.rfind('\n\n', start, end)
                    if para_break != -1 and para_break > start + chunk_overlap:
                        end = para_break
                    else:
                        # Priority 2: Sentence boundaries (. / ? / ! / numbered questions)
                        sentence_break = max(
                            text.rfind('. ', start, end),
                            text.rfind('? ', start, end),
                            text.rfind('!\n', start, end),
                            text.rfind(':\n', start, end)
                        )
                        if sentence_break != -1 and sentence_break > start + chunk_overlap:
                            end = sentence_break + 1
                        else:
                            # Priority 3: Whitespace
                            space_break = text.rfind(' ', start, end)
                            if space_break != -1 and space_break > start + chunk_overlap:
                                end = space_break

                chunk_text = text[start:end].strip()
                if chunk_text:
                    all_chunks.append({
                        "text": f"[Page {page_num}]\n{chunk_text}",
                        "page": page_num
                    })

                start = end - chunk_overlap if end < text_len else text_len

        return all_chunks

    def chunk_text(
        self,
        text: str,
        chunk_size: int = 800,
        chunk_overlap: int = 120
    ) -> List[str]:
        """Convenience method for chunking raw text strings."""
        if not text:
            return []
        chunks_meta = self.chunk_document([{"page": 1, "text": text}], chunk_size, chunk_overlap)
        return [c["text"].replace("[Page 1]\n", "") for c in chunks_meta]

    def add_document(self, file_path: str, doc_id_prefix: Optional[str] = None) -> int:
        """Extracts, chunks, embeds, and adds a document to ChromaDB."""
        filename = os.path.basename(file_path)
        prefix = doc_id_prefix or filename

        pages_content = self.extract_text_from_file(file_path)
        if not pages_content:
            print(f"[RAG] Warning: No readable text extracted from {filename}")
            return 0

        chunks_with_meta = self.chunk_document(pages_content)
        if not chunks_with_meta:
            print(f"[RAG] Warning: 0 chunks created from {filename}")
            return 0

        # Remove previous chunks of the same file to prevent duplicate bloat
        try:
            self.collection.delete(where={"source": filename})
        except Exception:
            pass

        documents = [c["text"] for c in chunks_with_meta]
        metadatas = [
            {
                "source": filename,
                "page": c["page"],
                "chunk_index": i
            }
            for i, c in enumerate(chunks_with_meta)
        ]
        ids = [f"{prefix}_chunk_{i}" for i in range(len(chunks_with_meta))]

        # Generate dense embeddings
        embeddings = self.embedder.encode(documents, convert_to_numpy=True).tolist()

        self.collection.upsert(
            ids=ids,
            embeddings=embeddings,
            documents=documents,
            metadatas=metadatas
        )
        self.latest_uploaded_document = filename
        print(f"[RAG] Successfully indexed {len(documents)} chunks from '{filename}' into vector store.")
        return len(documents)


    def retrieve(
        self,
        query: str,
        top_k: int = 5,
        document_filter: Optional[str] = None
    ) -> List[Dict[str, Any]]:
        """
        Query vector store with cosine similarity.
        If document_filter is provided, strictly restricts search to that specific document.
        """
        if self.collection.count() == 0:
            return []

        query_embedding = self.embedder.encode([query], convert_to_numpy=True).tolist()

        query_kwargs = {
            "query_embeddings": query_embedding,
            "n_results": min(top_k, self.collection.count()),
            "include": ["documents", "metadatas", "distances"]
        }

        # Apply document-scoped metadata filter if specified
        if document_filter:
            # Check if this document has chunks in the collection
            doc_count = len(self.collection.get(where={"source": document_filter})["ids"])
            if doc_count > 0:
                query_kwargs["where"] = {"source": document_filter}
                query_kwargs["n_results"] = min(top_k, doc_count)

        results = self.collection.query(**query_kwargs)

        retrieved = []
        if results and "documents" in results and results["documents"]:
            docs = results["documents"][0]
            metas = results["metadatas"][0] if "metadatas" in results else [{}] * len(docs)
            dists = results["distances"][0] if "distances" in results else [0.0] * len(docs)

            for doc, meta, dist in zip(docs, metas, dists):
                similarity = max(0.0, 1.0 - (dist / 2.0))
                retrieved.append({
                    "text": doc,
                    "source": meta.get("source", "Uploaded Document"),
                    "page": meta.get("page", 1),
                    "chunk_index": meta.get("chunk_index", 0),
                    "similarity": round(similarity, 4)
                })

        return retrieved

    def get_document_chunks(
        self,
        filename: str,
        max_chunks: int = 35
    ) -> List[Dict[str, Any]]:
        """
        Retrieves all sequential chunks of a document in page order for comprehensive summaries.
        """
        if self.collection.count() == 0:
            return []

        results = self.collection.get(
            where={"source": filename},
            include=["documents", "metadatas"]
        )

        if not results or not results["documents"]:
            return []

        chunks = []
        for doc, meta in zip(results["documents"], results["metadatas"]):
            chunks.append({
                "text": doc,
                "source": meta.get("source", filename),
                "page": meta.get("page", 1),
                "chunk_index": meta.get("chunk_index", 0)
            })

        # Sort chronologically by chunk_index
        chunks.sort(key=lambda x: x["chunk_index"])
        return chunks[:max_chunks]

    def get_all_sources(self) -> List[str]:
        """Returns a list of unique document filenames currently stored in ChromaDB."""
        if self.collection.count() == 0:
            return []
        try:
            res = self.collection.get(include=["metadatas"])
            sources = set()
            for m in res.get("metadatas", []):
                if m and "source" in m:
                    sources.add(m["source"])
            return sorted(list(sources))
        except Exception as e:
            print(f"[RAG] Error fetching sources: {e}")
            return []

    def clear(self):
        """Wipes all documents from the vector database."""
        self.client.delete_collection(self.collection_name)
        self.collection = self.client.get_or_create_collection(
            name=self.collection_name,
            metadata={"hnsw:space": "cosine"}
        )
        self.latest_uploaded_document = None
        print("[RAG] Vector store cleared.")

