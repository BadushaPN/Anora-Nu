/// Represents a piece of knowledge the companion has learned about the user.
/// Extracted automatically from conversations.
class Memory {
  final String id;
  final String type; // goal, emotion, fact, pattern, commitment
  final String content; // What was learned
  final String context; // The conversation context it came from
  final DateTime createdAt;
  DateTime lastReferenced;
  int importance; // 1-10 scale
  bool isActive; // Still relevant?

  Memory({
    required this.id,
    required this.type,
    required this.content,
    this.context = '',
    this.importance = 5,
    this.isActive = true,
    DateTime? createdAt,
    DateTime? lastReferenced,
  }) : createdAt = createdAt ?? DateTime.now(),
       lastReferenced = lastReferenced ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    'id': id,
    'type': type,
    'content': content,
    'context': context,
    'createdAt': createdAt.toIso8601String(),
    'lastReferenced': lastReferenced.toIso8601String(),
    'importance': importance,
    'isActive': isActive,
  };

  factory Memory.fromMap(Map<dynamic, dynamic> map) => Memory(
    id: map['id'] ?? '',
    type: map['type'] ?? 'fact',
    content: map['content'] ?? '',
    context: map['context'] ?? '',
    importance: map['importance'] ?? 5,
    isActive: map['isActive'] ?? true,
    createdAt: DateTime.parse(map['createdAt']),
    lastReferenced: DateTime.parse(map['lastReferenced']),
  );

  String get typeEmoji {
    switch (type) {
      case 'goal':
        return '🎯';
      case 'emotion':
        return '💭';
      case 'fact':
        return '📌';
      case 'pattern':
        return '🔄';
      case 'commitment':
        return '🤝';
      default:
        return '💡';
    }
  }

  String get typeLabel {
    switch (type) {
      case 'goal':
        return 'Goal';
      case 'emotion':
        return 'Emotion';
      case 'fact':
        return 'About You';
      case 'pattern':
        return 'Pattern';
      case 'commitment':
        return 'Commitment';
      default:
        return 'Memory';
    }
  }

  /// How many days ago this memory was created
  int get daysAgo => DateTime.now().difference(createdAt).inDays;

  String get timeAgoLabel {
    final days = daysAgo;
    if (days == 0) return 'Today';
    if (days == 1) return 'Yesterday';
    if (days < 7) return '$days days ago';
    if (days < 30) return '${(days / 7).floor()} weeks ago';
    if (days < 365) return '${(days / 30).floor()} months ago';
    return '${(days / 365).floor()} years ago';
  }
}
