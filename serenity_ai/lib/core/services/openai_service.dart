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
    final contents = <Map<String, dynamic>>[];

    // Add conversation history if provided
    if (history != null) {
      for (final msg in history) {
        final role = msg['role'] == 'user' ? 'user' : 'model';
        contents.add({
          'role': role,
          'parts': [{'text': msg['content']}]
        });
      }
    }

    contents.add({
      'role': 'user',
      'parts': [{'text': userMessage}]
    });

    final url = 'https://generativelanguage.googleapis.com/v1beta/models/${AppConstants.defaultModel}:generateContent?key=$apiKey';

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'system_instruction': {
          'parts': {'text': systemPrompt}
        },
        'contents': contents,
        'generationConfig': {
          'temperature': temperature,
          'maxOutputTokens': maxTokens,
        }
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final candidates = data['candidates'] as List?;
      if (candidates != null && candidates.isNotEmpty) {
        final parts = candidates[0]['content']?['parts'] as List?;
        if (parts != null && parts.isNotEmpty) {
          return parts[0]['text'].toString().trim();
        }
      }
      return '';
    } else {
      dynamic errorData;
      try {
        errorData = jsonDecode(response.body);
        if (errorData is List && errorData.isNotEmpty) {
          errorData = errorData.first;
        }
      } catch (e) {
        // Ignored
      }
      
      dynamic errorMessage;
      dynamic errorCode;
      if (errorData is Map) {
        final err = errorData['error'];
        if (err is Map) {
          errorCode = err['code'];
          errorMessage = err['message'];
        }
      }

      if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception(errorMessage ?? 'INVALID_API_KEY');
      } else if (response.statusCode == 429) {
        if (errorCode == 'insufficient_quota') {
          throw Exception('INSUFFICIENT_QUOTA');
        }
        throw Exception('RATE_LIMIT');
      } else {
        throw Exception(errorMessage ?? 'API_ERROR_${response.statusCode}');
      }
    }
  }
}
