import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/timeline/timeline_canvas.dart';
import '../widgets/inspector/inspector_panel.dart';
import '../widgets/editors/column_editor.dart';
import '../widgets/editors/row_editor.dart';
import '../widgets/settings/timeline_settings_dialog.dart';
import '../../domain/providers/timeline_provider.dart';
import '../../domain/providers/database_provider.dart';

/// Timeline Screen - Main interactive grid view
class TimelineScreen extends ConsumerStatefulWidget {
  const TimelineScreen({super.key});

  @override
  ConsumerState<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends ConsumerState<TimelineScreen> {
  bool _isInspectorOpen = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      print('📥 _initializeData() called');
      
      // Wait for Isar to initialize
      print('⏳ Waiting for Isar provider...');
      await ref.read(isarProvider.future);
      print('✅ Isar provider ready');
      
      final parser = ref.read(csvParserProvider);
      print('📊 Getting stats...');
      final stats = await ref.read(isarServiceProvider).getStats();
      print('📊 Stats received: $stats');
      
      // Import CSV if database is empty
      if (stats['events'] == 0) {
        print('📥 Database empty, importing CSV...');
        await parser.importFromAsset('assets/data.csv');
        print('✅ CSV import completed');
      } else {
        print('✅ Database already has data, skipping import');
      }
    } catch (e, stackTrace) {
      print('❌ _initializeData error: $e');
      print('Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Veri yükleme hatası: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isarAsync = ref.watch(isarProvider);
    
    // Wait for Isar to initialize
    return isarAsync.when(
      data: (_) => _buildContent(context),
      loading: () => const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Veritabanı başlatılıyor...'),
            ],
          ),
        ),
      ),
      error: (error, stack) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Hata: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(isarProvider);
                },
                child: const Text('Tekrar Dene'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final selectedEvent = ref.watch(selectedEventProvider);
    final civilizationsAsync = ref.watch(civilizationsProvider);
    final eventsAsync = ref.watch(eventsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Antik Medeniyetler Zaman Çizelgesi'),
            eventsAsync.when(
              data: (events) => Text(
                '${events.length} olay',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              loading: () => const SizedBox(),
              error: (_, __) => const SizedBox(),
            ),
          ],
        ),
        actions: [
          // Settings (Three dots menu)
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            tooltip: 'Ayarlar',
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const Row(
                  children: [
                    Icon(Icons.settings, size: 20),
                    SizedBox(width: 12),
                    Text('Timeline Ayarları'),
                  ],
                ),
                onTap: () {
                  Future.delayed(Duration.zero, () {
                    showDialog(
                      context: context,
                      builder: (context) => const TimelineSettingsDialog(),
                    );
                  });
                },
              ),
              PopupMenuItem(
                child: const Row(
                  children: [
                    Icon(Icons.view_column, size: 20),
                    SizedBox(width: 12),
                    Text('Yeni Sütun'),
                  ],
                ),
                onTap: () {
                  Future.delayed(Duration.zero, () => _showColumnEditor(context));
                },
              ),
              PopupMenuItem(
                child: const Row(
                  children: [
                    Icon(Icons.table_rows, size: 20),
                    SizedBox(width: 12),
                    Text('Yeni Satır'),
                  ],
                ),
                onTap: () {
                  Future.delayed(Duration.zero, () => _showRowEditor(context));
                },
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                child: const Row(
                  children: [
                    Icon(Icons.import_export, size: 20),
                    SizedBox(width: 12),
                    Text('CSV İçe Aktar'),
                  ],
                ),
                onTap: () {
                  // TODO: CSV import
                },
              ),
              PopupMenuItem(
                child: const Row(
                  children: [
                    Icon(Icons.download, size: 20),
                    SizedBox(width: 12),
                    Text('CSV Dışa Aktar'),
                  ],
                ),
                onTap: () {
                  // TODO: CSV export
                },
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, size: 20),
                    SizedBox(width: 12),
                    Text('Hakkında'),
                  ],
                ),
                onTap: () {
                  // TODO: About dialog
                },
              ),
            ],
          ),
          
          // Search
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearch(context),
            tooltip: 'Ara',
          ),
          
          // Filter
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilters(context),
            tooltip: 'Filtrele',
          ),
          
          // Refresh
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _initializeData(),
            tooltip: 'Yenile',
          ),
        ],
      ),
      body: civilizationsAsync.when(
        data: (civilizations) {
          if (civilizations.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return Row(
            children: [
              // Timeline Canvas
              Expanded(
                child: TimelineCanvas(
                  civilizations: civilizations,
                  onEventTap: (event) {
                    ref.read(selectedEventProvider.notifier).state = event;
                    setState(() {
                      _isInspectorOpen = true;
                    });
                  },
                ),
              ),
              
              // Inspector Panel
              if (_isInspectorOpen && selectedEvent != null)
                InspectorPanel(
                  event: selectedEvent,
                  onClose: () {
                    setState(() {
                      _isInspectorOpen = false;
                    });
                    ref.read(selectedEventProvider.notifier).state = null;
                  },
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Hata: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _initializeData(),
                child: const Text('Tekrar Dene'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showColumnEditor(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const ColumnEditor(),
    );
  }

  void _showRowEditor(BuildContext context) {
    final civilizations = ref.read(civilizationsProvider).value ?? [];
    showDialog(
      context: context,
      builder: (context) => RowEditor(civilizations: civilizations),
    );
  }

  void _showSearch(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ara'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Olay veya medeniyet ara...',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (value) {
            ref.read(searchQueryProvider.notifier).state = value;
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(searchQueryProvider.notifier).state = '';
              Navigator.pop(context);
            },
            child: const Text('Temizle'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  void _showFilters(BuildContext context) {
    final civilizations = ref.read(civilizationsProvider).value ?? [];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtreler'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<int?>(
              initialValue: ref.read(selectedCivilizationProvider),
              decoration: const InputDecoration(
                labelText: 'Medeniyet',
              ),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('Tümü'),
                ),
                ...civilizations.map((civ) => DropdownMenuItem(
                      value: civ.id,
                      child: Text(civ.name),
                    )),
              ],
              onChanged: (value) {
                ref.read(selectedCivilizationProvider.notifier).state = value;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(selectedCivilizationProvider.notifier).state = null;
              Navigator.pop(context);
            },
            child: const Text('Sıfırla'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }
}
