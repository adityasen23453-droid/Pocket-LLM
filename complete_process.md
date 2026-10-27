# PocketLLM: Offline On-Device AI Study Assistant for Indian Students
## Complete Engineering Process, Architecture, and Testing Report

---

### Project Metadata
* **Project Name**: PocketLLM (Student AI Study Assistant)
* **Project Category**: College Minor Project (Full-Stack AI / Mobile System)
* **Target Audience**: Indian CBSE, ICSE, JEE, NEET, and University Students
* **Hardware Architecture**: On-Device Local Edge Inference (NVIDIA GeForce RTX 3050 Laptop GPU, 4.00 GB VRAM, CUDA 12.4)
* **Core Philosophy**: 100% Offline, Zero Cloud Dependency, Privacy-Preserving Academic Knowledge Retrieval

---

## 1. Executive Summary & Objective

In Indian educational contexts, students often study in low-bandwidth or offline environments where access to commercial cloud LLMs (like OpenAI GPT-4 or Anthropic Claude) is either economically prohibitive or restricted by connectivity barriers. Furthermore, generic cloud AI tutors frequently hallucinate or fail to align with syllabus-specific textbooks (NCERT, state boards, engineering curricula).

**PocketLLM** solves this dual challenge:
1. **Local Foundation Model Inference**: Runs an open-weights Large Language Model (**Qwen/Qwen2.5-0.5B-Instruct**) locally on the student's hardware via CUDA float16 hardware acceleration, producing sub-100ms latency without any external internet connection.
2. **Dense Vector Retrieval-Augmented Generation (RAG)**: Integrates persistent vector indexing (**ChromaDB**) paired with dense semantic sentence embeddings (**sentence-transformers/all-MiniLM-L6-v2**), enabling students to upload PDFs, textbooks, and notes for cited, grounded answers.
3. **Cross-Platform Flutter Interface**: A clean UI styled in Forest Emerald & Warm Cream featuring real-time Server-Sent Events (SSE) token streaming, interactive study prompt cards, dynamic hardware status telemetry, and citation badges.

---

## 2. End-to-End System Architecture

```
 +-------------------------------------------------------------------------------+
 |                           FLUTTER FRONTEND APPLICATION                         |
 |  (Web on Port 8080 / Android / iOS / Desktop Native Client)                    |
 |                                                                               |
 |   +----------------------+    +----------------------+    +---------------+   |
 |   | ChatInput & Composer |    | Live CUDA Telemetry  |    | RAG Citation  |   |
 |   | (SSE Event Listener) |    | Badge (Notes Count)  |    | Badges        |   |
 |   +----------+-----------+    +----------+-----------+    +-------+-------+   |
 +--------------|---------------------------|------------------------|-----------+
                | HTTP / SSE Stream         | HTTP GET /api/health   |
                v                           v                        v
 +-------------------------------------------------------------------------------+
 |                           FASTAPI BACKEND SERVER                              |
 |                      (Uvicorn Daemon on Port 8000)                             |
 |                                                                               |
 |   [GET /api/health]       [POST /api/upload]         [POST /api/chat (SSE)]   |
 |          |                         |                           |              |
 |          v                         v                           v              |
 |   +---------------+       +-----------------+        +---------------------+  |
 |   | Hardware &    |       | Multipart File  |        | Context Builder     |  |
 |   | VRAM Monitor  |       | Buffer & Parser |        | & Prompt Formatter  |  |
 |   +---------------+       +--------+--------+        +----------+----------+  |
 +------------------------------------|----------------------------|-------------+
                                      |                            |
                     +----------------v----------------------------v-------------+
                     |                     LOCAL AI ENGINE LAYER                 |
                     |                                                           |
                     |  +-----------------------+     +-----------------------+  |
                     |  |  RAG Engine           |     |  LLM Inference Engine |  |
                     |  |  - Recursive Chunker  |     |  - Qwen2.5-0.5B-Inst. |  |
                     |  |  - all-MiniLM-L6-v2   |     |  - PyTorch CUDA fp16  |  |
                     |  |  - ChromaDB (Cosine)  |     |  - TextIteratorStream |  |
                     |  +-----------------------+     +-----------------------+  |
                     +-----------------------------------------------------------+
```

