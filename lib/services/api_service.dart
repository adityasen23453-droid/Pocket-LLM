import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static String get _detectBaseUrl {
    if (kIsWeb) {
      final host = Uri.base.host;
      if (host.isNotEmpty && host != 'localhost' && host != '127.0.0.1') {
        return 'http://$host:8000';
      }
      return 'http://127.0.0.1:8000';
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://192.168.1.3:8000';
    }
    return 'http://127.0.0.1:8000';
  }

  final String baseUrl;
  final http.Client _client;

  ApiService({String? baseUrl, http.Client? client})
      : baseUrl = baseUrl ?? _detectBaseUrl,
        _client = client ?? http.Client();

  /// Check backend health, device (CUDA/CPU), model name, and indexed RAG chunk count
  Future<Map<String, dynamic>> checkHealth() async {
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/api/health'))
          .timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('[ApiService] Health check failed: $e');
    }
    return {'status': 'offline', 'device': 'unknown', 'rag_chunks_indexed': 0};
  }

  /// Streams tokens in real-time from the local LLM server using Server-Sent Events (SSE)
  Stream<String> streamChat({
    required String message,
    List<Map<String, String>>? history,
    bool useRag = true,
    int topK = 5,
    String? activeDocument,
    void Function(List<String> sources)? onSources,
  }) async* {
    final payload = <String, dynamic>{
      'message': message,
      'use_rag': useRag,
      'top_k': topK,
    };
    if (activeDocument != null && activeDocument.isNotEmpty) {
      payload['active_document'] = activeDocument;
    }
    if (history != null) {
      payload['chat_history'] = history;
    }

    final uri = Uri.parse('$baseUrl/api/chat');
    final request = http.Request('POST', uri)
      ..headers['Content-Type'] = 'application/json'
      ..body = json.encode(payload);

    final response = await _client.send(request);

    if (response.statusCode != 200) {
      final errorBody = await response.stream.bytesToString();
      throw Exception('Server error (${response.statusCode}): $errorBody');
    }

    String buffer = '';
    await for (final chunk in response.stream.transform(utf8.decoder)) {
      buffer += chunk;
      while (buffer.contains('\n\n')) {
        final index = buffer.indexOf('\n\n');
        final eventBlock = buffer.substring(0, index).trim();
        buffer = buffer.substring(index + 2);

        for (final line in eventBlock.split('\n')) {
          if (line.startsWith('data: ')) {
            final jsonStr = line.substring(6).trim();
            if (jsonStr.isEmpty) continue;
            try {
              final data = json.decode(jsonStr) as Map<String, dynamic>;
              final type = data['type'] as String?;
              if (type == 'token') {
                final content = data['content'] as String? ?? '';
                yield content;
              } else if (type == 'sources') {
                final sourcesList = (data['sources'] as List<dynamic>?)
                    ?.map((e) => e.toString())
                    .toList();
                if (sourcesList != null && onSources != null) {
                  onSources(sourcesList);
                }
              } else if (type == 'done') {
                return;
              }
            } catch (_) {
              // Ignore non-json chunk or partial decode
            }
          }
        }
      }
    }
  }

  /// Uploads study notes (PDF, TXT, MD) to the backend vector store
  Future<Map<String, dynamic>> uploadDocument({
    required List<int> bytes,
    required String filename,
  }) async {
    final uri = Uri.parse('$baseUrl/api/upload');
    final request = http.MultipartRequest('POST', uri);

    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: filename,
      ),
    );

    final streamedResponse = await _client.send(request);
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Upload failed (${response.statusCode}): ${response.body}');
    }
  }

  /// Wipes all indexed notes in ChromaDB
  Future<bool> clearDocuments() async {
    try {
      final response = await _client.post(Uri.parse('$baseUrl/api/clear'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
