import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:llama_flutter_android/llama_flutter_android.dart' as llama;

/// Supported offline AI model tiers tailored from 3GB to 8GB Android phones.
enum ModelTierId {
  nano,      // 0.5B - For 3-4 GB RAM devices
  balanced,  // 1.5B - For 6 GB RAM devices (Default recommended for Arka Jain University)
  pro,       // 3B   - For 8 GB RAM devices
}

/// Information and hardware requirements for an offline model tier.
class ModelTierInfo {
  final ModelTierId id;
  final String displayName;
  final String subtitle;
  final String fileName;
  final String downloadUrl;
  final int fileSizeBytes;
  final String fileSizeDisplay;
  final String minRam;
  final String recommendedRam;
  final String speedRating;
  final String description;
  final String badgeText;

  const ModelTierInfo({
    required this.id,
    required this.displayName,
    required this.subtitle,
    required this.fileName,
    required this.downloadUrl,
    required this.fileSizeBytes,
    required this.fileSizeDisplay,
    required this.minRam,
    required this.recommendedRam,
    required this.speedRating,
    required this.description,
    required this.badgeText,
  });
}

/// Standalone on-device AI inference engine for Android devices.
/// Powered by llama.cpp ARM NEON multi-threaded CPU and Vulkan GPU acceleration.
class OfflineAiService {
  static final OfflineAiService _instance = OfflineAiService._internal();
  factory OfflineAiService() => _instance;
  OfflineAiService._internal();

  llama.LlamaController? _controller;
  bool _isModelLoaded = false;
  bool _isLoading = false;
  String? _loadedModelPath;
  ModelTierId? _activeTierId;

  bool get isModelLoaded => _isModelLoaded;
  bool get isLoading => _isLoading;
  String? get loadedModelPath => _loadedModelPath;
  ModelTierId? get activeTierId => _activeTierId;

  /// Official model tiers available in the PocketLLM Hub
  static const List<ModelTierInfo> tiers = [
    ModelTierInfo(
      id: ModelTierId.nano,
      displayName: 'PocketLLM Nano (0.5B)',
      subtitle: 'Qwen 2.5 0.5B Instruct · Q4_K_M',
      fileName: 'qwen2.5-0.5b-instruct-q4_k_m.gguf',
      downloadUrl: 'https://huggingface.co/Qwen/Qwen2.5-0.5B-Instruct-GGUF/resolve/main/qwen2.5-0.5b-instruct-q4_k_m.gguf',
      fileSizeBytes: 491400032,
      fileSizeDisplay: '468 MB',
      minRam: '3 GB RAM',
      recommendedRam: '4 GB RAM',
      speedRating: '⚡⚡⚡ Ultra Fast (~45 tok/s)',
      description: 'Ultra-lightweight & responsive. Perfect for budget phones (4 GB RAM), quick definitions, and zero thermal throttling.',
      badgeText: '4 GB PHONES',
    ),
    ModelTierInfo(
      id: ModelTierId.balanced,
      displayName: 'PocketLLM Balanced (1.5B)',
      subtitle: 'Qwen 2.5 1.5B Instruct · Q4_K_M',
      fileName: 'qwen2.5-1.5b-instruct-q4_k_m.gguf',
      downloadUrl: 'https://huggingface.co/Qwen/Qwen2.5-1.5B-Instruct-GGUF/resolve/main/qwen2.5-1.5b-instruct-q4_k_m.gguf',
      fileSizeBytes: 1117320736,
      fileSizeDisplay: '1.04 GB',
      minRam: '4 GB RAM',
      recommendedRam: '6 GB RAM',
      speedRating: '⚡⚡ Balanced (~25 tok/s)',
      description: 'Arka Jain University standard. Optimal balance of accuracy, multi-page PDF RAG, and problem-solving.',
      badgeText: 'RECOMMENDED · 6 GB',
    ),
    ModelTierInfo(
      id: ModelTierId.pro,
      displayName: 'PocketLLM Pro (3B)',
      subtitle: 'Llama 3.2 3B Instruct · Q4_K_M',
      fileName: 'Llama-3.2-3B-Instruct-Q4_K_M.gguf',
      downloadUrl: 'https://huggingface.co/bartowski/Llama-3.2-3B-Instruct-GGUF/resolve/main/Llama-3.2-3B-Instruct-Q4_K_M.gguf',
      fileSizeBytes: 2019377696,
      fileSizeDisplay: '1.88 GB',
      minRam: '6 GB RAM',
      recommendedRam: '8 GB RAM',
      speedRating: '⚡ Deep Academic (~15 tok/s)',
      description: 'Maximum intelligence for 8 GB devices. Advanced multi-step math, research paper synthesis, and in-depth academic essays.',
      badgeText: 'POWER · 8 GB PHONES',
    ),
  ];

