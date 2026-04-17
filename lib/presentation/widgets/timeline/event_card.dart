import 'package:flutter/material.dart';
import '../../../data/models/period_event.dart';
import '../../../data/models/civilization.dart';
import '../../../core/constants/app_constants.dart';
import '../editors/row_editor.dart';

/// Event Card Widget
class EventCard extends StatelessWidget {
  final PeriodEvent event;
  final Civilization civilization;
  final List<Civilization> allCivilizations;
  final VoidCallback onTap;

  const EventCard({
    super.key,
    required this.event,
    required this.civilization,
    required this.allCivilizations,
    required this.onTap,
  });

  void _showContextMenu(BuildContext context, Offset position) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx + 1,
        position.dy + 1,
      ),
      items: [
        const PopupMenuItem<String>(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit, size: 18),
              SizedBox(width: 8),
              Text('Düzenle'),
            ],
          ),
        ),
        const PopupMenuItem<String>(
          value: 'add_photo',
          child: Row(
            children: [
              Icon(Icons.add_photo_alternate, size: 18),
              SizedBox(width: 8),
              Text('Fotoğraf Ekle'),
            ],
          ),
        ),
        const PopupMenuItem<String>(
          value: 'add_tag',
          child: Row(
            children: [
              Icon(Icons.label, size: 18),
              SizedBox(width: 8),
              Text('Etiket Ekle'),
            ],
          ),
        ),
        const PopupMenuItem<String>(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, size: 18, color: Colors.red),
              SizedBox(width: 8),
              Text('Sil', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (value == 'edit' || value == 'add_photo' || value == 'add_tag') {
        showDialog(
          context: context,
          builder: (context) => RowEditor(
            event: event,
            civilizations: allCivilizations,
          ),
        );
      } else if (value == 'delete') {
        // TODO: Delete confirmation
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onSecondaryTapDown: (details) {
        _showContextMenu(context, details.globalPosition);
      },
      onLongPress: () {
        // For mobile - show context menu on long press
        final RenderBox box = context.findRenderObject() as RenderBox;
        final Offset position = box.localToGlobal(Offset.zero);
        _showContextMenu(context, position);
      },
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
        child: Stack(
          children: [
            // Photo background if exists
            if (event.photoUrl != null || event.photoPath != null)
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
                  child: Opacity(
                    opacity: 0.3,
                    child: Image.network(
                      event.photoUrl ?? event.photoPath!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox(),
                    ),
                  ),
                ),
              ),
            // Content
            Padding(
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
                  if (event.tags != null && event.tags!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Wrap(
                        spacing: 4,
                        children: event.tags!.take(2).map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              tag,
                              style: const TextStyle(
                                fontSize: 9,
                                color: Colors.white,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
