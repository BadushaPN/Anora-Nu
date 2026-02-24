import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/storage/local_storage_service.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/glass_card.dart';

class SettingsScreen extends StatelessWidget {
  SettingsScreen({super.key});

  final _apiKeyController = TextEditingController(
    text: LocalStorageService.getApiKey() ?? '',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // API Key
            Text(
              'OpenAI API Key',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Required for AI conversations. Your key stays on this device only.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _apiKeyController,
              obscureText: true,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'sk-...',
                suffixIcon: IconButton(
                  icon: const Icon(
                    Icons.save_rounded,
                    color: AppColors.primary,
                  ),
                  onPressed: () async {
                    await LocalStorageService.saveApiKey(
                      _apiKeyController.text.trim(),
                    );
                    Get.snackbar(
                      'Saved',
                      'API key stored securely on your device.',
                      backgroundColor: AppColors.moodHappy.withValues(
                        alpha: 0.2,
                      ),
                      colorText: AppColors.moodHappy,
                      snackPosition: SnackPosition.BOTTOM,
                      margin: const EdgeInsets.all(16),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 32),

            // About
            Text('About', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('🔮', style: TextStyle(fontSize: 24)),
                      const SizedBox(width: 12),
                      Text(
                        'Anora Nu',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'For thinkers. Not scrollers.\n\n'
                    'A private AI companion focused on emotional support, '
                    'personal growth, and meaningful conversations.\n\n'
                    'Your data never leaves your device.',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(height: 1.6),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Version 1.0.0 (MVP)',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Danger zone
            Text('Data', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            GlassCard(
              onTap: () {
                Get.defaultDialog(
                  title: 'Clear Chat History',
                  titleStyle: const TextStyle(color: AppColors.textPrimary),
                  middleText:
                      'This will delete all your chat messages. This cannot be undone.',
                  middleTextStyle: const TextStyle(
                    color: AppColors.textSecondary,
                  ),
                  backgroundColor: AppColors.surface,
                  confirm: ElevatedButton(
                    onPressed: () async {
                      await LocalStorageService.clearChat();
                      Get.back();
                      Get.snackbar(
                        'Cleared',
                        'Chat history has been deleted.',
                        backgroundColor: AppColors.accent.withValues(
                          alpha: 0.2,
                        ),
                        colorText: AppColors.accent,
                        snackPosition: SnackPosition.BOTTOM,
                        margin: const EdgeInsets.all(16),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                    ),
                    child: const Text('Clear'),
                  ),
                  cancel: TextButton(
                    onPressed: () => Get.back(),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                );
              },
              borderColor: AppColors.accent.withValues(alpha: 0.2),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Icon(Icons.delete_rounded, color: AppColors.accent, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    'Clear Chat History',
                    style: TextStyle(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
