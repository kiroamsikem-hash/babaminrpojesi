import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/civilization.dart';
import '../../../data/models/period_event.dart';
import '../../../domain/providers/timeline_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../editors/column_editor.dart';
import '../editors/row_editor.dart';
import 'event_card.dart';

/// Interactive Timeline Canvas with Pan & Zoom
class TimelineCanvas extends ConsumerStatefulWidget {
  final List<Civilization> civilizations;
  final Function(PeriodEvent) onEventTap;

  const TimelineCanvas({
    super.key,
    required this.civilizations,
    required this.onEventTap,
  });

  @override
  ConsumerState<TimelineCanvas> createState() => _TimelineCanvasState();
}

class _TimelineCanvasState extends ConsumerState<TimelineCanvas> {
  final TransformationController _transformationController =
      TransformationController();

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void _showColumnContextMenu(BuildContext context, Offset position, Civilization civ) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx + 1,
        position.dy + 1,
      ),
      items: [
        PopupMenuItem(
          child: const Row(
            children: [
              Icon(Icons.edit, size: 18),
              SizedBox(width: 8),
              Text('Sütunu Düzenle'),
            ],
          ),
          onTap: () {
            Future.delayed(Duration.zero, () {
              showDialog(
                context: context,
                builder: (context) => ColumnEditor(civilization: civ),
              );
            });
          },
        ),
        PopupMenuItem(
          child: const Row(
            children: [
              Icon(Icons.add, size: 18),
              SizedBox(width: 8),
              Text('Yeni Satır Ekle'),
            ],
          ),
          onTap: () {
            Future.delayed(Duration.zero, () {
              showDialog(
                context: context,
                builder: (context) => RowEditor(
                  civilizations: widget.civilizations,
                ),
              );
            });
          },
        ),
      ],
    );
  }

  void _showRowContextMenu(BuildContext context, Offset position, int year) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx + 1,
        position.dy + 1,
      ),
      items: [
        PopupMenuItem(
          child: const Row(
            children: [
              Icon(Icons.add, size: 18),
              SizedBox(width: 8),
              Text('Bu Yıla Olay Ekle'),
            ],
          ),
          onTap: () {
            Future.delayed(Duration.zero, () {
              showDialog(
                context: context,
                builder: (context) => RowEditor(
                  civilizations: widget.civilizations,
                ),
              );
            });
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final gridData = ref.watch(timelineGridProvider);
    final years = ref.watch(yearListProvider);

    if (years.isEmpty) {
      return const Center(
        child: Text('Veri bulunamadı'),
      );
    }

    return InteractiveViewer(
      transformationController: _transformationController,
      minScale: AppConstants.minScale,
      maxScale: AppConstants.maxScale,
      boundaryMargin: const EdgeInsets.all(double.infinity),
      constrained: false,
      child: Container(
        color: AppColors.background,
        child: Stack(
          children: [
            // Grid Lines
            CustomPaint(
              size: Size(
                widget.civilizations.length * AppConstants.columnWidth +
                    AppConstants.axisWidth,
                years.length * AppConstants.yearHeight +
                    AppConstants.headerHeight,
              ),
              painter: GridPainter(
                civilizations: widget.civilizations,
                years: years,
              ),
            ),

            // Content
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row (Civilization Names)
                _buildHeader(),

                // Timeline Grid
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Year Axis
                    _buildYearAxis(years),

                    // Event Grid
                    _buildEventGrid(years, gridData),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: AppConstants.headerHeight,
      color: AppColors.surface,
      child: Row(
        children: [
          // Corner cell
          Container(
            width: AppConstants.axisWidth,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              border: Border.all(color: AppColors.border),
            ),
            child: const Center(
              child: Text(
                'Yıl',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),

          // Civilization headers
          ...widget.civilizations.asMap().entries.map((entry) {
            final index = entry.key;
            final civ = entry.value;
            return GestureDetector(
              onSecondaryTapDown: (details) {
                _showColumnContextMenu(context, details.globalPosition, civ);
              },
              child: Container(
                width: AppConstants.columnWidth,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(civ.colorValue).withValues(alpha: 0.8),
                      Color(civ.colorValue).withValues(alpha: 0.6),
                    ],
                  ),
                  border: Border.all(color: AppColors.border),
                ),
                child: Stack(
                  children: [
                    // Photo background if exists
                    if (civ.photoUrl != null || civ.photoPath != null)
                      Positioned.fill(
                        child: Opacity(
                          opacity: 0.3,
                          child: Image.network(
                            civ.photoUrl ?? civ.photoPath!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const SizedBox(),
                          ),
                        ),
                      ),
                    // Name
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            civ.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (civ.tags != null && civ.tags!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Wrap(
                                spacing: 4,
                                children: civ.tags!.take(2).map((tag) {
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
                                        fontSize: 10,
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
          }),
        ],
      ),
    );
  }

  Widget _buildYearAxis(List<int> years) {
    return Container(
      width: AppConstants.axisWidth,
      color: AppColors.surface,
      child: Column(
        children: years.map((year) {
          return GestureDetector(
            onSecondaryTapDown: (details) {
              _showRowContextMenu(context, details.globalPosition, year);
            },
            child: Container(
              height: AppConstants.yearHeight,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
              ),
              child: Center(
                child: Text(
                  'M.Ö. ${year.abs()}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEventGrid(List<int> years, Map<int, Map<int, PeriodEvent>> gridData) {
    return Column(
      children: years.map((year) {
        final yearEvents = gridData[year] ?? {};

        return SizedBox(
          height: AppConstants.yearHeight,
          child: Row(
            children: widget.civilizations.map((civ) {
              final event = yearEvents[civ.id];

              return Container(
                width: AppConstants.columnWidth,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                ),
                child: event != null
                    ? EventCard(
                        event: event,
                        civilization: civ,
                        allCivilizations: widget.civilizations,
                        onTap: () => widget.onEventTap(event),
                      )
                    : const SizedBox(),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}

/// Grid Painter for background lines
class GridPainter extends CustomPainter {
  final List<Civilization> civilizations;
  final List<int> years;

  GridPainter({
    required this.civilizations,
    required this.years,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.border
      ..strokeWidth = AppConstants.gridLineWidth;

    // Vertical lines
    for (var i = 0; i <= civilizations.length; i++) {
      final x = AppConstants.axisWidth + (i * AppConstants.columnWidth);
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // Horizontal lines
    for (var i = 0; i <= years.length; i++) {
      final y = AppConstants.headerHeight + (i * AppConstants.yearHeight);
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
