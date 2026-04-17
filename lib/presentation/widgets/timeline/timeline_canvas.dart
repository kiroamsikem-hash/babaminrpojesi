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

  void _showRowContextMenu(BuildContext context, Offset position, int year) async {
    final value = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx + 1,
        position.dy + 1,
      ),
      items: const <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'edit_row',
          child: Row(
            children: [
              Icon(Icons.edit, size: 18),
              SizedBox(width: 8),
              Text('Satırı Düzenle'),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'add_photo',
          child: Row(
            children: [
              Icon(Icons.add_photo_alternate, size: 18),
              SizedBox(width: 8),
              Text('Satıra Fotoğraf Ekle'),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'add_tag',
          child: Row(
            children: [
              Icon(Icons.label, size: 18),
              SizedBox(width: 8),
              Text('Satıra Etiket Ekle'),
            ],
          ),
        ),
        PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'add_event',
          child: Row(
            children: [
              Icon(Icons.add, size: 18),
              SizedBox(width: 8),
              Text('Bu Yıla Olay Ekle'),
            ],
          ),
        ),
      ],
    );
    
    if (value == 'edit_row' || value == 'add_photo' || value == 'add_tag') {
      // Get existing year row from state
      final yearRowMap = ref.read(yearRowMapProvider);
      final yearRow = yearRowMap[year];
      
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => YearRowEditor(
            year: year,
            yearRow: yearRow,
          ),
        );
      }
    } else if (value == 'add_event') {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => RowEditor(
            civilizations: widget.civilizations,
          ),
        );
      }
    }
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
    final yearRowMap = ref.watch(yearRowMapProvider);
    final selectedRow = ref.watch(selectedRowProvider);
    
    return Container(
      width: AppConstants.axisWidth,
      color: AppColors.surface,
      child: Column(
        children: years.map((year) {
          final yearRow = yearRowMap[year];
          final isSelected = selectedRow == year;
          
          return GestureDetector(
            onTap: () {
              // Satırı seç/deselect et
              ref.read(selectedRowProvider.notifier).state = 
                  isSelected ? null : year;
            },
            onSecondaryTapDown: (details) {
              _showRowContextMenu(context, details.globalPosition, year);
            },
            onLongPress: () {
              // For mobile
              final RenderBox box = context.findRenderObject() as RenderBox;
              final Offset position = box.localToGlobal(Offset.zero);
              _showRowContextMenu(context, position, year);
            },
            child: Container(
              height: AppConstants.yearHeight,
              decoration: BoxDecoration(
                color: isSelected 
                    ? Colors.blue.withValues(alpha: 0.2) 
                    : Colors.transparent,
                border: Border.all(
                  color: isSelected 
                      ? Colors.blue.withValues(alpha: 0.5)
                      : AppColors.border,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Stack(
                children: [
                  // Photo background if exists
                  if (yearRow?.photoUrl != null || yearRow?.photoPath != null)
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.2,
                        child: Image.network(
                          yearRow!.photoUrl ?? yearRow.photoPath!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const SizedBox(),
                        ),
                      ),
                    ),
                  // Year label
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'M.Ö. ${year.abs()}',
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: 'monospace',
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? Colors.blue : Colors.white,
                          ),
                        ),
                        if (yearRow?.tags != null && yearRow!.tags!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                yearRow.tags!.first,
                                style: const TextStyle(
                                  fontSize: 8,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEventGrid(List<int> years, Map<int, Map<int, PeriodEvent>> gridData) {
    final selectedRow = ref.watch(selectedRowProvider);
    
    return Stack(
      children: [
        // Grid cells (background)
        Column(
          children: years.map((year) {
            final isSelected = selectedRow == year;

            return GestureDetector(
              onTap: () {
                ref.read(selectedRowProvider.notifier).state = 
                    isSelected ? null : year;
              },
              child: Container(
                height: AppConstants.yearHeight,
                decoration: BoxDecoration(
                  color: isSelected 
                      ? Colors.blue.withValues(alpha: 0.1) 
                      : Colors.transparent,
                  border: Border.all(
                    color: isSelected 
                        ? Colors.blue.withValues(alpha: 0.5)
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Row(
                  children: widget.civilizations.map((civ) {
                    return Container(
                      width: AppConstants.columnWidth,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                      ),
                    );
                  }).toList(),
                ),
              ),
            );
          }).toList(),
        ),
        
        // Event bars (overlay) - VERTICAL spanning from start year to end year
        ...widget.civilizations.asMap().entries.expand((civEntry) {
          final civIndex = civEntry.key;
          final civ = civEntry.value;
          
          // Get all unique events for this civilization
          final civEvents = <PeriodEvent>[];
          final processedEventIds = <int>{};
          
          for (var yearEvents in gridData.values) {
            if (yearEvents.containsKey(civ.id)) {
              final event = yearEvents[civ.id]!;
              if (event.id != null && !processedEventIds.contains(event.id)) {
                civEvents.add(event);
                processedEventIds.add(event.id!);
              }
            }
          }
          
          return civEvents.map((event) {
            final startYear = event.startYear;
            final endYear = event.endYear ?? event.startYear;
            
            // Calculate position based on actual years, not year list indices
            final minYear = years.first;
            final maxYear = years.last;
            final totalYearRange = (maxYear - minYear).abs();
            final totalPixelHeight = years.length * AppConstants.yearHeight;
            
            // Calculate where start year falls in the timeline
            final startOffset = (startYear - minYear).abs();
            final startPixelOffset = (startOffset / totalYearRange) * totalPixelHeight;
            
            // Calculate bar height based on year span
            final yearSpan = (endYear - startYear).abs();
            final barHeight = (yearSpan / totalYearRange) * totalPixelHeight;
            
            // Position
            final left = AppConstants.axisWidth + (civIndex * AppConstants.columnWidth) + 4;
            final top = AppConstants.headerHeight + startPixelOffset + 4;
            final barWidth = AppConstants.columnWidth - 8;
            
            return Positioned(
              left: left,
              top: top,
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
                  width: barWidth,
                  height: barHeight.clamp(20.0, double.infinity),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(civ.colorValue).withValues(alpha: 0.9),
                        Color(civ.colorValue).withValues(alpha: 0.7),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Color(civ.colorValue).withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
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
                      // Content
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (event.period != null && barHeight > 60)
                              Text(
                                event.period!,
                                style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white70,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            const SizedBox(height: 4),
                            Flexible(
                              child: Text(
                                event.title,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                                maxLines: (barHeight / 20).floor().clamp(1, 10),
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            if (yearSpan > 0 && barHeight > 40)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.white24,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${yearSpan}y',
                                    style: const TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
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
          });
        }).toList(),
      ],
    );
  }
  
  void _showEventContextMenu(BuildContext context, Offset position, PeriodEvent event) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx + 1,
        position.dy + 1,
      ),
      items: const <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit, size: 18),
              SizedBox(width: 8),
              Text('Düzenle'),
            ],
          ),
        ),
        PopupMenuItem<String>(
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
      if (value == 'edit') {
        showDialog(
          context: context,
          builder: (context) => RowEditor(
            event: event,
            civilizations: widget.civilizations,
          ),
        );
      } else if (value == 'delete') {
        ref.read(eventRepositoryProvider).delete(event.id!);
      }
    });
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
