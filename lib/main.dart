// main.dart
//
// Application entry point.
// Sets up Material 3 theme and routes to OtpScreen.

import 'package:flutter/material.dart';
import 'screens/otp_screen.dart';

void main() {
  runApp(const AmsApp());
}

/// Root application widget.
class AmsApp extends StatelessWidget {
  const AmsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AMS — Faculty Attendance',
      debugShowCheckedModeBanner: false,

      // ── Material 3 Theme ────────────────────────────────────────────────
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      themeMode: ThemeMode.system,

      home: const OtpScreen(),
    );
  }

  /// Builds a Material 3 theme seeded from a professional indigo-blue.
  ThemeData _buildTheme(Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF3F51B5), // Indigo — professional, academic
      brightness: brightness,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,

      // Typography — clean and readable
      textTheme: const TextTheme().apply(
        fontFamily: 'Roboto',
      ),

      // Card theme
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // AppBar theme
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 19,
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurface,
        ),
      ),
    );
  }
}
