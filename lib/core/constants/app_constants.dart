import 'package:flutter/material.dart';

/// Application Constants
class AppConstants {
  // Timeline Configuration
  static const double yearHeight = 100.0; // Her yıl için pixel yüksekliği
  static const double columnWidth = 300.0; // Her medeniyet sütunu genişliği
  static const double axisWidth = 120.0; // Sol Y-ekseni genişliği
  static const double headerHeight = 100.0; // Üst X-ekseni yüksekliği
  
  // Grid Configuration
  static const double gridCellPadding = 8.0;
  static const double gridLineWidth = 1.0;
  
  // Card Configuration
  static const double cardMinHeight = 80.0;
  static const double cardMaxHeight = 200.0;
  static const double cardBorderRadius = 12.0;
  static const double cardElevation = 4.0;
  
  // Zoom Configuration
  static const double minScale = 0.3;
  static const double maxScale = 3.0;
  static const double initialScale = 1.0;
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  
  // Inspector Panel
  static const double inspectorWidth = 400.0;
  static const double inspectorMinWidth = 300.0;
  static const double inspectorMaxWidth = 600.0;
  
  // Graph Configuration
  static const double nodeRadius = 40.0;
  static const double nodeSpacing = 150.0;
  static const double connectionLineWidth = 2.0;
  
  // Database
  static const String databaseName = 'civilization_timeline';
  static const int databaseVersion = 1;
  
  // File Upload
  static const int maxFileSize = 10 * 1024 * 1024; // 10 MB
  static const List<String> allowedImageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
  static const List<String> allowedDocExtensions = ['pdf', 'doc', 'docx'];
}

/// Connection Types
class ConnectionTypes {
  static const String similar = 'similar';
  static const String influenced = 'influenced';
  static const String trade = 'trade';
  static const String related = 'related';
  static const String conflict = 'conflict';
  static const String cultural = 'cultural';
  
  static const List<String> all = [
    similar,
    influenced,
    trade,
    related,
    conflict,
    cultural,
  ];
  
  static String getLabel(String type) {
    switch (type) {
      case similar:
        return 'Benzer';
      case influenced:
        return 'Etkiledi';
      case trade:
        return 'Ticaret';
      case related:
        return 'İlişkili';
      case conflict:
        return 'Çatışma';
      case cultural:
        return 'Kültürel';
      default:
        return type;
    }
  }
  
  static Color getColor(String type) {
    switch (type) {
      case similar:
        return Colors.blue;
      case influenced:
        return Colors.purple;
      case trade:
        return Colors.green;
      case related:
        return Colors.orange;
      case conflict:
        return Colors.red;
      case cultural:
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }
}

/// Entity Types
class EntityTypes {
  static const String civilization = 'civilization';
  static const String event = 'event';
  static const String artifact = 'artifact';
  
  static String getLabel(String type) {
    switch (type) {
      case civilization:
        return 'Medeniyet';
      case event:
        return 'Olay';
      case artifact:
        return 'Buluntu';
      default:
        return type;
    }
  }
}
