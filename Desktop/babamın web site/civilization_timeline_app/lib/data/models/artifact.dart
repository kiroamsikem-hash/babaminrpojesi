import 'package:isar/isar.dart';

part 'artifact.g.dart';

/// Artifact Entity (Buluntu/Not)
@collection
class Artifact {
  Id id = Isar.autoIncrement;

  @Index(type: IndexType.value)
  late String name;

  String? description;

  @Index()
  int? eventId; // Optional link to PeriodEvent

  @Index()
  int? civilizationId; // Optional link to Civilization

  String? location; // Buluntu yeri

  int? discoveryYear; // Bulunma yılı

  List<String> tags = []; // Etiketler: seramik, silah, yazıt, vb.

  // Media files stored as paths
  List<String> mediaFilePaths = [];

  DateTime? createdAt;
  DateTime? updatedAt;

  Artifact();

  Artifact.create({
    required this.name,
    this.description,
    this.eventId,
    this.civilizationId,
    this.location,
    this.discoveryYear,
    List<String>? tags,
    List<String>? mediaFilePaths,
  }) {
    this.tags = tags ?? [];
    this.mediaFilePaths = mediaFilePaths ?? [];
    createdAt = DateTime.now();
    updatedAt = DateTime.now();
  }
}