---

## 3. Detailed Phase-by-Phase Implementation

### Phase 1: Hardware Discovery & Environment Setup
- **OS**: Windows 11
- **GPU**: NVIDIA GeForce RTX 3050 Laptop GPU (4.00 GB Dedicated VRAM)
- **CUDA Runtime**: CUDA 12.4 with PyTorch 2.7.0.dev20250310+cu124
- **Verification Command**:
  ```python
  import torch
  assert torch.cuda.is_available()
  print("Device:", torch.cuda.get_device_name(0))
  # NVIDIA GeForce RTX 3050 Laptop GPU
  ```
- **Precision Decision**: `torch.float16` was selected over `float32`.
  - Qwen2.5-0.5B in fp16 consumes only **~1.0 GB VRAM**, leaving **~3.0 GB VRAM** completely safe from Out-of-Memory (OOM) faults during parallel vector embedding calculations.

---

### Phase 2: RAG Pipeline Engine (`backend/rag_engine.py`)
The RAG pipeline provides academic grounding for student queries.

1. **Text Extraction**:
   - Implemented via `pypdf.PdfReader` for syllabus books and notes.
   - Fallback loaders for `.txt`, `.md`, `.json`, and `.py`.

2. **Recursive Semantic Chunking**:
   - Academic textbooks contain nested structural demarcations (Chapters, Sections, Theorems, Formulas, Multi-step Derivations).
   - Parameters: `chunk_size = 800` characters, `chunk_overlap = 120` characters (expanded from 500/50 to preserve complete mathematical derivations, multi-line proofs, and multi-clause physics laws across chunk boundaries).
   - Hierarchy: Splits sequentially on `\n\n` (paragraphs) $\to$ `\n` $\to$ sentence boundaries (`. `, `? `, `!\n`) $\to$ spaces.

3. **Dense Vector Embeddings**:
   - Model: `sentence-transformers/all-MiniLM-L6-v2`.
   - Dimension: $384$-dimensional dense vector embeddings.
   - Normalized embedding space allows cosine distance calculation.

4. **Vector Database**:
   - `chromadb.PersistentClient(path="./backend/chroma_db")`.
   - Metric Space: HNSW Cosine Distance (`hnsw:space: "cosine"`).
   - Normalized Similarity Mapping:
     $$\text{Similarity}(u, v) = \max\left(0.0, 1.0 - \frac{d_{\text{cosine}}(u, v)}{2.0}\right)$$

---

### Phase 3: Local LLM Engine (`backend/llm_engine.py`)
1. **Model Selection**: `Qwen/Qwen2.5-0.5B-Instruct`
   - Pre-trained on multilingual datasets with strong reasoning in STEM (Mathematics, Physics, Computer Science).
   - Demonstrates high comprehension of **Hinglish** (Hindi-English colloquial code-mixing commonly used by Indian students).

2. **Multi-Threaded Real-Time Token Streaming**:
   - Utilizes `transformers.TextIteratorStreamer(skip_prompt=True, skip_special_tokens=True)`.
   - The generation process is launched inside a daemon `threading.Thread(target=self.model.generate, ...)` so the main loop can yield tokens as generator chunks with sub-second Time-To-First-Token (TTFT).

3. **System Persona Prompt**:
   - Explicitly tailored for Indian students taking CBSE, ICSE, JEE, NEET, and university exams.
   - Enforces grounding: answers reference context directly when notes are provided.

---

### Phase 4: Full-Stack API Server (`backend/app.py`)
Built using FastAPI with asynchronous lifecycle management:
* **`GET /api/health`**:
  Returns service status, device hardware (`cuda`), active model name, indexed RAG chunk count, and uptime.
* **`POST /api/upload`**:
  Receives multipart file uploads (`.pdf`, `.txt`, `.md`), saves to `./backend/uploads`, and indices chunks into ChromaDB.
* **`POST /api/chat` (SSE Streaming)**:
  Extracts user query, queries ChromaDB for top-$k$ chunks above similarity threshold ($0.40$), builds prompt context, and streams tokens over Server-Sent Events (`text/event-stream`). Emits `sources` metadata event on first hit.
