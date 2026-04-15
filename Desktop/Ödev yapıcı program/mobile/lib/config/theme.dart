import 'package:flutter/material.dart';

class AppTheme {
  // Sade ve modern renkler
  static const Color primary = Color(0xFF2563EB); // Mavi
  static const Color secondary = Color(0xFF64748B); // Gri
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Colors.white;
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color border = Color(0xFFE2E8F0);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, Color(0xFF1D4ED8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.light(
      primary: primary,
      secondary: secondary,
      surface: surface,
      error: error,
    ),
    scaffoldBackgroundColor: background,
    appBarTheme: const AppBarTheme(
      backgroundColor: surface,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: textPrimary),
      titleTextStyle: TextStyle(
        color: textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),
    cardTheme: CardTheme(
      color: surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: border, width: 1),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: error),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
  );
}

// Backward compatibility
class AppColors {
  static const Color primary = AppTheme.primary;
  static const Color secondary = AppTheme.secondary;
  static const Color background = AppTheme.background;
  static const Color surface = AppTheme.surface;
  static const Color error = AppTheme.error;
  static const Color success = AppTheme.success;
  static const Color warning = AppTheme.warning;
  static const Color textPrimary = AppTheme.textPrimary;
  static const Color textSecondary = AppTheme.textSecondary;
  static const Color border = AppTheme.border;
  static const LinearGradient primaryGradient = AppTheme.primaryGradient;
}
