import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/question_provider.dart';
import '../widgets/recent_question_card.dart';
import 'chat_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    await context.read<QuestionProvider>().fetchQuestions();
  }

  @override
  Widget build(BuildContext context) {
    final questionProvider = context.watch<QuestionProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('📚 Geçmiş'),
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: questionProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : questionProvider.questions.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadQuestions,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: questionProvider.questions.length,
                    itemBuilder: (context, index) {
                      final question = questionProvider.questions[index];
                      return RecentQuestionCard(
                        question: question,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatScreen(
                                questionType: question.type,
                                existingQuestion: question,
                              ),
                            ),
                          );
                        },
                      );
                    },
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
            Icons.history,
            size: 100,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 24),
          Text(
            'Henüz soru çözmediniz',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ana sayfadan soru çözmeye başlayın',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}
