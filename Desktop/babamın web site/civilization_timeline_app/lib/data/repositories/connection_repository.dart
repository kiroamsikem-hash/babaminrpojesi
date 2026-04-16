import 'package:isar/isar.dart';
import '../models/connection.dart';
import '../../core/database/isar_service.dart';

/// Connection Repository - CRUD operations for relationships
class ConnectionRepository {
  final IsarService _isarService;

  ConnectionRepository(this._isarService);

  Isar get _isar => _isarService.isar;

  /// Get all connections
  Future<List<Connection>> getAll() async {
    return await _isar.connections.where().findAll();
  }

  /// Get connection by ID
  Future<Connection?> getById(int id) async {
    return await _isar.connections.get(id);
  }

  /// Get connections for an entity (as source or target)
  Future<List<Connection>> getForEntity(int entityId, String entityType) async {
    final asSource = await _isar.connections
        .filter()
        .sourceIdEqualTo(entityId)
        .and()
        .sourceTypeEqualTo(entityType)
        .findAll();

    final asTarget = await _isar.connections
        .filter()
        .targetIdEqualTo(entityId)
        .and()
        .targetTypeEqualTo(entityType)
        .findAll();

    return [...asSource, ...asTarget];
  }

  /// Get connections by type
  Future<List<Connection>> getByType(String connectionType) async {
    return await _isar.connections
        .filter()
        .connectionTypeEqualTo(connectionType)
        .findAll();
  }

  /// Create connection
  Future<int> create(Connection connection) async {
    return await _isar.writeTxn(() async {
      return await _isar.connections.put(connection);
    });
  }

  /// Update connection
  Future<void> update(Connection connection) async {
    connection.updatedAt = DateTime.now();
    await _isar.writeTxn(() async {
      await _isar.connections.put(connection);
    });
  }

  /// Delete connection
  Future<bool> delete(int id) async {
    return await _isar.writeTxn(() async {
      return await _isar.connections.delete(id);
    });
  }

  /// Delete all connections for an entity
  Future<void> deleteForEntity(int entityId, String entityType) async {
    await _isar.writeTxn(() async {
      final connections = await getForEntity(entityId, entityType);
      final ids = connections.map((c) => c.id).toList();
      await _isar.connections.deleteAll(ids);
    });
  }

  /// Check if connection exists
  Future<bool> exists(int sourceId, int targetId) async {
    final connection = await _isar.connections
        .filter()
        .sourceIdEqualTo(sourceId)
        .and()
        .targetIdEqualTo(targetId)
        .findFirst();
    
    return connection != null;
  }

  /// Watch connections for entity (Stream)
  Stream<List<Connection>> watchForEntity(int entityId, String entityType) async* {
    yield* _isar.connections
        .filter()
        .sourceIdEqualTo(entityId)
        .and()
        .sourceTypeEqualTo(entityType)
        .watch(fireImmediately: true);
  }

  /// Get count
  Future<int> count() async {
    return await _isar.connections.count();
  }
}
