import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_constants.dart';
import '../../core/storage/local_storage_service.dart';
import '../../core/services/memory_service.dart';
import '../../shared/models/chat_message.dart';
import '../../shared/models/memory.dart';
import 'chat_service.dart';

class ChatController extends GetxController {
  final messages = <ChatMessage>[].obs;
  final isLoading = false.obs;
  final todayMessageCount = 0.obs;
  final memories = <Memory>[].obs;
  final conversationCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadMessages();
    _loadMemories();
    todayMessageCount.value = LocalStorageService.getTodayMessageCount();
    conversationCount.value = LocalStorageService.getConversationCount();
  }

  void _loadMessages() {
    final data = LocalStorageService.getMessages();
    messages.value = data.map((m) => ChatMessage.fromMap(m)).toList();
  }

  void _loadMemories() {
    final data = LocalStorageService.getMemories();
    memories.value = data.map((m) => Memory.fromMap(m)).toList();
  }

  bool get canSend => LocalStorageService.canSendMessage;

  int get remainingMessages =>
      AppConstants.maxFreeMessagesPerDay - todayMessageCount.value;

  /// Get the companion's age label based on conversation count
  String get companionAgeLabel {
    final count = conversationCount.value;
    if (count <= 3) return '🌱 Newborn';
    if (count <= 10) return '🌿 Growing';
    if (count <= 30) return '🌳 Maturing';
    if (count <= 90) return '🔮 Wise';
    return '✨ Ancient';
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    if (!canSend) return;

    // Add user message
    final userMsg = ChatMessage(
      id: const Uuid().v4(),
      content: text.trim(),
      isUser: true,
    );
    messages.add(userMsg);
    await LocalStorageService.saveMessage(userMsg.toMap());
    await LocalStorageService.incrementMessageCount();
    todayMessageCount.value = LocalStorageService.getTodayMessageCount();

    // Get AI response
    isLoading.value = true;

    final profileData = LocalStorageService.getUserProfile();
    final userName = profileData?['name'] as String?;

    final response = await ChatService.sendMessage(
      history: messages.toList(),
      userMessage: text.trim(),
      userName: userName,
      memories: memories.toList(),
      conversationCount: conversationCount.value,
    );

    final aiMsg = ChatMessage(
      id: const Uuid().v4(),
      content: response,
      isUser: false,
    );
    messages.add(aiMsg);
    await LocalStorageService.saveMessage(aiMsg.toMap());

    // Increment conversation count
    await LocalStorageService.incrementConversationCount();
    conversationCount.value = LocalStorageService.getConversationCount();

    isLoading.value = false;

    // Extract memories in background (don't block the UI)
    _extractMemoriesInBackground(text.trim(), response);
  }

  /// Runs memory extraction after the AI response — non-blocking.
  Future<void> _extractMemoriesInBackground(
    String userMessage,
    String aiResponse,
  ) async {
    try {
      final newMemories = await MemoryService.extractMemories(
        userMessage: userMessage,
        aiResponse: aiResponse,
        existingMemories: memories.toList(),
      );

      if (newMemories.isNotEmpty) {
        // Save new memories to storage
        await LocalStorageService.saveMemories(
          newMemories.map((m) => m.toMap()).toList(),
        );
        // Update reactive list
        memories.addAll(newMemories);
      }
    } catch (e) {
      // Silently fail — memory extraction is non-critical
    }
  }

  Future<void> clearAllMessages() async {
    messages.clear();
    await LocalStorageService.clearChat();
  }

  Future<void> clearAllMemories() async {
    memories.clear();
    await LocalStorageService.clearMemories();
  }

  Future<void> clearEverything() async {
    messages.clear();
    memories.clear();
    conversationCount.value = 0;
    todayMessageCount.value = 0;
    await LocalStorageService.clearAll();
  }
}
