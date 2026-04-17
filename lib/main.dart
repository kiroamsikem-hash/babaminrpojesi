import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/main_screen.dart';
import 'core/firebase/firebase_service.dart';
import 'core/firebase/sync_service.dart';
import 'core/database/isar_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('🚀 APP STARTING...');
  
  // Initialize Isar Database (MUST BE FIRST!)
  try {
    print('📦 Initializing Isar...');
    final isarService = IsarService.instance;
    print('📦 IsarService instance created');
    await isarService.init();
    print('✅ Isar database initialized successfully');
    print('📊 Isar instance: ${isarService.isar != null ? "NOT NULL" : "NULL"}');
  } catch (e, stackTrace) {
    print('❌ Isar initialization failed: $e');
    print('Stack trace: $stackTrace');
  }
  
  // Initialize Firebase
  try {
    print('🔥 Initializing Firebase...');
    final firebaseService = FirebaseService();
    await firebaseService.initialize();
    print('✅ Firebase initialized');
    
    // Sign in anonymously
    await firebaseService.signInAnonymously();
    print('✅ Firebase auth completed');
    
    // Initialize sync service (no initialize method needed)
    final syncService = SyncService();
    print('✅ Sync service created');
    
    print('✅ App initialized with Firebase sync');
  } catch (e, stackTrace) {
    print('⚠️ Firebase initialization failed: $e');
    print('Stack trace: $stackTrace');
    print('📱 App will run in offline mode');
  }
  
  print('🎨 Starting Flutter app...');
  
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Antik Medeniyetler Timeline',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const MainScreen(),
    );
  }
}
