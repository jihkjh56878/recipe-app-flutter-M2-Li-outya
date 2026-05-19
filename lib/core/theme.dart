import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFFFF6B35);
  static const Color secondary = Color(0xFF2EC4B6);
  static const Color background = Color(0xFFFAFAFA);
  static const Color cardLight = Color(0xFFF5F5F0); // Light beige/cream for cards
  static const Color textDark = Color(0xFF1A1A2E);
  static const Color textGrey = Color(0xFF6C757D);

  static ThemeData get theme => ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          primary: primary,
          secondary: secondary,
          surface: background,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: background,
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: background,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: textDark,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: textDark),
        ),
      );
}
