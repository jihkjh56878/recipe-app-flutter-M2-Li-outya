import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'core/theme.dart';
import 'screens/onboarding_screen.dart';
import 'screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Fix for SQLite on Windows
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // STABILITY FIX: 
  // 1. Limit image cache to 45MB to prevent memory exhaustion (OOM)
  // 2. Reduce the number of images kept in the 'ready' state
  PaintingBinding.instance.imageCache.maximumSizeBytes = 45 * 1024 * 1024;
  PaintingBinding.instance.imageCache.maximumSize = 50;

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recipe Finder',
      theme: AppTheme.theme,
      debugShowCheckedModeBanner: false,
      // Always show OnboardingScreen first as requested
      home: const OnboardingScreen(),
    );
  }
}
