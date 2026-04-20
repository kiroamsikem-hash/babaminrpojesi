import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../models/question_model.dart';
import '../providers/question_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/language_provider.dart';
import '../widgets/message_bubble.dart';
import '../widgets/quick_action_button.dart';

class ChatScreen extends StatefulWidget {
  final String questionType;
  final String? initialQuestion;
  final String? initialAnswer;
  final Question? existingQuestion;

  const ChatScreen({
    super.key,
    required this.questionType,
    this.initialQuestion,
    this.initialAnswer,
    this.existingQuestion,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  final List<Map<String, dynamic>> _messages = []; // Sohbet geçmişi
  String _loadingMessage = 'Düşünüyor...';

  @override
  void initState() {
    super.initState();
    if (widget.existingQuestion != null) {
      _messages.add({
        'type': 'user',
        'text': widget.existingQuestion!.question,
      });
      _messages.add({
        'type': 'ai',
        'text': widget.existingQuestion!.answer,
      });
    } else if (widget.initialQuestion != null) {
      if (widget.initialAnswer != null) {
        // Direkt fotoğraf analizi sonucu
        _messages.add({
          'type': 'user',
          'text': widget.initialQuestion!,
        });
        _messages.add({
          'type': 'ai',
          'text': widget.initialAnswer!,
        });
      } else {
        _sendMessage(widget.initialQuestion!);
      }
    }
  }

  Future<void> _sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    // Kullanıcı mesajını ekle
    setState(() {
      _messages.add({
        'type': 'user',
        'text': message,
      });
      _isLoading = true;
      _loadingMessage = 'Düşünüyor...';
    });
    _messageController.clear();
    _scrollToBottom();

    try {
      // Durum mesajlarını değiştir
      await Future.delayed(const Duration(milliseconds: 800));
      setState(() => _loadingMessage = 'Soru analiz ediliyor...');
      
      await Future.delayed(const Duration(milliseconds: 800));
      setState(() => _loadingMessage = 'Çözüm hazırlanıyor...');

      final questionProvider = context.read<QuestionProvider>();
      final authProvider = context.read<AuthProvider>();
      final userGrade = authProvider.user?.grade ?? 9;
      
      final result = await questionProvider.solveQuestion(
        question: message,
        type: widget.questionType,
        educationLevel: userGrade,
      );

      // AI cevabını ekle
      setState(() {
        _messages.add({
          'type': 'ai',
          'text': result.answer,
        });
        _isLoading = false;
      });

      _scrollToBottom();
    } catch (e) {
      setState(() => _isLoading = false);
      _showError(e.toString());
    }
  }

  Future<void> _simplifyExplanation() async {
    if (_messages.isEmpty) return;

    setState(() {
      _isLoading = true;
      _loadingMessage = 'Basitleştiriliyor...';
    });

    try {
      final questionProvider = context.read<QuestionProvider>();
      final lastAiMessage = _messages.lastWhere((m) => m['type'] == 'ai');
      
      final simplified = await questionProvider.simplifyExplanation(
        lastAiMessage['text'],
      );

      setState(() {
        _messages.add({
          'type': 'ai',
          'text': simplified,
        });
        _isLoading = false;
      });
      
      _scrollToBottom();
    } catch (e) {
      setState(() => _isLoading = false);
      _showError(e.toString());
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  String _getTypeTitle() {
    final languageProvider = context.read<LanguageProvider>();
    switch (widget.questionType) {
      case 'matematik':
        return languageProvider.translate('math_problem');
      case 'kompozisyon':
        return languageProvider.translate('composition');
      case 'ceviri':
        return languageProvider.translate('translate');
      default:
        return languageProvider.translate('chat');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTypeTitle()),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages Area
          Expanded(
            child: _messages.isEmpty && !_isLoading
                ? _buildEmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _messages.length && _isLoading) {
                        return _buildLoadingMessage();
                      }
                      final message = _messages[index];
                      return _buildMessageBubble(message);
                    },
                  ),
          ),

          // Quick Actions
          if (_messages.isNotEmpty && !_isLoading)
            _buildQuickActions(),

          // Input Area
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isUser = message['type'] == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isUser ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          message['text'],
          style: TextStyle(
            color: isUser ? Colors.white : AppColors.textPrimary,
            fontSize: 15,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingMessage() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(AppColors.primary),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              _loadingMessage,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getTypeIcon(),
            size: 80,
            color: AppColors.primary.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            _getEmptyStateText(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getTypeIcon() {
    switch (widget.questionType) {
      case 'matematik':
        return Icons.calculate_rounded;
      case 'kompozisyon':
        return Icons.edit_note_rounded;
      case 'ceviri':
        return Icons.translate_rounded;
      default:
        return Icons.chat_rounded;
    }
  }

  String _getEmptyStateText() {
    switch (widget.questionType) {
      case 'matematik':
        return 'Matematik sorunuzu yazın\nAdım adım çözelim!';
      case 'kompozisyon':
        return 'Kompozisyon konunuzu yazın\nBirlikte oluşturalım!';
      case 'ceviri':
        return 'Çevirmek istediğiniz metni yazın';
      default:
        return 'Sorunuzu yazın\nYardımcı olalım!';
    }
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.border),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            QuickActionButton(
              icon: Icons.lightbulb_outline,
              label: 'Daha Basit Anlat',
              onPressed: _simplifyExplanation,
            ),
            const SizedBox(width: 8),
            QuickActionButton(
              icon: Icons.list_alt,
              label: 'Adım Adım',
              onPressed: () {
                // Show step by step
              },
            ),
            const SizedBox(width: 8),
            QuickActionButton(
              icon: Icons.share,
              label: 'Paylaş',
              onPressed: () {
                // Share answer
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: _sendMessage,
              decoration: InputDecoration(
                hintText: 'Sorunuzu yazın...',
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send_rounded, color: Colors.white),
              onPressed: () => _sendMessage(_messageController.text),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
