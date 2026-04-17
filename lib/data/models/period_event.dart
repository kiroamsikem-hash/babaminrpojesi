import 'package:isar/isar.dart';

part 'period_event.g.dart';

/// Period/Event Entity (Dönem/Olay)
@collection
class PeriodEvent {
  Id id = Isar.autoIncrement;

  @Index()
  late int startYear; // M.Ö. yıllar için negatif değer

  int? endYear; // Null ise tek yıllık olay

  @Index(type: IndexType.value)
  late String title;

  String? description;

  @Index()
  late int civilizationId; // Foreign key to Civilization

  String? period; // Tunç Çağı, Demir Çağı, vb.

  // Coordinates for grid positioning
  double? gridX;
  double? gridY;

  // New features
  List<String>? tags; // Etiketler: ["Savaş", "Barış Antlaşması", vb.]
  String? photoUrl; // Satır fotoğrafı URL'i
  String? photoPath; // Local photo path

  DateTime? createdAt;
  DateTime? updatedAt;

  PeriodEvent();

  PeriodEvent.create({
    required this.startYear,
    this.endYear,
    required this.title,
    this.description,
    required this.civilizationId,
    this.period,
    this.gridX,
    this.gridY,
    this.tags,
    this.photoUrl,
    this.photoPath,
  }) {
    createdAt = DateTime.now();
    updatedAt = DateTime.now();
  }

  /// Duration in years
  int get duration => (endYear ?? startYear) - startYear;

  /// Check if event spans multiple years
  bool get isMultiYear => endYear != null && endYear! > startYear;

  // JSON Serialization
  Map<String, dynamic> toJson() => {
        'id': id,
        'startYear': startYear,
        'endYear': endYear,
        'title': title,
        'description': description,
        'civilizationId': civilizationId,
        'period': period,
        'gridX': gridX,
        'gridY': gridY,
        'tags': tags,
        'photoUrl': photoUrl,
        'photoPath': photoPath,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  factory PeriodEvent.fromJson(Map<String, dynamic> json) {
    final event = PeriodEvent();
    event.id = json['id'] ?? Isar.autoIncrement;
    event.startYear = json['startYear'] ?? 0;
    event.endYear = json['endYear'];
    event.title = json['title'] ?? '';
    event.description = json['description'];
    event.civilizationId = json['civilizationId'] ?? 0;
    event.period = json['period'];
    event.gridX = json['gridX']?.toDouble();
    event.gridY = json['gridY']?.toDouble();
    event.tags = json['tags'] != null ? List<String>.from(json['tags']) : null;
    event.photoUrl = json['photoUrl'];
    event.photoPath = json['photoPath'];
    event.createdAt = json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null;
    event.updatedAt = json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null;
    return event;
  }
}
