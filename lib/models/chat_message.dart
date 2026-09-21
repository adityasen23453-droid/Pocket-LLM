class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? imageUrl; // For image attachments or generated images
  final bool isImageGeneration; // Whether this is an AI-generated image response

  const ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.imageUrl,
    this.isImageGeneration = false,
  });
}
