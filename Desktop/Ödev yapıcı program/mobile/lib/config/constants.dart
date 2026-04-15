class AppConstants {
  // API Configuration
  static const String baseUrl = 'https://odev-asistani-backend.onrender.com/api';
  
  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  
  // Education Levels
  static const List<String> educationLevels = [
    'ilkokul',
    'ortaokul',
    'lise',
    'universite',
  ];
  
  // Question Types
  static const Map<String, String> questionTypes = {
    'matematik': 'Matematik Çöz',
    'kompozisyon': 'Kompozisyon Yaz',
    'ceviri': 'Çeviri Yap',
    'genel': 'Genel Soru',
  };
  
  // Question Type Icons
  static const Map<String, String> questionTypeIcons = {
    'matematik': '🔢',
    'kompozisyon': '✍️',
    'ceviri': '🌍',
    'genel': '💡',
  };
}
