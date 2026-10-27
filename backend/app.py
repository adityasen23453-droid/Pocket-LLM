import os
import time
import json
import shutil
from typing import List, Optional, Dict, Any
from contextlib import asynccontextmanager

from fastapi import FastAPI, UploadFile, File, Form, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import StreamingResponse, JSONResponse
from pydantic import BaseModel

from rag_engine import RAGEngine
from llm_engine import LLMEngine
from intent_router import classify_intent, QueryIntent, expand_conversational_query

# Global singleton handles
rag_engine: Optional[RAGEngine] = None
llm_engine: Optional[LLMEngine] = None
start_time: float = 0.0

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
UPLOAD_DIR = os.path.join(BASE_DIR, "uploads")
CHROMA_DIR = os.path.join(BASE_DIR, "chroma_db")
os.makedirs(UPLOAD_DIR, exist_ok=True)
os.makedirs(CHROMA_DIR, exist_ok=True)

@asynccontextmanager
async def lifespan(app: FastAPI):
    """Initializes LLM and RAG engines on startup."""
    global rag_engine, llm_engine, start_time
    start_time = time.time()
    
    print("[Server] Initializing RAG Engine...")
    rag_engine = RAGEngine(persist_directory=CHROMA_DIR)

    
    print("[Server] Initializing LLM Engine...")
    llm_engine = LLMEngine()
    
    print("[Server] PocketLLM Backend Server fully initialized and ready!")
    yield
    print("[Server] PocketLLM Backend Server shutting down...")

app = FastAPI(
    title="PocketLLM Backend API",
    description="Offline-first RAG and local LLM inference server for Indian students",
    version="1.0.0",
    lifespan=lifespan
)

# Enable CORS for Flutter web (port 8080 or localhost) and mobile devices
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class ChatTurn(BaseModel):
    role: str
    content: str

class ChatRequest(BaseModel):
    message: str
    use_rag: bool = True
    top_k: int = 5
    active_document: Optional[str] = None
    chat_history: Optional[List[ChatTurn]] = None

@app.get("/api/health")
def health():
    """Health check endpoint showing model, hardware device, and RAG document count."""
    global rag_engine, llm_engine, start_time
    chunk_count = rag_engine.collection.count() if rag_engine else 0
    return {
        "status": "online",
        "service": "PocketLLM Backend",
        "device": llm_engine.device if llm_engine else "unknown",
        "model": llm_engine.model_id if llm_engine else "unknown",
        "rag_chunks_indexed": chunk_count,
        "uptime_seconds": round(time.time() - start_time, 2)
    }

@app.post("/api/upload")
async def upload_document(file: UploadFile = File(...)):
    """Upload PDF, TXT, or Markdown study notes and index them into ChromaDB."""
    global rag_engine
    if not rag_engine:
        raise HTTPException(status_code=503, detail="RAG Engine not initialized")
        
    safe_filename = os.path.basename(file.filename or "notes.txt")
    dest_path = os.path.join(UPLOAD_DIR, safe_filename)
    
    # Save file to disk
    with open(dest_path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)
        
    try:
        chunks_added = rag_engine.add_document(dest_path)
        total_chunks = rag_engine.collection.count()
        return {
            "success": True,
            "filename": safe_filename,
            "chunks_added": chunks_added,
            "total_chunks_in_db": total_chunks,
            "message": f"Successfully parsed and indexed {chunks_added} chunks into vector store."
        }
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Failed to process file: {str(e)}")

