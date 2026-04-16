import 'package:isar/isar.dart';
import '../models/period_event.dart';
import '../../core/database/isar_service.dart';

/// Event Repository - CRUD operations
class EventRepository {
  final IsarService _isarService;

  EventRepository(this._isarService);

  Isar get _isar => _isarService.isar;

  /// Get all events
  Future<List<PeriodEvent>> getAll() async {
    return await _isar.periodEvents.where().sortByStartYear().findAll();
  }

  /// Get event by ID
  Future<PeriodEvent?> getById(int id) async {
    return await _isar.periodEvents.get(id);
  }

  /// Get events by civilization
  Future<List<PeriodEvent>> getByCivilization(int civilizationId) async {
    return await _isar.periodEvents
        .filter()
        .civilizationIdEqualTo(civilizationId)
        .sortByStartYear()
        .findAll();
  }

  /// Get events by year range
  Future<List<PeriodEvent>> getByYearRange(int startYear, int endYear) async {
    return await _isar.periodEvents
        .filter()
        .startYearBetween(startYear, endYear)
        .sortByStartYear()
        .findAll();
  }

  /// Get events by period
  Future<List<PeriodEvent>> getByPeriod(String period) async {
    return await _isar.periodEvents
        .filter()
        .periodEqualTo(period)
        .sortByStartYear()
        .findAll();
  }

  /// Create event
  Future<int> create(PeriodEvent event) async {
    return await _isar.writeTxn(() async {
      return await _isar.periodEvents.put(event);
    });
  }

  /// Update event
  Future<void> update(PeriodEvent event) async {
    event.updatedAt = DateTime.now();
    await _isar.writeTxn(() async {
      await _isar.periodEvents.put(event);
    });
  }

  /// Delete event
  Future<bool> delete(int id) async {
    return await _isar.writeTxn(() async {
      return await _isar.periodEvents.delete(id);
    });
  }

  /// Search events by title
  Future<List<PeriodEvent>> search(String query) async {
    return await _isar.periodEvents
        .filter()
        .titleContains(query, caseSensitive: false)
        .or()
        .descriptionContains(query, caseSensitive: false)
        .sortByStartYear()
        .findAll();
  }

  /// Watch all events (Stream)
  Stream<List<PeriodEvent>> watchAll() {
    return _isar.periodEvents.where().watch(fireImmediately: true);
  }

  /// Watch events by civilization (Stream)
  Stream<List<PeriodEvent>> watchByCivilization(int civilizationId) {
    return _isar.periodEvents
        .filter()
        .civilizationIdEqualTo(civilizationId)
        .watch(fireImmediately: true);
  }

  /// Get count
  Future<int> count() async {
    return await _isar.periodEvents.count();
  }

  /// Get year range (min and max years)
  Future<Map<String, int>> getYearRange() async {
    final events = await _isar.periodEvents.where().findAll();
    
    if (events.isEmpty) {
      return {'min': -3900, 'max': -500};
    }

    int minYear = events.first.startYear;
    int maxYear = events.first.startYear;

    for (var event in events) {
      if (event.startYear < minYear) minYear = event.startYear;
      if (event.startYear > maxYear) maxYear = event.startYear;
      if (event.endYear != null && event.endYear! > maxYear) {
        maxYear = event.endYear!;
      }
    }

    return {'min': minYear, 'max': maxYear};
  }
}
