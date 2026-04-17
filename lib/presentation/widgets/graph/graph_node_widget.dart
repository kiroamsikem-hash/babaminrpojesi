import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';

/// Graph Node Widget
class GraphNodeWidget extends StatelessWidget {
  final int id;
  final String type;
  final String title;
  final bool isCenter;
  final VoidCallback onTap;

  const GraphNodeWidget({
    super.key,
    required this.id,
    required this.type,
    required this.title,
    required this.isCenter,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: AppConstants.nodeRadius * 2,
        height: AppConstants.nodeRadius * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: isCenter
                ? [AppColors.primary, AppColors.secondary]
                : [AppColors.surfaceVariant, AppColors.surface],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: isCenter ? AppColors.primary : AppColors.border,
            width: isCenter ? 3 : 2,
          ),
          boxShadow: [
            BoxShadow(
              color: (isCenter ? AppColors.primary : AppColors.border)
                  .withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getIcon(),
              color: isCenter ? Colors.white : AppColors.textPrimary,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isCenter ? FontWeight.bold : FontWeight.normal,
                color: isCenter ? Colors.white : AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIcon() {
    switch (type) {
      case 'event':
        return Icons.event;
      case 'artifact':
        return Icons.museum;
      case 'civilization':
        return Icons.public;
      default:
        return Icons.circle;
    }
  }
}
