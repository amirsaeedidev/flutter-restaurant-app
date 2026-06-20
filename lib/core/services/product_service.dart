import '../../core/services/supabase_service.dart';
import '../model/product_model.dart';

class ProductService {
  static final _client = SupabaseService.client;

  /// همه محصولات فعال
  static Future<List<ProductModel>> getProducts() async {
    final res = await _client
        .from('products')
        .select('''
          id, name, description, price, image_url,
          rating, review_count, is_popular, category_id
        ''')
        .eq('is_active', true)
        .order('created_at', ascending: false);

    return (res as List)
        .map((row) => _fromRow(row as Map<String, dynamic>))
        .toList();
  }

  /// محصولات یک کتگوری خاص
  static Future<List<ProductModel>> getProductsByCategory(
      String categoryId) async {
    final res = await _client
        .from('products')
        .select('''
          id, name, description, price, image_url,
          rating, review_count, is_popular, category_id
        ''')
        .eq('category_id', categoryId)
        .eq('is_active', true)
        .order('created_at', ascending: false);

    return (res as List)
        .map((row) => _fromRow(row as Map<String, dynamic>))
        .toList();
  }

  /// محصولات پرطرفدار
  static Future<List<ProductModel>> getPopularProducts() async {
    final res = await _client
        .from('products')
        .select('''
          id, name, description, price, image_url,
          rating, review_count, is_popular, category_id
        ''')
        .eq('is_popular', true)
        .eq('is_active', true)
        .order('rating', ascending: false)
        .limit(10);

    return (res as List)
        .map((row) => _fromRow(row as Map<String, dynamic>))
        .toList();
  }

  /// جستجوی محصول با نام
  static Future<List<ProductModel>> searchProducts(String query) async {
    final res = await _client
        .from('products')
        .select('''
          id, name, description, price, image_url,
          rating, review_count, is_popular, category_id
        ''')
        .ilike('name', '%$query%')
        .eq('is_active', true);

    return (res as List)
        .map((row) => _fromRow(row as Map<String, dynamic>))
        .toList();
  }

  // ── mapper ──
  static ProductModel _fromRow(Map<String, dynamic> r) => ProductModel(
        id: r['id'] as String,
        name: r['name'] as String,
        description: r['description'] as String? ?? '',
        price: (r['price'] as num).toInt(),
        imageUrl: r['image_url'] as String? ?? '',
        rating: (r['rating'] as num?)?.toDouble() ?? 0.0,
        reviewCount: r['review_count'] as int? ?? 0,
        isPopular: r['is_popular'] as bool? ?? false,
        categoryId: r['category_id'] as String,
      );
}