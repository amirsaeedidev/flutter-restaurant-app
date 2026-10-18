class BannerModel {
  final String id;
  final String title;
  final String imageUrl;
  final int sortOrder;
  final String? subtitle;
  final String? promoTitle;
  final String? discountCode;
  final String? logoUrl;

  const BannerModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.sortOrder,
    this.subtitle,
    this.promoTitle,
    this.discountCode,
    this.logoUrl,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) => BannerModel(
        id: json['id'].toString(),
        title: (json['title'] ?? '').toString(),
        imageUrl: (json['image_url'] ?? '').toString(),
        sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
        subtitle: json['subtitle']?.toString(),
        promoTitle: json['promo_title']?.toString(),
        discountCode: json['discount_code']?.toString(),
        logoUrl: json['logo_url']?.toString(),
      );
}
