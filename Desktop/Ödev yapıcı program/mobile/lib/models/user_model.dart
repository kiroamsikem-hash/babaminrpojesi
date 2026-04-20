class User {
  final String id;
  final String name;
  final String email;
  final String educationLevel;
  final int grade;
  final bool isPremium;
  final String premiumTier;
  final String? premiumExpiresAt;
  final int dailyLimit;
  final bool isAdmin;
  final String? avatar;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.educationLevel,
    required this.grade,
    this.isPremium = false,
    this.premiumTier = 'free',
    this.premiumExpiresAt,
    this.dailyLimit = 5,
    this.isAdmin = false,
    this.avatar,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    try {
      // Grade'i parse et - educationLevel'dan veya grade field'ından
      int userGrade = 9;
      if (json['grade'] != null) {
        userGrade = int.tryParse(json['grade'].toString()) ?? 9;
      } else if (json['educationLevel'] != null) {
        userGrade = int.tryParse(json['educationLevel'].toString()) ?? 9;
      }

      return User(
        id: json['id']?.toString() ?? '0',
        name: json['name']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        educationLevel: json['educationLevel']?.toString() ?? 'lise',
        grade: userGrade,
        isPremium: json['isPremium'] == true || json['isPremium'] == 1,
        premiumTier: json['premiumTier']?.toString() ?? 'free',
        premiumExpiresAt: json['premiumExpiresAt']?.toString(),
        dailyLimit: int.tryParse(json['dailyLimit']?.toString() ?? '5') ?? 5,
        isAdmin: json['isAdmin'] == true || json['isAdmin'] == 1,
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
      'grade': grade,
      'isPremium': isPremium,
      'premiumTier': premiumTier,
      'premiumExpiresAt': premiumExpiresAt,
      'dailyLimit': dailyLimit,
      'isAdmin': isAdmin,
      'avatar': avatar,
    };
  }
}
