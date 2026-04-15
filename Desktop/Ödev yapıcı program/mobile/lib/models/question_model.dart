class Question {
  final String id;
  final String type;
  final String question;
  final String answer;
  final String? imageUrl;
  final List<QuestionStep>? steps;
  final DateTime createdAt;

  Question({
    required this.id,
    required this.type,
    required this.question,
    required this.answer,
    this.imageUrl,
    this.steps,
    required this.createdAt,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: (json['_id'] ?? json['id'])?.toString() ?? '',
      type: json['type']?.toString() ?? 'genel',
      question: json['question']?.toString() ?? '',
      answer: json['answer']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString(),
      steps: json['steps'] != null
          ? (json['steps'] as List)
              .map((step) => QuestionStep.fromJson(step))
              .toList()
          : null,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'question': question,
      'answer': answer,
      'imageUrl': imageUrl,
      'steps': steps?.map((step) => step.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class QuestionStep {
  final String title;
  final String content;
  final String? formula;

  QuestionStep({
    required this.title,
    required this.content,
    this.formula,
  });

  factory QuestionStep.fromJson(Map<String, dynamic> json) {
    return QuestionStep(
      title: json['title']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      formula: json['formula']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'formula': formula,
    };
  }
}
