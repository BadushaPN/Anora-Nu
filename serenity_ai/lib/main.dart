import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/storage/local_storage_service.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style for immersive dark theme
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF161628),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize local storage
  await LocalStorageService.init();

  runApp(const SerenityApp());
}
