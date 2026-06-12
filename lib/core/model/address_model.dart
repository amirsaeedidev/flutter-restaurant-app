class AddressModel {
  final String id;
  final String title;      // خونه / محل کار / ...
  final String fullAddress;
  final String? phone;
  final bool isDefault;

  const AddressModel({
    required this.id,
    required this.title,
    required this.fullAddress,
    this.phone,
    this.isDefault = false,
  });

  AddressModel copyWith({
    String? title,
    String? fullAddress,
    String? phone,
    bool? isDefault,
  }) {
    return AddressModel(
      id: id,
      title: title ?? this.title,
      fullAddress: fullAddress ?? this.fullAddress,
      phone: phone ?? this.phone,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'fullAddress': fullAddress,
        'phone': phone,
        'isDefault': isDefault,
      };

  factory AddressModel.fromJson(Map<String, dynamic> j) => AddressModel(
        id: j['id'],
        title: j['title'],
        fullAddress: j['fullAddress'],
        phone: j['phone'],
        isDefault: j['isDefault'] ?? false,
      );
}