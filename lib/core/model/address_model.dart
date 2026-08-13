class AddressModel {
  final String id;
  final String title; // خونه / محل کار / ...
  final String addressLine;
  final String? recipientName;
  final String? phone;
  final String? postalCode;
  final bool isDefault;

  const AddressModel({
    required this.id,
    required this.title,
    required this.addressLine,
    this.recipientName,
    this.phone,
    this.postalCode,
    this.isDefault = false,
  });

  AddressModel copyWith({
    String? title,
    String? addressLine,
    String? recipientName,
    String? phone,
    String? postalCode,
    bool? isDefault,
  }) {
    return AddressModel(
      id: id,
      title: title ?? this.title,
      addressLine: addressLine ?? this.addressLine,
      recipientName: recipientName ?? this.recipientName,
      phone: phone ?? this.phone,
      postalCode: postalCode ?? this.postalCode,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  // مپ کردن داده‌ها برای ارسال به Supabase
  Map<String, dynamic> toJson({bool includeId = false}) {
    final map = <String, dynamic>{
      'title': title,
      'address_line': addressLine,
      'recipient_name': recipientName,
      'phone': phone,
      'postal_code': postalCode,
      'is_default': isDefault,
    };
    if (includeId) map['id'] = id;
    return map;
  }

  // مپ کردن داده‌های دریافتی از Supabase
  factory AddressModel.fromJson(Map<String, dynamic> j) => AddressModel(
        id: j['id'].toString(),
        title: j['title'] ?? '',
        addressLine: j['address_line'] ?? '',
        recipientName: j['recipient_name'],
        phone: j['phone'],
        postalCode: j['postal_code'],
        isDefault: j['is_default'] ?? false,
      );
}