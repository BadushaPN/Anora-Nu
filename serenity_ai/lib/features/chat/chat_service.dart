import '../../core/constants/app_constants.dart';
import '../../core/storage/local_storage_service.dart';
import '../../core/services/openai_service.dart';
import '../../core/services/memory_service.dart';
import '../../shared/models/chat_message.dart';
import '../../shared/models/memory.dart';

/// Handles chat conversations with memory-aware system prompts.
class ChatService {
  /// Build the dynamic system prompt with memories + companion age.
  static String _buildSystemPrompt({
    String? userName,
    required List<Memory> memories,
    required int conversationCount,
  }) {
    final buffer = StringBuffer(AppConstants.baseSystemPrompt);

    // Companion age behavior
    buffer.writeln('\n');
    buffer.writeln(MemoryService.getCompanionAge(conversationCount));

    // User name
    if (userName != null && userName.isNotEmpty) {
      buffer.writeln('\nThe user\'s name is $userName.');
    }

    // Inject memories
    buffer.write(MemoryService.buildMemoryContext(memories));

    // Contradiction detection rules
    buffer.write(MemoryService.buildContradictionPrompt(memories));

    return buffer.toString();
  }

  /// Send a message and get AI response.
  static Future<String> sendMessage({
    required List<ChatMessage> history,
    required String userMessage,
    String? userName,
    required List<Memory> memories,
    required int conversationCount,
  }) async {
    final apiKey = LocalStorageService.getApiKey();

    if (apiKey == null || apiKey.isEmpty) {
      return '🔑 Please add your OpenAI API key in Settings to start chatting with me.';
    }

    final systemPrompt = _buildSystemPrompt(
      userName: userName,
      memories: memories,
      conversationCount: conversationCount,
    );

    // Build conversation history (last 20 messages for context)
    final recentHistory = history.length > 20
        ? history.sublist(history.length - 20)
        : history;

    final historyMaps = recentHistory
        .map(
          (msg) => {
            'role': msg.isUser ? 'user' : 'assistant',
            'content': msg.content,
          },
        )
        .toList();

    try {
      final response = await OpenAIService.sendRawMessage(
        apiKey: apiKey,
        systemPrompt: systemPrompt,
        userMessage: userMessage,
        history: historyMaps,
        temperature: 0.8,
        maxTokens: 500,
      );

      return response;
    } on Exception catch (e) {
      final msg = e.toString();
      if (msg.contains('INVALID_API_KEY')) {
        return '🔑 Invalid API key. Please check your OpenAI API key in Settings.';
      } else if (msg.contains('INSUFFICIENT_QUOTA')) {
        return '💳 Insufficient balance. Please add credits to your OpenAI account at platform.openai.com.';
      } else if (msg.contains('RATE_LIMIT')) {
        return '⏳ Too many requests. Please wait a moment and try again.';
      } else {
        return '😔 Something went wrong. Please try again.';
      }
    } catch (e) {
      return '📡 Connection error. Please check your internet and try again.';
    }
  }
}
