import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/languages.dart';

class LanguageProvider with ChangeNotifier {
  String _currentLanguage = 'tr';
  
  String get currentLanguage => _currentLanguage;
  
  LanguageProvider() {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLanguage = prefs.getString('language') ?? 'tr';
    notifyListeners();
  }

  Future<void> setLanguage(String lang) async {
    _currentLanguage = lang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', lang);
    notifyListeners();
  }

  String translate(String key) {
    return AppLanguages.get(key, _currentLanguage);
  }

  String get(String key) => translate(key);
}