def _resolve_rag_context(request: ChatRequest, query: str):
    """
    Intelligently retrieves document-scoped context based on user intent.
    Guarantees conversational isolation (no RAG for greetings) and full coverage for assignments.
    """
    context_chunks = []
    sources = []
    if not request.use_rag or not rag_engine or rag_engine.collection.count() == 0:
        return context_chunks, sources, QueryIntent.CONVERSATIONAL

    all_sources = rag_engine.get_all_sources()
    target_doc: Optional[str] = None

    # Priority 1: Document explicitly sent by client in request
    if request.active_document and request.active_document.strip():
        candidate = request.active_document.strip()
        for s in all_sources:
            if s.lower() == candidate.lower() or candidate.lower() in s.lower():
                target_doc = s
                break
        if not target_doc and candidate in all_sources:
            target_doc = candidate

    # Priority 2: Document filename or stem mentioned directly in the user query
    if not target_doc and all_sources:
        q_lower = query.lower()
        for s in all_sources:
            stem = os.path.splitext(s)[0].lower().replace("_", " ").replace("-", " ")
            if stem in q_lower:
                target_doc = s
                break

    # Priority 3: Single active document in vector store (only if query is not pure conversational)
    if not target_doc and len(all_sources) == 1:
        target_doc = all_sources[0]

    # Expand conversational follow-ups (e.g. 'What about other answers?')
    expanded_query, _ = expand_conversational_query(
        query=query,
        active_document=target_doc,
        chat_history=[turn.model_dump() for turn in request.chat_history] if request.chat_history else None
    )

    # Classify intent with knowledge of document availability
    intent = classify_intent(expanded_query, has_active_document=bool(target_doc))

    # CRITICAL RULE: Pure conversational greetings NEVER receive RAG document context!
    if intent == QueryIntent.CONVERSATIONAL:
        return [], [], intent

    # Path A: Target document is resolved
    if target_doc:
        doc_chunks = rag_engine.get_document_chunks(target_doc, max_chunks=35)
        
        if intent in [QueryIntent.ALL_QUESTIONS, QueryIntent.DOCUMENT_SUMMARY]:
            # Provide full sequential grounding for compact or assignment documents (up to 30 chunks)
            for item in doc_chunks[:30]:
                context_chunks.append(f"[{item['source']} - Page {item['page']}]: {item['text']}")
            sources.append(target_doc)
            
        elif intent == QueryIntent.CONTINUATION:
            # Provide middle-to-end chunks to complete remaining questions
            start_offset = min(6, len(doc_chunks) // 2) if len(doc_chunks) > 6 else 0
            for item in doc_chunks[start_offset:start_offset + 25]:
                context_chunks.append(f"[{item['source']} - Page {item['page']}]: {item['text']}")
            sources.append(target_doc)
            
        else: # SPECIFIC_QA
            retrieved = rag_engine.retrieve(
                query=expanded_query,
                top_k=max(request.top_k, 6),
                document_filter=target_doc
            )
            for item in retrieved:
                if item["similarity"] >= 0.28:
                    context_chunks.append(f"[{item['source']} - Page {item['page']}]: {item['text']}")
                    if item["source"] not in sources:
                        sources.append(item["source"])

    # Path B: No specific target document could be resolved (search globally if not conversational)
    if not context_chunks and intent != QueryIntent.CONVERSATIONAL:
        retrieved = rag_engine.retrieve(
            query=expanded_query,
            top_k=request.top_k,
            document_filter=None
        )
        for item in retrieved:
            if item["similarity"] >= 0.30:
                context_chunks.append(f"[{item['source']} - Page {item['page']}]: {item['text']}")
                if item["source"] not in sources:
                    sources.append(item["source"])

    return context_chunks, sources, intent


@app.post("/api/chat")
async def chat_stream(request: ChatRequest):
    """
    Real-time streaming chat endpoint using Server-Sent Events (SSE).
    Uses intent-tailored prompt routing, anti-conditioning controls, and structured diagnostics.
    """
    global rag_engine, llm_engine
    if not llm_engine:
        raise HTTPException(status_code=503, detail="LLM Engine not initialized")
        
    query = request.message.strip()
    if not query:
        raise HTTPException(status_code=400, detail="Message cannot be empty")
        
    t_start = time.time()
    context_chunks, sources, intent = _resolve_rag_context(request, query)
    context_str = "\n\n".join(context_chunks) if context_chunks else None
    history = [turn.model_dump() for turn in request.chat_history] if request.chat_history else None

    print(f"[Chat] Query: '{query}' | Intent: {intent.value} | Document: {request.active_document} -> Sources: {sources} ({len(context_chunks)} chunks)")

    def event_generator():
        # First send metadata event if sources were found
        if sources:
            yield f"data: {json.dumps({'type': 'sources', 'sources': sources})}\n\n"
            
        token_stream = llm_engine.generate_stream(
            query=query,
            context=context_str,
            chat_history=history,
            intent=intent,
            max_new_tokens=1280,
            temperature=0.2,
            repetition_penalty=1.15,
            no_repeat_ngram_size=4
        )
        
        token_count = 0
        for token in token_stream:
            token_count += 1
            yield f"data: {json.dumps({'type': 'token', 'content': token})}\n\n"
            
        duration_ms = round((time.time() - t_start) * 1000, 1)
        print(f"[Chat] Stream completed: {token_count} tokens generated in {duration_ms}ms")
        yield f"data: {json.dumps({'type': 'done'})}\n\n"

    return StreamingResponse(
        event_generator(),
        media_type="text/event-stream",
        headers={
            "Cache-Control": "no-cache",
            "Connection": "keep-alive",
            "Content-Type": "text/event-stream"
        }
    )


@app.post("/api/chat/sync")
def chat_sync(request: ChatRequest):
    """Non-streaming chat endpoint returning complete JSON response."""
    global rag_engine, llm_engine
    if not llm_engine:
        raise HTTPException(status_code=503, detail="LLM Engine not initialized")
        
    query = request.message.strip()
    if not query:
        raise HTTPException(status_code=400, detail="Message cannot be empty")
        
    t_start = time.time()
    context_chunks, sources, intent = _resolve_rag_context(request, query)
    context_str = "\n\n".join(context_chunks) if context_chunks else None
    history = [turn.model_dump() for turn in request.chat_history] if request.chat_history else None
    
    print(f"[Chat/Sync] Query: '{query}' | Intent: {intent.value} | Sources: {sources} ({len(context_chunks)} chunks)")

    response_text = llm_engine.generate(
        query=query,
        context=context_str,
        chat_history=history,
        intent=intent,
        max_new_tokens=1280,
        temperature=0.2,
        repetition_penalty=1.15,
        no_repeat_ngram_size=4
    )
    
    duration_ms = round((time.time() - t_start) * 1000, 1)
    print(f"[Chat/Sync] Generated {len(response_text)} chars in {duration_ms}ms")

    return {
        "response": response_text.strip(),
        "sources": sources,
        "intent": intent.value,
        "used_rag": bool(context_str),
        "chunks_count": len(context_chunks),
        "duration_ms": duration_ms
    }


@app.get("/api/documents")
def list_documents():
    """List statistics of indexed documents in vector store."""
    global rag_engine
    count = rag_engine.collection.count() if rag_engine else 0
    return {"total_chunks": count}

@app.post("/api/clear")
def clear_vector_store():
    """Clears all indexed notes and reset vector database."""
    global rag_engine
    if rag_engine:
        rag_engine.clear()
    return {"success": True, "message": "Vector database cleared"}

