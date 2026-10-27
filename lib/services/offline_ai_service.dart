import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:llama_flutter_android/llama_flutter_android.dart' as llama;

/// High-performance On-Device AI inference service running Qwen 2.5 1.5B
/// directly on the mobile phone using ARM NEON multi-threaded CPU or Vulkan GPU acceleration.
class OfflineAiService {
  static final OfflineAiService _instance = OfflineAiService._internal();
  factory OfflineAiService() => _instance;
  OfflineAiService._internal();

  llama.LlamaController? _controller;
  bool _isModelLoaded = false;
  bool _isLoading = false;
  String? _loadedModelPath;

  bool get isModelLoaded => _isModelLoaded;
  bool get isLoading => _isLoading;
  String? get loadedModelPath => _loadedModelPath;

  /// Checks possible locations for the Qwen 2.5 1.5B GGUF file
  Future<String?> getModelPath() async {
    if (kIsWeb || !Platform.isAndroid) return null;

    try {
      final docDir = await getApplicationDocumentsDirectory();
      final modelDir = Directory('${docDir.path}/models');
      if (!await modelDir.exists()) {
        await modelDir.create(recursive: true);
      }

      // 1. Check primary app document location
      final file1 = File('${modelDir.path}/qwen2.5-1.5b-instruct-q4_k_m.gguf');
      if (await file1.exists() && await file1.length() > 50000000) {
        return file1.path;
      }

      // 2. Check 0.5B fallback if user has 0.5B
      final file2 = File('${modelDir.path}/qwen2.5-0.5b-instruct-q4_k_m.gguf');
      if (await file2.exists() && await file2.length() > 50000000) {
        return file2.path;
      }

      // 3. Check /sdcard/Download or public downloads
      final downloadDir = Directory('/storage/emulated/0/Download');
      if (await downloadDir.exists()) {
        final dFile1 = File('${downloadDir.path}/qwen2.5-1.5b-instruct-q4_k_m.gguf');
        if (await dFile1.exists()) return dFile1.path;
        final dFile2 = File('${downloadDir.path}/qwen2.5-0.5b-instruct-q4_k_m.gguf');
        if (await dFile2.exists()) return dFile2.path;
      }
    } catch (e) {
      debugPrint('[OfflineAiService] Error resolving model path: $e');
    }
    return null;
  }

  /// Ensures native inference engine is idle and not stuck in 'generating' state
  Future<void> ensureIdle() async {
    if (_controller != null && _controller!.isGenerating) {
      try {
        await _controller!.stop();
      } catch (_) {}
      await Future.delayed(const Duration(milliseconds: 80));
    }
  }

  /// Initializes and loads the GGUF model into phone RAM with 4096 context and CPU fallback
  Future<bool> initModel({String? customPath, bool forceCpu = false}) async {
    if (_isModelLoaded) return true;
    if (_isLoading) return false;

    if (kIsWeb || !Platform.isAndroid) {
      debugPrint('[OfflineAiService] On-device inference only active on Android.');
      return false;
    }

    _isLoading = true;
    try {
      final path = customPath ?? await getModelPath();
      if (path == null) {
        debugPrint('[OfflineAiService] No GGUF model found on device.');
        _isLoading = false;
        return false;
      }

      _controller = llama.LlamaController();
      int gpuLayers = 0;

      if (!forceCpu) {
        try {
          final gpu = await _controller!.detectGpu();
          gpuLayers = gpu.recommendedGpuLayers > 0 ? gpu.recommendedGpuLayers : 0;
        } catch (e) {
          debugPrint('[OfflineAiService] GPU detect warning: $e');
          gpuLayers = 0;
        }
      }

      debugPrint('[OfflineAiService] Loading model from: $path (GPU layers: $gpuLayers)');
      try {
        await _controller!.loadModel(
          modelPath: path,
          threads: 4,
          contextSize: 4096, // Expanded to 4096 tokens for 6GB devices (eliminates context crashes)
          gpuLayers: gpuLayers,
        );
      } catch (loadErr) {
        // If Vulkan GPU fails on this chipset, fallback to ARM NEON CPU
        debugPrint('[OfflineAiService] GPU load failed ($loadErr). Falling back to ARM NEON CPU...');
        _controller = llama.LlamaController();
        await _controller!.loadModel(
          modelPath: path,
          threads: 4,
          contextSize: 4096,
          gpuLayers: 0,
        );
      }

      _isModelLoaded = true;
      _loadedModelPath = path;
      debugPrint('[OfflineAiService] Qwen model successfully initialized!');
      return true;
    } catch (e) {
      debugPrint('[OfflineAiService] Failed to load model: $e');
      _isModelLoaded = false;
      return false;
    } finally {
      _isLoading = false;
    }
  }

