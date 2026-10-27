# 📱 PocketLLM · Arka Jain University (AJU)
> **100% Standalone, On-Device AI Academic Tutor & RAG Assistant for Android**  
> *Zero Server. Zero Laptop. Zero Internet Required. 100% Private.*

---

## 🌟 Overview

**PocketLLM** is an on-device Small Language Model (SLM) assistant built specifically for students and faculty at **Arka Jain University (AJU), Jamshedpur**. 

Unlike conventional cloud AI apps that require continuous internet connectivity and remote API keys, PocketLLM runs **open-weights language models entirely on the smartphone's local processor**. It features a native **On-Device PDF RAG (Retrieval-Augmented Generation)** engine and an interactive **3-Tier Model Hub** allowing students to choose between 0.5B, 1.5B, and 3B models tailored for 4 GB, 6 GB, and up to 8 GB Android devices—even in **Airplane Mode**.

---

## ✨ Key Features

* **⚡ 100% Standalone & Offline Execution:**  
  No laptop, no Python backend, and no internet connection required during study sessions. Turn off Wi-Fi and mobile data; the entire AI brain runs locally on your phone.
* **🎛️ 3-Tier In-App Model Hub (4 GB to 8 GB Devices):**  
  Download, switch, and hot-swap between 3 optimized GGUF models directly within the app:
  * **PocketLLM Nano (0.5B):** For entry-level **4 GB RAM** phones. Ultra-fast (~45 tok/s), lightweight (~468 MB).
  * **PocketLLM Balanced (1.5B) [Default]:** Recommended for **6 GB RAM** phones. University standard for syllabus Q&A and assignments (~1.04 GB).
  * **PocketLLM Pro (3B):** For power-user **8 GB RAM** phones. Deep multi-step analytical reasoning and research synthesis (~1.88 GB).
* **📄 Isolated On-Device PDF RAG:**  
  Built with native Dart PDF extraction and a local **BM25 semantic ranking engine** (< 10 ms retrieval). Attach lecture slides, assignments, and survey forms; the app tags each excerpt with its exact filename and page number with zero cross-document contamination.
* **🧹 Native KV-Cache Ghost Memory Purging:**  
  Hardened with native C++ JNI context resets (`clearContext` / `llama_memory_seq_rm`), eliminating token position shifts, echo loops, and ghost memory bleed across chats.
* **📲 1-Tap Wireless In-App Downloader:**  
  Students never need a USB cable or PC connection. Download models directly over Wi-Fi/5G in-app, or import an existing `.gguf` file via Quick Share / SD Card.
* **💾 Persistent Offline Chat History:**  
  Conversations, timestamps, and attached documents persist locally in sandboxed storage (`chat_sessions.json`). Chats reload instantly across phone reboots.
* **🎨 Forest Emerald & Editorial Cream Theme:**  
  Designed with an elegant academic aesthetic, 3D animated AI Orb, and official neon Arka Jain University launcher icons.

---

## 🏗️ Architecture

