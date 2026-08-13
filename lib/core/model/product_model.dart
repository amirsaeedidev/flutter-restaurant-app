class CategoryModel {
  final String id;
  final String name;
  final String imageUrl;
  final int loyaltyPointsPerItem; // از جدول categories.loyalty_points_per_item

  const CategoryModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.loyaltyPointsPerItem = 0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'image_url': imageUrl,
        'loyalty_points_per_item': loyaltyPointsPerItem,
      };

  factory CategoryModel.fromJson(Map<String, dynamic> j) => CategoryModel(
        id: j['id'].toString(),
        name: j['name'] ?? '',
        imageUrl: j['image_url'] ?? '',
        loyaltyPointsPerItem: j['loyalty_points_per_item'] ?? 0,
      );
}

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

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'price': price,
        'image_url': imageUrl,
        'rating': rating,
        'review_count': reviewCount,
        'is_popular': isPopular,
        'category_id': categoryId,
      };

  factory ProductModel.fromJson(Map<String, dynamic> j) => ProductModel(
        id: j['id'].toString(),
        name: j['name'] ?? '',
        description: j['description'] ?? '',
        price: j['price'] ?? 0,
        imageUrl: j['image_url'] ?? '',
        rating: (j['rating'] ?? 0).toDouble(),
        reviewCount: j['review_count'] ?? 0,
        isPopular: j['is_popular'] ?? false,
        categoryId: j['category_id']?.toString() ?? '',
      );
}