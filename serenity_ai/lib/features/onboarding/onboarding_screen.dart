import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/storage/local_storage_service.dart';
import '../../core/theme/app_theme.dart';

class OnboardingController extends GetxController {
  final nameController = TextEditingController();

  Future<void> complete() async {
    final name = nameController.text.trim().isEmpty
        ? 'Friend'
        : nameController.text.trim();

    await LocalStorageService.saveUserProfile({'name': name});
  }

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }
}

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OnboardingController());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: Text('🔮', style: TextStyle(fontSize: 32)),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Hello.\nI\'m Serenity.',
                style: Theme.of(
                  context,
                ).textTheme.displayLarge?.copyWith(height: 1.2),
              ),
              const SizedBox(height: 12),
              Text(
                'I don\'t know anything about you yet.\nBut I\'d like to learn.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 48),
              TextField(
                controller: controller.nameController,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                ),
                decoration: const InputDecoration(
                  hintText: 'What should I call you?',
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await controller.complete();
                    Get.offAllNamed('/main');
                  },
                  child: const Text('Let\'s begin'),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'The more we talk, the more I\'ll understand you.',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
