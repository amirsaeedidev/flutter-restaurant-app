// core/services/discount_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/discount_model.dart';

class DiscountResult {
  final bool success;
  final String? errorMessage;
  final DiscountModel? discount;
  final int discountAmount;

  const DiscountResult({
    required this.success,
    this.errorMessage,
    this.discount,
    this.discountAmount = 0,
  });

  factory DiscountResult.error(String message) =>
      DiscountResult(success: false, errorMessage: message);

  factory DiscountResult.ok(DiscountModel discount, int amount) =>
      DiscountResult(success: true, discount: discount, discountAmount: amount);
}

class DiscountService {
  DiscountService._();
  static final SupabaseClient _client = Supabase.instance.client;

  static const _discounts = 'discounts';
  static const _usages = 'discount_usages';

  // فقط ستون‌های لازم را select کن (کاهش پهنای‌باند و سرعت بیشتر)
  static const _columns =
      'id, code, title, description, type, status, value, min_order_price, expires_at, emoji';

  // ── خواندن کدهای کاربر + علامت‌زدن کدهای استفاده‌شده ──
  static Future<List<DiscountModel>> fetchUserDiscounts(String userId) async {
    try {
      final rows = await _client
          .from(_discounts)
          .select(_columns)
          .or('user_id.eq.$userId,user_id.is.null')
          .order('created_at', ascending: false);

      final list = (rows as List)
          .map((r) => DiscountModel.fromJson(r as Map<String, dynamic>))
          .toList();

      final usedIds = await _fetchUsedIds(userId);
      if (usedIds.isEmpty) return list;

      return list
          .map((d) => usedIds.contains(d.id)
              ? d.copyWith(status: DiscountStatus.used)
              : d)
          .toList();
    } on PostgrestException catch (e) {
      throw Exception('خطا در دریافت تخفیف‌ها: ${e.message}');
    }
  }

  static Future<Set<String>> _fetchUsedIds(String userId) async {
    final rows = await _client
        .from(_usages)
        .select('discount_id')
        .eq('user_id', userId);
    return (rows as List)
        .map((r) => (r as Map)['discount_id'].toString())
        .toSet();
  }

  // ── اعمال کد با validation کامل ──
  static Future<DiscountResult> applyCode({
    required String code,
    required int cartTotal,
    String? userId,
  }) async {
    final normalized = code.trim().toUpperCase();
    if (normalized.isEmpty) return DiscountResult.error('کد تخفیف را وارد کنید');

    try {
      final row = await _client
          .from(_discounts)
          .select(_columns)
          .eq('code', normalized)
          .maybeSingle();

      if (row == null) return DiscountResult.error('کد تخفیف معتبر نیست');

      final discount = DiscountModel.fromJson(row);

      if (discount.isExpired) {
        return DiscountResult.error('این کد تخفیف منقضی شده است');
      }
      if (!discount.isActive) {
        return DiscountResult.error('این کد تخفیف فعال نیست');
      }

      // بررسی استفاده‌ی قبلیِ همین کاربر
      if (userId != null) {
        final already = await _client
            .from(_usages)
            .select('id')
            .eq('user_id', userId)
            .eq('discount_id', discount.id)
            .maybeSingle();
        if (already != null) {
          return DiscountResult.error('شما قبلاً از این کد استفاده کرده‌اید');
        }
      }

      if (discount.minOrderPrice != null &&
          cartTotal < discount.minOrderPrice!) {
        return DiscountResult.error(
          'حداقل مبلغ سفارش برای این کد ${_formatPrice(discount.minOrderPrice!)} تومان است',
        );
      }

      final raw = discount.type == DiscountType.percent
          ? (cartTotal * discount.value / 100).round()
          : discount.value.toInt();

      // تخفیف هیچ‌وقت از کل سبد بیشتر نشود
      final amount = raw > cartTotal ? cartTotal : raw;

      return DiscountResult.ok(discount, amount);
    } on PostgrestException catch (e) {
      return DiscountResult.error('خطای سرور: ${e.message}');
    } catch (_) {
      return DiscountResult.error('خطای غیرمنتظره. دوباره تلاش کنید');
    }
  }

  // ── ثبت استفاده بعد از پرداخت موفق ──
  static Future<void> markAsUsed({
    required String discountId,
    required String orderId,
    required String userId,
  }) async {
    await _client.from(_usages).insert({
      'discount_id': discountId,
      'order_id': orderId,
      'user_id': userId,
      // used_at را به default now() دیتابیس بسپار
    });
  }

  static String _formatPrice(int price) {
    final s = price.toString();
    final buf = StringBuffer();
    final offset = s.length % 3;
    for (int i = 0; i < s.length; i++) {
      if (i != 0 && (i - offset) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}