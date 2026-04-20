import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' as http_parser;
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
      print('🔍 GET Request: $baseUrl$endpoint');
      
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('İstek zaman aşımına uğradı');
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
      print('❌ GET Error: $e');
      throw Exception('Bağlantı hatası: ${e.toString()}');
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
      print('📤 POST Request: $baseUrl$endpoint');
      print('📦 Data: ${json.encode(data)}');
      
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
      print('❌ POST Error: $e');
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
      print('🔄 PUT Request: $baseUrl$endpoint');
      
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          if (authToken != null) 'Authorization': 'Bearer $authToken',
        },
        body: json.encode(data),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('İstek zaman aşımına uğradı');
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
      print('❌ PUT Error: $e');
      throw Exception('Bağlantı hatası: ${e.toString()}');
    }
  }

  // DELETE Request
  Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final token = await _getToken();
      print('🗑️ DELETE Request: $baseUrl$endpoint');
      
      final response = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('İstek zaman aşımına uğradı');
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
      print('❌ DELETE Error: $e');
      throw Exception('Bağlantı hatası: ${e.toString()}');
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

      // Dosya uzantısından mime type belirle
      String mimeType = 'image/jpeg';
      if (imagePath.toLowerCase().endsWith('.png')) {
        mimeType = 'image/png';
      } else if (imagePath.toLowerCase().endsWith('.jpg') || imagePath.toLowerCase().endsWith('.jpeg')) {
        mimeType = 'image/jpeg';
      }

      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imagePath,
          contentType: http_parser.MediaType.parse(mimeType),
        ),
      );

      print('📤 Resim gönderiliyor: $imagePath');
      print('📝 Mime type: $mimeType');

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          throw Exception('OCR işlemi zaman aşımına uğradı');
        },
      );
      
      final response = await http.Response.fromStream(streamedResponse);
      
      print('📥 Yanıt alındı: ${response.statusCode}');

      return _handleResponse(response);
    } catch (e) {
      print('❌ Upload hatası: $e');
      throw Exception('Resim yükleme hatası: $e');
    }
  }

  // Handle Response
  Map<String, dynamic> _handleResponse(http.Response response) {
    print('📥 Response status: ${response.statusCode}');
    print('📥 Response headers: ${response.headers}');
    print('📥 Response body (first 1000 chars): ${response.body.substring(0, response.body.length > 1000 ? 1000 : response.body.length)}');
    
    // HTML response kontrolü
    if (response.body.trim().startsWith('<!DOCTYPE') || response.body.trim().startsWith('<html')) {
      print('❌ Backend HTML döndürdü!');
      throw Exception('Backend çalışmıyor. Lütfen daha sonra tekrar deneyin.');
    }

    // Empty response kontrolü
    if (response.body.trim().isEmpty) {
      print('❌ Backend boş yanıt döndürdü!');
      throw Exception('Backend boş yanıt döndürdü. Lütfen tekrar deneyin.');
    }

    // JSON parse dene
    Map<String, dynamic>? data;
    try {
      data = json.decode(response.body);
    } catch (e) {
      print('❌ JSON parse hatası!');
      print('❌ Response body: ${response.body}');
      
      // Backend'den text mesaj gelmiş olabilir
      if (response.statusCode >= 400) {
        throw Exception('İşlem başarısız. Lütfen tekrar deneyin.');
      } else {
        throw Exception('Geçersiz yanıt formatı. Lütfen tekrar deneyin.');
      }
    }

    // Success kontrolü
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      // Backend'den gelen hata mesajını göster
      final errorMessage = data['message'] ?? data['error'] ?? 'İşlem başarısız';
      print('❌ Backend error: $errorMessage');
      throw Exception(errorMessage);
    }
  }

  // Video Lab endpoints
  Future<Map<String, dynamic>> analyzeVideo(String videoUrl, {String? analysisType}) async {
    return await post('/video/analyze', {
      'videoUrl': videoUrl,
      'analysisType': analysisType ?? 'full',
    });
  }

  Future<Map<String, dynamic>> getVideoNotes({int page = 1, int limit = 20}) async {
    return await get('/video/notes?page=$page&limit=$limit');
  }

  Future<Map<String, dynamic>> getVideoNote(String id) async {
    return await get('/video/notes/$id');
  }

  Future<Map<String, dynamic>> deleteVideoNote(String id) async {
    return await delete('/video/notes/$id');
  }

  // Flashcard endpoints
  Future<Map<String, dynamic>> generateFlashcards({
    required String text,
    String? subject,
    int count = 10,
    String? deckName,
  }) async {
    return await post('/flashcards/generate', {
      'text': text,
      'subject': subject,
      'count': count,
      'deckName': deckName,
    });
  }

  Future<Map<String, dynamic>> generateFlashcardsFromVideo(
    String videoUrl, {
    int count = 10,
    String? deckName,
  }) async {
    return await post('/flashcards/generate-from-video', {
      'videoUrl': videoUrl,
      'count': count,
      'deckName': deckName,
    });
  }

  Future<Map<String, dynamic>> createFlashcard({
    required String front,
    required String back,
    String? subject,
    String? difficulty,
    String? deckName,
  }) async {
    return await post('/flashcards', {
      'front': front,
      'back': back,
      'subject': subject,
      'difficulty': difficulty,
      'deckName': deckName,
    });
  }

  Future<Map<String, dynamic>> getDueFlashcards({int limit = 20}) async {
    return await get('/flashcards/due?limit=$limit');
  }

  Future<Map<String, dynamic>> getFlashcardDecks() async {
    return await get('/flashcards/decks');
  }

  Future<Map<String, dynamic>> getFlashcardStats() async {
    return await get('/flashcards/stats');
  }

  Future<Map<String, dynamic>> reviewFlashcard(String id, int quality) async {
    return await put('/flashcards/$id/review', {'quality': quality});
  }

  Future<Map<String, dynamic>> deleteFlashcard(String id) async {
    return await delete('/flashcards/$id');
  }

  // Study Session endpoints
  Future<Map<String, dynamic>> createStudySession({
    required String subject,
    required String targetDate,
    required int dailyGoal,
    String? notes,
  }) async {
    return await post('/study/sessions', {
      'subject': subject,
      'targetDate': targetDate,
      'dailyGoal': dailyGoal,
      'notes': notes,
    });
  }

  Future<Map<String, dynamic>> getActiveSessions() async {
    return await get('/study/sessions');
  }

  Future<Map<String, dynamic>> updateStudyProgress(String id, int minutesStudied) async {
    return await put('/study/sessions/$id/progress', {
      'minutesStudied': minutesStudied,
    });
  }

  Future<Map<String, dynamic>> getTodayStats() async {
    return await get('/study/today');
  }

  Future<Map<String, dynamic>> deleteStudySession(String id) async {
    return await delete('/study/sessions/$id');
  }
}
