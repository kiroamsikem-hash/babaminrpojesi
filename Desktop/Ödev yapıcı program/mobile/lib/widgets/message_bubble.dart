import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/theme.dart';

class MessageBubble extends StatelessWidget {
  final String message;
  final bool isUser;
  final bool isMarkdown;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isUser,
    this.isMarkdown = false,
  });

  List<TextSpan> _parseMessage(String text) {
    final List<TextSpan> spans = [];
    final lines = text.split('\n');

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      
      // Başlıklar (📚, 🎯, 💡, ✅)
      if (line.startsWith('📚') || line.startsWith('🎯') || 
          line.startsWith('💡') || line.startsWith('✅') ||
          line.startsWith('📝') || line.startsWith('🌍')) {
        spans.add(TextSpan(
          text: line + '\n',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
            height: 1.8,
          ),
        ));
      }
      // Numaralı adımlar (1., 2., 3.)
      else if (RegExp(r'^\d+\.').hasMatch(line.trim())) {
        spans.add(TextSpan(
          text: line + '\n',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            height: 1.6,
          ),
        ));
      }
      // Normal metin
      else {
        spans.add(TextSpan(
          text: line + (i < lines.length - 1 ? '\n' : ''),
          style: const TextStyle(
            fontSize: 15,
            color: AppColors.textPrimary,
            height: 1.5,
          ),
        ));
      }
    }

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.85,
        ),
        margin: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: isUser ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(20).copyWith(
                  bottomRight: isUser ? const Radius.circular(4) : null,
                  bottomLeft: !isUser ? const Radius.circular(4) : null,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: isUser
                  ? Text(
                      message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        height: 1.4,
                      ),
                    )
                  : RichText(
                      text: TextSpan(
                        children: _parseMessage(message),
                        style: const TextStyle(
                          fontFamily: 'Roboto',
                        ),
                      ),
                    ),
            ),
            if (!isUser) ...[
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.copy, size: 18),
                    color: Colors.grey[600],
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: message));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Kopyalandı!'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
