import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../config/theme.dart';
import '../services/api_service.dart';
import 'chat_screen.dart';

class PageScanScreen extends StatefulWidget {
  const PageScanScreen({super.key});

  @override
  State<PageScanScreen> createState() => _PageScanScreenState();
}

class _PageScanScreenState extends State<PageScanScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isDetecting = false;
  File? _capturedImage;
  List<dynamic> _detectedQuestions = [];
  bool _isProcessing = false;
  final ImagePicker _picker = ImagePicker();
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        _cameraController = CameraController(
          _cameras![0],
          ResolutionPreset.high,
          enableAudio: false,
        );
        await _cameraController!.initialize();
        if (mounted) {
          setState(() => _isCameraInitialized = true);
        }
      }
    } catch (e) {
      print('Kamera başlatma hatası: $e');
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _captureImage() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      setState(() => _isDetecting = true);
      
      final image = await _cameraController!.takePicture();
      
      setState(() {
        _capturedImage = File(image.path);
        _isDetecting = false;
      });
    } catch (e) {
      setState(() => _isDetecting = false);
      _showError('Fotoğraf çekilemedi: $e');
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _capturedImage = File(image.path);
        });
      }
    } catch (e) {
      _showError('Resim seçilemedi: $e');
    }
  }

  Future<void> _scanPage() async {
    if (_capturedImage == null) return;

    setState(() => _isProcessing = true);

    try {
      print('📤 Sayfa tarama başlatılıyor...');
      final response = await _apiService.uploadImage(
        '/page-scan/scan',
        _capturedImage!.path,
      );

      print('📥 Sayfa tarama yanıtı: ${response}');

      if (mounted) {
        if (response['success'] == true) {
          final questions = response['data']?['questions'] ?? [];
          setState(() {
            _detectedQuestions = questions;
            _isProcessing = false;
          });

          if (_detectedQuestions.isEmpty) {
            _showError('Sayfada soru tespit edilemedi. Lütfen daha net bir fotoğraf çekin.');
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${_detectedQuestions.length} soru bulundu!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          final errorMessage = response['message'] ?? 'Tarama başarısız';
          throw Exception(errorMessage);
        }
      }
    } catch (e) {
      print('❌ Sayfa tarama hatası: $e');
      if (mounted) {
        setState(() => _isProcessing = false);
        
        String errorMessage = 'Sayfa taranamadı';
        final errorStr = e.toString();
        
        if (errorStr.contains('çok küçük') || errorStr.contains('boş')) {
          errorMessage = 'Fotoğraf çok küçük veya boş. Lütfen geçerli bir fotoğraf çekin.';
        } else if (errorStr.contains('soru bulunamadı') || errorStr.contains('tespit edilemedi')) {
          errorMessage = 'Sayfada soru bulunamadı. Lütfen soruların net göründüğünden emin olun.';
        } else if (errorStr.contains('timeout') || errorStr.contains('zaman aşımı')) {
          errorMessage = 'İşlem zaman aşımına uğradı. Lütfen tekrar deneyin.';
        } else if (errorStr.contains('internet') || errorStr.contains('bağlantı')) {
          errorMessage = 'İnternet bağlantısı yok. Lütfen bağlantınızı kontrol edin.';
        } else {
          errorMessage = 'Sayfa taranamadı. Lütfen tekrar deneyin.';
        }
        
        _showError(errorMessage);
      }
    }
  }

  Future<void> _solveQuestion(Map<String, dynamic> question) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final response = await _apiService.post('/page-scan/solve', {
        'questionText': question['text'],
        'questionType': question['type'],
        'options': question['options'] ?? [],
      });

      if (mounted) {
        Navigator.pop(context); // Close loading dialog

        if (response['success']) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatScreen(
                questionType: question['type'] ?? 'genel',
                initialQuestion: question['text'],
                initialAnswer: response['data']['answer'],
              ),
            ),
          );
        } else {
          throw Exception(response['message'] ?? 'Çözüm alınamadı');
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        _showError('Soru çözülemedi: $e');
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📄 Sayfa Tara'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _capturedImage == null
          ? _buildCameraView()
          : _detectedQuestions.isEmpty
              ? _buildPreviewView()
              : _buildQuestionsView(),
    );
  }

  Widget _buildCameraView() {
    if (!_isCameraInitialized || _cameraController == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        // Camera Preview
        Positioned.fill(
          child: CameraPreview(_cameraController!),
        ),

        // Overlay with detection frame
        Positioned.fill(
          child: CustomPaint(
            painter: DetectionFramePainter(isDetecting: _isDetecting),
          ),
        ),

        // Instructions
        Positioned(
          top: 20,
          left: 20,
          right: 20,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Text(
                  '📄 Sayfayı Çerçeveye Sığdır',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _isDetecting
                      ? '✅ Sayfa tespit edildi!'
                      : 'Sayfanın tamamını gösterin',
                  style: TextStyle(
                    color: _isDetecting ? Colors.green : Colors.white70,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),

        // Bottom Controls
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
            ),
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Gallery Button
                  IconButton(
                    onPressed: _pickFromGallery,
                    icon: const Icon(Icons.photo_library, size: 32),
                    color: Colors.white,
                  ),

                  // Capture Button
                  GestureDetector(
                    onTap: _captureImage,
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        color: _isDetecting ? Colors.green : Colors.white,
                      ),
                      child: _isDetecting
                          ? const Icon(Icons.check, color: Colors.white, size: 32)
                          : null,
                    ),
                  ),

                  // Placeholder for symmetry
                  const SizedBox(width: 48),
                ],
              ),
            ),
          ),
        ),
      ],
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
                _capturedImage!,
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
                if (_isProcessing)
                  const Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Sayfa taranıyor...'),
                    ],
                  )
                else ...[
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => setState(() {
                            _capturedImage = null;
                            _detectedQuestions = [];
                          }),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Yeniden Çek'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _scanPage,
                          icon: const Icon(Icons.document_scanner),
                          label: const Text('Tara'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionsView() {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          color: AppColors.primary,
          child: SafeArea(
            bottom: false,
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tarama Tamamlandı',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${_detectedQuestions.length} soru tespit edildi',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => setState(() {
                    _capturedImage = null;
                    _detectedQuestions = [];
                  }),
                  icon: const Icon(Icons.refresh, color: Colors.white),
                ),
              ],
            ),
          ),
        ),

        // Questions List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _detectedQuestions.length,
            itemBuilder: (context, index) {
              final question = _detectedQuestions[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () => _solveQuestion(question),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Soru ${question['number']}',
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                question['type'] ?? 'Genel',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          question['text'] ?? '',
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.5,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (question['options'] != null &&
                            (question['options'] as List).isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            '${(question['options'] as List).length} şık',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: () => _solveQuestion(question),
                              icon: const Icon(Icons.auto_awesome, size: 18),
                              label: const Text('Çöz'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// Custom painter for detection frame
class DetectionFramePainter extends CustomPainter {
  final bool isDetecting;

  DetectionFramePainter({required this.isDetecting});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDetecting ? Colors.green : Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final rect = Rect.fromLTRB(
      size.width * 0.1,
      size.height * 0.15,
      size.width * 0.9,
      size.height * 0.75,
    );

    // Draw corners
    final cornerLength = 40.0;

    // Top-left
    canvas.drawLine(
      rect.topLeft,
      rect.topLeft + Offset(cornerLength, 0),
      paint,
    );
    canvas.drawLine(
      rect.topLeft,
      rect.topLeft + Offset(0, cornerLength),
      paint,
    );

    // Top-right
    canvas.drawLine(
      rect.topRight,
      rect.topRight + Offset(-cornerLength, 0),
      paint,
    );
    canvas.drawLine(
      rect.topRight,
      rect.topRight + Offset(0, cornerLength),
      paint,
    );

    // Bottom-left
    canvas.drawLine(
      rect.bottomLeft,
      rect.bottomLeft + Offset(cornerLength, 0),
      paint,
    );
    canvas.drawLine(
      rect.bottomLeft,
      rect.bottomLeft + Offset(0, -cornerLength),
      paint,
    );

    // Bottom-right
    canvas.drawLine(
      rect.bottomRight,
      rect.bottomRight + Offset(-cornerLength, 0),
      paint,
    );
    canvas.drawLine(
      rect.bottomRight,
      rect.bottomRight + Offset(0, -cornerLength),
      paint,
    );

    // Draw center lines if detecting
    if (isDetecting) {
      final dashedPaint = Paint()
        ..color = Colors.green.withOpacity(0.5)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      // Horizontal center line
      canvas.drawLine(
        Offset(rect.left, rect.center.dy),
        Offset(rect.right, rect.center.dy),
        dashedPaint,
      );

      // Vertical center line
      canvas.drawLine(
        Offset(rect.center.dx, rect.top),
        Offset(rect.center.dx, rect.bottom),
        dashedPaint,
      );
    }
  }

  @override
  bool shouldRepaint(DetectionFramePainter oldDelegate) {
    return oldDelegate.isDetecting != isDetecting;
  }
}
