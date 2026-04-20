class VideoNote {
  final String id;
  final String videoUrl;
  final String title;
  final String summary;
  final List<VideoTimestamp> timestamps;
  final List<VideoQuestion> questions;
  final DateTime createdAt;

  VideoNote({
    required this.id,
    required this.videoUrl,
    required this.title,
    required this.summary,
    required this.timestamps,
    required this.questions,
    required this.createdAt,
  });

  factory VideoNote.fromJson(Map<String, dynamic> json) {
    return VideoNote(
      id: json['id'].toString(),
      videoUrl: json['video_url'] ?? json['videoUrl'] ?? '',
      title: json['title'] ?? '',
      summary: json['summary'] ?? '',
      timestamps: (json['timestamps'] as List?)
              ?.map((t) => VideoTimestamp.fromJson(t))
              .toList() ??
          [],
      questions: (json['questions'] as List?)
              ?.map((q) => VideoQuestion.fromJson(q))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['created_at'] ?? json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class VideoTimestamp {
  final String time;
  final String title;
  final String description;

  VideoTimestamp({
    required this.time,
    required this.title,
    required this.description,
  });

  factory VideoTimestamp.fromJson(Map<String, dynamic> json) {
    return VideoTimestamp(
      time: json['time'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
    );
  }
}

class VideoQuestion {
  final String question;
  final List<String> options;
  final String correct;
  final String explanation;

  VideoQuestion({
    required this.question,
    required this.options,
    required this.correct,
    required this.explanation,
  });

  factory VideoQuestion.fromJson(Map<String, dynamic> json) {
    return VideoQuestion(
      question: json['question'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      correct: json['correct'] ?? '',
      explanation: json['explanation'] ?? '',
    );
  }
}
