import 'package:isar/isar.dart';
import '../models/civilization.dart';
import '../../core/database/isar_service.dart';

/// Civilization Repository - CRUD operations
class CivilizationRepository {
  final IsarService _isarService;

  CivilizationRepository(this._isarService);

  Future<Isar> get _isar async {
    print('🔍 CivilizationRepository._isar getter called');
    if (_isarService.isar == null) {
      print('⚠️ Isar is null in repository, calling init()...');
      await _isarService.init();
    }
    print('✅ Returning Isar instance from repository');
    return _isarService.isar!;
  }

  /// Get all civilizations
  Future<List<Civilization>> getAll() async {
    final isar = await _isar;
    return await isar.civilizations.where().findAll();
  }

  /// Get civilization by ID
  Future<Civilization?> getById(int id) async {
    final isar = await _isar;
    return await isar.civilizations.get(id);
  }

  /// Get civilization by name
  Future<Civilization?> getByName(String name) async {
    final isar = await _isar;
    return await isar.civilizations
        .filter()
        .nameEqualTo(name)
        .findFirst();
  }

  /// Create civilization
  Future<int> create(Civilization civilization) async {
    final isar = await _isar;
    return await isar.writeTxn(() async {
      return await isar.civilizations.put(civilization);
    });
  }

  /// Update civilization
  Future<void> update(Civilization civilization) async {
    final isar = await _isar;
    await isar.writeTxn(() async {
      await isar.civilizations.put(civilization);
    });
  }

  /// Delete civilization
  Future<bool> delete(int id) async {
    final isar = await _isar;
    return await isar.writeTxn(() async {
      return await isar.civilizations.delete(id);
    });
  }

  /// Search civilizations by name
  Future<List<Civilization>> search(String query) async {
    final isar = await _isar;
    return await isar.civilizations
        .filter()
        .nameContains(query, caseSensitive: false)
        .findAll();
  }

  /// Watch all civilizations (Stream)
  Stream<List<Civilization>> watchAll() async* {
    print('👀 CivilizationRepository.watchAll() called');
    final isar = await _isar;
    print('✅ Got Isar instance in watchAll, starting stream...');
    yield* isar.civilizations.where().watch(fireImmediately: true);
  }

  /// Get count
  Future<int> count() async {
    final isar = await _isar;
    return await isar.civilizations.count();
  }
}
