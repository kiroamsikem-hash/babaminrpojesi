import 'package:isar/isar.dart';

part 'year_row.g.dart';

/// Year Row Entity - Satır (Yıl) için fotoğraf ve etiketler
@collection
class YearRow {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late int year; // Yıl (-4050, -4000, -3950, vb.)

  String? photoUrl; // Satır fotoğrafı URL'i
  String? photoPath; // Local photo path
  List<String>? tags; // Satır etiketleri
  String? description; // Satır açıklaması

  DateTime? createdAt;
  DateTime? updatedAt;

  YearRow();

  YearRow.create({
    required this.year,
    this.photoUrl,
    this.photoPath,
    this.tags,
    this.description,
  }) {
    createdAt = DateTime.now();
    updatedAt = DateTime.now();
  }

  // JSON Serialization
  Map<String, dynamic> toJson() => {
        'id': id,
        'year': year,
        'photoUrl': photoUrl,
        'photoPath': photoPath,
        'tags': tags,
        'description': description,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  factory YearRow.fromJson(Map<String, dynamic> json) {
    final row = YearRow();
    row.id = json['id'] ?? Isar.autoIncrement;
    row.year = json['year'] ?? 0;
    row.photoUrl = json['photoUrl'];
    row.photoPath = json['photoPath'];
    row.tags = json['tags'] != null ? List<String>.from(json['tags']) : null;
    row.description = json['description'];
    row.createdAt = json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null;
    row.updatedAt = json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null;
    return row;
  }
}
