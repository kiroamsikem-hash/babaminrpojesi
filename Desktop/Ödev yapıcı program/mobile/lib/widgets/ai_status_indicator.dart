import 'package:flutter/material.dart';
import '../config/theme_v2.dart';

class AIStatusIndicator extends StatelessWidget {
  final String status;
  
  const AIStatusIndicator({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final statusInfo = _getStatusInfo(status);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: QuietTechColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: QuietTechColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(statusInfo['color']),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${statusInfo['icon']} ${statusInfo['text']}',
            style: TextStyle(
              fontSize: 14,
              color: QuietTechColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  
  Map<String, dynamic> _getStatusInfo(String status) {
    switch (status) {
      case 'analyzing':
        return {
          'icon': '🔍',
          'text': 'Soru analiz ediliyor...',
          'color': QuietTechColors.cardBlue,
        };
      case 'checking_curriculum':
        return {
          'icon': '📚',
          'text': 'Müfredat kontrol ediliyor...',
          'color': QuietTechColors.cardPurple,
        };
      case 'generating':
        return {
          'icon': '✨',
          'text': 'Çözüm hazırlanıyor...',
          'color': QuietTechColors.primary,
        };
      case 'complete':
        return {
          'icon': '✅',
          'text': 'Çözüm hazır!',
          'color': QuietTechColors.success,
        };
      default:
        return {
          'icon': '🤖',
          'text': 'İşleniyor...',
          'color': QuietTechColors.textSecondary,
        };
    }
  }
}
