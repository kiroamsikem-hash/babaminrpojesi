import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../config/theme.dart';
import '../providers/question_provider.dart';
import '../providers/language_provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import 'chat_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  File? _imageFile;
  bool _isProcessing = false;
  final ImagePicker _picker = ImagePicker();
  final ApiService _apiService = ApiService();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _imageFile = File(image.path);
        });
      }
    } catch (e) {
      _showError('Resim seçilemedi: $e');
    }
  }

  Future<void> _processImageDirectly() async {
    if (_imageFile == null) return;

    setState(() => _isProcessing = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;

      // Fotoğrafı direkt backend'e gönder
      final response = await _apiService.uploadImage(
        '/ai/solve-image',
        _imageFile!.path,
      );

      if (!mounted) return;

      if (response['success']) {
        // Çözümü chat ekranında göster
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => ChatScreen(
              questionType: 'genel',
              initialQuestion: response['data']['question'] ?? '',
              initialAnswer: response['data']['answer'] ?? '',
            ),
          ),
        );
      } else {
        throw Exception(response['message'] ?? 'Analiz başarısız');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      _showError('Fotoğraf analizi başarısız: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  void _showCropDialog() {
    // Basit kırpma UI'ı - gelişmiş kırpma için image_cropper paketi kullanılabilir
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kırpma'),
        content: const Text('Kırpma özelliği yakında eklenecek'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    
    return Scaffold(
      appBar: AppBar(
        title: Text(languageProvider.translate('photo_scan')),
      ),
      body: _imageFile == null ? _buildPickerView() : _buildPreviewView(),
    );
  }

  Widget _buildPickerView() {
    final languageProvider = context.watch<LanguageProvider>();
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.camera_alt_rounded,
            size: 100,
            color: AppColors.primary,
          ),
          const SizedBox(height: 24),
          Text(
            languageProvider.translate('take_photo_or_select'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 48),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: Text(languageProvider.translate('open_camera')),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: Text(languageProvider.translate('select_from_gallery')),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewView() {
    final languageProvider = context.watch<LanguageProvider>();
    
    return Column(
      children: [
        Expanded(
          child: Container(
            color: Colors.black,
            child: Center(
              child: Image.file(
                _imageFile!,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isProcessing
                            ? null
                            : () => setState(() => _imageFile = null),
                        icon: const Icon(Icons.refresh),
                        label: Text(languageProvider.translate('retake')),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isProcessing ? null : _showCropDialog,
                        icon: const Icon(Icons.crop),
                        label: const Text('Kırp'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isProcessing ? null : _processImageDirectly,
                    icon: _isProcessing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.auto_awesome),
                    label: Text(_isProcessing 
                        ? 'Analiz ediliyor...'
                        : 'Fotoğrafı Analiz Et'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
