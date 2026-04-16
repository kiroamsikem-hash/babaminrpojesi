import 'package:flutter/material.dart';
import '../../../data/models/period_event.dart';
import '../../../data/models/civilization.dart';
import '../../../core/constants/app_constants.dart';

/// Event Card Widget
class EventCard extends StatelessWidget {
  final PeriodEvent event;
  final Civilization civilization;
  final VoidCallback onTap;

  const EventCard({
    super.key,
    required this.event,
    required this.civilization,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(AppConstants.gridCellPadding),
        constraints: const BoxConstraints(
          minHeight: AppConstants.cardMinHeight,
          maxHeight: AppConstants.cardMaxHeight,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(civilization.colorValue).withValues(alpha: 0.9),
              Color(civilization.colorValue).withValues(alpha: 0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
          boxShadow: [
            BoxShadow(
              color: Color(civilization.colorValue).withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (event.period != null)
                Text(
                  event.period!,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 4),
              Flexible(
                child: Text(
                  event.title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
