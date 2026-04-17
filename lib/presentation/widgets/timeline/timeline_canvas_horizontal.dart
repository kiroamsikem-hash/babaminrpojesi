import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/civilization.dart';
import '../../../data/models/period_event.dart';
import '../../../data/models/year_row.dart';
import '../../../domain/providers/timeline_provider.dart';
import '../../../domain/providers/database_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../editors/column_editor.dart';
import '../editors/row_editor.dart';
import '../editors/year_row_editor.dart';

/// Horizontal Timeline Canvas - Gantt Chart Style
class TimelineCanvasHorizontal extends ConsumerStatefulWidget {
  final List<Civilization> civilizations;
  final Function(PeriodEvent) onEventTap;

  const TimelineCanvasHorizontal({
    super.key,
    required this.civilizations,
    required this.onEventTap,
  });

  @override
  ConsumerState<TimelineCanvasHorizontal> createState() => _TimelineCanvasHorizontalState();
}

class _TimelineCanvasHorizontalState extends ConsumerState<TimelineCanvasHorizontal> {
  final TransformationController _transformationController = TransformationController();

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final events = ref.watch(filteredEventsProvider);
    final years = ref.watch(yearListProvider);
    final yearRange = ref.watch(yearRangeProvider);

    if (years.isEmpty || widget.civilizations.isEmpty) {
      return const Center(child: Text('Veri bulunamadı'));
    }

    // Calculate year range for horizontal axis
    final minYear = yearRange.min;
    final maxYear = yearRange.max;
    final yearSpan = maxYear - minYear;
    final pixelsPerYear = 2.0; // 2 pixel per year
    final timelineWidth = yearSpan * pixelsPerYear;

