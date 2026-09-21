import 'chat_message.dart';

class ChatSession {
  final String id;
  String title;
  final List<ChatMessage> messages;
  DateTime lastModified;

  ChatSession({
    required this.id,
    required this.title,
    List<ChatMessage>? messages,
    DateTime? lastModified,
  })  : messages = messages ?? [],
        lastModified = lastModified ?? DateTime.now();
}
