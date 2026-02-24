import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';

/// Low-level OpenAI API wrapper.
/// Used by ChatService for conversations and MemoryService for extraction.
class OpenAIService {
  /// Send a raw message to OpenAI and get the text response.
  static Future<String> sendRawMessage({
    required String apiKey,
    required String systemPrompt,
    required String userMessage,
    List<Map<String, String>>? history,
    double temperature = 0.7,
    int maxTokens = 500,
  }) async {
    final messages = <Map<String, String>>[
      {'role': 'system', 'content': systemPrompt},
    ];

    // Add conversation history if provided
    if (history != null) {
      messages.addAll(history);
    }

    messages.add({'role': 'user', 'content': userMessage});

    final response = await http.post(
      Uri.parse(AppConstants.openAiBaseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': AppConstants.defaultModel,
        'messages': messages,
        'temperature': temperature,
        'max_tokens': maxTokens,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'].toString().trim();
    } else if (response.statusCode == 401) {
      throw Exception('INVALID_API_KEY');
    } else if (response.statusCode == 429) {
      throw Exception('RATE_LIMIT');
    } else {
      throw Exception('API_ERROR_${response.statusCode}');
    }
  }
}
