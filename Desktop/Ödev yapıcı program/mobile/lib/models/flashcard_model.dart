class Flashcard {
  final String id;
  final String front;
  final String back;
  final String subject;
  final String difficulty;
  final String deckName;
  final double easeFactor;
  final int intervalDays;
  final int repetitions;
  final DateTime nextReview;
  final DateTime? lastReviewed;
  final int reviewCount;

  Flashcard({
    required this.id,
    required this.front,
    required this.back,
    required this.subject,
    required this.difficulty,
    required this.deckName,
    required this.easeFactor,
    required this.intervalDays,
    required this.repetitions,
    required this.nextReview,
    this.lastReviewed,
    required this.reviewCount,
  });

  factory Flashcard.fromJson(Map<String, dynamic> json) {
    return Flashcard(
      id: json['id'].toString(),
      front: json['front'] ?? '',
      back: json['back'] ?? '',
      subject: json['subject'] ?? 'Genel',
      difficulty: json['difficulty'] ?? 'orta',
      deckName: json['deck_name'] ?? json['deckName'] ?? 'Genel',
      easeFactor: double.parse(json['ease_factor']?.toString() ?? '2.5'),
      intervalDays: int.parse(json['interval_days']?.toString() ?? '1'),
      repetitions: int.parse(json['repetitions']?.toString() ?? '0'),
      nextReview: DateTime.parse(json['next_review'] ?? json['nextReview'] ?? DateTime.now().toIso8601String()),
      lastReviewed: json['last_reviewed'] != null ? DateTime.parse(json['last_reviewed']) : null,
      reviewCount: int.parse(json['review_count']?.toString() ?? '0'),
    );
  }
}

class FlashcardDeck {
  final String name;
  final int cardCount;
  final int dueCount;

  FlashcardDeck({
    required this.name,
    required this.cardCount,
    required this.dueCount,
  });

  factory FlashcardDeck.fromJson(Map<String, dynamic> json) {
    return FlashcardDeck(
      name: json['deck_name'] ?? json['name'] ?? 'Genel',
      cardCount: int.parse(json['card_count']?.toString() ?? '0'),
      dueCount: int.parse(json['due_count']?.toString() ?? '0'),
    );
  }
}
