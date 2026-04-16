import 'package:isar/isar.dart';

part 'civilization.g.dart';

/// Civilization Entity (Medeniyet/Bölge)
@collection
class Civilization {
  Id id = Isar.autoIncrement;

  @Index(type: IndexType.value)
  late String name; // Hitit, Miken, Batı Anadolu, vb.

  late String region; // Anadolu, Yunanistan, Mezopotamya

  late int colorValue; // ARGB color value

  String? description;

  DateTime? createdAt;
  DateTime? updatedAt;

  Civilization();

  Civilization.create({
    required this.name,
    required this.region,
    required this.colorValue,
    this.description,
  }) {
    createdAt = DateTime.now();
    updatedAt = DateTime.now();
  }

  // JSON Serialization
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'region': region,
        'colorValue': colorValue,
        'description': description,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  factory Civilization.fromJson(Map<String, dynamic> json) {
    final civ = Civilization();
    civ.id = json['id'] ?? Isar.autoIncrement;
    civ.name = json['name'] ?? '';
    civ.region = json['region'] ?? '';
    civ.colorValue = json['colorValue'] ?? 0xFF000000;
    civ.description = json['description'];
    civ.createdAt = json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null;
    civ.updatedAt = json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null;
    return civ;
  }
}