  ModelTierInfo? get activeTier {
    if (_activeTierId == null) return null;
    return tiers.firstWhere((t) => t.id == _activeTierId, orElse: () => tiers[1]);
  }

  String get activeTierName {
    if (_activeTierId == ModelTierId.nano) return '0.5B';
    if (_activeTierId == ModelTierId.balanced) return '1.5B';
    if (_activeTierId == ModelTierId.pro) return '3B';
    if (_loadedModelPath != null) return 'Custom';
    return '1.5B';
  }

  Future<Directory> _getModelDir() async {
    final docDir = await getApplicationDocumentsDirectory();
    final modelDir = Directory('${docDir.path}/models');
    if (!await modelDir.exists()) {
      await modelDir.create(recursive: true);
    }
    return modelDir;
  }

  /// Checks if a specific model tier is downloaded and valid on device storage
  Future<bool> isModelDownloaded(ModelTierId tierId) async {
    final tier = tiers.firstWhere((t) => t.id == tierId);
    final path = await getModelPathForTier(tier);
    return path != null;
  }

  /// Resolves the absolute path for a specific model tier
  Future<String?> getModelPathForTier(ModelTierInfo tier) async {
    if (kIsWeb || !Platform.isAndroid) return null;

    try {
      final modelDir = await _getModelDir();
      final appFile = File('${modelDir.path}/${tier.fileName}');
      if (await appFile.exists() && await appFile.length() > 50000000) {
        return appFile.path;
      }

      // Check public /storage/emulated/0/Download
      final downloadDir = Directory('/storage/emulated/0/Download');
      if (await downloadDir.exists()) {
        final dFile = File('${downloadDir.path}/${tier.fileName}');
        if (await dFile.exists() && await dFile.length() > 50000000) {
          return dFile.path;
        }
      }
    } catch (e) {
      debugPrint('[OfflineAiService] Error resolving tier path: $e');
    }
    return null;
  }

  /// Checks possible locations for any installed model (checks balanced -> nano -> pro)
  Future<String?> getModelPath() async {
    if (kIsWeb || !Platform.isAndroid) return null;

    // 1. Try currently selected tier if set
    if (_activeTierId != null) {
      final selectedTier = tiers.firstWhere((t) => t.id == _activeTierId);
      final path = await getModelPathForTier(selectedTier);
      if (path != null) return path;
    }

    // 2. Try Balanced (1.5B - Default)
    final balancedPath = await getModelPathForTier(tiers[1]);
    if (balancedPath != null) {
      _activeTierId = ModelTierId.balanced;
      return balancedPath;
    }

    // 3. Try Nano (0.5B)
    final nanoPath = await getModelPathForTier(tiers[0]);
    if (nanoPath != null) {
      _activeTierId = ModelTierId.nano;
      return nanoPath;
    }

    // 4. Try Pro (3B)
    final proPath = await getModelPathForTier(tiers[2]);
    if (proPath != null) {
      _activeTierId = ModelTierId.pro;
      return proPath;
    }

    return null;
  }

