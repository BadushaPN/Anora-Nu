import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
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

  // Voice related
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();

  final isListening = false.obs;
  final lastWords = ''.obs;
  final isSpeechAvailable = false.obs;
  final isSpeaking = false.obs;
  final isVoiceMode = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadMessages();
    _loadMemories();
    _initVoice();
    todayMessageCount.value = LocalStorageService.getTodayMessageCount();
    conversationCount.value = LocalStorageService.getConversationCount();

    // Check for microphone permission on first launch
    if (!LocalStorageService.hasPromptedForMic) {
      _checkMicrophonePermission();
    }
  }

  Future<void> _checkMicrophonePermission() async {
    final status = await Permission.microphone.status;
    if (status.isDenied) {
      // Re-request
      final result = await Permission.microphone.request();
      if (result.isDenied || result.isPermanentlyDenied) {
        _handleMicDenial(result.isPermanentlyDenied);
      }
      await LocalStorageService.markMicPrompted();
    } else if (status.isGranted) {
      await LocalStorageService.markMicPrompted();
    }
  }

  void _handleMicDenial(bool permanentlyDenied) {
    Get.snackbar(
      'Microphone Access Required',
      permanentlyDenied
          ? 'Microphone access is permanently denied. Please enable it in settings to use voice features.'
          : 'Microphone access is needed for voice mode. You can still use text chat.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 5),
      mainButton: permanentlyDenied
          ? TextButton(
              onPressed: () => openAppSettings(),
              child: const Text('Settings'),
            )
          : null,
    );
  }

  Future<void> _initVoice() async {
    try {
      isSpeechAvailable.value = await _speech.initialize(
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            isListening.value = false;
          }
        },
        onError: (error) {
          isListening.value = false;
        },
      );

      await _tts.setLanguage("en-US");
      await _tts.setPitch(1.0);
      await _tts.setSpeechRate(0.5);

      _tts.setStartHandler(() => isSpeaking.value = true);
      _tts.setCompletionHandler(() => isSpeaking.value = false);
      _tts.setErrorHandler((msg) => isSpeaking.value = false);
    } catch (e) {
      isSpeechAvailable.value = false;
    }
  }

  Future<void> startListening() async {
    final status = await Permission.microphone.request();
    if (status.isGranted) {
      if (isSpeechAvailable.value) {
        lastWords.value = '';
        isListening.value = true;
        await _speech.listen(
          onResult: (result) {
            lastWords.value = result.recognizedWords;
            if (result.finalResult) {
              isListening.value = false;
              sendMessage(result.recognizedWords, fromVoice: true);
            }
          },
        );
      }
    }
  }

  Future<void> stopListening() async {
    await _speech.stop();
    isListening.value = false;
  }

  Future<void> speak(String text) async {
    if (text.isEmpty) return;
    await _tts.speak(text);
  }

  Future<void> stopSpeaking() async {
    await _tts.stop();
    isSpeaking.value = false;
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

  Future<void> sendMessage(String text, {bool fromVoice = false}) async {
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

    // Speak response
    speak(response);

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
