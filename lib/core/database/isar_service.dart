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
    if (_isar != null && _isar!.isOpen) {
      return _isar!;
    }

    final dir = await getApplicationDocumentsDirectory();

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

    return _isar!;
  }

  /// Get Isar instance (returns null if not initialized)
  Isar? get isar => _isar;

  /// Close database
  Future<void> close() async {
    await _isar?.close();
    _isar = null;
  }

  /// Clear all data (for testing/reset)
  Future<void> clearAll() async {
    await isar.writeTxn(() async {
      await isar.clear();
    });
  }

  /// Get database statistics
  Future<Map<String, int>> getStats() async {
    return {
      'civilizations': await isar.civilizations.count(),
      'events': await isar.periodEvents.count(),
      'artifacts': await isar.artifacts.count(),
      'mediaFiles': await isar.mediaFiles.count(),
      'connections': await isar.connections.count(),
    };
  }
}
