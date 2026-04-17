import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Timeline Settings Provider
final timelineSettingsProvider = StateNotifierProvider<TimelineSettingsNotifier, TimelineSettings>((ref) {
  return TimelineSettingsNotifier();
});

class TimelineSettings {
  final int yearStep; // Yıllar kaçar kaçar artsın (1, 5, 10, 25, 50, 100)
  final int startYear; // Başlangıç yılı
  final int endYear; // Bitiş yılı
  final bool showEmptyRows; // Boş satırları göster
  final bool showEmptyColumns; // Boş sütunları göster
  final bool showGridLines; // Grid çizgilerini göster
  final bool showYearLabels; // Yıl etiketlerini göster
  final bool compactMode; // Kompakt mod (daha küçük hücreler)
  final bool showPhotos; // Fotoğrafları göster
  final bool showTags; // Etiketleri göster
  final String dateFormat; // Tarih formatı (BC, BCE, M.Ö.)
  final bool highlightCenturies; // Yüzyılları vurgula
  final bool highlightDecades; // On yılları vurgula
  final int cellHeight; // Hücre yüksekliği (px)
  final int cellWidth; // Hücre genişliği (px)

  TimelineSettings({
    this.yearStep = 50,
    this.startYear = -3900,
    this.endYear = -500,
    this.showEmptyRows = false,
    this.showEmptyColumns = true,
    this.showGridLines = true,
    this.showYearLabels = true,
    this.compactMode = false,
    this.showPhotos = true,
    this.showTags = true,
    this.dateFormat = 'M.Ö.',
    this.highlightCenturies = true,
    this.highlightDecades = false,
    this.cellHeight = 60,
    this.cellWidth = 200,
  });

  TimelineSettings copyWith({
    int? yearStep,
    int? startYear,
    int? endYear,
    bool? showEmptyRows,
    bool? showEmptyColumns,
    bool? showGridLines,
    bool? showYearLabels,
    bool? compactMode,
    bool? showPhotos,
    bool? showTags,
    String? dateFormat,
    bool? highlightCenturies,
    bool? highlightDecades,
    int? cellHeight,
    int? cellWidth,
  }) {
    return TimelineSettings(
      yearStep: yearStep ?? this.yearStep,
      startYear: startYear ?? this.startYear,
      endYear: endYear ?? this.endYear,
      showEmptyRows: showEmptyRows ?? this.showEmptyRows,
      showEmptyColumns: showEmptyColumns ?? this.showEmptyColumns,
      showGridLines: showGridLines ?? this.showGridLines,
      showYearLabels: showYearLabels ?? this.showYearLabels,
      compactMode: compactMode ?? this.compactMode,
      showPhotos: showPhotos ?? this.showPhotos,
      showTags: showTags ?? this.showTags,
      dateFormat: dateFormat ?? this.dateFormat,
      highlightCenturies: highlightCenturies ?? this.highlightCenturies,
      highlightDecades: highlightDecades ?? this.highlightDecades,
      cellHeight: cellHeight ?? this.cellHeight,
      cellWidth: cellWidth ?? this.cellWidth,
    );
  }

  /// Get years list based on settings
  List<int> getYearsList() {
    final years = <int>[];
    for (int year = startYear; year <= endYear; year += yearStep) {
      years.add(year);
    }
    return years;
  }

  /// Format year based on settings
  String formatYear(int year) {
    final absYear = year.abs();
    switch (dateFormat) {
      case 'BC':
        return 'BC $absYear';
      case 'BCE':
        return '$absYear BCE';
      case 'M.Ö.':
      default:
        return 'M.Ö. $absYear';
    }
  }
}

class TimelineSettingsNotifier extends StateNotifier<TimelineSettings> {
  TimelineSettingsNotifier() : super(TimelineSettings());

  void updateYearStep(int step) {
    state = state.copyWith(yearStep: step);
  }

  void updateYearRange(int start, int end) {
    state = state.copyWith(startYear: start, endYear: end);
  }

  void toggleShowEmptyRows() {
    state = state.copyWith(showEmptyRows: !state.showEmptyRows);
  }

  void toggleShowEmptyColumns() {
    state = state.copyWith(showEmptyColumns: !state.showEmptyColumns);
  }

  void toggleShowGridLines() {
    state = state.copyWith(showGridLines: !state.showGridLines);
  }

  void toggleShowYearLabels() {
    state = state.copyWith(showYearLabels: !state.showYearLabels);
  }

