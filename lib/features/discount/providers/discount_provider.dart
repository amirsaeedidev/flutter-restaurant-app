import 'package:flutter/material.dart';
import '../../../core/model/discount_model.dart';

class DiscountProvider extends ChangeNotifier {
  // کدهای تخفیف Mock
  final List<DiscountModel> _discounts = [
    DiscountModel(
      id: '1',
      code: 'FIRST20',
      title: 'تخفیف اولین سفارش',
      description: 'برای اولین سفارش از اپ رستوران',
      type: DiscountType.percent,
      status: DiscountStatus.active,
      value: 20,
      expiresAt: DateTime.now().add(const Duration(days: 30)),
      emoji: '🎉',
      minOrderPrice: 100000,
    ),
    DiscountModel(
      id: '2',
      code: 'MEMBER5',
      title: 'تخفیف عضویت عادی',
      description: 'مزیت سطح عضویت عادی باشگاه',
      type: DiscountType.percent,
      status: DiscountStatus.active,
      value: 5,
      expiresAt: DateTime.now().add(const Duration(days: 90)),
      emoji: '🥉',
    ),
    DiscountModel(
      id: '3',
      code: 'WEEKEND15',
      title: 'تخفیف آخر هفته',
      description: 'هر آخر هفته از این کد استفاده کن',
      type: DiscountType.percent,
      status: DiscountStatus.active,
      value: 15,
      expiresAt: DateTime.now().add(const Duration(days: 7)),
      emoji: '🎊',
      minOrderPrice: 200000,
    ),
    DiscountModel(
      id: '4',
      code: 'FREESHIP',
      title: 'ارسال رایگان',
      description: 'هزینه ارسال رایگان برای این سفارش',
      type: DiscountType.fixed,
      status: DiscountStatus.active,
      value: 15000,
      expiresAt: DateTime.now().add(const Duration(days: 14)),
      emoji: '🛵',
    ),
    DiscountModel(
      id: '5',
      code: 'SUMMER10',
      title: 'تخفیف تابستانه',
      description: 'جشنواره تابستان رستوران',
      type: DiscountType.percent,
      status: DiscountStatus.used,
      value: 10,
      expiresAt: DateTime.now().subtract(const Duration(days: 5)),
      emoji: '☀️',
    ),
    DiscountModel(
      id: '6',
      code: 'NEWYEAR',
      title: 'تخفیف سال نو',
      description: 'جشن سال نو مبارک',
      type: DiscountType.percent,
      status: DiscountStatus.expired,
      value: 25,
      expiresAt: DateTime.now().subtract(const Duration(days: 30)),
      emoji: '🎆',
    ),
  ];

  List<DiscountModel> get all => List.unmodifiable(_discounts);

  List<DiscountModel> get active =>
      _discounts.where((d) => d.isActive).toList();

  List<DiscountModel> get usedOrExpired =>
      _discounts.where((d) => !d.isActive).toList();

  // اعمال کد دستی
  String? applyCode(String code) {
    final match = _discounts.where(
      (d) => d.code.toLowerCase() == code.toLowerCase(),
    );
    if (match.isEmpty) return 'کد تخفیف معتبر نیست';
    final d = match.first;
    if (d.isUsed) return 'این کد قبلاً استفاده شده';
    if (d.isExpired) return 'این کد منقضی شده';
    return null; // null = موفق
  }

  DiscountModel? findActive(String code) {
    try {
      return _discounts.firstWhere(
        (d) => d.code.toLowerCase() == code.toLowerCase() && d.isActive,
      );
    } catch (_) {
      return null;
    }
  }
}