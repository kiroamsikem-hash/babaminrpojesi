import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/constants.dart';

class ApiService {
  final String baseUrl = AppConstants.baseUrl;

  // Get token from storage
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.tokenKey);
  }

  // GET Request
  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // POST Request
  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> data, {
    String? token,
  }) async {
    try {
      final authToken = token ?? await _getToken();
      final response = await http
          .post(
            Uri.parse('$baseUrl$endpoint'),
            headers: {
              'Content-Type': 'application/json',
              if (authToken != null) 'Authorization': 'Bearer $authToken',
            },
            body: json.encode(data),
          )
          .timeout(
            const Duration(seconds: 60),
            onTimeout: () {
              throw Exception('İstek zaman aşımına uğradı. Lütfen tekrar deneyin.');
            },
          );

      return _handleResponse(response);
    } on SocketException {
      throw Exception('İnternet bağlantısı yok');
    } on HttpException {
      throw Exception('Sunucuya bağlanılamadı');
    } on FormatException {
      throw Exception('Geçersiz yanıt formatı');
    } catch (e) {
      throw Exception('Bağlantı hatası: ${e.toString()}');
    }
  }

  // PUT Request
  Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> data, {
    String? token,
  }) async {
    try {
      final authToken = token ?? await _getToken();
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          if (authToken != null) 'Authorization': 'Bearer $authToken',
        },
        body: json.encode(data),
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // DELETE Request
  Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final token = await _getToken();
      final response = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Upload Image (Multipart)
  Future<Map<String, dynamic>> uploadImage(
    String endpoint,
    String imagePath,
  ) async {
    try {
      final token = await _getToken();
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl$endpoint'),
      );

      request.headers.addAll({
        if (token != null) 'Authorization': 'Bearer $token',
      });

      request.files.add(
        await http.MultipartFile.fromPath('image', imagePath),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Upload error: $e');
    }
  }

  // Handle Response
  Map<String, dynamic> _handleResponse(http.Response response) {
    final data = json.decode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Request failed');
    }
  }
}
