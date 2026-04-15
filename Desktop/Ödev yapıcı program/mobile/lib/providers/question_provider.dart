import 'package:flutter/foundation.dart';
import '../models/question_model.dart';
import '../services/api_service.dart';

class QuestionProvider with ChangeNotifier {
  List<Question> _questions = [];
  bool _isLoading = false;
  String? _error;

  List<Question> get questions => _questions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  final ApiService _apiService = ApiService();

  // Fetch questions history
  Future<void> fetchQuestions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.get('/questions');

      if (response['success']) {
        _questions = (response['data'] as List)
            .map((json) => Question.fromJson(json))
            .toList();
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  // Solve question
  Future<Question> solveQuestion({
    required String question,
    required String type,
    String? educationLevel,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.post('/ai/solve', {
        'question': question,
        'type': type,
        'educationLevel': educationLevel ?? 'lise',
      });

      if (response['success']) {
        final newQuestion = Question.fromJson(response['data']);
        _questions.insert(0, newQuestion);
        _isLoading = false;
        notifyListeners();
        return newQuestion;
      }

      throw Exception(response['message'] ?? 'Soru çözülemedi');
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Perform OCR
  Future<String> performOCR(String imagePath) async {
    try {
      final response = await _apiService.uploadImage('/ai/ocr', imagePath);

      if (response['success']) {
        return response['data']['text'];
      }

      throw Exception(response['message'] ?? 'OCR başarısız');
    } catch (e) {
      rethrow;
    }
  }

  // Write composition
  Future<Question> writeComposition({
    required String topic,
    int wordCount = 300,
    String tone = 'akademik',
    String? educationLevel,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.post('/ai/compose', {
        'topic': topic,
        'wordCount': wordCount,
        'tone': tone,
        'educationLevel': educationLevel ?? 'lise',
      });

      if (response['success']) {
        final newQuestion = Question.fromJson(response['data']);
        _questions.insert(0, newQuestion);
        _isLoading = false;
        notifyListeners();
        return newQuestion;
      }

      throw Exception(response['message'] ?? 'Kompozisyon yazılamadı');
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Simplify explanation
  Future<String> simplifyExplanation(String text) async {
    try {
      final response = await _apiService.post('/ai/simplify', {
        'text': text,
      });

      if (response['success']) {
        return response['data']['simplified'];
      }

      throw Exception(response['message'] ?? 'Basitleştirme başarısız');
    } catch (e) {
      rethrow;
    }
  }

  // Translate text
  Future<String> translateText({
    required String text,
    required String targetLang,
    String? sourceLang,
  }) async {
    try {
      final response = await _apiService.post('/ai/translate', {
        'text': text,
        'targetLang': targetLang,
        'sourceLang': sourceLang ?? 'auto',
      });

      if (response['success']) {
        return response['data']['translation'];
      }

      throw Exception(response['message'] ?? 'Çeviri başarısız');
    } catch (e) {
      rethrow;
    }
  }

  // Delete question
  Future<bool> deleteQuestion(String id) async {
    try {
      final response = await _apiService.delete('/questions/$id');

      if (response['success']) {
        _questions.removeWhere((q) => q.id == id);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
