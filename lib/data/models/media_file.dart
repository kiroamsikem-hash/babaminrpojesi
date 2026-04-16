import 'package:isar/isar.dart';

part 'media_file.g.dart';

/// MediaFile Entity (Fotoğraf/Dosya)
@collection
class MediaFile {
  Id id = Isar.autoIncrement;

  @Index(type: IndexType.value)
  late String path; // Local file path or URL

  @Index(type: IndexType.value)
  late String type; // 'image', 'pdf', 'video', 'audio'

  String? fileName;

  String? mimeType;

  int? fileSizeBytes;

  @Index()
  int? artifactId; // Link to Artifact

  @Index()
  int? eventId; // Link to PeriodEvent

  String? caption; // Fotoğraf açıklaması

  int? width;
  int? height;

  DateTime? createdAt;
  DateTime? updatedAt;

  MediaFile();

  MediaFile.create({
    required this.path,
    required this.type,
    this.fileName,
    this.mimeType,
    this.fileSizeBytes,
    this.artifactId,
    this.eventId,
    this.caption,
    this.width,
    this.height,
  }) {
    createdAt = DateTime.now();
    updatedAt = DateTime.now();
  }

  /// Check if file is an image
  bool get isImage => type == 'image';

  /// Check if file is a document
  bool get isDocument => type == 'pdf' || type == 'doc';

  /// Get file extension
  String? get extension {
    if (fileName == null) return null;
    final parts = fileName!.split('.');
    return parts.length > 1 ? parts.last : null;
  }
}