  void toggleCompactMode() {
    state = state.copyWith(compactMode: !state.compactMode);
  }

  void toggleShowPhotos() {
    state = state.copyWith(showPhotos: !state.showPhotos);
  }

  void toggleShowTags() {
    state = state.copyWith(showTags: !state.showTags);
  }

  void updateDateFormat(String format) {
    state = state.copyWith(dateFormat: format);
  }

  void toggleHighlightCenturies() {
    state = state.copyWith(highlightCenturies: !state.highlightCenturies);
  }

  void toggleHighlightDecades() {
    state = state.copyWith(highlightDecades: !state.highlightDecades);
  }

  void updateCellSize(int height, int width) {
    state = state.copyWith(cellHeight: height, cellWidth: width);
  }

  void resetToDefaults() {
    state = TimelineSettings();
  }
}

/// Timeline Settings Dialog
class TimelineSettingsDialog extends ConsumerStatefulWidget {
  const TimelineSettingsDialog({super.key});

  @override
  ConsumerState<TimelineSettingsDialog> createState() => _TimelineSettingsDialogState();
}

class _TimelineSettingsDialogState extends ConsumerState<TimelineSettingsDialog> {
  late TextEditingController _startYearController;
  late TextEditingController _endYearController;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(timelineSettingsProvider);
    _startYearController = TextEditingController(text: settings.startYear.toString());
    _endYearController = TextEditingController(text: settings.endYear.toString());
  }

  @override
  void dispose() {
    _startYearController.dispose();
    _endYearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(timelineSettingsProvider);
    final notifier = ref.read(timelineSettingsProvider.notifier);

    return Dialog(
      child: Container(
        width: 700,
        constraints: const BoxConstraints(maxHeight: 800),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.settings, color: Colors.blue),
                const SizedBox(width: 12),
                Text(
                  'Timeline Ayarları',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    notifier.resetToDefaults();
                    _startYearController.text = settings.startYear.toString();
                    _endYearController.text = settings.endYear.toString();
                  },
                  tooltip: 'Varsayılana Dön',
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // YEAR RANGE SECTION
                    _buildSectionTitle('📅 Tarih Aralığı'),
                    const SizedBox(height: 12),
                    
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _startYearController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Başlangıç Yılı',
                              hintText: '-3900',
                              prefixIcon: Icon(Icons.calendar_today),
                            ),
                            onChanged: (value) {
                              final year = int.tryParse(value);
                              if (year != null) {
                                notifier.updateYearRange(year, settings.endYear);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: _endYearController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Bitiş Yılı',
                              hintText: '-500',
                              prefixIcon: Icon(Icons.event_available),
                            ),
                            onChanged: (value) {
                              final year = int.tryParse(value);
                              if (year != null) {
                                notifier.updateYearRange(settings.startYear, year);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Quick presets
                    const Text('Hızlı Seçim:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        _buildPresetChip('Tunç Çağı', -3300, -1200, notifier),
                        _buildPresetChip('Demir Çağı', -1200, -500, notifier),
                        _buildPresetChip('Tümü', -3900, -500, notifier),
                        _buildPresetChip('Son 1000 Yıl', -1500, -500, notifier),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // YEAR STEP SECTION
                    _buildSectionTitle('⏱️ Yıl Adımı'),
                    const SizedBox(height: 12),
                    const Text('Tarihler kaçar kaçar artsın:'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [1, 5, 10, 25, 50, 100, 200, 500].map((step) {
                        return ChoiceChip(
                          label: Text('$step yıl'),
                          selected: settings.yearStep == step,
                          onSelected: (selected) {
                            if (selected) notifier.updateYearStep(step);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Toplam ${((settings.endYear - settings.startYear) / settings.yearStep).ceil()} satır gösterilecek',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 24),

                    // DATE FORMAT SECTION
                    _buildSectionTitle('🌍 Tarih Formatı'),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: ['M.Ö.', 'BC', 'BCE'].map((format) {
                        return ChoiceChip(
                          label: Text(format),
                          selected: settings.dateFormat == format,
                          onSelected: (selected) {
                            if (selected) notifier.updateDateFormat(format);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Örnek: ${settings.formatYear(-1200)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // DISPLAY OPTIONS SECTION
                    _buildSectionTitle('👁️ Görünüm Seçenekleri'),
                    const SizedBox(height: 12),
                    
                    SwitchListTile(
                      title: const Text('Grid Çizgilerini Göster'),
                      subtitle: const Text('Hücre sınırlarını göster'),
                      value: settings.showGridLines,
                      onChanged: (_) => notifier.toggleShowGridLines(),
                    ),
                    
                    SwitchListTile(
                      title: const Text('Yıl Etiketlerini Göster'),
                      subtitle: const Text('Sol taraftaki yıl sütununu göster'),
                      value: settings.showYearLabels,
                      onChanged: (_) => notifier.toggleShowYearLabels(),
                    ),
                    
                    SwitchListTile(
                      title: const Text('Fotoğrafları Göster'),
                      subtitle: const Text('Satır ve sütun fotoğraflarını göster'),
                      value: settings.showPhotos,
                      onChanged: (_) => notifier.toggleShowPhotos(),
                    ),
                    
                    SwitchListTile(
                      title: const Text('Etiketleri Göster'),
                      subtitle: const Text('Olay ve medeniyet etiketlerini göster'),
                      value: settings.showTags,
                      onChanged: (_) => notifier.toggleShowTags(),
                    ),
                    
                    SwitchListTile(
                      title: const Text('Boş Satırları Göster'),
                      subtitle: const Text('Hiç olay olmayan yılları göster'),
                      value: settings.showEmptyRows,
                      onChanged: (_) => notifier.toggleShowEmptyRows(),
                    ),
                    
                    SwitchListTile(
                      title: const Text('Boş Sütunları Göster'),
                      subtitle: const Text('Hiç olay olmayan medeniyetleri göster'),
                      value: settings.showEmptyColumns,
                      onChanged: (_) => notifier.toggleShowEmptyColumns(),
                    ),
                    const SizedBox(height: 24),

                    // HIGHLIGHT OPTIONS SECTION
                    _buildSectionTitle('✨ Vurgulama'),
                    const SizedBox(height: 12),
                    
                    SwitchListTile(
                      title: const Text('Yüzyılları Vurgula'),
                      subtitle: const Text('100\'er yıllık aralıkları farklı renkle göster'),
                      value: settings.highlightCenturies,
                      onChanged: (_) => notifier.toggleHighlightCenturies(),
                    ),
                    
                    SwitchListTile(
                      title: const Text('On Yılları Vurgula'),
                      subtitle: const Text('10\'ar yıllık aralıkları farklı renkle göster'),
                      value: settings.highlightDecades,
                      onChanged: (_) => notifier.toggleHighlightDecades(),
                    ),
                    const SizedBox(height: 24),

                    // CELL SIZE SECTION
                    _buildSectionTitle('📏 Hücre Boyutu'),
                    const SizedBox(height: 12),
                    
                    SwitchListTile(
                      title: const Text('Kompakt Mod'),
                      subtitle: const Text('Daha küçük hücreler, daha fazla veri'),
                      value: settings.compactMode,
                      onChanged: (_) => notifier.toggleCompactMode(),
                    ),
                    
                    const SizedBox(height: 12),
                    Text('Hücre Yüksekliği: ${settings.cellHeight}px'),
                    Slider(
                      value: settings.cellHeight.toDouble(),
                      min: 40,
                      max: 120,
                      divisions: 8,
                      label: '${settings.cellHeight}px',
                      onChanged: (value) {
                        notifier.updateCellSize(value.toInt(), settings.cellWidth);
                      },
                    ),
                    
                    const SizedBox(height: 12),
                    Text('Hücre Genişliği: ${settings.cellWidth}px'),
                    Slider(
                      value: settings.cellWidth.toDouble(),
                      min: 120,
                      max: 300,
                      divisions: 9,
                      label: '${settings.cellWidth}px',
                      onChanged: (value) {
                        notifier.updateCellSize(settings.cellHeight, value.toInt());
                      },
                    ),
                  ],
                ),
              ),
            ),

            const Divider(),

            // Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${settings.getYearsList().length} satır × ${settings.cellHeight}px = ${(settings.getYearsList().length * settings.cellHeight / 1000).toStringAsFixed(1)}k px',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Kapat'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context, true),
                      icon: const Icon(Icons.check),
                      label: const Text('Uygula'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildPresetChip(String label, int start, int end, TimelineSettingsNotifier notifier) {
    return ActionChip(
      label: Text(label),
      onPressed: () {
        notifier.updateYearRange(start, end);
        _startYearController.text = start.toString();
        _endYearController.text = end.toString();
      },
    );
  }
}
