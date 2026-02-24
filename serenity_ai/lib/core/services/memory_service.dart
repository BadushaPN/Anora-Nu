import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../../shared/models/memory.dart';
import '../../shared/models/chat_message.dart';
import '../storage/local_storage_service.dart';
import 'openai_service.dart';

/// Extracts and manages memories from conversations.
/// This is the brain of Serenity — it learns from every conversation.
class MemoryService {
  /// Extract memories from a conversation exchange.
  /// Called after each AI response to analyze what was said.
  static Future<List<Memory>> extractMemories({
    required String userMessage,
    required String aiResponse,
    required List<Memory> existingMemories,
  }) async {
    final apiKey = LocalStorageService.getApiKey();
    if (apiKey == null || apiKey.isEmpty) return [];

    // Build extraction prompt
    final existingMemorySummary = existingMemories.isEmpty
        ? 'No existing memories yet.'
        : existingMemories
              .map(
                (m) =>
                    '- [${m.type.toUpperCase()}] (${m.timeAgoLabel}): ${m.content}',
              )
              .join('\n');

    final extractionPrompt =
        '''
Analyze this conversation exchange and extract any important information the user revealed.

EXISTING MEMORIES (what you already know):
$existingMemorySummary

USER SAID: "$userMessage"
AI RESPONDED: "$aiResponse"

Extract NEW information only (don't repeat existing memories). For each piece of information, classify it as:
- "goal": Something the user wants to achieve (e.g., "I want to move to Bangalore", "I want financial freedom")
- "emotion": An emotional state or feeling (e.g., "I moved on from my ex", "I feel lonely")
- "fact": A personal fact (e.g., "I'm a developer", "I live alone")
- "pattern": A behavioral pattern you notice (e.g., "User changes goals frequently")
- "commitment": A specific promise to do something (e.g., "I'll study 2 hours daily")

IMPORTANT: Also check if the user is CONTRADICTING any existing memory. If so, create a "pattern" memory noting the contradiction.

Respond ONLY with a JSON array. If nothing new to extract, respond with [].
Example: [{"type": "goal", "content": "Wants to build a startup", "importance": 8}, {"type": "emotion", "content": "Feeling motivated about career", "importance": 5}]

JSON array only, no other text:''';

    try {
      final response = await OpenAIService.sendRawMessage(
        apiKey: apiKey,
        systemPrompt:
            'You are a memory extraction system. Output ONLY valid JSON arrays. No explanations.',
        userMessage: extractionPrompt,
      );

      // Parse the JSON response
      final cleaned = response.trim();
      final List<dynamic> parsed = jsonDecode(cleaned);

      final uuid = const Uuid();
      return parsed.map((item) {
        return Memory(
          id: uuid.v4(),
          type: item['type'] ?? 'fact',
          content: item['content'] ?? '',
          context: userMessage,
          importance: item['importance'] ?? 5,
        );
      }).toList();
    } catch (e) {
      // If extraction fails, silently continue — don't break the chat
      return [];
    }
  }

  /// Build memory context string to inject into the AI system prompt.
  /// Groups memories by type and includes time context.
  static String buildMemoryContext(List<Memory> memories) {
    if (memories.isEmpty) return '';

    final grouped = <String, List<Memory>>{};
    for (final m in memories) {
      grouped.putIfAbsent(m.type, () => []).add(m);
    }

    final buffer = StringBuffer();
    buffer.writeln(
      '\n--- WHAT YOU KNOW ABOUT THIS USER (from past conversations) ---',
    );

    final typeOrder = ['goal', 'commitment', 'emotion', 'fact', 'pattern'];
    for (final type in typeOrder) {
      final items = grouped[type];
      if (items == null || items.isEmpty) continue;

      buffer.writeln('\n${items.first.typeEmoji} ${items.first.typeLabel}s:');
      for (final m in items) {
        buffer.writeln('  - "${m.content}" (${m.timeAgoLabel})');
      }
    }

    buffer.writeln('\n--- END OF MEMORIES ---');
    return buffer.toString();
  }

  /// Build contradiction detection instructions based on existing memories.
  static String buildContradictionPrompt(List<Memory> memories) {
    if (memories.isEmpty) return '';

    final goals = memories
        .where((m) => m.type == 'goal' && m.isActive)
        .toList();
    final emotions = memories.where((m) => m.type == 'emotion').toList();
    final commitments = memories
        .where((m) => m.type == 'commitment' && m.isActive)
        .toList();

    if (goals.isEmpty && emotions.isEmpty && commitments.isEmpty) return '';

    final buffer = StringBuffer();
    buffer.writeln('\n--- CONTRADICTION DETECTION RULES ---');
    buffer.writeln(
      'If the user says something that contradicts these past statements, gently ask about it:',
    );

    for (final m in [...goals, ...emotions, ...commitments]) {
      buffer.writeln(
        '- ${m.timeAgoLabel} they said: "${m.content}" → If they now say the opposite, ask what changed.',
      );
    }

    buffer.writeln(
      '\nBe gentle but honest. Don\'t be a yes-man. You are their growth partner.',
    );
    buffer.writeln(
      'If they set a new goal that conflicts with an old one, ask why before accepting the change.',
    );
    buffer.writeln('--- END RULES ---');

    return buffer.toString();
  }

  /// Get companion age description based on conversation count.
  static String getCompanionAge(int conversationCount) {
    if (conversationCount <= 3) {
      return 'You are brand new — you just met this person. Be curious, listen more, talk less. Ask open-ended questions to learn about them.';
    } else if (conversationCount <= 10) {
      return 'You\'ve been talking for a few days. You\'re starting to understand them. Still mostly listening, but you can reference things they\'ve told you before.';
    } else if (conversationCount <= 30) {
      return 'You know this person fairly well now. You can challenge them gently, reference past conversations, and hold them accountable to their goals.';
    } else if (conversationCount <= 90) {
      return 'You\'re a trusted companion now. You understand their patterns, their dreams, their struggles. Be honest, direct, and supportive. Challenge them when they\'re avoiding growth.';
    } else {
      return 'You\'ve been with this person for a long time. You know them deeply. You can be direct, challenge contradictions firmly but lovingly, and push them toward their stated goals.';
    }
  }
}
