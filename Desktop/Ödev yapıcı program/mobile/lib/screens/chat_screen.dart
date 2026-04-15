import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../models/question_model.dart';
import '../providers/question_provider.dart';
import '../widgets/message_bubble.dart';
import '../widgets/quick_action_button.dart';

class ChatScreen extends StatefulWidget {
  final String questionType;
  final String? initialQuestion;
  final Question? existingQuestion;

  const ChatScreen({
    super.key,
    required this.questionType,
    this.initialQuestion,
    this.existingQuestion,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  Question? _currentQuestion;

  @override
  void initState() {
    super.initState();
    if (widget.existingQuestion != null) {
      _currentQuestion = widget.existingQuestion;
    } else if (widget.initialQuestion != null) {
      _sendMessage(widget.initialQuestion!);
    }
  }

  Future<void> _sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    setState(() => _isLoading = true);
    _messageController.clear();

    try {
      final questionProvider = context.read<QuestionProvider>();
      final result = await questionProvider.solveQuestion(
        question: message,
        type: widget.questionType,
      );

      setState(() {
        _currentQuestion = result;
        _isLoading = false;
      });

      _scrollToBottom();
    } catch (e) {
      setState(() => _isLoading = false);
      _showError(e.toString());
    }
  }

  Future<void> _simplifyExplanation() async {
    if (_currentQuestion == null) return;

    setState(() => _isLoading = true);

    try {
      final questionProvider = context.read<QuestionProvider>();
      final simplified = await questionProvider.simplifyExplanation(
        _currentQuestion!.answer,
      );

      setState(() {
        _currentQuestion = Question(
          id: _currentQuestion!.id,
          type: _currentQuestion!.type,
          question: _currentQuestion!.question,
          answer: simplified,
          createdAt: _currentQuestion!.createdAt,
        );
        _isLoading = false;
      });
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
    switch (widget.questionType) {
      case 'matematik':
        return 'Matematik Çözücü';
      case 'kompozisyon':
        return 'Kompozisyon Yazıcı';
      case 'ceviri':
        return 'Çeviri';
      default:
        return 'Sohbet';
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
            onPressed: () {
              // Show options menu
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages Area
          Expanded(
            child: _currentQuestion == null && !_isLoading
                ? _buildEmptyState()
                : _buildMessagesArea(),
          ),

          // Quick Actions (when answer is shown)
          if (_currentQuestion != null && !_isLoading)
            _buildQuickActions(),

          // Input Area
          _buildInputArea(),
        ],
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

  Widget _buildMessagesArea() {
    return ListView(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      children: [
        // User Question
        if (_currentQuestion != null)
          MessageBubble(
            message: _currentQuestion!.question,
            isUser: true,
          ),

        const SizedBox(height: 16),

        // AI Answer
        if (_currentQuestion != null)
          MessageBubble(
            message: _currentQuestion!.answer,
            isUser: false,
            isMarkdown: true,
          ),

        // Loading Indicator
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
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
