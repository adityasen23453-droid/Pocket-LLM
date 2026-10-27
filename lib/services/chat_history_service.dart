import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../models/chat_session.dart';

/// Manages persistent offline storage of chat sessions and message histories on device.
class ChatHistoryService {
  static final ChatHistoryService _instance = ChatHistoryService._internal();
  factory ChatHistoryService() => _instance;
  ChatHistoryService._internal();

  File? _cachedFile;

  Future<File> _getHistoryFile() async {
    if (_cachedFile != null) return _cachedFile!;
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/chat_sessions.json');
    _cachedFile = file;
    return file;
  }

  /// Loads all saved chat sessions from internal storage
  Future<List<ChatSession>> loadSessions() async {
    try {
      final file = await _getHistoryFile();
      if (!await file.exists()) {
        return [];
      }

      final content = await file.readAsString();
      if (content.trim().isEmpty) {
        return [];
      }

      final decoded = jsonDecode(content);
      if (decoded is List) {
        final sessions = decoded
            .map((item) => ChatSession.fromJson(item as Map<String, dynamic>))
            .toList();

        // Sort by most recently modified
        sessions.sort((a, b) => b.lastModified.compareTo(a.lastModified));
        return sessions;
      }
    } catch (e) {
      debugPrint('[ChatHistoryService] Error loading sessions: $e');
    }
    return [];
  }

  /// Saves the full list of chat sessions atomically to internal storage
  Future<void> saveSessions(List<ChatSession> sessions) async {
    try {
      final file = await _getHistoryFile();
      final tempFile = File('${file.path}.tmp');

      final listJson = sessions.map((s) => s.toJson()).toList();
      final encoded = jsonEncode(listJson);

      await tempFile.writeAsString(encoded, flush: true);
      if (await file.exists()) {
        await file.delete();
      }
      await tempFile.rename(file.path);
    } catch (e) {
      debugPrint('[ChatHistoryService] Error saving sessions: $e');
    }
  }

  /// Clears all stored chat sessions from disk
  Future<void> clearAll() async {
    try {
      final file = await _getHistoryFile();
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('[ChatHistoryService] Error clearing history: $e');
    }
  }
}