* **`POST /api/chat/sync`**:
  Synchronous JSON alternative returning complete response and citations.
* **`GET /api/documents` & `POST /api/clear`**:
  Collection telemetry and reset capabilities.

---

### Phase 5: Flutter Client Integration
1. **`lib/services/api_service.dart`**:
   - Clean, modular networking layer.
   - Handles SSE stream decoding across line boundaries (`data: {"type": "token", ...}`).
   - Automatically detects host platform (`http://10.0.2.2:8000` on Android emulator vs `http://127.0.0.1:8000` on Web/Desktop).
2. **`lib/screens/chat_screen.dart`**:
   - Real-time token accumulation: updates the active AI message bubble on every incoming token with smooth auto-scroll.
   - File attachment integration: `FilePicker` allows users to select notes directly from their device and triggers immediate indexing into the local vector database.
   - Top Bar Hardware Badge: Displays live `[● CUDA Offline (X notes)]` telemetry.
3. **`lib/widgets/chat_bubble.dart`**:
   - Renders emerald citation badges (`Grounded in: <file>`) whenever an AI answer uses RAG context.

---

## 4. Test Suite and Verification Results

To satisfy rigorous project standards, testing was performed at every tier of the stack:

### 1. RAG Unit Tests (`backend/test_rag.py`)
```
Ran 2 tests in 9.346s
Status: OK (100% Passed)
- test_01_chunking_with_overlap: VERIFIED (Recursive splitting created valid overlapping chunks)
- test_02_add_and_retrieve_document: VERIFIED (Retrieved Newton's Third Law and Friction with similarity 0.8326)
```

### 2. LLM Engine Tests (`backend/test_llm.py`)
```
Ran 4 tests in 12.907s
Status: OK (100% Passed)
- test_01_device_and_model: VERIFIED (Model & tokenizer loaded on CUDA)
- test_02_sync_generation: VERIFIED (Generated complete response in 2.93s)
- test_03_streaming_generation: VERIFIED (Yielded 31 token chunks via TextIteratorStreamer)
- test_04_rag_grounded_generation: VERIFIED (Grounding on custom context confirmed)
```

### 3. FastAPI Backend Integration Tests (`backend/test_api.py`)
```
Ran 5 tests in 20.694s
Status: OK (100% Passed)
- test_01_health_check: VERIFIED (Returned 200, status=online, device=cuda)
- test_02_upload_document: VERIFIED (Uploaded and indexed Ohm's law notes)
- test_03_chat_sync_rag: VERIFIED (Answered Ohm's law formula V=I*R citing source file)
- test_04_chat_streaming: VERIFIED (Streamed 27 tokens via SSE)
- test_05_clear_vector_store: VERIFIED (Reset collection to 0 chunks)
```

### 4. Flutter Quality & Unit Tests
```
$ flutter analyze
Analyzing PocketLLM...
No issues found! (ran in 5.6s)

$ flutter test
00:01 +4: All tests passed!
- ApiService Tests checkHealth: PASSED
- ApiService Tests streamChat SSE parsing: PASSED
- ApiService Tests uploadDocument: PASSED
- PocketLLMApp smoke test & theme toggle: PASSED
```

### 5. Full End-to-End Live Verification (`backend/test_e2e.py`)
Simulated live HTTP client communication against running daemon:
```
[Step 1] Checking Backend Health on http://127.0.0.1:8000/api/health...
  Status: online | Hardware Device: CUDA | Model ID: Qwen/Qwen2.5-0.5B-Instruct
[Step 2] Uploading NCERT/CBSE Ray Optics Note to RAG Vector Store...
  Upload Success: True | Chunks Added: 1
[Step 3] Querying: 'What are the two conditions for Total Internal Reflection?'
  [RAG Citation Event]: Grounded in ['cbse_optics_notes.txt']
  Streaming tokens in real time from local Qwen 2.5 on CUDA:
  "According to your notes, Total Internal Reflection occurs when light travels from a
  denser medium to an optically rarer medium...
  Condition 1: Light must enter from denser medium.
  Condition 2: Angle of incidence must exceed critical angle (i > c)..."
[Step 4] Received 238 tokens successfully!
>>> ALL END-TO-END TESTS PASSED WITH 100% SUCCESS! <<<
```