```
                       📱 ANDROID MOBILE DEVICE (100% OFFLINE)
┌─────────────────────────────────────────────────────────────────────────────┐
│                                                                             │
│   FLUTTER UI (Forest Emerald & Warm Cream Theme)                            │
│   ├── LandingScreen / ChatScreen / ChatSidebar / AnimatedAiOrb             │
│   └── OfflineModelSheet (3-Tier In-App Model Hub)                           │
│                                                                             │
│   ──────────────────────────────────┬────────────────────────────────────   │
│                                     │                                       │
│   ON-DEVICE RAG PIPELINE            │   ON-DEVICE INFERENCE ENGINE          │
│   ├── syncfusion_flutter_pdf        │   ├── llama_flutter_android (C++ JNI) │
│   ├── Semantic Chunker (750 chars)  │   ├── Active Model (0.5B / 1.5B / 3B) │
│   ├── Pure Dart BM25 Search Engine  │   ├── 4-Thread ARM NEON CPU Mode      │
│   ├── Target Document Scoping       │   ├── Vulkan GPU Acceleration         │
│   └── Local JSON Index Storage      │   └── KV-Cache clearContext Purge    │
│                                     │                                       │
│   ──────────────────────────────────┴────────────────────────────────────   │
│                                                                             │
│   PERSISTENCE LAYER (path_provider)                                         │
│   └── chat_sessions.json (Atomic write, zero cloud sync)                   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 📱 Model Tier Comparison & Hardware Requirements

| Model Tier | Base Architecture | GGUF File Size | Minimum RAM | Recommended RAM | Speed (approx.) | Best For |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **PocketLLM Nano (0.5B)** | Qwen 2.5 0.5B Instruct (Q4_K_M) | 468 MB | **3 GB** | **4 GB** | ⚡⚡⚡ 35–50 tok/s | Budget phones, quick definitions, lowest battery drain |
| **PocketLLM Balanced (1.5B)** | Qwen 2.5 1.5B Instruct (Q4_K_M) | 1.04 GB | **4 GB** | **6 GB** | ⚡⚡ 18–28 tok/s | **AJU Recommended Standard**, assignment solving, PDF RAG |
| **PocketLLM Pro (3B)** | Llama 3.2 3B Instruct (Q4_K_M) | 1.88 GB | **6 GB** | **8 GB** | ⚡ 10–16 tok/s | Heavy academic reasoning, research papers, long essays |

* **Operating System:** Android 8.0+ (API Level 26 or higher)
* **Architecture:** ARM64 (arm64-v8a)
* **Maximum Target:** Android phones with up to **8 GB RAM**

---

## 🚀 Getting Started

### 1. Build the Release APK
Ensure you have Flutter SDK (3.24+), Android SDK, and JDK 17 configured:
```powershell
flutter pub get
flutter build apk --release
```
The production APK will be generated at:
`build/app/outputs/flutter-apk/app-release.apk`

### 2. Install on Phone (Zero Cables Needed)
1. Share `app-release.apk` to your phone via WhatsApp, Telegram, Google Drive, or Quick Share.
2. Tap the APK on your phone and select **Install** (*Allow installation from unknown sources* if prompted).

### 3. Choose & Download Your Model Wirelessly
1. Open **PocketLLM - AJU**.
2. Tap the top status pill: **TAP FOR OFFLINE AI**.
3. The **AI Model Hub** displays all 3 tiers with minimum RAM requirements.
4. Tap **1-Tap Download** on your preferred model (e.g. Balanced 1.5B for 6GB phones or Pro 3B for 8GB phones).
5. The model streams directly to your phone. Once finished, the status badge turns green: **🟢 OFFLINE AI (1.5B)**.

---

## 📂 Repository Structure

```
PocketLLM/
├── android/                   # Native Android host & Gradle build configs
├── assets/
│   ├── images/                # AJU official emblem and branding assets
│   └── models/                # Ignored by git (GGUF weights remain local)
├── lib/
│   ├── models/
│   │   ├── chat_message.dart  # Message model with source citations & JSON serialization
│   │   └── chat_session.dart  # Session model with multi-document tracking
│   ├── screens/
│   │   ├── chat_screen.dart   # Main conversational UI with isolated document scoping
│   │   └── landing_screen.dart# University welcome screen
│   ├── services/
│   │   ├── offline_ai_service.dart   # 3-Tier model manager, KV-cache clearContext & downloader
│   │   ├── offline_rag_service.dart  # Pure Dart BM25 document search & PDF parser
│   │   └── chat_history_service.dart # Persistent JSON conversation manager
│   ├── theme/
│   │   └── app_theme.dart     # Forest Emerald & Editorial Cream theme
│   └── widgets/
│       ├── offline_model_sheet.dart  # Interactive 3-Tier Model Hub bottom sheet
│       ├── chat_bubble.dart          # Message bubbles with collapsible source badges
│       ├── chat_input.dart           # Floating input bar with file attachment & voice buttons
│       ├── chat_sidebar.dart         # Drawer for chat sessions & session management
│       └── animated_ai_orb.dart      # 3D animated gradient pulsing orb
├── pubspec.yaml               # Flutter dependencies (llama_flutter_android, syncfusion_flutter_pdf)
└── README.md                  # Comprehensive documentation
```

---

## 🎓 About Arka Jain University (AJU)
PocketLLM was engineered to democratize AI access for higher education students, eliminating financial barriers, subscription fees, and server dependency. All intelligence runs 100% privately on the device in your pocket.
