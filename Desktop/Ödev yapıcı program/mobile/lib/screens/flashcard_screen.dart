import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../config/theme.dart';
import '../services/api_service.dart';
import '../models/flashcard_model.dart';

class FlashcardScreen extends StatefulWidget {
  const FlashcardScreen({super.key});

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  List<Flashcard> _dueCards = [];
  int _currentIndex = 0;
  bool _showAnswer = false;
  bool _isLoading = true;
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );
    _loadDueCards();
  }

  Future<void> _loadDueCards() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiService.getDueFlashcards();
      if (response['success']) {
        setState(() {
          _dueCards = (response['data'] as List)
              .map((json) => Flashcard.fromJson(json))
              .toList();
          _isLoading = false;
        });
      } else {
        throw Exception(response['message'] ?? 'Kartlar yüklenemedi');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _flipCard() {
    if (_showAnswer) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
    setState(() => _showAnswer = !_showAnswer);
  }

  Future<void> _reviewCard(int quality) async {
    if (_currentIndex >= _dueCards.length) return;

    try {
      await _apiService.reviewFlashcard(_dueCards[_currentIndex].id, quality);
      
      setState(() {
        if (_currentIndex < _dueCards.length - 1) {
          _currentIndex++;
          _showAnswer = false;
          _flipController.reset();
        } else {
          // Tüm kartlar tamamlandı
          _showCompletionDialog();
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🎉 Tebrikler!'),
        content: const Text('Bugünkü tüm kartları tamamladınız!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎴 Akıllı Kartlar'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.video_library),
            onPressed: () => _showVideoDialog(),
            tooltip: 'Video\'dan Oluştur',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateCardDialog(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _dueCards.isEmpty
              ? _buildEmptyState()
              : _buildCardView(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline, size: 80, color: Colors.green[300]),
          const SizedBox(height: 16),
          const Text(
            'Bugün için kart yok! 🎉',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Yeni kartlar eklemek için + butonuna tıklayın',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildCardView() {
    final card = _dueCards[_currentIndex];

    return Column(
      children: [
        // Progress
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Kart ${_currentIndex + 1} / ${_dueCards.length}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getDifficultyColor(card.difficulty).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      card.difficulty.toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _getDifficultyColor(card.difficulty),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: (_currentIndex + 1) / _dueCards.length,
                backgroundColor: Colors.grey[200],
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ],
          ),
        ),

        // Card
        Expanded(
          child: Center(
            child: GestureDetector(
              onTap: _flipCard,
              child: AnimatedBuilder(
                animation: _flipAnimation,
                builder: (context, child) {
                  final angle = _flipAnimation.value * math.pi;
                  final transform = Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateY(angle);

                  return Transform(
                    transform: transform,
                    alignment: Alignment.center,
                    child: angle >= math.pi / 2
                        ? Transform(
                            transform: Matrix4.identity()..rotateY(math.pi),
                            alignment: Alignment.center,
                            child: _buildCardContent(card.back, true),
                          )
                        : _buildCardContent(card.front, false),
                  );
                },
              ),
            ),
          ),
        ),

        // Actions
        if (_showAnswer) _buildReviewButtons(),
      ],
    );
  }

  Widget _buildCardContent(String text, bool isBack) {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isBack ? 'CEVAP' : 'SORU',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            text,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Text(
            isBack ? '' : 'Kartı çevirmek için tıklayın',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Bu kartı ne kadar iyi biliyorsunuz?',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildReviewButton('Zor', Colors.red, 1),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildReviewButton('Orta', Colors.orange, 3),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildReviewButton('Kolay', Colors.green, 5),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReviewButton(String label, Color color, int quality) {
    return ElevatedButton(
      onPressed: () => _reviewCard(quality),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'kolay':
        return Colors.green;
      case 'orta':
        return Colors.orange;
      case 'zor':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showCreateCardDialog() {
    final frontController = TextEditingController();
    final backController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yeni Kart Oluştur'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: frontController,
              decoration: const InputDecoration(
                labelText: 'Ön Yüz (Soru)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: backController,
              decoration: const InputDecoration(
                labelText: 'Arka Yüz (Cevap)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (frontController.text.trim().isEmpty || backController.text.trim().isEmpty) {
                return;
              }

              try {
                await _apiService.createFlashcard(
                  front: frontController.text.trim(),
                  back: backController.text.trim(),
                );
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ Kart oluşturuldu!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  _loadDueCards();
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Hata: ${e.toString().replaceAll('Exception: ', '')}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Oluştur'),
          ),
        ],
      ),
    );
  }

  void _showVideoDialog() {
    final urlController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('🎬 Video\'dan Kart Oluştur'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'YouTube video linkini girin. Video analiz edilip otomatik kartlar oluşturulacak.',
                style: TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: urlController,
                decoration: const InputDecoration(
                  labelText: 'YouTube URL',
                  hintText: 'https://youtube.com/watch?v=...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.link),
                ),
              ),
              if (isLoading) ...[
                const SizedBox(height: 16),
                const CircularProgressIndicator(),
                const SizedBox(height: 8),
                const Text('Video analiz ediliyor...', style: TextStyle(fontSize: 12)),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (urlController.text.trim().isEmpty) return;

                      setDialogState(() => isLoading = true);

                      try {
                        final response = await _apiService.generateFlashcardsFromVideo(
                          urlController.text.trim(),
                        );

                        if (response['success']) {
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('✅ ${response['count']} kart oluşturuldu!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                            _loadDueCards();
                          }
                        } else {
                          throw Exception(response['message'] ?? 'Kartlar oluşturulamadı');
                        }
                      } catch (e) {
                        setDialogState(() => isLoading = false);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Hata: ${e.toString().replaceAll('Exception: ', '')}'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
              child: const Text('Oluştur'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }
}
