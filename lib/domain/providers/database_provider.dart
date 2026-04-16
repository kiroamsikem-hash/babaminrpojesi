import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../../core/database/isar_service.dart';
import '../../data/repositories/civilization_repository.dart';
import '../../data/repositories/event_repository.dart';
import '../../data/repositories/connection_repository.dart';
import '../../data/parsers/csv_parser.dart';

/// Isar Database Provider
final isarServiceProvider = Provider<IsarService>((ref) {
  return IsarService.instance;
});

/// Isar Instance Provider
final isarProvider = FutureProvider<Isar>((ref) async {
  final service = ref.watch(isarServiceProvider);
  return await service.init();
});

/// Civilization Repository Provider
final civilizationRepositoryProvider = Provider<CivilizationRepository>((ref) {
  final service = ref.watch(isarServiceProvider);
  return CivilizationRepository(service);
});

/// Event Repository Provider
final eventRepositoryProvider = Provider<EventRepository>((ref) {
  final service = ref.watch(isarServiceProvider);
  return EventRepository(service);
});

/// Connection Repository Provider
final connectionRepositoryProvider = Provider<ConnectionRepository>((ref) {
  final service = ref.watch(isarServiceProvider);
  return ConnectionRepository(service);
});

/// CSV Parser Provider
final csvParserProvider = Provider<CsvParser>((ref) {
  final service = ref.watch(isarServiceProvider);
  return CsvParser(service);
});

/// Database Stats Provider
final databaseStatsProvider = FutureProvider<Map<String, int>>((ref) async {
  final service = ref.watch(isarServiceProvider);
  await ref.watch(isarProvider.future); // Ensure DB is initialized
  return await service.getStats();
});