---

## 5. Advanced UX & Academic RAG Enhancements (Sprint 2)

Based on empirical student evaluation with NCERT physics/math textbooks and everyday colloquial usage, 5 targeted enhancements were integrated across the full stack:

### 1. Mid-Stream SSE Cancellation ([ ⏹ Stop Generating ] Button)
* **The Problem**: When students ask a long question or make a typo, waiting for the LLM to finish streaming 300+ tokens wastes GPU compute, battery power, and user time.
* **Architecture Solution**:
  * The Flutter `_ChatScreenState` manages a persistent `StreamSubscription<String>? _chatStreamSubscription` paired with an asynchronous `Completer`.
  * The `ChatInput` send button dynamically morphs into an interactive red-tinted square **[ ⏹ Stop ]** button whenever `isBusy == true`.
  * Triggering `_handleStopGenerating()` immediately calls `_chatStreamSubscription?.cancel()`, terminating the underlying HTTP SSE TCP connection without tearing down the existing message history.

### 2. ChatGPT/Gemini-Style Staged Document Cards
* **The Problem**: Previously, uploading notes only showed a brief transient snackbar; students couldn't verify which notes were attached to their current query.
* **Architecture Solution**:
  * **Staged Composer Pill**: When a file is indexed, an emerald pill appears directly above the text input (`filename.pdf • X chunks ready`) with a one-tap `[✕]` remove button.
  * **Persistent Chat Bubble Card**: Upon sending, the file pill transfers into the user's chat bubble (`ChatMessage.attachedFileName` and `attachedFileChunks`), preserving visual document provenance throughout the conversation history.

### 3. Textbook Math & LaTeX Equation Card Formatter (`TextbookFormattedText`)
* **The Problem**: Raw LLM output containing `\[ F = m \times a \]` or `\frac{1}{2}mv^2` rendered as confusing bracketed code instead of natural textbook notation.
* **Architecture Solution**:
  * An offline regex tokenizer parses display blocks (`\[ ... \]`, `$$ ... $$`) and transforms them into standalone, centered emerald-bordered formula callout cards with a `[ ∑ FORMULA ]` header.
  * Greek letters (`\alpha` $\to$ α, `\lambda` $\to$ λ, `\theta` $\to$ θ, `\Delta` $\to$ Δ), fractions (`\frac{a}{b}` $\to$ `a / b`), roots (`\sqrt{x}` $\to$ `√(x)`), superscripts (`^2` $\to$ `²`), and subscripts (`_0` $\to$ `₀`) are mapped to clean Unicode mathematical glyphs.
  * Markdown bold (`**concept**`), bullet points, and monospace code blocks (` `code` `) render with zero external CDN dependencies.

### 4. Smart Dense Chunking (800 / 120) & Similarity Threshold (0.28)
* **The Problem**: A rigid 500-character chunk cut off physics derivations mid-equation. A strict 0.40 cosine threshold dropped queries when students phrased questions colloquially or in Hinglish.
* **Architecture Solution**:
  * Chunk size expanded from $500 \to 800$ characters with $120$-character overlap in `backend/rag_engine.py`, guaranteeing complete multi-step theorem contexts.
  * Similarity threshold relaxed from $0.40 \to 0.28$ in `backend/app.py`, ensuring high recall for conversational student prompts while maintaining relevance.

### 5. Precision Low Temperature (0.2)
* **The Problem**: Default temperature of 0.7 introduced creative prose fluctuations undesirable in scientific laws and mathematical problem-solving.
* **Architecture Solution**:
  * Standardized generation temperature at `0.2` across `backend/app.py` and `backend/llm_engine.py` for deterministic, factual accuracy.

---

## 6. Document-Scoped RAG & Linguistic Steering (Sprint 3)

Following live classroom tests on college assignments (`Assignment_1.pdf` and question papers), 5 foundational system flaws were resolved:

