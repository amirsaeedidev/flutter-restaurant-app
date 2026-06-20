import '../../core/services/supabase_service.dart';
import '../model/product_model.dart';

class CategoryService {
  static final _client = SupabaseService.client;

  /// دریافت همه کتگوری‌های فعال، مرتب‌شده
  static Future<List<CategoryModel>> getCategories() async {
    final res = await _client
        .from('categories')
        .select('id, name, image_url, sort_order, loyalty_points_per_item')
        .eq('is_active', true)
        .order('sort_order');

    return (res as List)
        .map((row) => CategoryModel(
              id: row['id'] as String,
              name: row['name'] as String,
              imageUrl: row['image_url'] as String? ?? '',
              loyaltyPointsPerItem:
                  row['loyalty_points_per_item'] as int? ?? 0,
            ))
        .toList();
  }
}