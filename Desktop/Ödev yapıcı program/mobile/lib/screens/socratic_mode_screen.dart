import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme_v2.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';

class SocraticModeScreen extends StatefulWidget {
  final String question;
  
  const SocraticModeScreen({super.key, required this.question});

  @override
  State<SocraticModeScreen> createState() => _SocraticModeScreenState();
}

class _SocraticModeScreenState extends State<SocraticModeScreen> {
  final List<Map<String, dynamic>> _conversation = [];
  final TextEditingController _answerController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _conversation.add({
      'type': 'question',
      'text': widget.question,
    });
    _getFirstHint();
  }

  Future<void> _getFirstHint() async {
    setState(() => _isLoading = true);
    
    try {
      final token = context.read<AuthProvider>().token;
      final apiService = ApiService();
      
      // Durum mesajları
      await Future.delayed(const Duration(milliseconds: 500));
      
      final response = await apiService.post(
        '/ai/socratic/hint',
        {'question': widget.question},
        token: token,
      );
      
      if (response['success']) {
        setState(() {
          _conversation.add({
            'type': 'hint',
            'text': response['data']['hint'],
            'level': 1,
          });
        });
      }
    } catch (e) {
      _showError('İpucu alınamadı: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _getMoreHint() async {
    setState(() => _isLoading = true);
    
    try {
      final token = context.read<AuthProvider>().token;
      final apiService = ApiService();
      final previousHints = _conversation
          .where((m) => m['type'] == 'hint')
          .map((m) => m['text'] as String)
          .toList();
      
      final response = await apiService.post(
        '/ai/socratic/hint',
        {
          'question': widget.question,
          'previousHints': previousHints,
        },
        token: token,
      );
      
      if (response['success']) {
        setState(() {
          _conversation.add({
            'type': 'hint',
            'text': response['data']['hint'],
            'level': previousHints.length + 1,
          });
        });
      }
    } catch (e) {
      _showError('İpucu alınamadı: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _checkAnswer() async {
    if (_answerController.text.trim().isEmpty) return;
    
    final studentAnswer = _answerController.text.trim();
    setState(() {
      _conversation.add({
        'type': 'student',
        'text': studentAnswer,
      });
      _isLoading = true;
    });
    _answerController.clear();
    
    try {
      final token = context.read<AuthProvider>().token;
      final apiService = ApiService();
      
      final response = await apiService.post(
        '/ai/socratic/check',
        {
          'question': widget.question,
          'studentAnswer': studentAnswer,
        },
        token: token,
      );
      
      if (response['success']) {
        setState(() {
          _conversation.add({
            'type': 'feedback',
            'text': response['data']['feedback'],
          });
        });
      }
    } catch (e) {
      _showError('Cevap kontrol edilemedi: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🤔 Sokratik Öğrenme'),
        backgroundColor: QuietTechColors.primary,
      ),
      body: Column(
        children: [
          // Açıklama Banner
          Container(
            padding: const EdgeInsets.all(16),
            color: QuietTechColors.cardBlue.withOpacity(0.1),
            child: Row(
              children: [
                const Text('💡', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Direkt cevap vermiyorum! Seni düşündürerek öğreniyoruz.',
                    style: TextStyle(
                      fontSize: 13,
                      color: QuietTechColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Konuşma
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _conversation.length,
              itemBuilder: (context, index) {
                final message = _conversation[index];
                return _buildMessage(message);
              },
            ),
          ),
          
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          
          // Alt Butonlar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: QuietTechColors.surface,
              border: Border(
                top: BorderSide(color: QuietTechColors.border),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _answerController,
                        decoration: InputDecoration(
                          hintText: 'Cevabını yaz...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        maxLines: 2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _checkAnswer,
                      icon: const Icon(Icons.send),
                      color: QuietTechColors.primary,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _getMoreHint,
                  icon: const Icon(Icons.lightbulb_outline),
                  label: const Text('Daha Fazla İpucu'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(Map<String, dynamic> message) {
    final type = message['type'];
    
    Color bgColor;
    IconData icon;
    String title;
    
    switch (type) {
      case 'question':
        bgColor = QuietTechColors.cardPurple.withOpacity(0.1);
        icon = Icons.help_outline;
        title = 'SORU';
        break;
      case 'hint':
        bgColor = QuietTechColors.cardBlue.withOpacity(0.1);
        icon = Icons.lightbulb_outline;
        title = 'İPUCU ${message['level']}';
        break;
      case 'student':
        bgColor = QuietTechColors.cardGreen.withOpacity(0.1);
        icon = Icons.person;
        title = 'SENİN CEVABIM';
        break;
      case 'feedback':
        bgColor = QuietTechColors.cardOrange.withOpacity(0.1);
        icon = Icons.check_circle_outline;
        title = 'GERİ BİLDİRİM';
        break;
      default:
        bgColor = QuietTechColors.background;
        icon = Icons.chat;
        title = '';
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: QuietTechColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: QuietTechColors.textSecondary),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: QuietTechColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            message['text'],
            style: const TextStyle(fontSize: 15, height: 1.5),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }
}
