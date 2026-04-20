class StudySession {
  final String id;
  final String subject;
  final DateTime targetDate;
  final int dailyGoal;
  final int completedToday;
  final int totalMinutes;
  final String? notes;
  final DateTime? lastStudy;

  StudySession({
    required this.id,
    required this.subject,
    required this.targetDate,
    required this.dailyGoal,
    required this.completedToday,
    required this.totalMinutes,
    this.notes,
    this.lastStudy,
  });

  factory StudySession.fromJson(Map<String, dynamic> json) {
    return StudySession(
      id: json['id'].toString(),
      subject: json['subject'] ?? '',
      targetDate: DateTime.parse(json['target_date'] ?? json['targetDate'] ?? DateTime.now().toIso8601String()),
      dailyGoal: int.parse(json['daily_goal']?.toString() ?? '60'),
      completedToday: int.parse(json['completed_today']?.toString() ?? '0'),
      totalMinutes: int.parse(json['total_minutes']?.toString() ?? '0'),
      notes: json['notes'],
      lastStudy: json['last_study'] != null ? DateTime.parse(json['last_study']) : null,
    );
  }

  int get daysRemaining {
    final now = DateTime.now();
    final difference = targetDate.difference(DateTime(now.year, now.month, now.day));
    return difference.inDays;
  }

  double get progressPercentage {
    if (dailyGoal == 0) return 0;
    return (completedToday / dailyGoal * 100).clamp(0, 100);
  }
}