    return InteractiveViewer(
      transformationController: _transformationController,
      minScale: 0.1,
      maxScale: 5.0,
      boundaryMargin: const EdgeInsets.all(double.infinity),
      constrained: false,
      child: Container(
        color: AppColors.background,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Year axis (horizontal)
            _buildYearAxis(minYear, maxYear, timelineWidth),
            
            // Civilization rows
            ...widget.civilizations.map((civ) {
              final civEvents = events.where((e) => e.civilizationId == civ.id).toList();
              return _buildCivilizationRow(civ, civEvents, minYear, maxYear, timelineWidth);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildYearAxis(int minYear, int maxYear, double timelineWidth) {
    final yearStep = _calculateYearStep(maxYear - minYear);
    
    return Container(
      height: 60,
      width: 200 + timelineWidth,
      color: AppColors.surface,
      child: Row(
        children: [
          // Corner cell
          Container(
            width: 200,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              border: Border.all(color: AppColors.border),
            ),
            child: const Center(
              child: Text(
                'Medeniyet',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ),
          
          // Year markers
          SizedBox(
            width: timelineWidth,
            child: CustomPaint(
              painter: YearAxisPainter(
                minYear: minYear,
                maxYear: maxYear,
                yearStep: yearStep,
                pixelsPerYear: 2.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCivilizationRow(
    Civilization civ,
    List<PeriodEvent> events,
    int minYear,
    int maxYear,
    double timelineWidth,
  ) {
    return GestureDetector(
      onSecondaryTapDown: (details) {
        _showCivContextMenu(context, details.globalPosition, civ);
      },
      onLongPress: () {
        final RenderBox box = context.findRenderObject() as RenderBox;
        final Offset position = box.localToGlobal(Offset.zero);
        _showCivContextMenu(context, position, civ);
      },
      child: Container(
        height: 80,
        width: 200 + timelineWidth,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            // Civilization name
            Container(
              width: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(civ.colorValue).withValues(alpha: 0.8),
                    Color(civ.colorValue).withValues(alpha: 0.6),
                  ],
                ),
                border: Border(right: BorderSide(color: AppColors.border)),
              ),
              child: Stack(
                children: [
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
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.white24,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    tag,
                                    style: const TextStyle(fontSize: 10, color: Colors.white),
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
            
            // Timeline area with events
            SizedBox(
              width: timelineWidth,
              child: Stack(
                children: events.map((event) {
                  return _buildEventBar(event, civ, minYear, maxYear);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventBar(PeriodEvent event, Civilization civ, int minYear, int maxYear) {
    final startYear = event.startYear;
    final endYear = event.endYear ?? event.startYear;
    
    // Calculate position and width
    final startX = (startYear - minYear) * 2.0;
    final duration = endYear - startYear;
    final width = duration == 0 ? 40.0 : duration * 2.0;
    
    return Positioned(
      left: startX,
      top: 10,
      child: GestureDetector(
        onTap: () => widget.onEventTap(event),
        onSecondaryTapDown: (details) {
          _showEventContextMenu(context, details.globalPosition, event);
        },
        onLongPress: () {
          final RenderBox box = context.findRenderObject() as RenderBox;
          final Offset position = box.localToGlobal(Offset.zero);
          _showEventContextMenu(context, position, event);
        },
        child: Container(
          width: width,
          height: 60,
          decoration: BoxDecoration(
            color: Color(civ.colorValue).withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Photo background
              if (event.photoUrl != null || event.photoPath != null)
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
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
              // Title
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      event.title,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (event.tags != null && event.tags!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Wrap(
                          spacing: 4,
                          children: event.tags!.take(2).map((tag) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                              decoration: BoxDecoration(
                                color: Colors.white24,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                tag,
                                style: const TextStyle(fontSize: 8, color: Colors.white),
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
      ),
    );
  }

  int _calculateYearStep(int yearSpan) {
    if (yearSpan > 2000) return 500;
    if (yearSpan > 1000) return 200;
    if (yearSpan > 500) return 100;
    if (yearSpan > 200) return 50;
    if (yearSpan > 100) return 25;
    if (yearSpan > 50) return 10;
    return 5;
  }

  void _showCivContextMenu(BuildContext context, Offset position, Civilization civ) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(position.dx, position.dy, position.dx + 1, position.dy + 1),
      items: [
        PopupMenuItem(
          child: const Row(
            children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text('Düzenle')],
          ),
          onTap: () {
            Future.delayed(Duration.zero, () {
              showDialog(context: context, builder: (context) => ColumnEditor(civilization: civ));
            });
          },
        ),
        PopupMenuItem(
          child: const Row(
            children: [Icon(Icons.add, size: 18), SizedBox(width: 8), Text('Olay Ekle')],
          ),
          onTap: () {
            Future.delayed(Duration.zero, () {
              showDialog(context: context, builder: (context) => RowEditor(civilizations: widget.civilizations));
            });
          },
        ),
      ],
    );
  }

  void _showEventContextMenu(BuildContext context, Offset position, PeriodEvent event) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(position.dx, position.dy, position.dx + 1, position.dy + 1),
      items: [
        PopupMenuItem(
          child: const Row(
            children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text('Düzenle')],
          ),
          onTap: () {
            Future.delayed(Duration.zero, () {
              showDialog(context: context, builder: (context) => RowEditor(event: event, civilizations: widget.civilizations));
            });
          },
        ),
        PopupMenuItem(
          child: const Row(
            children: [Icon(Icons.delete, size: 18), SizedBox(width: 8), Text('Sil')],
          ),
          onTap: () async {
            await ref.read(eventRepositoryProvider).delete(event.id!);
          },
        ),
      ],
    );
  }
}

/// Year Axis Painter
class YearAxisPainter extends CustomPainter {
  final int minYear;
  final int maxYear;
  final int yearStep;
  final double pixelsPerYear;

  YearAxisPainter({
    required this.minYear,
    required this.maxYear,
    required this.yearStep,
    required this.pixelsPerYear,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    for (int year = minYear; year <= maxYear; year += yearStep) {
      final x = (year - minYear) * pixelsPerYear;
      
      // Draw tick
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, 10),
        paint,
      );
      
      // Draw year label
      textPainter.text = TextSpan(
        text: 'M.Ö. ${year.abs()}',
        style: const TextStyle(fontSize: 10, color: Colors.white),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - textPainter.width / 2, 15));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
