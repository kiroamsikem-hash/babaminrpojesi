import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../config/constants.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  String? _token;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _token != null && _user != null;

  final ApiService _apiService = ApiService();

  // Initialize - Check if user is logged in
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString(AppConstants.tokenKey);
      final userJson = prefs.getString(AppConstants.userKey);

      if (_token != null && userJson != null) {
        _user = User.fromJson(json.decode(userJson));
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  // Register
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    String educationLevel = 'lise',
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.post('/auth/register', {
        'name': name,
        'email': email,
        'password': password,
        'educationLevel': educationLevel,
      });

      if (response['success']) {
        _token = response['token'];
        _user = User.fromJson(response['user']);
        await _saveToStorage();
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _error = response['message'] ?? 'Kayıt başarısız';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      // Kullanıcı dostu hata mesajları
      if (e.toString().contains('SocketException')) {
        _error = 'İnternet bağlantınızı kontrol edin';
      } else if (e.toString().contains('TimeoutException') || e.toString().contains('zaman aşımı')) {
        _error = 'Sunucu yanıt vermiyor. Lütfen 30 saniye bekleyip tekrar deneyin.';
      } else if (e.toString().contains('FormatException')) {
        _error = 'Sunucudan geçersiz yanıt alındı';
      } else if (e.toString().contains('type') && e.toString().contains('subtype')) {
        _error = 'Veri formatı hatası. Lütfen tekrar deneyin.';
      } else {
        _error = 'Bir hata oluştu. Lütfen tekrar deneyin.';
      }
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Login
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.post('/auth/login', {
        'email': email,
        'password': password,
      });

      if (response['success']) {
        _token = response['token'];
        _user = User.fromJson(response['user']);
        await _saveToStorage();
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _error = response['message'] ?? 'Giriş başarısız';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      // Kullanıcı dostu hata mesajları
      if (e.toString().contains('SocketException')) {
        _error = 'İnternet bağlantınızı kontrol edin';
      } else if (e.toString().contains('TimeoutException') || e.toString().contains('zaman aşımı')) {
        _error = 'Sunucu yanıt vermiyor. Lütfen 30 saniye bekleyip tekrar deneyin.';
      } else if (e.toString().contains('FormatException')) {
        _error = 'Sunucudan geçersiz yanıt alındı';
      } else if (e.toString().contains('type') && e.toString().contains('subtype')) {
        _error = 'Veri formatı hatası. Lütfen tekrar deneyin.';
      } else {
        _error = 'Bir hata oluştu. Lütfen tekrar deneyin.';
      }
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    _user = null;
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.tokenKey);
    await prefs.remove(AppConstants.userKey);
    notifyListeners();
  }

  // Save to local storage
  Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.tokenKey, _token!);
    await prefs.setString(AppConstants.userKey, json.encode(_user!.toJson()));
  }

  // Update profile
  Future<bool> updateProfile({
    String? name,
    String? educationLevel,
  }) async {
    try {
      final response = await _apiService.put(
        '/users/profile',
        {
          if (name != null) 'name': name,
          if (educationLevel != null) 'educationLevel': educationLevel,
        },
        token: _token,
      );

      if (response['success']) {
        _user = User.fromJson(response['data']);
        await _saveToStorage();
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