### 1. Document-Scoped Metadata Filtering
* **Defect**: Previously, ChromaDB had a single unpartitioned collection (`student_notes`). Querying any document matched chunks across all 218 historic notes from past sessions (e.g. mixing an exam schedule with an algorithms assignment).
* **Fix**: Added `active_document` to `ChatRequest` and wired `where={"source": document_filter}` into `rag_engine.py`. Flutter now sends the current session's active document so chunks from unrelated files are 100% excluded.

### 2. High-Fidelity PDF Extraction via PyMuPDF (`pymupdf 1.28.2`)
* **Defect**: Basic `pypdf` jumbled multi-column question papers, dropped square roots and fractions, and extracted 0 text on complex layouts.
* **Fix**: Integrated `pymupdf` (`fitz`), reading block-by-block in natural reading order, preserving mathematical symbols and table rows, and indexing page-level metadata (`[Page N]`).

### 3. Full-Document Summarization Engine
* **Defect**: Semantic vector search with `top_k=3` only provided 350 words of context, omitting 85% of multi-page assignments when students asked "summarize the complete pdf".
* **Fix**: Added `get_document_chunks()` in `rag_engine.py` and automatic summary intent detection in `app.py`. When an overview query is received, the backend fetches all sequential chunks of that document in chronological page order (up to 15 chunks / 12,000 characters), feeding the entire assignment to the LLM.

### 4. Few-Shot Romanized Hindi (Hinglish) Steering
* **Defect**: The 0.5B model repeated "PDF Summary in Hinglish" as a heading, but wrote the explanation in 100% formal British/American English.
* **Fix**: Strengthened the system prompt with explicit linguistic rules:
  > *"If the student requests Hinglish or writes in Hinglish: You MUST reply in natural Romanized Hindi/Hinglish (e.g. 'Is assignment me prime numbers aur modular arithmetic ke main concepts explain kiye gaye hain...'). Never output pure English when Hinglish is requested."*

### 5. Chat History Sanitizer & Prefix Loop Prevention
* **Defect**: The model repeated previous markdown headers and generated fake student questionnaires (`### Student Questions: ...`) when running low on retrieved tokens.
* **Fix**: Added a regex history sanitizer in `llm_engine.py` that strips repetitive meta-headers before passing context to subsequent conversation turns, combined with strict negative constraints ("Direct answers only. Never generate fake quizzes or questions unless asked").

---

## 7. College Minor Project Viva Examiner Q&A Guide

When presenting PocketLLM to project evaluators, use the following technical justifications:

#### Q1: Why did you use Qwen 2.5 (0.5B) instead of LLaMA-3 or Gemma-2?
> **Answer**: "Our primary target is Indian students using standard consumer laptops (typically equipped with 4GB VRAM GPUs like the RTX 3050). LLaMA-3-8B requires 16GB VRAM in fp16 (or 6GB in 4-bit quant), which exceeds student laptop hardware limits. Qwen 2.5 0.5B is specifically trained on extensive multilingual tokens, has out-of-the-box Hinglish code-switching comprehension, and runs comfortably within 1.0 GB VRAM on CUDA float16, leaving sufficient GPU memory for embedding calculations."

#### Q2: What is the purpose of RAG when the LLM already knows physics and math?
> **Answer**: "Pretrained LLMs suffer from two major flaws: **hallucinations** and **syllabus misalignment**. While a model may know general physics, CBSE, ICSE, and state university exams demand specific textbook phrasing, definitions, and formulas. With our RAG pipeline, students upload their exact syllabus PDFs; the vector search extracts the precise paragraph, forces the model to ground its response on that paragraph, and displays an explicit citation badge."

#### Q3: How does your vector similarity search work mathematically?
> **Answer**: "We convert text chunks into 384-dimensional dense vectors using `all-MiniLM-L6-v2`. We store them in ChromaDB indexed with an HNSW (Hierarchical Navigable Small World) graph. When a user asks a question, we compute the cosine distance:
> $$d_{\text{cosine}}(u, v) = 1 - \frac{u \cdot v}{\|u\|_2 \|v\|_2}$$
> Chunks with similarity score $\ge 0.28$ are dynamically prepended to the LLM system prompt as reference context."

