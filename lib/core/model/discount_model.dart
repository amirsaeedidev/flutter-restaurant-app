// core/model/discount_model.dart

enum DiscountType { percent, fixed }

enum DiscountStatus { active, used, expired }

class DiscountModel {
  final String id;
  final String code;
  final String title;
  final String description;
  final DiscountType type;
  final DiscountStatus status;
  final double value;
  final int? minOrderPrice;
  final DateTime? expiresAt;
  final String emoji;

  const DiscountModel({
    required this.id,
    required this.code,
    required this.title,
    required this.description,
    required this.type,
    required this.status,
    required this.value,
    required this.emoji,
    this.minOrderPrice,
    this.expiresAt,
  });

  // ── computed (بدون allocation اضافه) ──
  bool get isExpired {
    if (status == DiscountStatus.expired) return true;
    final exp = expiresAt;
    if (exp == null) return false;
    return DateTime.now().isAfter(exp);
  }

  bool get isUsed => status == DiscountStatus.used;

  bool get isActive =>
      status == DiscountStatus.active && !isExpired && !isUsed;

  int get daysLeft {
    final exp = expiresAt;
    if (exp == null) return 0;
    final d = exp.difference(DateTime.now()).inDays;
    return d < 0 ? 0 : d;
  }

  String get valueLabel {
    if (type == DiscountType.percent) {
      final isWhole = value.truncateToDouble() == value;
      return '${value.toStringAsFixed(isWhole ? 0 : 1)}%';
    }
    return '${_format(value.toInt())}\nتومان';
  }

  static String _format(int p) {
    final s = p.toString();
    final buf = StringBuffer();
    final offset = s.length % 3;
    for (int i = 0; i < s.length; i++) {
      if (i != 0 && (i - offset) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  // ── fromJson مقاوم در برابر null و نوع داده (Supabase) ──
  factory DiscountModel.fromJson(Map<String, dynamic> json) {
    return DiscountModel(
      id: json['id'].toString(),
      code: (json['code'] as String?)?.toUpperCase() ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      type: _typeFrom(json['type'] as String?),
      status: _statusFrom(json['status'] as String?),
      value: _toDouble(json['value']),
      minOrderPrice: _toIntOrNull(json['min_order_price']),
      expiresAt: _toDateOrNull(json['expires_at']),
      emoji: json['emoji'] as String? ?? '🏷️',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'title': title,
        'description': description,
        'type': type.name,
        'status': status.name,
        'value': value,
        'min_order_price': minOrderPrice,
        'expires_at': expiresAt?.toIso8601String(),
        'emoji': emoji,
      };

  DiscountModel copyWith({DiscountStatus? status}) => DiscountModel(
        id: id,
        code: code,
        title: title,
        description: description,
        type: type,
        status: status ?? this.status,
        value: value,
        minOrderPrice: minOrderPrice,
        expiresAt: expiresAt,
        emoji: emoji,
      );

  // ── helpers ──
  static DiscountType _typeFrom(String? v) =>
      v == 'fixed' ? DiscountType.fixed : DiscountType.percent;

  static DiscountStatus _statusFrom(String? v) {
    switch (v) {
      case 'used':
        return DiscountStatus.used;
      case 'expired':
        return DiscountStatus.expired;
      default:
        return DiscountStatus.active;
    }
  }

  static double _toDouble(dynamic v) {
    if (v is num) return v.toDouble();
    return double.tryParse(v?.toString() ?? '') ?? 0;
  }

  static int? _toIntOrNull(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
  }

  static DateTime? _toDateOrNull(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    return DateTime.tryParse(v.toString())?.toLocal();
  }
}