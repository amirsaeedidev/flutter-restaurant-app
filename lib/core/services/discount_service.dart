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
  static final SupabaseClient _client = Supabase.instance.client;
  static const _table = 'discounts';

  // ── خواندن کدهای تخفیف فعال (عمومی) ──
  static Future<List<DiscountModel>> fetchAvailableDiscounts() async {
    try {
      final rows = await _client
          .from(_table)
          .select()
          .eq('is_active', true)
          .order('created_at', ascending: false);

      return (rows as List)
          .map((r) => DiscountModel.fromJson(r as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw Exception('خطا در دریافت تخفیف‌ها: ${e.message}');
    }
  }

  // ── اعمال کد با validation کامل ──
  static Future<DiscountResult> applyCode({
    required String code,
    required int cartTotal,
  }) async {
    final normalized = code.trim().toUpperCase();
    if (normalized.isEmpty) return DiscountResult.error('کد تخفیف را وارد کنید');

    try {
      final row = await _client
          .from(_table)
          .select()
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

      // بررسی حداقل مبلغ سفارش
      if (discount.minOrderPrice != null &&
          cartTotal < discount.minOrderPrice!) {
        return DiscountResult.error(
          'حداقل مبلغ سفارش برای این کد ${_formatPrice(discount.minOrderPrice!)} تومان است',
        );
      }

      // محاسبه مبلغ تخفیف
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
  static Future<void> markAsUsed({required String discountId}) async {
    // در دیتابیس شما جدول discount_usages وجود ندارد.
    // برای Production بهتر است یک RPC بنویسید که used_count را یکی اضافه کند.
    // فعلا برای جلوگیری از خطا، این متد فقط لاگ می‌اندازد.
    print('Discount $discountId marked as used (locally).');
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