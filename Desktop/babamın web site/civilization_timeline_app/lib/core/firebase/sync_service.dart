import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../database/isar_service.dart';
import 'firestore_service.dart';
import '../../data/models/civilization.dart';
import '../../data/models/period_event.dart';
import '../../data/models/connection.dart';

/// Sync Service - Bidirectional sync between Isar (local) and Firestore (cloud)
class SyncService {
  final IsarService _isarService = IsarService();
  final FirestoreService _firestoreService = FirestoreService();
  final Connectivity _connectivity = Connectivity();

  bool _isSyncing = false;
  bool _isOnline = false;
  StreamSubscription? _connectivitySubscription;
  final List<StreamSubscription> _firestoreSubscriptions = [];

  /// Initialize sync service
  Future<void> initialize() async {
    // Check initial connectivity
    final connectivityResult = await _connectivity.checkConnectivity();
    _isOnline = connectivityResult != ConnectivityResult.none;

    // Listen to connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((result) {
      final wasOnline = _isOnline;
      _isOnline = result != ConnectivityResult.none;

      if (!wasOnline && _isOnline) {
        // Just came online - sync
        print('📡 Connection restored - starting sync');
        syncAll();
      } else if (wasOnline && !_isOnline) {
        print('📡 Connection lost - working offline');
      }
    });

    // Start listening to Firestore changes
    if (_isOnline) {
      _startFirestoreListeners();
      await syncAll();
    }

    print('✅ Sync service initialized (${_isOnline ? "Online" : "Offline"})');
  }

  /// Dispose sync service
  void dispose() {
    _connectivitySubscription?.cancel();
    for (final subscription in _firestoreSubscriptions) {
      subscription.cancel();
    }
    _firestoreSubscriptions.clear();
  }

  /// Check if online
  bool get isOnline => _isOnline;

  /// Check if syncing
  bool get isSyncing => _isSyncing;

  // ==================== SYNC ALL ====================

  /// Sync all data (bidirectional)
  Future<void> syncAll() async {
    if (_isSyncing || !_isOnline) return;

    _isSyncing = true;
    print('🔄 Starting full sync...');

    try {
      // Sync in order (civilizations first, then events, etc.)
      await _syncCivilizations();
      await _syncEvents();
      await _syncConnections();

      print('✅ Full sync completed');
    } catch (e) {
      print('❌ Sync failed: $e');
    } finally {
      _isSyncing = false;
    }
  }

  // ==================== SYNC CIVILIZATIONS ====================

  Future<void> _syncCivilizations() async {
    try {
      // 1. Get local civilizations
      final localCivs = await _isarService.isar.civilizations.where().findAll();

      // 2. Get cloud civilizations
      final cloudSnapshot = await _firestoreService
          ._firestore
          .collection(_firestoreService._getUserCollection(FirestoreService.civilizationsCollection))
          .get();

      // 3. Create maps for comparison
      final localMap = {for (var c in localCivs) c.id.toString(): c};
      final cloudMap = {for (var doc in cloudSnapshot.docs) doc.id: doc.data()};

      // 4. Upload local items not in cloud
      for (final civ in localCivs) {
        final id = civ.id.toString();
        if (!cloudMap.containsKey(id)) {
          await _firestoreService.saveCivilization(civ.toJson());
          print('⬆️ Uploaded civilization: ${civ.name}');
        }
      }

      // 5. Download cloud items not in local
      for (final doc in cloudSnapshot.docs) {
        if (!localMap.containsKey(doc.id)) {
          final data = doc.data();
          final civ = Civilization.fromJson({...data, 'id': int.tryParse(doc.id) ?? 0});
          await _isarService.isar.writeTxn(() async {
            await _isarService.isar.civilizations.put(civ);
          });
          print('⬇️ Downloaded civilization: ${civ.name}');
        }
      }
    } catch (e) {
      print('❌ Civilization sync failed: $e');
    }
  }

  // ==================== SYNC EVENTS ====================

  Future<void> _syncEvents() async {
    try {
      // 1. Get local events
      final localEvents = await _isarService.isar.periodEvents.where().findAll();

      // 2. Get cloud events
      final cloudSnapshot = await _firestoreService
          ._firestore
          .collection(_firestoreService._getUserCollection(FirestoreService.eventsCollection))
          .get();

      // 3. Create maps for comparison
      final localMap = {for (var e in localEvents) e.id.toString(): e};
      final cloudMap = {for (var doc in cloudSnapshot.docs) doc.id: doc.data()};

      // 4. Upload local items not in cloud
      for (final event in localEvents) {
        final id = event.id.toString();
        if (!cloudMap.containsKey(id)) {
          await _firestoreService.saveEvent(event.toJson());
          print('⬆️ Uploaded event: ${event.title}');
        }
      }

      // 5. Download cloud items not in local
      for (final doc in cloudSnapshot.docs) {
        if (!localMap.containsKey(doc.id)) {
          final data = doc.data();
          final event = PeriodEvent.fromJson({...data, 'id': int.tryParse(doc.id) ?? 0});
          await _isarService.isar.writeTxn(() async {
            await _isarService.isar.periodEvents.put(event);
          });
          print('⬇️ Downloaded event: ${event.title}');
        }
      }
    } catch (e) {
      print('❌ Event sync failed: $e');
    }
  }

  // ==================== SYNC CONNECTIONS ====================

  Future<void> _syncConnections() async {
    try {
      // 1. Get local connections
      final localConns = await _isarService.isar.connections.where().findAll();

      // 2. Get cloud connections
      final cloudSnapshot = await _firestoreService
          ._firestore
          .collection(_firestoreService._getUserCollection(FirestoreService.connectionsCollection))
          .get();

      // 3. Create maps for comparison
      final localMap = {for (var c in localConns) c.id.toString(): c};
      final cloudMap = {for (var doc in cloudSnapshot.docs) doc.id: doc.data()};

      // 4. Upload local items not in cloud
      for (final conn in localConns) {
        final id = conn.id.toString();
        if (!cloudMap.containsKey(id)) {
          await _firestoreService.saveConnection(conn.toJson());
          print('⬆️ Uploaded connection');
        }
      }

      // 5. Download cloud items not in local
      for (final doc in cloudSnapshot.docs) {
        if (!localMap.containsKey(doc.id)) {
          final data = doc.data();
          final conn = Connection.fromJson({...data, 'id': int.tryParse(doc.id) ?? 0});
          await _isarService.isar.writeTxn(() async {
            await _isarService.isar.connections.put(conn);
          });
          print('⬇️ Downloaded connection');
        }
      }
    } catch (e) {
      print('❌ Connection sync failed: $e');
    }
  }

  // ==================== REAL-TIME LISTENERS ====================

  void _startFirestoreListeners() {
    // Listen to events changes
    final eventsSubscription = _firestoreService.getEventsStream().listen((snapshot) {
      _handleEventsSnapshot(snapshot);
    });
    _firestoreSubscriptions.add(eventsSubscription);

    // Listen to civilizations changes
    final civsSubscription = _firestoreService.getCivilizationsStream().listen((snapshot) {
      _handleCivilizationsSnapshot(snapshot);
    });
    _firestoreSubscriptions.add(civsSubscription);

    // Listen to connections changes
    final connsSubscription = _firestoreService.getConnectionsStream().listen((snapshot) {
      _handleConnectionsSnapshot(snapshot);
    });
    _firestoreSubscriptions.add(connsSubscription);

    print('👂 Firestore listeners started');
  }

  void _handleEventsSnapshot(QuerySnapshot snapshot) async {
    for (final change in snapshot.docChanges) {
      final data = change.doc.data() as Map<String, dynamic>?;
      if (data == null) continue;

      final id = int.tryParse(change.doc.id) ?? 0;
      final event = PeriodEvent.fromJson({...data, 'id': id});

      if (change.type == DocumentChangeType.added || change.type == DocumentChangeType.modified) {
        await _isarService.isar.writeTxn(() async {
          await _isarService.isar.periodEvents.put(event);
        });
        print('🔄 Event synced from cloud: ${event.title}');
      } else if (change.type == DocumentChangeType.removed) {
        await _isarService.isar.writeTxn(() async {
          await _isarService.isar.periodEvents.delete(id);
        });
        print('🗑️ Event deleted from cloud: ${event.title}');
      }
    }
  }

  void _handleCivilizationsSnapshot(QuerySnapshot snapshot) async {
    for (final change in snapshot.docChanges) {
      final data = change.doc.data() as Map<String, dynamic>?;
      if (data == null) continue;

      final id = int.tryParse(change.doc.id) ?? 0;
      final civ = Civilization.fromJson({...data, 'id': id});

      if (change.type == DocumentChangeType.added || change.type == DocumentChangeType.modified) {
        await _isarService.isar.writeTxn(() async {
          await _isarService.isar.civilizations.put(civ);
        });
        print('🔄 Civilization synced from cloud: ${civ.name}');
      } else if (change.type == DocumentChangeType.removed) {
        await _isarService.isar.writeTxn(() async {
          await _isarService.isar.civilizations.delete(id);
        });
        print('🗑️ Civilization deleted from cloud: ${civ.name}');
      }
    }
  }

  void _handleConnectionsSnapshot(QuerySnapshot snapshot) async {
    for (final change in snapshot.docChanges) {
      final data = change.doc.data() as Map<String, dynamic>?;
      if (data == null) continue;

      final id = int.tryParse(change.doc.id) ?? 0;
      final conn = Connection.fromJson({...data, 'id': id});

      if (change.type == DocumentChangeType.added || change.type == DocumentChangeType.modified) {
        await _isarService.isar.writeTxn(() async {
          await _isarService.isar.connections.put(conn);
        });
        print('🔄 Connection synced from cloud');
      } else if (change.type == DocumentChangeType.removed) {
        await _isarService.isar.writeTxn(() async {
          await _isarService.isar.connections.delete(id);
        });
        print('🗑️ Connection deleted from cloud');
      }
    }
  }

  // ==================== MANUAL SYNC METHODS ====================

  /// Upload single event to cloud
  Future<void> uploadEvent(PeriodEvent event) async {
    if (!_isOnline) {
      print('⚠️ Offline - event will sync when online');
      return;
    }

    try {
      await _firestoreService.saveEvent(event.toJson());
      print('⬆️ Event uploaded: ${event.title}');
    } catch (e) {
      print('❌ Event upload failed: $e');
    }
  }

  /// Upload single civilization to cloud
  Future<void> uploadCivilization(Civilization civ) async {
    if (!_isOnline) {
      print('⚠️ Offline - civilization will sync when online');
      return;
    }

    try {
      await _firestoreService.saveCivilization(civ.toJson());
      print('⬆️ Civilization uploaded: ${civ.name}');
    } catch (e) {
      print('❌ Civilization upload failed: $e');
    }
  }

  /// Upload single connection to cloud
  Future<void> uploadConnection(Connection conn) async {
    if (!_isOnline) {
      print('⚠️ Offline - connection will sync when online');
      return;
    }

    try {
      await _firestoreService.saveConnection(conn.toJson());
      print('⬆️ Connection uploaded');
    } catch (e) {
      print('❌ Connection upload failed: $e');
    }
  }
}
