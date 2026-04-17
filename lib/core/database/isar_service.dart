import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../../data/models/civilization.dart';
import '../../data/models/period_event.dart';
import '../../data/models/artifact.dart';
import '../../data/models/media_file.dart';
import '../../data/models/connection.dart';

/// Isar Database Service (Singleton)
class IsarService {
  static IsarService? _instance;
  static Isar? _isar;

  IsarService._();

  static IsarService get instance {
    _instance ??= IsarService._();
    return _instance!;
  }

  /// Initialize Isar database
  Future<Isar> init() async {
    print('🔧 IsarService.init() called');
    
    if (_isar != null && _isar!.isOpen) {
      print('✅ Isar already initialized and open');
      return _isar!;
    }

    print('📂 Getting application documents directory...');
    final dir = await getApplicationDocumentsDirectory();
    print('📂 Directory: ${dir.path}');

    print('🔨 Opening Isar database...');
    _isar = await Isar.open(
      [
        CivilizationSchema,
        PeriodEventSchema,
        ArtifactSchema,
        MediaFileSchema,
        ConnectionSchema,
      ],
      directory: dir.path,
      name: 'civilization_timeline',
      inspector: true, // Enable Isar Inspector for debugging
    );

    print('✅ Isar database opened successfully');
    print('📊 Isar instance is ${_isar!.isOpen ? "OPEN" : "CLOSED"}');
    return _isar!;
  }

  /// Get Isar instance (returns null if not initialized)
  Isar? get isar {
    print('🔍 IsarService.isar getter called, _isar is ${_isar == null ? "NULL" : "NOT NULL"}');
    return _isar;
  }

  /// Close database
  Future<void> close() async {
    await _isar?.close();
    _isar = null;
  }

  /// Clear all data (for testing/reset)
  Future<void> clearAll() async {
    if (_isar == null) {
      await init();
    }
    await _isar!.writeTxn(() async {
      await _isar!.clear();
    });
  }

  /// Get database statistics
  Future<Map<String, int>> getStats() async {
    print('📊 getStats() called');
    if (_isar == null) {
      print('⚠️ Isar is null, calling init()...');
      await init();
    }
    print('📊 Counting records...');
    final stats = {
      'civilizations': await _isar!.civilizations.count(),
      'events': await _isar!.periodEvents.count(),
      'artifacts': await _isar!.artifacts.count(),
      'mediaFiles': await _isar!.mediaFiles.count(),
      'connections': await _isar!.connections.count(),
    };
    print('📊 Stats: $stats');
    return stats;
  }
}