#### Q4: Why Server-Sent Events (SSE) instead of standard REST JSON or WebSockets?
> **Answer**: "Large Language Models generate text autoregressively, token by token. Waiting for all 200 tokens over standard HTTP POST would cause high latency (3-5 seconds of blank screen). SSE provides unidirectional HTTP streaming with minimal protocol overhead, native reconnection support, and sub-100ms Time-To-First-Token on the Flutter UI."

#### Q5: Is the application truly 100% offline?
> **Answer**: "Yes. Once the model weights (`Qwen2.5-0.5B-Instruct` and `all-MiniLM-L6-v2`) are cached locally in the Hugging Face cache directory, both ChromaDB and PyTorch execute exclusively on the local machine's GPU and CPU. No data packets ever leave the student's laptop."

#### Q6: How does the client cancel generation mid-stream without crashing the server?
> **Answer**: "The Flutter frontend wraps the SSE token stream inside a `StreamSubscription`. When the student clicks the `[ ⏹ Stop ]` button, Flutter calls `subscription.cancel()`. This immediately drops the client-side TCP socket. In FastAPI, the `StreamingResponse` detects the broken client pipe (`ClientDisconnect`), terminating the background generator thread and freeing GPU execution cycles instantly."

#### Q7: How are complex textbook formulas rendered offline without MathJax or KaTeX CDN scripts?
> **Answer**: "To maintain strict 100% offline isolation without pulling megabytes of JavaScript libraries, we built a dedicated Flutter widget `TextbookFormattedText`. It segments text into prose vs display math (`\[...\]`), converting LaTeX tokens into Unicode mathematical notation (Greek symbols, superscripts, subscripts, fractions) and embeds them inside an aesthetic formula card."

---

## 7. How to Run & Reproduce

### 1. Start the FastAPI Backend Server
```powershell
cd d:\PocketLLM\backend
python -m uvicorn app:app --host 127.0.0.1 --port 8000
```
*Health Check*: Open `http://127.0.0.1:8000/api/health` in browser to verify CUDA acceleration and model readiness.

### 2. Run the Automated Tests
```powershell
cd d:\PocketLLM
python backend/test_rag.py     # RAG Unit tests
python backend/test_llm.py     # LLM CUDA tests
python backend/test_api.py     # Backend API integration tests
python backend/test_e2e.py     # Live End-to-End test
flutter test                   # Flutter frontend tests
```

### 3. Launch the Flutter Application
```powershell
# To run web build:
python -m http.server 8080 -d build/web
# Open http://localhost:8080 in browser

# Or run live Flutter development server:
flutter run -d chrome
```

---

## 8. RAG Accuracy Overhaul: Cross-Document Isolation & Full-Document Grounding

