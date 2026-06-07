class ProductModel {
  final String id;
  final String name;
  final String description;
  final int price;
  final String imageUrl;
  final double rating;
  final int reviewCount;
  final bool isPopular;
  final String categoryId;

  const ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.rating,
    required this.reviewCount,
    required this.isPopular,
    required this.categoryId,
  });
}

class CategoryModel {
  final String id;
  final String name;
  final String icon;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
  });
}