import 'package:isar/isar.dart';
import '../models/connection.dart';
import '../../core/database/isar_service.dart';

/// Connection Repository - CRUD operations for relationships
class ConnectionRepository {
  final IsarService _isarService;

  ConnectionRepository(this._isarService);

  Future<Isar> get _isar async {
    if (_isarService.isar == null || !_isarService.isar.isOpen) {
      await _isarService.init();
    }
    return _isarService.isar;
  }

  /// Get all connections
  Future<List<Connection>> getAll() async {
    final isar = await _isar;
    return await isar.connections.where().findAll();
  }

  /// Get connection by ID
  Future<Connection?> getById(int id) async {
    final isar = await _isar;
    return await isar.connections.get(id);
  }

  /// Get connections for an entity (as source or target)
  Future<List<Connection>> getForEntity(int entityId, String entityType) async {
    final isar = await _isar;
    final asSource = await isar.connections
        .filter()
        .sourceIdEqualTo(entityId)
        .and()
        .sourceTypeEqualTo(entityType)
        .findAll();

    final asTarget = await isar.connections
        .filter()
        .targetIdEqualTo(entityId)
        .and()
        .targetTypeEqualTo(entityType)
        .findAll();

    return [...asSource, ...asTarget];
  }

  /// Get connections by type
  Future<List<Connection>> getByType(String connectionType) async {
    final isar = await _isar;
    return await isar.connections
        .filter()
        .connectionTypeEqualTo(connectionType)
        .findAll();
  }

  /// Create connection
  Future<int> create(Connection connection) async {
    final isar = await _isar;
    return await isar.writeTxn(() async {
      return await isar.connections.put(connection);
    });
  }

  /// Update connection
  Future<void> update(Connection connection) async {
    final isar = await _isar;
    connection.updatedAt = DateTime.now();
    await isar.writeTxn(() async {
      await isar.connections.put(connection);
    });
  }

  /// Delete connection
  Future<bool> delete(int id) async {
    final isar = await _isar;
    return await isar.writeTxn(() async {
      return await isar.connections.delete(id);
    });
  }

  /// Delete all connections for an entity
  Future<void> deleteForEntity(int entityId, String entityType) async {
    final isar = await _isar;
    await isar.writeTxn(() async {
      final connections = await getForEntity(entityId, entityType);
      final ids = connections.map((c) => c.id).toList();
      await isar.connections.deleteAll(ids);
    });
  }

  /// Check if connection exists
  Future<bool> exists(int sourceId, int targetId) async {
    final isar = await _isar;
    final connection = await isar.connections
        .filter()
        .sourceIdEqualTo(sourceId)
        .and()
        .targetIdEqualTo(targetId)
        .findFirst();
    
    return connection != null;
  }

  /// Watch connections for entity (Stream)
  Stream<List<Connection>> watchForEntity(int entityId, String entityType) async* {
    final isar = await _isar;
    yield* isar.connections
        .filter()
        .sourceIdEqualTo(entityId)
        .and()
        .sourceTypeEqualTo(entityType)
        .watch(fireImmediately: true);
  }

  /// Get count
  Future<int> count() async {
    final isar = await _isar;
    return await isar.connections.count();
  }
}
