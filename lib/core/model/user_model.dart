class UserModel {
  final String id;
  final String firstName;
  final String lastName;
  final String phone;
  final int points;           // امتیاز باشگاه مشترکین (از loyalty_wallets.total_points)
  final String? avatarUrl;

  const UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    this.points = 0,
    this.avatarUrl,
  });

  String get fullName => '$firstName $lastName';

  // نمایش امتیاز با جداکننده هزارگان
  String get formattedPoints {
    final s = points.toString();
    final buf = StringBuffer();
    final offset = s.length % 3;
    for (int i = 0; i < s.length; i++) {
      if (i != 0 && (i - offset) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  UserModel copyWith({
    String? firstName,
    String? lastName,
    String? phone,
    int? points,
    String? avatarUrl,
  }) {
    return UserModel(
      id: id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      points: points ?? this.points,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  // برای آپدیت اطلاعات در Supabase
  Map<String, dynamic> toJson() => {
        'first_name': firstName,
        'last_name': lastName,
        'phone': phone,
        'avatar_url': avatarUrl,
      };

  // برای خواندن اطلاعات از Supabase
  factory UserModel.fromJson(Map<String, dynamic> j) => UserModel(
        id: j['id'],
        firstName: j['first_name'] ?? '',
        lastName: j['last_name'] ?? '',
        phone: j['phone'] ?? '',
        avatarUrl: j['avatar_url'],
        // اگر کوئری ما Join با جدول loyalty_wallets داشته باشد، total_points را می‌گیرد
        points: j['total_points'] ?? 0, 
      );
}