import 'package:isar/isar.dart';

part 'connection.g.dart';

/// Connection Entity (Bağlantı/İlişki)
/// Herhangi iki entity arasında mantıksal bağ kurar
@collection
class Connection {
  Id id = Isar.autoIncrement;

  @Index()
  late int sourceId; // Kaynak entity ID

  @Index()
  late int targetId; // Hedef entity ID

  @Index(type: IndexType.value)
  late String sourceType; // 'event', 'artifact', 'civilization'

  @Index(type: IndexType.value)
  late String targetType; // 'event', 'artifact', 'civilization'

  @Index(type: IndexType.value)
  late String connectionType; // 'similar', 'influenced', 'related', 'trade', vb.

  String? label; // Bağlantı açıklaması

  String? description; // Detaylı açıklama

  int? strength; // Bağlantı gücü (1-10)

  DateTime? createdAt;
  DateTime? updatedAt;

  Connection();

  Connection.create({
    required this.sourceId,
    required this.targetId,
    required this.sourceType,
    required this.targetType,
    required this.connectionType,
    this.label,
    this.description,
    this.strength,
  }) {
    createdAt = DateTime.now();
    updatedAt = DateTime.now();
  }

  /// Check if connection is bidirectional
  bool get isBidirectional => connectionType == 'trade' || connectionType == 'similar';

  // JSON Serialization
  Map<String, dynamic> toJson() => {
        'id': id,
        'sourceId': sourceId,
        'targetId': targetId,
        'sourceType': sourceType,
        'targetType': targetType,
        'connectionType': connectionType,
        'label': label,
        'description': description,
        'strength': strength,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  factory Connection.fromJson(Map<String, dynamic> json) {
    final conn = Connection();
    conn.id = json['id'] ?? Isar.autoIncrement;
    conn.sourceId = json['sourceId'] ?? 0;
    conn.targetId = json['targetId'] ?? 0;
    conn.sourceType = json['sourceType'] ?? '';
    conn.targetType = json['targetType'] ?? '';
    conn.connectionType = json['connectionType'] ?? '';
    conn.label = json['label'];
    conn.description = json['description'];
    conn.strength = json['strength'];
    conn.createdAt = json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null;
    conn.updatedAt = json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null;
    return conn;
  }
}
