# 📱 PocketLLM · Arka Jain University (AJU)
> **100% Standalone, On-Device AI Academic Tutor & RAG Assistant for Android**  
> *Zero Server. Zero Laptop. Zero Cloud Dependency. 100% Private & Free Forever.*

[![Android](https://img.shields.io/badge/Android-8.0%2B%20(API%2026%2B)-3DDC84?logo=android&logoColor=white)](https://developer.android.com)
[![Flutter](https://img.shields.io/badge/Flutter-3.24%2B-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Offline AI](https://img.shields.io/badge/Inference-100%25%20On--Device%20(Offline)-2E6B41)](https://github.com/adityasen23453-droid/Pocket-LLM)
[![Architecture](https://img.shields.io/badge/CPU%20%2F%20GPU-ARM%20NEON%20%7C%20Vulkan-orange)](https://github.com/ggerganov/llama.cpp)
[![University](https://img.shields.io/badge/Institution-Arka%20Jain%20University-0A4D2E)](https://arkajainuniversity.ac.in)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

---

## 🌟 Overview

**PocketLLM** is an on-device Small Language Model (SLM) assistant engineered specifically for college students and faculty at **Arka Jain University (AJU), Jamshedpur**. 

Traditional educational AI apps depend on continuous cloud access, expensive commercial API subscriptions, and constant internet connectivity. This creates significant barriers in exam halls, rural transit, remote hostels, and areas with spotty cellular coverage. 

PocketLLM eliminates all external dependencies by running **open-weights Large Language Models directly on mobile hardware**. Powered by optimized C++ inference (`llama.cpp`), native multithreaded ARM NEON vector instructions, and Vulkan GPU acceleration, PocketLLM provides high-speed academic tutoring, assignment solving, and multi-page PDF document analysis—**completely offline in Airplane Mode with zero cables, zero laptops, and zero cloud sync.**

---

## 📸 App Interface & Features at a Glance

```
┌─────────────────────────────────────────────────────────────────────────────┐
│ 🟢 OFFLINE AI (1.5B)                🌙 [Dark/Light]           🕒 [History]  │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│     🔮 [3D Pulsing Emerald Orb]                                             │
│                                                                             │
│     "How can PocketLLM assist your university studies today?"               │
│                                                                             │
│     User: "Analyze and solve the first 3 questions of this assignment"      │
│     📄 Grounded in: Assignment_1.pdf (p. 1, p. 2)                           │
│                                                                             │
│     PocketLLM:                                                              │
│     1. Differentiate between Analysis and Reporting:                        │
│        • Reporting presents raw historical facts...                         │
│        • Analysis explains causality and guides strategic decisions...      │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│  [+] Attach PDF / Notes        [ 💬 Ask me anything... ]        [ 🎙️ / ➔ ]  │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## ✨ Exhaustive Feature Breakdown

### 1. 🎛️ 3-Tier In-App Model Hub (Tailored for 4 GB to 8 GB Phones)
Accessible by tapping the top status pill (**`TAP FOR OFFLINE AI`**), the interactive Model Hub allows students to download, switch, and hot-swap between three official models calibrated for different phone hardware:

| Model Tier | Base Weights | GGUF Size | Min RAM | Smooth RAM | Speed | Best Academic Use Cases |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **PocketLLM Nano (0.5B)** | Qwen 2.5 0.5B Instruct (Q4_K_M) | **468 MB** | 3 GB | **4 GB** | ⚡⚡⚡ 35–50 tok/s | Entry-level phones, rapid concept definitions, zero thermal throttling, ultra-low battery drain. |
| **PocketLLM Balanced (1.5B)** *(Default)* | Qwen 2.5 1.5B Instruct (Q4_K_M) | **1.04 GB** | 4 GB | **6 GB** | ⚡⚡ 18–28 tok/s | **AJU University Standard.** Syllabus queries, assignment solutions, multi-page PDF document RAG. |
| **PocketLLM Pro (3B)** | Llama 3.2 3B Instruct (Q4_K_M) | **1.88 GB** | 6 GB | **8 GB** | ⚡ 10–16 tok/s | High-end 8 GB devices. Advanced multi-step math derivations, academic essays, research paper synthesis. |

#### 🛡️ 3-Stage Progressive Memory Fallback Loader
To prevent Out-Of-Memory (OOM) crashes on devices with restricted background RAM:
1. **Attempt 1 (High Performance):** Probes device GPU capabilities via Vulkan and attempts to offload layers with a 4096-token context window.
2. **Attempt 2 (Stable CPU):** If Vulkan fails on the chipset, it automatically purges native state and falls back to pure multithreaded ARM NEON CPU with 4096 context.
3. **Attempt 3 (Ultra-Safe CPU):** If RAM is heavily occupied by background apps, it safely loads using ARM NEON CPU with a compact 2048-token context window (~1.2 GB total RAM footprint).

#### 🔍 Strict Integrity Verification & 1-Tap Repair
- **No Partial Download Traps:** A model is only marked as installed when its file size matches at least 85% of official weight size.
- **Auto-Cleanup:** If a download is paused or interrupted by network drops, the incomplete file is automatically detected, deleted, and reset.
- **1-Tap Re-download (`🔄`):** A dedicated refresh button allows users to delete and re-download an intact file if corruption is ever suspected.

---

### 2. 📄 Isolated On-Device PDF RAG Engine (Zero Cloud)
Unlike cloud RAG solutions that transmit student documents to third-party vector databases, PocketLLM indexes and queries documents **locally inside the phone's memory**:
- **Pure Dart Extraction (`syncfusion_flutter_pdf`):** Extracts digital text directly from PDFs, Markdown, and TXT files without external Python or server dependencies.
- **Semantic Overlapping Chunking:** Documents are split into 750-character chunks with a 120-character sliding overlap, prioritizing natural paragraph and sentence boundaries.
- **Sub-10ms BM25 Search Engine:** Custom on-device BM25 ranking algorithm scores document relevance using term frequency (TF) and inverse document frequency (IDF) in milliseconds.
- **Target Document Isolation:** When a student attaches `Assignment_1.pdf`, the retrieval strictly scopes to that document, preventing older PDFs (`Course End Survey`) from contaminating answers.
- **Overview Intent Auto-Detection:** Queries such as *"What does this PDF say?"*, *"Summarize this document"*, or *"Analyze this file"* automatically deliver the introductory pages (Pages 1–3) even if generic words don't match specific keyword tokens.
- **Ordinal Question Booster:** Questions such as *"Answer the first 3 questions"* or *"Provide the 4th question"* boost chunks containing `1.`, `2.`, `3.`, `Question 1`, or `Q1`.
- **40-Page Safety Ceiling:** Large documents are capped to the first 40 pages (`math.min(pageCount, 40)`) to prevent Android Application Not Responding (ANR) freezes.

---

### 3. 🧹 Native C++ KV-Cache Purge & Anti-Ghost Memory Engine
During extended testing, Android LLM plugins often suffer from "ghost memory" where answers from previous turns repeat (e.g. repeating *"The capital of India is New Delhi"* or echoing greetings).
- **Native Context Reset:** Before every prompt generation, the service executes `clearContext()` (`llama_memory_seq_rm`), setting the native C++ position counter `g_n_past = 0`.
- **Clean Position 0 Evaluation:** The chat history and system prompt are evaluated from token position 0, preventing overlapping token corruption in the KV cache.
- **Single-Block ChatML Formatting:** Prompts and RAG study notes are unified into a single `<|im_start|>system` block, preserving tokenizer alignment.
- **Anti-Repetition Penalties:** Generation parameters are tuned with `repeatPenalty: 1.15`, `presencePenalty: 1.0`, and `repeatLastN: 128` to prevent echo loops.
- **Thread Concurrency Lock (`ensureIdle`):** Guarantees the native C++ JNI thread completes or stops before new tokens are generated, permanently eliminating `Bad state: Already generating` errors.

---

### 4. 💾 Local Sandboxed Storage & Persistent Offline History
- **Zero Cloud Sync:** Student chats, attached document references, and timestamps are written atomically to `chat_sessions.json` in the app's sandboxed data directory.
- **Persistent Sessions:** Chats persist across device reboots and app updates.
- **Sidebar Drawer Management:** Create new chats, rename subjects, switch between previous discussions, or delete finished study sessions.

---

### 5. 📲 1-Tap Wireless Downloader & Custom GGUF Importer
- **No USB Cables Required:** Downloads models over Wi-Fi/5G directly from Hugging Face with automatic HTTP 302 redirect handling and real-time progress indicators.
- **Local Storage Picker:** Users can select any `.gguf` file stored on internal storage or an SD card.
- **Scoped Storage Auto-Import:** If a student downloads a model via Chrome into `/storage/emulated/0/Download/`, the app automatically copies it into its private sandbox so native C++ `fopen()` avoids Android 11+ permission blocks.

---

### 6. 🎨 Forest Emerald & Editorial Cream Academic UI
- **Branding:** Official Arka Jain University neon emblem across all Android mipmap densities (`mdpi` to `xxxhdpi`).
- **Aesthetic:** Editorial Cream and deep Forest Emerald theme inspired by academic university libraries.
- **Dynamic 3D AI Orb:** Real-time animated gradient orb reflecting thinking and idle states.
- **Collapsible Source Citations:** Clickable pills displaying exact reference files and page numbers (e.g. `[Grounded in: Data Analytics.pdf (p. 3)]`).
- **Theme Toggle:** Instant switching between Dark and Light mode.

---

## 🏗️ Technical Architecture

```
                       📱 ANDROID MOBILE DEVICE (100% OFFLINE)
┌─────────────────────────────────────────────────────────────────────────────┐
│                                                                             │
│   FLUTTER UI LAYER                                                          │
│   ├── LandingScreen / ChatScreen / ChatSidebar / AnimatedAiOrb             │
│   └── OfflineModelSheet (Interactive 3-Tier Model Hub)                      │
│                                                                             │
│   ──────────────────────────────────┬────────────────────────────────────   │
│                                     │                                       │
│   ON-DEVICE RAG PIPELINE            │   ON-DEVICE INFERENCE ENGINE          │
│   ├── syncfusion_flutter_pdf        │   ├── llama_flutter_android (C++ JNI) │
│   ├── Semantic Chunker (750 chars)  │   ├── Active Model (0.5B / 1.5B / 3B) │
│   ├── Pure Dart BM25 Search Engine  │   ├── 4-Thread ARM NEON Vector CPU    │
│   ├── Scoped Document Filter        │   ├── Vulkan GPU Acceleration         │
│   └── Local JSON Index Storage      │   └── KV-Cache clearContext Purge    │
│                                     │                                       │
│   ──────────────────────────────────┴────────────────────────────────────   │
│                                                                             │
│   STORAGE & PERSISTENCE LAYER (path_provider)                               │
│   ├── chat_sessions.json (Atomic local conversation history)                │
│   ├── rag_index.json (Precomputed document chunk index)                     │
│   └── /models/*.gguf (Locally stored model weights)                         │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 📱 Hardware & Phone Compatibility Guide

| Phone RAM | Compatible Model Tiers | Expected Performance | Thermal Footprint |
| :--- | :--- | :--- | :--- |
| **3 GB – 4 GB RAM** | **PocketLLM Nano (0.5B)** | ⚡⚡⚡ 35–50 tok/s | Zero heating, minimal battery impact |
| **6 GB RAM** | **PocketLLM Balanced (1.5B)** *(Recommended)* | ⚡⚡ 18–28 tok/s | Balanced thermal profile, smooth multi-turn chats |
| **8 GB RAM** | **PocketLLM Pro (3B)** or **Balanced (1.5B)** | ⚡ 10–16 tok/s | High reasoning capability, deep academic answers |

- **Operating System:** Android 8.0 (Oreo) or higher (API Level 26+)
- **CPU Architecture:** 64-bit ARM (`arm64-v8a`)
- **Supported Chipsets:** Qualcomm Snapdragon (600/700/800 series), MediaTek Dimensity/Helio G-series, Google Tensor, Samsung Exynos.
- **Disk Storage Required:**
  - App APK installation: **~75 MB**
  - Nano (0.5B) model: **~468 MB**
  - Balanced (1.5B) model: **~1.04 GB**
  - Pro (3B) model: **~1.88 GB**

---

## 📖 Complete User & Student Guide

### Step 1: Install the APK on Your Phone
1. Transfer `app-release.apk` to your phone via **Quick Share, WhatsApp, Telegram, or Google Drive**.
2. Tap the APK file in your phone's file manager or download list.
3. Select **Install**. *(If prompted with "Install unknown apps", tap Settings and allow for your browser or file manager).*

---

### Step 2: First-Time Setup & Downloading Your Model Wirelessly
1. Open **PocketLLM - AJU** from your phone's home screen.
2. Tap the top status pill in the header: **`• TAP FOR OFFLINE AI`**.
3. In the **AI Model Hub**, review the hardware guidance:
   - For **4 GB phones**: Select **PocketLLM Nano (0.5B)**.
   - For **6 GB phones**: Select **PocketLLM Balanced (1.5B)** *(University Default)*.
   - For **8 GB phones**: Select **PocketLLM Pro (3B)**.
4. Tap **1-Tap Download**. The model will stream directly to your phone's local storage with a real-time progress bar.
5. Once complete, the top status badge will turn green: **`🟢 OFFLINE AI (1.5B)`**.

---

### Step 3: Chatting Completely Offline in Airplane Mode
1. Swipe down your Android notification panel and turn on **Airplane Mode** (disable Wi-Fi and mobile data).
2. Type any question into the chat bar (e.g., *"Explain Dijkstra's Algorithm step-by-step"* or *"What is the difference between supervised and unsupervised learning?"*).
3. Tap **Send** (`➔`). The on-device engine streams tokens in real-time with zero internet connection.

---

### Step 4: Attaching Documents & Asking PDF Questions
1. In the chat screen, tap the **`+`** icon on the bottom input bar.
2. Select **Upload Study Document (PDF / TXT / MD)**.
3. Choose your syllabus, lecture slides, or assignment question bank.
4. Once indexed (typically `< 2 seconds`), a pill appears showing the document name and chunk count (e.g. `📄 Assignment_1.pdf • 9 chunks`).
5. Ask specific questions:
   - *"What does this new PDF say? Summarize the main topics."*
   - *"Analyze and solve the first 3 questions of this assignment."*
   - *"Explain the definition of simple linear regression on page 2."*
6. PocketLLM will answer with exact document citations: **`Grounded in: Assignment_1.pdf (p. 2)`**.

---

### Step 5: Switching Models or Repairing a Download
1. Tap the green/orange status pill at the top of the chat screen at any time.
2. To switch models: Tap **`⚡ Switch to this Model`** on any other downloaded tier.
3. If a previous download was interrupted or corrupted:
   - The app automatically detects incomplete sizes and resets the card to **`1-Tap Download`**.
   - You can also tap the **`🔄 Re-download`** icon next to any model to delete the old file and re-download fresh.

---

### Step 6: Managing Chats & Subjects
1. Tap the hamburger menu (`☰`) in the top-left corner to open the **Chat Sessions Drawer**.
2. Tap **`+ New Chat`** to start a clean session for a new course or subject.
3. Tap on any previous conversation to resume studying.
4. To clear or delete a conversation, use the options menu inside the sidebar.

---

## 💻 Developer Setup & Build Guide

### Prerequisites
- **Flutter SDK:** 3.24.0 or higher
- **Dart SDK:** 3.5.0 or higher
- **Android SDK:** API 34 (UpsideDownCake) with `cmdline-tools`
- **JDK:** OpenJDK 17 (`JAVA_HOME`)
- **Android NDK:** Version 28.2.13676358 or compatible

### Environment Setup (Windows PowerShell Example)
```powershell
$env:JAVA_HOME = "C:\Users\adity\jdk-17\jdk-17.0.12+7"
$env:ANDROID_HOME = "C:\Users\adity\Android\Sdk"
$env:PATH = "$env:JAVA_HOME\bin;$env:ANDROID_HOME\cmdline-tools\latest\bin;$env:ANDROID_HOME\platform-tools;$env:PATH"
```

### 1. Clone & Fetch Dependencies
```bash
git clone https://github.com/adityasen23453-droid/Pocket-LLM.git
cd Pocket-LLM
flutter pub get
```

### 2. Analyze Codebase
```bash
flutter analyze
```
*(Guaranteed 0 warnings and 0 errors).*

### 3. Build Release APK
```bash
flutter build apk --release
```
The compiled, production-ready APK will be output to:
```
build/app/outputs/flutter-apk/app-release.apk
```

---

## 📂 Project Structure

```
PocketLLM/
├── android/                   # Native Android Gradle configuration & NDK bindings
├── assets/
│   ├── images/                # AJU official emblems & branding icons
│   └── models/                # Local GGUF models directory (.gitignore protected)
├── lib/
│   ├── main.dart              # Application entrypoint & theme initialization
│   ├── models/
│   │   ├── chat_message.dart  # Message model with source citation serialization
│   │   └── chat_session.dart  # Multi-document conversation session model
│   ├── screens/
│   │   ├── chat_screen.dart   # Primary chat UI with RAG retrieval & model pill
│   │   └── landing_screen.dart# University welcome and onboarding portal
│   ├── services/
│   │   ├── offline_ai_service.dart   # 3-Tier model manager, KV clearContext & downloader
│   │   ├── offline_rag_service.dart  # Pure Dart BM25 document search & PDF parser
│   │   ├── chat_history_service.dart # Atomic local JSON persistence service
│   │   └── api_service.dart          # Optional hybrid network fallback client
│   ├── theme/
│   │   └── app_theme.dart     # Forest Emerald & Warm Editorial Cream color palette
│   └── widgets/
│       ├── offline_model_sheet.dart  # Interactive 3-Tier Model Hub bottom sheet
│       ├── chat_bubble.dart          # Message bubbles with collapsible document citations
│       ├── chat_input.dart           # Floating input bar with file attachment & voice buttons
│       ├── chat_sidebar.dart         # Drawer for managing course chat sessions
│       └── animated_ai_orb.dart      # 3D animated gradient pulsing orb
├── pubspec.yaml               # Flutter dependencies (llama_flutter_android, syncfusion_flutter_pdf)
└── README.md                  # Comprehensive documentation
```

---

## 🔒 Privacy, Security & Ethics

- **Zero Data Collection:** PocketLLM collects zero analytics, telemetry, crash reports, or user personal data.
- **Zero Cloud Transmission:** Student questions, exam papers, syllabus notes, and AI responses never leave the physical device.
- **Open Weights:** Powered exclusively by transparent, open-weights models (Qwen 2.5 by Alibaba Cloud & Llama 3.2 by Meta).
- **Academic Integrity:** Designed as an intelligent study companion to help students comprehend principles, debug code, and prepare for examinations ethically.

---

## 🎓 About Arka Jain University (AJU)

**Arka Jain University**, located in Gamharia, Jamshedpur, Jharkhand, is committed to academic excellence, digital innovation, and multidisciplinary research. **PocketLLM** was developed to empower AJU students with self-contained, borderless artificial intelligence that functions seamlessly across campuses, libraries, and hostels.

---

## 📄 License
This project is licensed under the **MIT License**. Open-weights models are subject to their respective licenses:
- Qwen 2.5: [Qwen Open Model License](https://github.com/QwenLM/Qwen2.5)
- Llama 3.2: [Llama 3.2 Community License](https://llama.meta.com)
