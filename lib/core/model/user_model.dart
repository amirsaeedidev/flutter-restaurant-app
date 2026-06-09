class UserModel {
  final String id;
  final String firstName;
  final String lastName;
  final String phone;
  final int points;           // امتیاز باشگاه مشترکین
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
}