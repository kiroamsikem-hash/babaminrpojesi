import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

/// Firebase Service - Singleton
class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  // Firebase instances
  FirebaseAuth get auth => FirebaseAuth.instance;
  FirebaseFirestore get firestore => FirebaseFirestore.instance;
  FirebaseStorage get storage => FirebaseStorage.instance;

  bool _initialized = false;
  bool get isInitialized => _initialized;

  /// Initialize Firebase
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      await Firebase.initializeApp();
      
      // Enable offline persistence
      firestore.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );

      _initialized = true;
      print('✅ Firebase initialized successfully');
    } catch (e) {
      print('❌ Firebase initialization failed: $e');
      rethrow;
    }
  }

  /// Sign in anonymously (for single user)
  Future<User?> signInAnonymously() async {
    try {
      final userCredential = await auth.signInAnonymously();
      print('✅ Signed in anonymously: ${userCredential.user?.uid}');
      return userCredential.user;
    } catch (e) {
      print('❌ Anonymous sign in failed: $e');
      return null;
    }
  }

  /// Get current user
  User? get currentUser => auth.currentUser;

  /// Check if user is signed in
  bool get isSignedIn => currentUser != null;

  /// Sign out
  Future<void> signOut() async {
    await auth.signOut();
  }
}
