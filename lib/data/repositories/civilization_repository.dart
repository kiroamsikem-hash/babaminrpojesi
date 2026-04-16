import 'package:isar/isar.dart';
import '../models/civilization.dart';
import '../../core/database/isar_service.dart';

/// Civilization Repository - CRUD operations
class CivilizationRepository {
  final IsarService _isarService;

  CivilizationRepository(this._isarService);

  Isar get _isar => _isarService.isar;

  /// Get all civilizations
  Future<List<Civilization>> getAll() async {
    return await _isar.civilizations.where().findAll();
  }

  /// Get civilization by ID
  Future<Civilization?> getById(int id) async {
    return await _isar.civilizations.get(id);
  }

  /// Get civilization by name
  Future<Civilization?> getByName(String name) async {
    return await _isar.civilizations
        .filter()
        .nameEqualTo(name)
        .findFirst();
  }

  /// Create civilization
  Future<int> create(Civilization civilization) async {
    return await _isar.writeTxn(() async {
      return await _isar.civilizations.put(civilization);
    });
  }

  /// Update civilization
  Future<void> update(Civilization civilization) async {
    await _isar.writeTxn(() async {
      await _isar.civilizations.put(civilization);
    });
  }

  /// Delete civilization
  Future<bool> delete(int id) async {
    return await _isar.writeTxn(() async {
      return await _isar.civilizations.delete(id);
    });
  }

  /// Search civilizations by name
  Future<List<Civilization>> search(String query) async {
    return await _isar.civilizations
        .filter()
        .nameContains(query, caseSensitive: false)
        .findAll();
  }

  /// Watch all civilizations (Stream)
  Stream<List<Civilization>> watchAll() {
    return _isar.civilizations.where().watch(fireImmediately: true);
  }

  /// Get count
  Future<int> count() async {
    return await _isar.civilizations.count();
  }
}
