import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../config/theme.dart';
import '../providers/question_provider.dart';
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

  Future<void> _processImage() async {
    if (_imageFile == null) return;

    setState(() => _isProcessing = true);

    try {
      final questionProvider = context.read<QuestionProvider>();
      final extractedText = await questionProvider.performOCR(_imageFile!.path);

      if (!mounted) return;

      // Navigate to chat with extracted text
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            questionType: 'genel',
            initialQuestion: extractedText,
          ),
        ),
      );
    } catch (e) {
      setState(() => _isProcessing = false);
      _showError('OCR işlemi başarısız: $e');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fotoğraf Tarama'),
      ),
      body: _imageFile == null ? _buildPickerView() : _buildPreviewView(),
    );
  }

  Widget _buildPickerView() {
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
          const Text(
            'Sorunun fotoğrafını çek\nveya galeriden seç',
            textAlign: TextAlign.center,
            style: TextStyle(
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
                    label: const Text('Kamera Aç'),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Galeriden Seç'),
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
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isProcessing
                        ? null
                        : () => setState(() => _imageFile = null),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Yeniden Çek'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _isProcessing ? null : _processImage,
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
                        : const Icon(Icons.check),
                    label: Text(_isProcessing ? 'İşleniyor...' : 'Devam Et'),
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
