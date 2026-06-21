import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/banner_model.dart';
import '../services/supabase_service.dart';

class BannerService {
  static final _client = SupabaseService.client;

  static Future<List<BannerModel>> getBanners() async {
    try {
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
    } on PostgrestException catch (e) {
      throw Exception('خطا در دریافت بنرها: ${e.message}');
    } catch (e) {
      throw Exception('خطای غیرمنتظره: $e');
    }
  }
}