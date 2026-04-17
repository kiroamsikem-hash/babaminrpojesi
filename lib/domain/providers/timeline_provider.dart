import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/civilization.dart';
import '../../data/models/period_event.dart';
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

/// Selected Civilization Provider
final selectedCivilizationProvider = StateProvider<int?>((ref) => null);

/// Selected Event Provider
final selectedEventProvider = StateProvider<PeriodEvent?>((ref) => null);

/// Year Range Filter Provider
final yearRangeProvider = StateProvider<({int min, int max})>((ref) {
  return (min: -3900, max: -500);
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

/// Year List Provider (sorted)
final yearListProvider = Provider<List<int>>((ref) {
  final events = ref.watch(filteredEventsProvider);
  final years = events.map((e) => e.startYear).toSet().toList();
  years.sort();
  return years;
});
