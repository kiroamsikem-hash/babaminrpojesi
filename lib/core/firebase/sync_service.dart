import 'package:connectivity_plus/connectivity_plus.dart';
import '../database/isar_service.dart';
import 'firestore_service.dart';
import '../../data/repositories/civilization_repository.dart';
import '../../data/repositories/event_repository.dart';
import '../../data/repositories/connection_repository.dart';
import '../../data/models/civilization.dart';
import '../../data/models/period_event.dart';
import '../../data/models/connection.dart';

/// Sync Service - Bidirectional sync between Isar (local) and Firestore (cloud)
class SyncService {
  final IsarService _isarService = IsarService.instance;
  final FirestoreService _firestoreService = FirestoreService();
  final Connectivity _connectivity = Connectivity();

  late final CivilizationRepository _civilizationRepo;
  late final EventRepository _eventRepo;
  late final ConnectionRepository _connectionRepo;

  bool _isSyncing = false;
  DateTime? _lastSyncTime;

  SyncService() {
    _civilizationRepo = CivilizationRepository(_isarService);
    _eventRepo = EventRepository(_isarService);
    _connectionRepo = ConnectionRepository(_isarService);
  }

  /// Check if device is online
  Future<bool> isOnline() async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  /// Sync all data (civilizations, events, connections)
  Future<void> syncAll() async {
    if (_isSyncing) {
      print('⏳ Sync already in progress...');
      return;
    }

    if (!await isOnline()) {
      print('📵 Offline - skipping sync');
      return;
    }

    _isSyncing = true;
    print('🔄 Starting sync...');

    try {
      await _syncCivilizations();
      await _syncEvents();
      await _syncConnections();

      _lastSyncTime = DateTime.now();
      print('✅ Sync completed at ${_lastSyncTime}');
    } catch (e) {
      print('❌ Sync error: $e');
      rethrow;
    } finally {
      _isSyncing = false;
    }
  }

  /// Sync civilizations
  Future<void> _syncCivilizations() async {
    try {
      // Get local data
      final localCivs = await _civilizationRepo.getAll();

      // Get cloud data
      final cloudSnapshot = await _firestoreService.getCivilizationsStream().first;

      // Upload local items to cloud
      for (final civ in localCivs) {
        await _firestoreService.saveCivilization(civ.toJson());
      }

      // Download cloud items to local
      for (final doc in cloudSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        await _civilizationRepo.create(Civilization.fromJson(data));
      }

      print('✅ Synced ${localCivs.length} civilizations');
    } catch (e) {
      print('❌ Civilization sync error: $e');
    }
  }

  /// Sync events
  Future<void> _syncEvents() async {
    try {
      // Get local data
      final localEvents = await _eventRepo.getAll();

      // Get cloud data
      final cloudSnapshot = await _firestoreService.getEventsStream().first;

      // Upload local items to cloud
      for (final event in localEvents) {
        await _firestoreService.saveEvent(event.toJson());
      }

      // Download cloud items to local
      for (final doc in cloudSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        await _eventRepo.create(PeriodEvent.fromJson(data));
      }

      print('✅ Synced ${localEvents.length} events');
    } catch (e) {
      print('❌ Event sync error: $e');
    }
  }

  /// Sync connections
  Future<void> _syncConnections() async {
    try {
      // Get local data
      final localConns = await _connectionRepo.getAll();

      // Get cloud data
      final cloudSnapshot = await _firestoreService.getConnectionsStream().first;

      // Upload local items to cloud
      for (final conn in localConns) {
        await _firestoreService.saveConnection(conn.toJson());
      }

      // Download cloud items to local
      for (final doc in cloudSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        await _connectionRepo.create(Connection.fromJson(data));
      }

      print('✅ Synced ${localConns.length} connections');
    } catch (e) {
      print('❌ Connection sync error: $e');
    }
  }

  /// Force upload all local data to cloud
  Future<void> uploadAll() async {
    if (!await isOnline()) {
      throw Exception('Device is offline');
    }

    print('⬆️ Uploading all local data...');

    final civs = await _civilizationRepo.getAll();
    for (final civ in civs) {
      await _firestoreService.saveCivilization(civ.toJson());
    }

    final events = await _eventRepo.getAll();
    for (final event in events) {
      await _firestoreService.saveEvent(event.toJson());
    }

    final conns = await _connectionRepo.getAll();
    for (final conn in conns) {
      await _firestoreService.saveConnection(conn.toJson());
    }

    print('✅ Upload completed');
  }

  /// Force download all cloud data to local
  Future<void> downloadAll() async {
    if (!await isOnline()) {
      throw Exception('Device is offline');
    }

    print('⬇️ Downloading all cloud data...');

    // Download civilizations
    final civsSnapshot = await _firestoreService.getCivilizationsStream().first;
    for (final doc in civsSnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      await _civilizationRepo.create(Civilization.fromJson(data));
    }

    // Download events
    final eventsSnapshot = await _firestoreService.getEventsStream().first;
    for (final doc in eventsSnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      await _eventRepo.create(PeriodEvent.fromJson(data));
    }

    // Download connections
    final connsSnapshot = await _firestoreService.getConnectionsStream().first;
    for (final doc in connsSnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      await _connectionRepo.create(Connection.fromJson(data));
    }

    print('✅ Download completed');
  }

  /// Get sync status
  Map<String, dynamic> getSyncStatus() {
    return {
      'isSyncing': _isSyncing,
      'lastSyncTime': _lastSyncTime?.toIso8601String(),
      'isOnline': isOnline(),
    };
  }
}