  /// Streams tokens in real-time from the on-device model
  Stream<String> streamChat({
    required String message,
    List<Map<String, String>>? history,
    List<String>? contextChunks,
    String? activeDocument,
  }) async* {
    if (!_isModelLoaded || _controller == null) {
      final success = await initModel();
      if (!success) {
        yield "⚠️ On-Device AI Model not found on phone storage.\n\n"
            "Please tap the top status pill to download the model wirelessly.";
        return;
      }
    }

    // Guarantee the native C++ engine is idle before starting a new prompt
    await ensureIdle();

    // 1. Build a SINGLE unified system prompt (Fixes ChatML template corruption)
    final systemBuffer = StringBuffer(
      'You are PocketLLM, an expert AI academic tutor for students at Arka Jain University (AJU), Jamshedpur.\n'
      'Help students understand concepts, solve assignments step-by-step, and summarize study notes cleanly.',
    );

    if (contextChunks != null && contextChunks.isNotEmpty) {
      systemBuffer.write('\n\nStudy Notes & Reference Material:\n');
      systemBuffer.write(contextChunks.join("\n\n---\n\n"));
      systemBuffer.write(
        '\n\nInstructions: Answer the student\'s question based on the above reference material. '
        'Cite the page numbers or document names when referencing facts. If the answer is not mentioned in the material, state that clearly.',
      );
    } else if (activeDocument != null && activeDocument.isNotEmpty) {
      systemBuffer.write('\n\nActive Document: $activeDocument');
    }

    final chatMessages = <llama.ChatMessage>[
      llama.ChatMessage(
        role: 'system',
        content: systemBuffer.toString(),
      ),
    ];

    // 2. Add sliding history (already filtered by caller to latest turns)
    if (history != null) {
      for (final h in history) {
        final role = h['role'] ?? 'user';
        final content = h['content'] ?? '';
        if (content.isNotEmpty) {
          chatMessages.add(llama.ChatMessage(role: role, content: content));
        }
      }
    }

    // 3. Add current user message
    chatMessages.add(llama.ChatMessage(role: 'user', content: message));

    try {
      // Configured anti-repetition parameters for Qwen 2.5
      yield* _controller!.generateChat(
        messages: chatMessages,
        maxTokens: 512,
        temperature: 0.7,
        topP: 0.9,
        topK: 40,
        minP: 0.05,
        repeatPenalty: 1.15, // Prevents echo loops
        presencePenalty: 1.0, // Discourages repeating earlier phrases
        repeatLastN: 128,
      );
    } catch (e) {
      debugPrint('[OfflineAiService] Generation exception: $e');
      yield "⚠️ On-device generation error: $e\n\nTip: You can re-open the model or try a shorter prompt.";
    }
  }

  /// In-app model downloader with streaming chunk writing, automatic 302 redirect support, and live progress
  Future<bool> downloadModel({
    required void Function(double progress, String statusText) onProgress,
  }) async {
    if (kIsWeb || !Platform.isAndroid) return false;

    try {
      final docDir = await getApplicationDocumentsDirectory();
      final modelDir = Directory('${docDir.path}/models');
      if (!await modelDir.exists()) {
        await modelDir.create(recursive: true);
      }

      final targetFile = File('${modelDir.path}/qwen2.5-1.5b-instruct-q4_k_m.gguf');
      final tempFile = File('${modelDir.path}/qwen2.5-1.5b-instruct-q4_k_m.gguf.tmp');

      const modelUrl = 'https://huggingface.co/Qwen/Qwen2.5-1.5B-Instruct-GGUF/resolve/main/qwen2.5-1.5b-instruct-q4_k_m.gguf';

      final client = HttpClient();
      final request = await client.getUrl(Uri.parse(modelUrl));
      final response = await request.close();

      if (response.statusCode != 200) {
        throw Exception('Download failed with status: ${response.statusCode}');
      }

      final totalBytes = response.contentLength > 0 ? response.contentLength : 1117320736;
      int receivedBytes = 0;
      final sink = tempFile.openWrite();

      await for (final chunk in response) {
        sink.add(chunk);
        receivedBytes += chunk.length;
        final progress = (receivedBytes / totalBytes).clamp(0.0, 1.0);
        final mbReceived = (receivedBytes / (1024 * 1024)).toStringAsFixed(1);
        final mbTotal = (totalBytes / (1024 * 1024)).toStringAsFixed(0);
        onProgress(progress, '$mbReceived MB / $mbTotal MB (${(progress * 100).toStringAsFixed(0)}%)');
      }

      await sink.flush();
      await sink.close();
      client.close();

      if (await targetFile.exists()) {
        await targetFile.delete();
      }
      await tempFile.rename(targetFile.path);
      return await initModel(customPath: targetFile.path);
    } catch (e) {
      debugPrint('[OfflineAiService] Download error: $e');
      return false;
    }
  }

  /// Allows selecting an existing .gguf model from phone internal storage or SD card
  Future<bool> pickLocalModel() async {
    try {
      final files = await FilePicker.pickFiles(
        type: FileType.any,
      );
      if (files.isNotEmpty && files.first.path != null) {
        final path = files.first.path!;
        if (path.endsWith('.gguf')) {
          return await initModel(customPath: path);
        }
      }
    } catch (e) {
      debugPrint('[OfflineAiService] Error picking model file: $e');
    }
    return false;
  }

  Future<void> stop() async {
    await _controller?.stop();
  }

  Future<void> dispose() async {
    await _controller?.dispose();
    _isModelLoaded = false;
    _loadedModelPath = null;
  }
}
