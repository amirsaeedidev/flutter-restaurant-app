import '../../core/services/supabase_service.dart';
import '../model/banner_model.dart';

class BannerService {
  static final _client = SupabaseService.client;

  /// دریافت بنرهای فعال، مرتب‌شده
  static Future<List<BannerModel>> getBanners() async {
    final res = await _client
        .from('banners')
        .select('id, title, image_url, sort_order')
        .eq('is_active', true)
        .order('sort_order');

    return (res as List)
        .map((row) => BannerModel(
              id: row['id'] as String,
              title: row['title'] as String,
              imageUrl: row['image_url'] as String? ?? '',
              sortOrder: row['sort_order'] as int? ?? 0,
            ))
        .toList();
  }
}