import 'package:flutter/material.dart';

// 🎨 MINIMALIST & SADE - Temiz Renkler
class QuietTechColors {
  // PRIMARY - Sade Mavi
  static const primary = Color(0xFF2563EB);        // Parlak mavi
  static const primaryLight = Color(0xFF60A5FA);   
  static const primaryDark = Color(0xFF1E40AF);    
  
  // SUCCESS - Sade Yeşil
  static const success = Color(0xFF10B981);
  
  // NEUTRAL - Çok Sade
  static const background = Color(0xFFFAFAFA);     // Neredeyse beyaz
  static const surface = Color(0xFFFFFFFF);        // Tam beyaz
  static const border = Color(0xFFE5E7EB);         // Açık gri
  
  // TEXT - Basit
  static const textPrimary = Color(0xFF1F2937);
  static const textSecondary = Color(0xFF6B7280);
  static const textTertiary = Color(0xFF9CA3AF);
  
  // DARK MODE
  static const darkBackground = Color(0xFF111827);
  static const darkSurface = Color(0xFF1F2937);
  static const darkBorder = Color(0xFF374151);
  static const darkText = Color(0xFFF9FAFB);
  
  // CARD COLORS - Sade Tonlar (gradient yok!)
  static const cardBlue = Color(0xFF3B82F6);
  static const cardGreen = Color(0xFF10B981);
  static const cardOrange = Color(0xFFF59E0B);
  static const cardPurple = Color(0xFF8B5CF6);
  static const cardPink = Color(0xFFEC4899);
  static const cardTeal = Color(0xFF14B8A6);
  static const cardRed = Color(0xFFEF4444);
  
  // SHADOWS - Çok Hafif
  static BoxShadow softShadow = BoxShadow(
    color: Colors.black.withOpacity(0.04),
    blurRadius: 8,
    offset: const Offset(0, 2),
  );
}

class QuietTechTheme {
  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Inter',
      colorScheme: ColorScheme.light(
        primary: QuietTechColors.primary,
        secondary: QuietTechColors.success,
        surface: QuietTechColors.surface,
        background: QuietTechColors.background,
      ),
      scaffoldBackgroundColor: QuietTechColors.background,
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: QuietTechColors.border, width: 1),
        ),
      ),
    );
  }
  
  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Inter',
      colorScheme: ColorScheme.dark(
        primary: QuietTechColors.primaryLight,
        secondary: QuietTechColors.success,
        surface: QuietTechColors.darkSurface,
        background: QuietTechColors.darkBackground,
      ),
      scaffoldBackgroundColor: QuietTechColors.darkBackground,
      cardTheme: CardThemeData(
        elevation: 0,
        color: QuietTechColors.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: QuietTechColors.darkBorder, width: 1),
        ),
      ),
    );
  }
}