  /// Ensures native inference engine is idle and not stuck in 'generating' state
  Future<void> ensureIdle() async {
    if (_controller != null) {
      try {
        if (_controller!.isGenerating) {
          await _controller!.stop();
        }
      } catch (e) {
        debugPrint('[OfflineAiService] Stop error during ensureIdle: $e');
      }
      // Give native JNI thread 100ms to exit its token loop safely
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  /// Clears native KV cache (resets g_n_past = 0 in C++ memory).
  /// Keeps model weights loaded in RAM while completely wiping ghost tokens and repetitions.
  Future<void> clearContext() async {
    if (_controller != null && _isModelLoaded) {
      try {
        await _controller!.clearContext();
        debugPrint('[OfflineAiService] Native KV cache cleared (g_n_past reset to 0).');
      } catch (e) {
        debugPrint('[OfflineAiService] Warning clearing context: $e');
      }
    }
  }

  /// Initializes and loads the GGUF model into phone RAM with 4096 context and CPU fallback
  Future<bool> initModel({String? customPath, bool forceCpu = false}) async {
    if (_isLoading) return false;

    if (kIsWeb || !Platform.isAndroid) {
      debugPrint('[OfflineAiService] On-device inference only active on Android.');
      return false;
    }

    _isLoading = true;
    try {
      final path = customPath ?? await getModelPath();
      if (path == null) {
        debugPrint('[OfflineAiService] No GGUF model found on device storage.');
        _isLoading = false;
        return false;
      }

      // Identify which tier this path corresponds to
      for (final t in tiers) {
        if (path.toLowerCase().contains(t.fileName.toLowerCase())) {
          _activeTierId = t.id;
          break;
        }
      }

      // Dispose existing controller if switching
      if (_controller != null) {
        try {
          await ensureIdle();
          await _controller!.dispose();
        } catch (_) {}
        _controller = null;
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
          contextSize: 4096, // 4096 token context window
          gpuLayers: gpuLayers,
        );
      } catch (loadErr) {
        // Fallback to pure ARM NEON CPU if GPU compilation fails
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
      debugPrint('[OfflineAiService] Model loaded successfully: $path (Tier: $activeTierName)');
      return true;
    } catch (e) {
      debugPrint('[OfflineAiService] Failed to load model: $e');
      _isModelLoaded = false;
      return false;
    } finally {
      _isLoading = false;
    }
  }

  /// Switches active model tier cleanly by disposing old model and loading new tier
  Future<bool> switchModel(ModelTierId tierId) async {
    final tier = tiers.firstWhere((t) => t.id == tierId);
    final path = await getModelPathForTier(tier);
    if (path == null) {
      debugPrint('[OfflineAiService] Model file not found for tier: ${tier.displayName}');
      return false;
    }

    await ensureIdle();
    await dispose();
    _activeTierId = tierId;
    return await initModel(customPath: path);
  }

  /// Streams tokens in real-time from the on-device model with KV cache reset & anti-repetition
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
            "Please tap the top status pill to download a model wirelessly.";
        return;
      }
    }

    // 1. Ensure engine is completely idle
    await ensureIdle();

    // 2. Clear native KV cache (g_n_past = 0) so this generation starts cleanly from position 0
    // This permanently prevents duplicate token positions, repeating answers, and ghost memory
    await clearContext();

    // 3. Build a SINGLE unified system prompt (Guarantees ChatML template integrity)
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

    // 4. Add sliding history (last 4 valid turns)
    if (history != null) {
      for (final h in history) {
        final role = h['role'] ?? 'user';
        final content = h['content'] ?? '';
        if (content.isNotEmpty) {
          chatMessages.add(llama.ChatMessage(role: role, content: content));
        }
      }
    }

    // 5. Add current user prompt
    chatMessages.add(llama.ChatMessage(role: 'user', content: message));

    try {
      // Optimized generation configuration for coherent, non-repetitive responses
      yield* _controller!.generateChat(
        messages: chatMessages,
        maxTokens: 512,
        temperature: 0.7,
        topP: 0.9,
        topK: 40,
        minP: 0.05,
        repeatPenalty: 1.15, // Suppresses token looping
        presencePenalty: 1.0, // Discourages re-using previous phrases
        repeatLastN: 128,
      );
    } catch (e) {
      debugPrint('[OfflineAiService] Generation exception: $e');
      yield "⚠️ On-device generation error: $e\n\nTip: You can re-open the model or try a shorter prompt.";
    }
  }

  /// In-app wireless model downloader with streaming chunk writing, automatic 302 redirect support, and live progress
  Future<bool> downloadModel({
    required ModelTierId tierId,
    required void Function(double progress, String statusText) onProgress,
  }) async {
    if (kIsWeb || !Platform.isAndroid) return false;

    final tier = tiers.firstWhere((t) => t.id == tierId);

    try {
      final modelDir = await _getModelDir();
      final targetFile = File('${modelDir.path}/${tier.fileName}');
      final tempFile = File('${modelDir.path}/${tier.fileName}.tmp');

      final client = HttpClient();
      final request = await client.getUrl(Uri.parse(tier.downloadUrl));
      final response = await request.close();

      if (response.statusCode != 200) {
        throw Exception('Download failed with status: ${response.statusCode}');
      }

      final totalBytes = response.contentLength > 0 ? response.contentLength : tier.fileSizeBytes;
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

      _activeTierId = tierId;
      return await initModel(customPath: targetFile.path);
    } catch (e) {
      debugPrint('[OfflineAiService] Download error for ${tier.displayName}: $e');
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
    await stop();
    await _controller?.dispose();
    _controller = null;
    _isModelLoaded = false;
    _loadedModelPath = null;
  }
}
