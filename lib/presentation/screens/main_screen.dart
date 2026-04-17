import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'timeline_screen.dart';
import 'graph_screen.dart';
import '../../domain/providers/database_provider.dart';

/// Main Screen with Navigation
class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const TimelineScreen(),
    const GraphScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final dbStatsAsync = ref.watch(databaseStatsProvider);

    return Scaffold(
      body: Row(
        children: [
          // Navigation Rail
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.grid_on),
                label: Text('Timeline'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.account_tree),
                label: Text('Graph'),
              ),
            ],
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.settings),
                        onPressed: () {
                          _showSettings(context);
                        },
                        tooltip: 'Ayarlar',
                      ),
                      const SizedBox(height: 8),
                      dbStatsAsync.when(
                        data: (stats) => Tooltip(
                          message: 'Toplam: ${stats['events']} olay',
                          child: Icon(
                            Icons.info_outline,
                            size: 20,
                            color: Colors.grey[600],
                          ),
                        ),
                        loading: () => const SizedBox(),
                        error: (_, __) => const SizedBox(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          const VerticalDivider(thickness: 1, width: 1),
          
          // Main Content
          Expanded(
            child: _screens[_selectedIndex],
          ),
        ],
      ),
    );
  }

  void _showSettings(BuildContext context) {
    final stats = ref.read(databaseStatsProvider).value;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Veritabanı İstatistikleri'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Medeniyetler: ${stats?['civilizations'] ?? 0}'),
            Text('Olaylar: ${stats?['events'] ?? 0}'),
            Text('Buluntular: ${stats?['artifacts'] ?? 0}'),
            Text('Medya Dosyaları: ${stats?['mediaFiles'] ?? 0}'),
            Text('Bağlantılar: ${stats?['connections'] ?? 0}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }
}
