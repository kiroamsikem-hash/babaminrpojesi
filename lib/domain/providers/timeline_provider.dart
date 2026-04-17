import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/civilization.dart';
import '../../data/models/period_event.dart';
import '../../data/models/year_row.dart';
import '../../presentation/widgets/settings/timeline_settings_dialog.dart';
import 'database_provider.dart';

/// All Civilizations Provider (Stream)
final civilizationsProvider = StreamProvider<List<Civilization>>((ref) async* {
  print('🏛️ civilizationsProvider called');
  // Wait for Isar to initialize first
  await ref.watch(isarProvider.future);
  print('✅ Isar ready, starting civilizations stream');
  final repo = ref.watch(civilizationRepositoryProvider);
  yield* repo.watchAll();
});

/// All Events Provider (Stream)
final eventsProvider = StreamProvider<List<PeriodEvent>>((ref) async* {
  print('📅 eventsProvider called');
  // Wait for Isar to initialize first
  await ref.watch(isarProvider.future);
  print('✅ Isar ready, starting events stream');
  final repo = ref.watch(eventRepositoryProvider);
  yield* repo.watchAll();
});

/// Year Rows Provider - Simple map for now
final yearRowMapProvider = StateProvider<Map<int, YearRow>>((ref) {
  return {};
});

/// Selected Civilization Provider
final selectedCivilizationProvider = StateProvider<int?>((ref) => null);

/// Selected Event Provider
final selectedEventProvider = StateProvider<PeriodEvent?>((ref) => null);

/// Selected Row (Year) Provider - Excel gibi satır seçimi
final selectedRowProvider = StateProvider<int?>((ref) => null);

/// Year Range Filter Provider (now uses settings)
final yearRangeProvider = Provider<({int min, int max})>((ref) {
  final settings = ref.watch(timelineSettingsProvider);
  return (min: settings.startYear, max: settings.endYear);
});

/// Search Query Provider
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Filtered Events Provider
final filteredEventsProvider = Provider<List<PeriodEvent>>((ref) {
  final eventsAsync = ref.watch(eventsProvider);
  final selectedCivId = ref.watch(selectedCivilizationProvider);
  final yearRange = ref.watch(yearRangeProvider);
  final searchQuery = ref.watch(searchQueryProvider);

  return eventsAsync.when(
    data: (events) {
      var filtered = events;

      // Filter by civilization
      if (selectedCivId != null) {
        filtered = filtered
            .where((e) => e.civilizationId == selectedCivId)
            .toList();
      }

      // Filter by year range
      filtered = filtered
          .where((e) =>
              e.startYear >= yearRange.min && e.startYear <= yearRange.max)
          .toList();

      // Filter by search query
      if (searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        filtered = filtered
            .where((e) =>
                e.title.toLowerCase().contains(query) ||
                (e.description?.toLowerCase().contains(query) ?? false))
            .toList();
      }

      return filtered;
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Timeline Grid Data Provider
/// Groups events by year and civilization for grid rendering
final timelineGridProvider = Provider<Map<int, Map<int, PeriodEvent>>>((ref) {
  final events = ref.watch(filteredEventsProvider);

  final grid = <int, Map<int, PeriodEvent>>{};

  for (var event in events) {
    if (!grid.containsKey(event.startYear)) {
      grid[event.startYear] = {};
    }
    grid[event.startYear]![event.civilizationId] = event;
  }

  return grid;
});

/// Year List Provider (sorted, uses settings)
final yearListProvider = Provider<List<int>>((ref) {
  final settings = ref.watch(timelineSettingsProvider);
  return settings.getYearsList();
});
