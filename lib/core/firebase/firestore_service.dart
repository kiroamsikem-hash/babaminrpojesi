import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_service.dart';

/// Firestore Service - Cloud Database Operations
class FirestoreService {
  final FirebaseService _firebase = FirebaseService();
  FirebaseFirestore get _firestore => _firebase.firestore;

  // Collections
  static const String civilizationsCollection = 'civilizations';
  static const String eventsCollection = 'events';
  static const String artifactsCollection = 'artifacts';
  static const String connectionsCollection = 'connections';
  static const String mediaFilesCollection = 'media_files';

  /// Get user-specific collection path
  String _getUserCollection(String collection) {
    final userId = _firebase.currentUser?.uid ?? 'anonymous';
    return 'users/$userId/$collection';
  }

  // ==================== CIVILIZATIONS ====================

  /// Get civilizations stream
  Stream<QuerySnapshot> getCivilizationsStream() {
    return _firestore
        .collection(_getUserCollection(civilizationsCollection))
        .snapshots();
  }

  /// Save civilization
  Future<void> saveCivilization(Map<String, dynamic> data) async {
    final id = data['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString();
    await _firestore
        .collection(_getUserCollection(civilizationsCollection))
        .doc(id)
        .set({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Delete civilization
  Future<void> deleteCivilization(String id) async {
    await _firestore
        .collection(_getUserCollection(civilizationsCollection))
        .doc(id)
        .delete();
  }

  // ==================== EVENTS ====================

  /// Get events stream
  Stream<QuerySnapshot> getEventsStream() {
    return _firestore
        .collection(_getUserCollection(eventsCollection))
        .orderBy('startYear')
        .snapshots();
  }

  /// Save event
  Future<void> saveEvent(Map<String, dynamic> data) async {
    final id = data['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString();
    await _firestore
        .collection(_getUserCollection(eventsCollection))
        .doc(id)
        .set({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Delete event
  Future<void> deleteEvent(String id) async {
    await _firestore
        .collection(_getUserCollection(eventsCollection))
        .doc(id)
        .delete();
  }

  // ==================== ARTIFACTS ====================

  /// Get artifacts stream
  Stream<QuerySnapshot> getArtifactsStream() {
    return _firestore
        .collection(_getUserCollection(artifactsCollection))
        .snapshots();
  }

  /// Save artifact
  Future<void> saveArtifact(Map<String, dynamic> data) async {
    final id = data['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString();
    await _firestore
        .collection(_getUserCollection(artifactsCollection))
        .doc(id)
        .set({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Delete artifact
  Future<void> deleteArtifact(String id) async {
    await _firestore
        .collection(_getUserCollection(artifactsCollection))
        .doc(id)
        .delete();
  }

  // ==================== CONNECTIONS ====================

  /// Get connections stream
  Stream<QuerySnapshot> getConnectionsStream() {
    return _firestore
        .collection(_getUserCollection(connectionsCollection))
        .snapshots();
  }

  /// Save connection
  Future<void> saveConnection(Map<String, dynamic> data) async {
    final id = data['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString();
    await _firestore
        .collection(_getUserCollection(connectionsCollection))
        .doc(id)
        .set({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Delete connection
  Future<void> deleteConnection(String id) async {
    await _firestore
        .collection(_getUserCollection(connectionsCollection))
        .doc(id)
        .delete();
  }

  // ==================== MEDIA FILES ====================

  /// Get media files stream
  Stream<QuerySnapshot> getMediaFilesStream() {
    return _firestore
        .collection(_getUserCollection(mediaFilesCollection))
        .snapshots();
  }

  /// Save media file metadata
  Future<void> saveMediaFile(Map<String, dynamic> data) async {
    final id = data['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString();
    await _firestore
        .collection(_getUserCollection(mediaFilesCollection))
        .doc(id)
        .set({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Delete media file metadata
  Future<void> deleteMediaFile(String id) async {
    await _firestore
        .collection(_getUserCollection(mediaFilesCollection))
        .doc(id)
        .delete();
  }

  // ==================== BATCH OPERATIONS ====================

  /// Batch write (for initial sync)
  Future<void> batchWrite(
    String collection,
    List<Map<String, dynamic>> items,
  ) async {
    final batch = _firestore.batch();
    final collectionRef = _firestore.collection(_getUserCollection(collection));

    for (final item in items) {
      final id = item['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString();
      final docRef = collectionRef.doc(id);
      batch.set(docRef, {
        ...item,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    await batch.commit();
  }

  /// Clear all user data (for testing)
  Future<void> clearAllData() async {
    final collections = [
      civilizationsCollection,
      eventsCollection,
      artifactsCollection,
      connectionsCollection,
      mediaFilesCollection,
    ];

    for (final collection in collections) {
      final snapshot = await _firestore
          .collection(_getUserCollection(collection))
          .get();

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }
  }
}
