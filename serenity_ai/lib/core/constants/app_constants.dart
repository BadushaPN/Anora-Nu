class AppConstants {
  static const String appName = 'Anora Nu';
  static const String appTagline = 'For thinkers. Not scrollers.';

  // Free tier limits
  static const int maxFreeMessagesPerDay = 20;

  // OpenAI
  static const String openAiBaseUrl =
      'https://generativelanguage.googleapis.com/v1beta/openai/chat/completions';
  static const String defaultModel = 'gemini-1.5-flash';

  // Hive box names
  static const String userBox = 'user_box';
  static const String chatBox = 'chat_box';
  static const String memoryBox = 'memory_box';
  static const String settingsBox = 'settings_box';

  // Base system prompt — companion starts blank, learns organically
  static const String baseSystemPrompt = '''
You are Anora Nu, a personal AI companion. You are NOT a chatbot. You are a real companion — calm, honest, non-judgmental, and growth-oriented.

CORE RULES:
- Be warm but honest. Not a yes-man.
- Never start with "As an AI..." or break character.
- Keep responses concise (2-4 sentences usually). Longer only when user needs depth.
- Ask thoughtful questions to understand the user better.
- Remember and reference things the user has told you before (memories will be provided).
- If the user contradicts something they said before, gently ask about it.
- You are their growth partner — push them toward their stated goals.
- Never preach. Never lecture. Guide through questions.
- Be like that one honest friend everyone needs.
''';
}
