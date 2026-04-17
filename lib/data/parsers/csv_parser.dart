import 'package:csv/csv.dart';
import 'package:flutter/services.dart';
import 'package:isar/isar.dart';
import '../models/civilization.dart';
import '../models/period_event.dart';
import '../../core/database/isar_service.dart';

/// CSV Parser - Converts CSV data to Isar entities
class CsvParser {
  final IsarService _isarService;

  CsvParser(this._isarService);

  /// Parse CSV file and import to database
  Future<void> importFromAsset(String assetPath) async {
    try {
      print('📄 CSV import started from: $assetPath');
      
      // Load CSV from assets
      print('📄 Loading CSV from assets...');
      final csvString = await rootBundle.loadString(assetPath);
      print('📄 CSV loaded, length: ${csvString.length}');
      
      // Parse CSV
      print('📄 Parsing CSV...');
      final csvTable = const CsvToListConverter(
        fieldDelimiter: ',',
        eol: '\n',
      ).convert(csvString);
      print('📄 CSV parsed, rows: ${csvTable.length}');

      if (csvTable.isEmpty) {
        throw Exception('CSV file is empty');
      }

      // First row is headers
      final headers = csvTable[0].map((e) => e.toString()).toList();
      print('📄 Headers: $headers');
      
      // Extract civilization names (skip first column which is "Yıl")
      final civilizationNames = headers.sublist(1);
      print('📄 Civilizations: $civilizationNames');

      await _importData(csvTable, civilizationNames);
      print('✅ CSV import completed successfully');
    } catch (e, stackTrace) {
      print('❌ CSV import failed: $e');
      print('Stack trace: $stackTrace');
      throw Exception('CSV import failed: $e');
    }
  }

  /// Import data to Isar
  Future<void> _importData(
    List<List<dynamic>> csvTable,
    List<String> civilizationNames,
  ) async {
    print('💾 _importData() called');
    
    // Ensure Isar is initialized
    if (_isarService.isar == null) {
      print('⚠️ Isar is null in CSV parser, calling init()...');
      await _isarService.init();
      print('✅ Isar initialized in CSV parser');
    }
    
    final isar = _isarService.isar!;
    print('💾 Got Isar instance, starting transaction...');

    await isar.writeTxn(() async {
      print('💾 Inside write transaction');
      
      // Clear existing data
      print('🗑️ Clearing existing data...');
      await isar.clear();
      print('✅ Data cleared');

      // Create civilizations with colors
      print('🏛️ Creating civilizations...');
      final civilizationColors = _getCivilizationColors();
      final civilizations = <Civilization>[];

      for (var i = 0; i < civilizationNames.length; i++) {
        final name = civilizationNames[i];
        final civ = Civilization.create(
          name: name,
          region: _getRegion(name),
          colorValue: civilizationColors[name] ?? 0xFF6B7280,
        );
        civilizations.add(civ);
      }
      print('🏛️ Created ${civilizations.length} civilizations');

      // Save civilizations
      print('💾 Saving civilizations...');
      await isar.civilizations.putAll(civilizations);
      print('✅ Civilizations saved');

      // Create map of civilization name to ID
      final civMap = <String, int>{};
      for (var civ in civilizations) {
        civMap[civ.name] = civ.id;
      }
      print('🗺️ Civilization map created: $civMap');

      // Parse events
      print('📅 Parsing events...');
      final events = <PeriodEvent>[];
      
      for (var i = 1; i < csvTable.length; i++) {
        final row = csvTable[i];
        
        // Get year from first column
        final yearStr = row[0].toString();
        final year = int.tryParse(yearStr);
        
        if (year == null) continue;

        // Process each civilization column
        for (var j = 1; j < row.length && j <= civilizationNames.length; j++) {
          final cellValue = row[j]?.toString().trim() ?? '';
          
          // Skip empty cells
          if (cellValue.isEmpty) continue;

          final civilizationName = civilizationNames[j - 1];
          final civilizationId = civMap[civilizationName];
          
          if (civilizationId == null) continue;

          // Create event
          final event = PeriodEvent.create(
            startYear: year,
            title: cellValue,
            civilizationId: civilizationId,
            period: _determinePeriod(year),
            gridX: j.toDouble(),
            gridY: _yearToGridY(year),
          );

          events.add(event);
        }
      }
      print('📅 Created ${events.length} events');

      // Save events
      print('💾 Saving events...');
      await isar.periodEvents.putAll(events);
      print('✅ Events saved');
      
      print('✅ Transaction completed successfully');
    });
    
    print('✅ _importData() completed');
  }

  /// Get civilization colors
  Map<String, int> _getCivilizationColors() {
    return {
      'Minoan': 0xFFFFD700, // Gold
      'Hitit': 0xFFDC143C, // Crimson
      'Miken': 0xFF4169E1, // Royal Blue
      'Mezopotamya': 0xFF8B4513, // Saddle Brown
      'Yunan': 0xFF00CED1, // Dark Turquoise
      'Batı Anadolu': 0xFF9370DB, // Medium Purple
    };
  }

  /// Get region for civilization
  String _getRegion(String civilizationName) {
    if (civilizationName.contains('Anadolu') || civilizationName == 'Hitit') {
      return 'Anadolu';
    } else if (civilizationName == 'Yunan' || civilizationName == 'Miken' || civilizationName == 'Minoan') {
      return 'Yunanistan';
    } else if (civilizationName == 'Mezopotamya') {
      return 'Mezopotamya';
    }
    return 'Bilinmeyen';
  }

  /// Determine period based on year
  String _determinePeriod(int year) {
    if (year >= -4050 && year < -3000) return 'Erken Dönem';
    if (year >= -3000 && year < -1200) return 'Tunç Çağı';
    if (year >= -1200 && year <= -550) return 'Demir Çağı';
    return 'Bilinmeyen Dönem';
  }

  /// Convert year to grid Y coordinate
  double _yearToGridY(int year) {
    // Normalize year to positive grid coordinate
    // -4050 -> 0, -550 -> max
    const minYear = -4050;
    const maxYear = -550;
    const yearRange = maxYear - minYear;
    
    return ((year - minYear) / yearRange) * 100;
  }
}
