import 'package:hive_flutter/hive_flutter.dart';
import '../constants/app_constants.dart';

class LocalStorageService {
  static late Box _userBox;
  static late Box _chatBox;
  static late Box _memoryBox;
  static late Box _settingsBox;

  static Future<void> init() async {
    await Hive.initFlutter();
    _userBox = await Hive.openBox(AppConstants.userBox);
    _chatBox = await Hive.openBox(AppConstants.chatBox);
    _memoryBox = await Hive.openBox(AppConstants.memoryBox);
    _settingsBox = await Hive.openBox(AppConstants.settingsBox);
  }

  // ── User Profile ──────────────────────────────────────
  static Future<void> saveUserProfile(Map<String, dynamic> profile) async {
    await _userBox.put('profile', profile);
  }

  static Map<dynamic, dynamic>? getUserProfile() {
    return _userBox.get('profile');
  }

  static bool get isOnboarded => _userBox.containsKey('profile');

  // ── Chat Messages ─────────────────────────────────────
  static Future<void> saveMessage(Map<String, dynamic> message) async {
    final messages = getMessages();
    messages.add(message);
    await _chatBox.put('messages', messages);
  }

  static List<Map<dynamic, dynamic>> getMessages() {
    final data = _chatBox.get('messages');
    if (data == null) return [];
    return List<Map<dynamic, dynamic>>.from(data);
  }

  static Future<void> clearChat() async {
    await _chatBox.put('messages', []);
  }

  // ── Conversation Count (for companion age) ────────────
  static int getConversationCount() {
    return _chatBox.get('conversation_count', defaultValue: 0);
  }

  static Future<void> incrementConversationCount() async {
    final count = getConversationCount();
    await _chatBox.put('conversation_count', count + 1);
  }

  // ── Daily Message Count ───────────────────────────────
  static int getTodayMessageCount() {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    return _chatBox.get('count_$today', defaultValue: 0);
  }

  static Future<void> incrementMessageCount() async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final count = getTodayMessageCount();
    await _chatBox.put('count_$today', count + 1);
  }

  static bool get canSendMessage =>
      getTodayMessageCount() < AppConstants.maxFreeMessagesPerDay;

  // ── Memories ──────────────────────────────────────────
  static Future<void> saveMemory(Map<String, dynamic> memory) async {
    await _memoryBox.put(memory['id'], memory);
  }

  static Future<void> saveMemories(List<Map<String, dynamic>> memories) async {
    for (final m in memories) {
      await _memoryBox.put(m['id'], m);
    }
  }

  static List<Map<dynamic, dynamic>> getMemories() {
    return _memoryBox.values.map((e) => Map<dynamic, dynamic>.from(e)).toList();
  }

  static Future<void> deleteMemory(String id) async {
    await _memoryBox.delete(id);
  }

  static Future<void> clearMemories() async {
    await _memoryBox.clear();
  }

  // ── Settings ──────────────────────────────────────────
  static Future<void> saveApiKey(String key) async {
    await _settingsBox.put('openai_api_key', key);
  }

  static String? getApiKey() {
    return _settingsBox.get('openai_api_key');
  }

  // ── Permissions ───────────────────────────────────────
  static bool get hasPromptedForMic =>
      _settingsBox.get('has_prompted_for_mic', defaultValue: false);

  static Future<void> markMicPrompted() async {
    await _settingsBox.put('has_prompted_for_mic', true);
  }

  // ── Full Reset ────────────────────────────────────────
  static Future<void> clearAll() async {
    await _userBox.clear();
    await _chatBox.clear();
    await _memoryBox.clear();
  }
}
