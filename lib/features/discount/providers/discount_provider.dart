import 'package:flutter/material.dart';
import '../../../core/model/discount_model.dart';
import '../../../core/services/discount_service.dart';

/// وضعیت لودینگ Provider
enum DiscountLoadState { idle, loading, loaded, error }

class DiscountProvider extends ChangeNotifier {
  // ── State ──
  List<DiscountModel> _discounts = [];
  DiscountLoadState _loadState = DiscountLoadState.idle;
  String? _loadError;

  // ── برای checkout ──
  DiscountModel? _appliedDiscount;
  int _discountAmount = 0;
  bool _isApplying = false;
  String? _applyError;

  // ── Getters ──
  List<DiscountModel> get all => List.unmodifiable(_discounts);
  List<DiscountModel> get active =>
      _discounts.where((d) => d.isActive).toList();
  List<DiscountModel> get usedOrExpired =>
      _discounts.where((d) => !d.isActive).toList();

  DiscountLoadState get loadState => _loadState;
  bool get isLoading => _loadState == DiscountLoadState.loading;
  String? get loadError => _loadError;

  DiscountModel? get appliedDiscount => _appliedDiscount;
  int get discountAmount => _discountAmount;
  bool get isApplying => _isApplying;
  String? get applyError => _applyError;
  bool get hasDiscount => _appliedDiscount != null && _discountAmount > 0;

  // ────────────────────────────────────────────
  // بارگذاری تخفیف‌ها از Supabase
  // ────────────────────────────────────────────
  Future<void> loadDiscounts() async {
    if (_loadState == DiscountLoadState.loaded) return;

    _loadState = DiscountLoadState.loading;
    _loadError = null;
    notifyListeners();

    try {
      _discounts = await DiscountService.fetchAvailableDiscounts();
      _loadState = DiscountLoadState.loaded;
    } catch (e) {
      _loadState = DiscountLoadState.error;
      _loadError = e.toString();
    }

    notifyListeners();
  }

  // ── force reload (برای pull-to-refresh) ──
  Future<void> reload() async {
    _loadState = DiscountLoadState.idle;
    await loadDiscounts();
  }

  // ────────────────────────────────────────────
  // اعمال کد تخفیف (Supabase)
  // ────────────────────────────────────────────
  Future<void> applyCode({
    required String code,
    required int cartTotal,
  }) async {
    if (code.trim().isEmpty) return;

    _isApplying = true;
    _applyError = null;
    notifyListeners();

    final result = await DiscountService.applyCode(
      code: code,
      cartTotal: cartTotal,
    );

    if (result.success) {
      _appliedDiscount = result.discount;
      _discountAmount = result.discountAmount;
      _applyError = null;
    } else {
      _appliedDiscount = null;
      _discountAmount = 0;
      _applyError = result.errorMessage;
    }

    _isApplying = false;
    notifyListeners();
  }

  // ────────────────────────────────────────────
  // حذف کد اعمال‌شده
  // ────────────────────────────────────────────
  void removeDiscount() {
    _appliedDiscount = null;
    _discountAmount = 0;
    _applyError = null;
    notifyListeners();
  }

  // ────────────────────────────────────────────
  // علامت‌گذاری به‌عنوان استفاده‌شده (بعد از پرداخت)
  // ────────────────────────────────────────────
  Future<void> markAppliedAsUsed() async {
    if (_appliedDiscount == null) return;

    await DiscountService.markAsUsed(
      discountId: _appliedDiscount!.id,
    );

    // آپدیت local state
    final index = _discounts.indexWhere((d) => d.id == _appliedDiscount!.id);
    if (index != -1) {
      _discounts[index] = _discounts[index].copyWith(status: DiscountStatus.used);
    }

    removeDiscount();
    notifyListeners();
  }

  // ── reset کامل (هنگام logout) ──
  void reset() {
    _discounts = [];
    _loadState = DiscountLoadState.idle;
    _loadError = null;
    _appliedDiscount = null;
    _discountAmount = 0;
    _applyError = null;
    _isApplying = false;
    notifyListeners();
  }
}