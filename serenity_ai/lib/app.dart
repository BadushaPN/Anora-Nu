import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/theme/app_theme.dart';
import 'core/storage/local_storage_service.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/home/home_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/chat/chat_screen.dart';
import 'features/chat/chat_controller.dart';

class AnoraNuApp extends StatelessWidget {
  const AnoraNuApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Register global controllers
    Get.put(ChatController());

    return GetMaterialApp(
      title: 'Anora Nu',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: LocalStorageService.isOnboarded ? '/chat' : '/onboarding',
      getPages: [
        GetPage(name: '/onboarding', page: () => const OnboardingScreen()),
        GetPage(name: '/main', page: () => const HomeScreen()),
        GetPage(name: '/chat', page: () => ChatScreen()),
        GetPage(name: '/settings', page: () => SettingsScreen()),
      ],
    );
  }
}
