import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../config/theme.dart';
import '../config/constants.dart';
import '../models/question_model.dart';

class RecentQuestionCard extends StatelessWidget {
  final Question question;
  final VoidCallback onTap;

  const RecentQuestionCard({
    super.key,
    required this.question,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    timeago.setLocaleMessages('tr', timeago.TrMessages());

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getTypeColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  AppConstants.questionTypeIcons[question.type] ?? '💡',
                  style: const TextStyle(fontSize: 24),
                ),
              ),
              const SizedBox(width: 16),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _truncateText(question.question, 50),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      timeago.format(question.createdAt, locale: 'tr'),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Arrow
              const Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getTypeColor() {
    switch (question.type) {
      case 'matematik':
        return const Color(0xFFFF6B9D);
      case 'kompozisyon':
        return const Color(0xFF4ECDC4);
      case 'ceviri':
        return const Color(0xFF4A90E2);
      default:
        return AppColors.primary;
    }
  }

  String _truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }
}
