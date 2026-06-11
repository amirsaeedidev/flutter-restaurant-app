enum DiscountType { percent, fixed }
enum DiscountStatus { active, used, expired }

class DiscountModel {
  final String id;
  final String code;
  final String title;
  final String description;
  final DiscountType type;
  final DiscountStatus status;
  final double value;          // ۱۵ یعنی ۱۵٪ یا ۱۵۰۰۰ تومان
  final int? minOrderPrice;   // حداقل مبلغ سفارش
  final DateTime expiresAt;
  final String emoji;

  const DiscountModel({
    required this.id,
    required this.code,
    required this.title,
    required this.description,
    required this.type,
    required this.status,
    required this.value,
    required this.expiresAt,
    required this.emoji,
    this.minOrderPrice,
  });

  bool get isActive => status == DiscountStatus.active;
  bool get isExpired => status == DiscountStatus.expired;
  bool get isUsed => status == DiscountStatus.used;

  String get valueLabel => type == DiscountType.percent
      ? '${value.toInt()}٪'
      : '${_fmt(value.toInt())} تومان';

  String _fmt(int p) {
    final s = p.toString();
    final buf = StringBuffer();
    final offset = s.length % 3;
    for (int i = 0; i < s.length; i++) {
      if (i != 0 && (i - offset) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  // روزهای مانده تا انقضا
  int get daysLeft => expiresAt.difference(DateTime.now()).inDays;
}