import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF0F2027);
  static const Color secondaryColor = Color(0xFF2C5364);
  static const Color accentColor = Color(0xFF00BCD4);

  static ThemeData light = ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    fontFamily: 'Vazir',
    primaryColor: primaryColor,
    hintColor: accentColor,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: accentColor,
      surface: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: 'Vazir',
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      systemOverlayStyle: SystemUiOverlayStyle.light,
    ),
    scaffoldBackgroundColor: Colors.white,
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.grey.shade50,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontFamily: 'Vazir', fontWeight: FontWeight.bold),
      titleLarge: TextStyle(fontFamily: 'Vazir', fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(fontFamily: 'Vazir', height: 1.5),
      bodyMedium: TextStyle(fontFamily: 'Vazir', height: 1.4),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );

  static ThemeData dark = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    fontFamily: 'Vazir',
    primaryColor: primaryColor,
    hintColor: accentColor,
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      secondary: accentColor,
      surface: Color(0xFF1E1E2F),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1A1A2E),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: 'Vazir',
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      systemOverlayStyle: SystemUiOverlayStyle.light,
    ),
    scaffoldBackgroundColor: const Color(0xFF121212),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.grey.shade800,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontFamily: 'Vazir', fontWeight: FontWeight.bold),
      titleLarge: TextStyle(fontFamily: 'Vazir', fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(fontFamily: 'Vazir', height: 1.5),
      bodyMedium: TextStyle(fontFamily: 'Vazir', height: 1.4),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}