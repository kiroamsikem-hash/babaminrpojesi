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
      // Load CSV from assets
      final csvString = await rootBundle.loadString(assetPath);
      
      // Parse CSV
      final csvTable = const CsvToListConverter(
        fieldDelimiter: ',',
        eol: '\n',
      ).convert(csvString);

      if (csvTable.isEmpty) {
        throw Exception('CSV file is empty');
      }

      // First row is headers
      final headers = csvTable[0].map((e) => e.toString()).toList();
      
      // Extract civilization names (skip first column which is "Yıl")
      final civilizationNames = headers.sublist(1);

      await _importData(csvTable, civilizationNames);
    } catch (e) {
      throw Exception('CSV import failed: $e');
    }
  }

  /// Import data to Isar
  Future<void> _importData(
    List<List<dynamic>> csvTable,
    List<String> civilizationNames,
  ) async {
    final isar = _isarService.isar;

    await isar.writeTxn(() async {
      // Clear existing data
      await isar.clear();

      // Create civilizations with colors
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

      // Save civilizations
      await isar.civilizations.putAll(civilizations);

      // Create map of civilization name to ID
      final civMap = <String, int>{};
      for (var civ in civilizations) {
        civMap[civ.name] = civ.id;
      }

      // Parse events
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

      // Save events
      await isar.periodEvents.putAll(events);
    });
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
    if (year >= -3900 && year < -3000) return 'Erken Dönem';
    if (year >= -3000 && year < -1200) return 'Tunç Çağı';
    if (year >= -1200 && year <= -500) return 'Demir Çağı';
    return 'Bilinmeyen Dönem';
  }

  /// Convert year to grid Y coordinate
  double _yearToGridY(int year) {
    // Normalize year to positive grid coordinate
    // -3900 -> 0, -500 -> max
    const minYear = -3900;
    const maxYear = -500;
    const yearRange = maxYear - minYear;
    
    return ((year - minYear) / yearRange) * 100;
  }
}
