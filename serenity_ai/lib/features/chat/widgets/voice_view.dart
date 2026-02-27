import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../chat_controller.dart';

class VoiceView extends StatelessWidget {
  const VoiceView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ChatController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // Top Bar
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      controller.stopSpeaking();
                      Get.toNamed('/main');
                    },
                    icon: const Icon(Icons.dashboard_outlined),
                    color: AppColors.textSecondary,
                    tooltip: 'Dashboard',
                  ),
                  IconButton(
                    onPressed: () => Get.toNamed('/settings'),
                    icon: const Icon(Icons.settings_outlined),
                    color: AppColors.textSecondary,
                    tooltip: 'Settings',
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 80),
                  // Companion Identity
                  Obx(
                    () => Column(
                      children: [
                        Text(
                          'Anora Nu',
                          style: Theme.of(context).textTheme.displayLarge
                              ?.copyWith(fontSize: 32, letterSpacing: -0.5),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          controller.isListening.value
                              ? 'Listening...'
                              : (controller.isLoading.value
                                    ? 'Thinking...'
                                    : 'Tap to speak'),
                          style: TextStyle(
                            color: controller.isListening.value
                                ? AppColors.primary
                                : AppColors.textSecondary,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Transcription / Last words
                  Obx(
                    () => Container(
                      height: 120,
                      alignment: Alignment.center,
                      child: Text(
                        controller.lastWords.value.isEmpty &&
                                !controller.isListening.value
                            ? (controller.messages.isNotEmpty &&
                                      !controller.messages.last.isUser
                                  ? controller.messages.last.content
                                  : '')
                            : controller.lastWords.value,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textPrimary.withValues(alpha: 0.8),
                          fontSize: 18,
                          height: 1.5,
                          fontStyle: controller.isListening.value
                              ? FontStyle.normal
                              : FontStyle.italic,
                        ),
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Visualizer / Pulse
                  Center(
                    child: Obx(
                      () => GestureDetector(
                        onTap: () {
                          if (controller.isListening.value) {
                            controller.stopListening();
                          } else {
                            controller.startListening();
                          }
                        },
                        child: _VoiceVisualizer(
                          isListening: controller.isListening.value,
                          isThinking: controller.isLoading.value,
                          isSpeaking: controller.isSpeaking.value,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 60),

                  // Switch to Chat Button
                  TextButton.icon(
                    onPressed: () {
                      controller.stopSpeaking();
                      controller.isVoiceMode.value = false;
                    },
                    icon: const Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 20,
                    ),
                    label: const Text('Switch to Chat'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VoiceVisualizer extends StatefulWidget {
  final bool isListening;
  final bool isThinking;
  final bool isSpeaking;

  const _VoiceVisualizer({
    required this.isListening,
    required this.isThinking,
    required this.isSpeaking,
  });

  @override
  State<_VoiceVisualizer> createState() => _VoiceVisualizerState();
}

class _VoiceVisualizerState extends State<_VoiceVisualizer>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotateController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseController, _rotateController]),
      builder: (context, child) {
        double scale = 1.0;
        if (widget.isListening) {
          scale = 1.0 + (_pulseController.value * 0.2);
        } else if (widget.isThinking) {
          scale = 1.0 + (_pulseController.value * 0.05);
        }

        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer glow / rings
            if (widget.isListening || widget.isSpeaking)
              ...List.generate(3, (index) {
                final double delay = index * 0.2;
                final double ringValue = (_pulseController.value + delay) % 1.0;
                return Container(
                  width: 120 + (ringValue * 100),
                  height: 120 + (ringValue * 100),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary.withValues(
                        alpha: (1.0 - ringValue) * 0.3,
                      ),
                      width: 2,
                    ),
                  ),
                );
              }),

            // Main Sphere
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withValues(alpha: 0.8),
                    AppColors.surfaceLight,
                  ],
                  stops: const [0.0, 0.6, 1.0],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Transform.scale(
                scale: scale,
                child: Center(
                  child: Icon(
                    widget.isThinking
                        ? Icons.auto_awesome_rounded
                        : (widget.isListening
                              ? Icons.mic_rounded
                              : Icons.mic_none_rounded),
                    color: Colors.white,
                    size: 48,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