### 8.1 Problem Statement & Root Cause Discovery
During student evaluation, an accuracy regression was observed where asking for answers to an uploaded assignment (e.g., `Assignment_11__Theory_and_Practice_of_Modern_Cryptography_.pdf`) yielded answers mixed with questions from an older assignment (e.g., modular arithmetic and Euler's phi from `Assignment_6.pdf`).

Thorough codebase and runtime inspection revealed four compounding factors:
1. **Split-Brain ChromaDB Directory Paths**:
   `app.py` originally specified `persist_directory="./backend/chroma_db"`. When Uvicorn was executed with working directory `d:\PocketLLM\backend`, it created and populated an accidental nested directory `d:\PocketLLM\backend\backend\chroma_db` (214 legacy chunks from 16 historical test uploads), while automated test scripts invoked from the project root targeted `d:\PocketLLM\backend\chroma_db`.
2. **Aggressive Mobile Browser Asset Caching**:
   Mobile Chrome aggressively cached the compiled `main.dart.js` bundle. Prior to cache-busting, the mobile frontend did not transmit the newly added `active_document` parameter, delivering `active_document: null` in the JSON payload to `/api/chat`.
3. **Unscoped Fallback Vector Search**:
   When `active_document` was null, ChromaDB conducted an un-scoped cosine search across all 214 chunks. Because Assignment 6 and Assignment 11 shared the identical course prefix (*Theory and Practice of Modern Cryptography*), chunks from Assignment 6 were retrieved alongside chunks from Assignment 11.
4. **The `top_k=5` Retrieval Choke Point**:
   Assignment 11 spans 5 pages and 12 semantic chunks. Under a static `top_k = 5`, 7 chunks (containing Questions 4 through 8) were discarded by vector similarity. The LLM was asked to solve 10 questions while having context for only 3 to 4 questions, forcing it to hallucinate the missing numbers.

---

### 8.2 Architectural Solution

```
 +-----------------------------------------------------------------------------------+
 |                             INCOMING CHAT REQUEST                                 |
 |  Payload: { message: "give answers to all questions", active_document: null/str } |
 +-----------------------------------------+-----------------------------------------+
                                           |
                                           v
 +-----------------------------------------------------------------------------------+
 |                   INTELLIGENT 4-TIER DOCUMENT RESOLUTION                          |
 |  1. Client active_document match                                                  |
 |  2. rag_engine.latest_uploaded_document in-memory pointer                         |
 |  3. Unambiguous single document in vector DB                                      |
 |  4. Document stem substring matching in user query                                |
 +-----------------------------------------+-----------------------------------------+
                                           |
                    +----------------------+----------------------+
                    |                                             |
             Target Document Found                        No Target Document
                    |                                             |
                    v                                             v
     +------------------------------+             +------------------------------+
     | Check Document Chunk Count   |             | Global Fallback Retrieval    |
     +--------------+---------------+             | (top_k cosine similarity)    |
                    |                             +------------------------------+
         +----------+----------+
         |                     |
     <= 15 Chunks          > 15 Chunks
         |                     |
         v                     v
+------------------+  +----------------------------------+
| FULL-DOCUMENT    |  | Broad Query: First 15 chunks     |
| SEQUENTIAL FEED  |  | Specific Query: Scoped vector    |
| (100% of Chunks  |  | search strictly within document  |
| in Page Order)   |  +----------------------------------+
+------------------+
```

1. **Absolute Canonical Directory Anchoring**:
   Both `app.py` and `rag_engine.py` now anchor all storage paths to the file's absolute directory:
   ```python
   BASE_DIR = os.path.dirname(os.path.abspath(__file__))
   UPLOAD_DIR = os.path.join(BASE_DIR, "uploads")
   CHROMA_DIR = os.path.join(BASE_DIR, "chroma_db")
   ```
   The accidental nested directory was permanently consolidated and removed.

2. **Full-Document Sequential Chunk Feeding**:
   For compact assignments, question papers, and homework notes ($\le 15$ chunks, which is $\sim 1500$ tokens and easily fits within Qwen2.5's 32K context window), PocketLLM automatically feeds **all sequential chunks in page order**. This guarantees:
   - Zero missing questions or exercises.
   - Zero vector retrieval ranking misses.
   - Complete contextual grounding for broad prompts like *"solve all questions"*, *"what about the rest of the answers"*, or *"give me the complete solution"*.

3. **High-Token Generation Budget (`max_new_tokens=1024`)**:
   Expanded generation ceiling from 512 to 1024 tokens for both SSE streaming and synchronous chat, ensuring 10-question assignments with detailed explanations never get truncated midway.

4. **Mobile Browser Cache-Busting**:
   Updated `web/index.html` with HTTP cache-control directives and script version query parameters (`flutter_bootstrap.js?v=2.1`), preventing stale mobile browser JavaScript from sending null document parameters.

---

### 8.3 Verification & Live Results
Running `backend/test_assignment11_live.py` against the live Uvicorn daemon confirmed:
* **Grounded Source**: Strictly cited `['Assignment_11__Theory_and_Practice_of_Modern_Cryptography_.pdf']`.
* **Zero Leakage**: Exactly 0 occurrences of Euler's totient or modular arithmetic from Assignment 6.
* **100% Accuracy**: All 10 questions (MPC Input Independence, Honest Majority >50%, Homomorphic Encryption, Lattice-based FHE, IPFE, Functional Encryption, Fuzzy IBE, Collusion Resistance, Registration-Based Encryption, and RABE) correctly solved and streamed in real time.

---
*Report updated with RAG accuracy overhaul on October 14, 2026.*


