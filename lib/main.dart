import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/main_screen.dart';
import 'core/firebase/firebase_service.dart';
import 'core/firebase/sync_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  try {
    final firebaseService = FirebaseService();
    await firebaseService.initialize();
    
    // Sign in anonymously
    await firebaseService.signInAnonymously();
    
    // Initialize sync service (no initialize method needed)
    final syncService = SyncService();
    
    print('✅ App initialized with Firebase sync');
  } catch (e) {
    print('⚠️ Firebase initialization failed: $e');
    print('📱 App will run in offline mode');
  }
  
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
