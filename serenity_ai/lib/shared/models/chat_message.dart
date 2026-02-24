class ChatMessage {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.content,
    required this.isUser,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    'id': id,
    'content': content,
    'isUser': isUser,
    'timestamp': timestamp.toIso8601String(),
  };

  factory ChatMessage.fromMap(Map<dynamic, dynamic> map) => ChatMessage(
    id: map['id'] ?? '',
    content: map['content'] ?? '',
    isUser: map['isUser'] ?? true,
    timestamp: DateTime.parse(map['timestamp']),
  );
}
