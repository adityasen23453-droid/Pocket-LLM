import 'chat_message.dart';

class ChatSession {
  final String id;
  String title;
  final List<ChatMessage> messages;
  DateTime lastModified;
  List<String> activeDocuments;

  String? get activeDocument => activeDocuments.isNotEmpty ? activeDocuments.last : null;
  set activeDocument(String? doc) {
    if (doc != null && doc.isNotEmpty) {
      if (!activeDocuments.contains(doc)) {
        activeDocuments.add(doc);
      }
    } else {
      activeDocuments.clear();
    }
  }

  ChatSession({
    required this.id,
    required this.title,
    List<ChatMessage>? messages,
    DateTime? lastModified,
    String? activeDocument,
    List<String>? activeDocuments,
  })  : messages = messages ?? [],
        lastModified = lastModified ?? DateTime.now(),
        activeDocuments = activeDocuments ?? (activeDocument != null ? [activeDocument] : []);

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'messages': messages.map((m) => m.toJson()).toList(),
        'lastModified': lastModified.toIso8601String(),
        'activeDocuments': activeDocuments,
      };

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    final docs = <String>[];
    if (json['activeDocuments'] is List) {
      docs.addAll((json['activeDocuments'] as List).map((e) => e.toString()));
    } else if (json['activeDocument'] is String) {
      docs.add(json['activeDocument'] as String);
    }

    return ChatSession(
      id: json['id'] as String? ?? 'session_${DateTime.now().millisecondsSinceEpoch}',
      title: json['title'] as String? ?? 'New Chat',
      messages: (json['messages'] as List<dynamic>?)
              ?.map((m) => ChatMessage.fromJson(m as Map<String, dynamic>))
              .toList() ??
          [],
      lastModified: json['lastModified'] != null
          ? DateTime.tryParse(json['lastModified'] as String) ?? DateTime.now()
          : DateTime.now(),
      activeDocuments: docs,
    );
  }
}
