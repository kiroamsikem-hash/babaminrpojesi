import 'package:flutter/material.dart';

/// Application Color Palette
class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFFFFD700); // Gold
  static const Color secondary = Color(0xFFD4A574); // Light Gold
  
  // Background Colors
  static const Color background = Color(0xFF0F172A); // Dark Blue
  static const Color surface = Color(0xFF1E293B); // Lighter Dark Blue
  static const Color surfaceVariant = Color(0xFF334155); // Even Lighter
  
  // Text Colors
  static const Color textPrimary = Color(0xFFF1F5F9); // Almost White
  static const Color textSecondary = Color(0xFFCBD5E1); // Light Gray
  static const Color textTertiary = Color(0xFF94A3B8); // Medium Gray
  
  // Border & Divider
  static const Color border = Color(0xFF334155);
  static const Color divider = Color(0xFF1E293B);
  
  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
  
  // Civilization Colors
  static const Map<String, Color> civilizationColors = {
    'Minoan': Color(0xFFFFD700), // Gold
    'Hitit': Color(0xFFDC143C), // Crimson
    'Miken': Color(0xFF4169E1), // Royal Blue
    'Mezopotamya': Color(0xFF8B4513), // Saddle Brown
    'Yunan': Color(0xFF00CED1), // Dark Turquoise
    'Batı Anadolu': Color(0xFF9370DB), // Medium Purple
  };
  
  /// Get civilization color
  static Color getCivilizationColor(String name) {
    return civilizationColors[name] ?? textSecondary;
  }
  
  /// Get period color
  static Color getPeriodColor(String period) {
    switch (period) {
      case 'Tunç Çağı':
        return const Color(0xFFCD7F32);
      case 'Demir Çağı':
        return const Color(0xFF708090);
      case 'Erken Dönem':
        return const Color(0xFF8B7355);
      default:
        return textSecondary;
    }
  }
}
