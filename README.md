# 📱 PocketLLM · Arka Jain University (AJU)
> **100% Standalone, On-Device AI Academic Tutor & RAG Assistant for Android**  
> *Zero Server. Zero Laptop. Zero Internet Required. 100% Private.*

---

## 🌟 Overview

**PocketLLM** is an on-device Small Language Model (SLM) assistant built specifically for college students at **Arka Jain University (AJU), Jamshedpur**. 

Unlike conventional cloud AI apps that require continuous internet connectivity and remote API keys, PocketLLM runs **Qwen 2.5 1.5B Instruct directly on the smartphone's processor**. It features a native **On-Device PDF RAG (Retrieval-Augmented Generation)** engine that allows students to attach lecture slides, question banks, and syllabus notes, and receive instant, grounded explanations with exact page citations—even in **Airplane Mode**.

---

## ✨ Key Features

* **⚡ 100% Standalone & Offline Execution:**  
  No laptop, no Python server, and no internet required during chat or study sessions. Shut down your PC, turn off Wi-Fi/data, and chat anywhere.
* **🧠 Qwen 2.5 1.5B Instruct On-Device Engine:**  
  Powered by `llama_flutter_android` with multi-threaded **ARM NEON CPU** and **Vulkan GPU** acceleration, delivering 10–18 tokens/second on 6 GB Android phones.
* **📄 On-Device PDF RAG (Multi-Document Support):**  
  Built with native Dart PDF extraction and an on-device **BM25 semantic search engine** (< 10 ms retrieval). Attach multiple PDFs in one chat; the app tags each excerpt with its filename and page number.
* **📲 In-App 1-Tap Wireless Model Downloader:**  
  Neither students nor friends ever need a USB cable. Tap the status badge inside the app to download the model directly over Wi-Fi/5G, or pick an existing `.gguf` file via Quick Share / SD Card.
* **💾 Persistent Offline Chat History:**  
  Conversations, timestamps, and attached documents are stored locally in the app's sandboxed storage (`chat_sessions.json`). Chats reload instantly across phone reboots.
* **🛡️ Bulletproof Error & Repetition Protection:**  
  Configured with single-block ChatML prompt templating, `presencePenalty: 1.0`, `repeatPenalty: 1.15`, thread-safe `ensureIdle` locks, and an expanded **4096-token context window**.
* **🎨 Forest Emerald & Editorial Cream Theme:**  
  Designed with an elegant editorial aesthetic, 3D animated AI Orb, and official neon Arka Jain University launcher icons.

---

## 🏗️ Architecture

```
                       📱 ANDROID MOBILE DEVICE (100% OFFLINE)
┌─────────────────────────────────────────────────────────────────────────────┐
│                                                                             │
│   FLUTTER UI (Forest Emerald & Warm Cream Theme)                            │
│   ├── LandingScreen / ChatScreen / ChatSidebar / AnimatedAiOrb             │
│   └── OfflineModelSheet (In-App Wireless Downloader)                        │
│                                                                             │
│   ──────────────────────────────────┬────────────────────────────────────   │
│                                     │                                       │
│   ON-DEVICE RAG PIPELINE            │   ON-DEVICE INFERENCE ENGINE          │
│   ├── syncfusion_flutter_pdf        │   ├── llama_flutter_android           │
│   ├── Semantic Chunker (800 chars)  │   ├── Qwen 2.5 1.5B Instruct (Q4_K_M) │
│   ├── Pure Dart BM25 Search Engine  │   ├── 4-Thread ARM NEON CPU Mode      │
│   └── Local JSON Index Storage      │   └── Vulkan GPU Acceleration         │
│                                     │                                       │
│   ──────────────────────────────────┴────────────────────────────────────   │
│                                                                             │
│   PERSISTENCE LAYER (path_provider)                                         │
│   └── chat_sessions.json (Atomic write, zero cloud sync)                   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 📱 Hardware Requirements & Recommended Specs

* **Operating System:** Android 8.0+ (API Level 26 or higher)
* **Architecture:** ARM64 (arm64-v8a)
* **Recommended RAM:** **6 GB or higher** (Runs smoothly with ~1.3 GB total memory footprint)
* **Phone Storage Needed:**
  * **Installed App:** ~75 MB
  * **Qwen 2.5 1.5B GGUF Model:** ~1.04 GB (downloaded once inside the app)
  * **Total Footprint:** **~1.15 GB**

---

## 🚀 Getting Started

### 1. Build the Release APK
Ensure you have the Flutter SDK, Android SDK, and JDK 17 configured:
```powershell
flutter pub get
flutter build apk --release
```
The optimized production APK will be generated at:
`build/app/outputs/flutter-apk/app-release.apk`

### 2. Install on Phone (No USB Cable Needed)
1. Share `app-release.apk` to your phone via WhatsApp, Google Drive, Telegram, or Quick Share.
2. Tap the APK on your phone and select **Install** (*Allow installation from unknown sources* if prompted).

### 3. Load the Model Wirelessly
1. Open **PocketLLM - AJU**.
2. Tap the top status pill: **TAP FOR OFFLINE AI**.
3. Tap **"1-Tap Download Model (Wi-Fi/5G)"**.
4. The app streams `qwen2.5-1.5b-instruct-q4_k_m.gguf` directly to your phone's storage.
5. Once complete, the badge turns green: **🟢 OFFLINE AI (1.5B)**.

---

## 📂 Repository Structure

```
PocketLLM/
├── android/                   # Native Android configuration & launcher icons
├── assets/
│   ├── images/                # AJU PocketLLM official neon logos
│   └── models/                # Local GGUF models (git-ignored)
├── lib/
│   ├── models/                # ChatMessage, ChatSession data models
│   ├── screens/               # LandingScreen, ChatScreen
│   ├── services/
│   │   ├── api_service.dart          # Optional local FastAPI server client
│   │   ├── offline_ai_service.dart   # On-device llama.cpp inference controller
│   │   ├── offline_rag_service.dart  # On-device PDF parser & BM25 search
│   │   └── chat_history_service.dart # Local atomic JSON persistence
│   ├── theme/                 # AppTheme tokens (Forest Emerald / Cream)
│   ├── widgets/               # ChatBubble, ChatInput, Sidebar, OfflineModelSheet
│   └── main.dart              # App entry point
├── backend/                   # Optional Python FastAPI & ChromaDB server
├── pubspec.yaml               # Flutter package configuration
└── README.md                  # Project documentation
```

---

## 🎓 University Attribution & Credits

* **Institution:** Arka Jain University (AJU), Jamshedpur, Jharkhand, India.
* **Core Model:** Qwen 2.5 1.5B Instruct by Alibaba Cloud (GGUF Q4_K_M quantization).
* **Inference Runtime:** `llama.cpp` via `llama_flutter_android`.
* **Lead Developer:** Aditya Sen ([@adityasen23453-droid](https://github.com/adityasen23453-droid))
