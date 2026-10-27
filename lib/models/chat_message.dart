class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? imageUrl; // For image attachments or generated images
  final bool isImageGeneration; // Whether this is an AI-generated image response
  final List<String>? sources; // RAG document citations
  final String? attachedFileName; // Uploaded PDF/notes name
  final int? attachedFileChunks; // Chunks indexed for the document

  const ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.imageUrl,
    this.isImageGeneration = false,
    this.sources,
    this.attachedFileName,
    this.attachedFileChunks,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'isUser': isUser,
        'timestamp': timestamp.toIso8601String(),
        'imageUrl': imageUrl,
        'isImageGeneration': isImageGeneration,
        'sources': sources,
        'attachedFileName': attachedFileName,
        'attachedFileChunks': attachedFileChunks,
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: json['id'] as String? ?? 'msg_${DateTime.now().millisecondsSinceEpoch}',
        text: json['text'] as String? ?? '',
        isUser: json['isUser'] as bool? ?? false,
        timestamp: json['timestamp'] != null
            ? DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now()
            : DateTime.now(),
        imageUrl: json['imageUrl'] as String?,
        isImageGeneration: json['isImageGeneration'] as bool? ?? false,
        sources: (json['sources'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
        attachedFileName: json['attachedFileName'] as String?,
        attachedFileChunks: json['attachedFileChunks'] as int?,
      );
}
