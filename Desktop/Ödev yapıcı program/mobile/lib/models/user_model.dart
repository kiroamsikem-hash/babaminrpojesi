class User {
  final String id;
  final String name;
  final String email;
  final String educationLevel;
  final bool isPremium;
  final String? avatar;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.educationLevel,
    this.isPremium = false,
    this.avatar,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    try {
      return User(
        id: json['id']?.toString() ?? '0',
        name: json['name']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        educationLevel: json['educationLevel']?.toString() ?? 'lise',
        isPremium: json['isPremium'] == true || json['isPremium'] == 1,
        avatar: json['avatar']?.toString(),
      );
    } catch (e) {
      print('User.fromJson error: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'educationLevel': educationLevel,
      'isPremium': isPremium,
      'avatar': avatar,
    };
  }
}
