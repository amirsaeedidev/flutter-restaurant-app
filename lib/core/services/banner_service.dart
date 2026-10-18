import 'package:supabase_flutter/supabase_flutter.dart';

import '../model/banner_model.dart';
import 'supabase_service.dart';

class BannerService {
  static final SupabaseClient _client = SupabaseService.client;

  static Future<List<BannerModel>> getBanners() async {
    try {
      final response = await _client
          .from('banners')
          .select('id, title, subtitle, promo_title, discount_code, logo_url, image_url, sort_order')
          .eq('is_active', true)
          .order('sort_order', ascending: true);

      return (response as List)
          .map((row) => BannerModel.fromJson(row as Map<String, dynamic>))
          .toList(growable: false);
    } on PostgrestException catch (error) {
      throw Exception('خطا در دریافت بنرها: ${error.message}');
    } catch (error) {
      throw Exception('خطای غیرمنتظره در دریافت بنرها: $error');
    }
  }
}
