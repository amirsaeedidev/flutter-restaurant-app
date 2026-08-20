import 'package:flutter/material.dart';
import '../../../core/model/loyalty_model.dart';
import '../../../core/services/supabase_service.dart';

class LoyaltyProvider extends ChangeNotifier {
  int _points = 0;
  bool _isLoading = false;
  bool _loaded = false;

  int get points => _points;
  bool get isLoading => _isLoading;
  bool get loaded => _loaded;

  LevelConfig get currentLevel => levelOf(_points);
  LevelConfig get nextLevel =>
      currentLevel.level == MemberLevel.vip ? currentLevel : levels[1];

  // پیشرفت تا سطح بعدی (0.0 تا 1.0)
  double get progress {
    if (currentLevel.level == MemberLevel.vip) return 1.0;
    return (_points / nextLevel.minPoints).clamp(0.0, 1.0);
  }

  // چند امتیاز تا VIP مانده
  int get pointsToNextLevel =>
      currentLevel.level == MemberLevel.vip
          ? 0
          : nextLevel.minPoints - _points;

  // قالب‌بندی عدد با هزارگان
  String formatPoints(int p) {
    final s = p.toString();
    final buf = StringBuffer();
    final offset = s.length % 3;
    for (int i = 0; i < s.length; i++) {
      if (i != 0 && (i - offset) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  LoyaltyProvider() {
    fetchPoints();
  }

  // دریافت امتیازات از Supabase
  Future<void> fetchPoints() async {
    _isLoading = true;
    notifyListeners();

    try {
      final userId = SupabaseService.client.auth.currentUser?.id;
      if (userId == null) {
        _points = 0;
        return;
      }

      final response = await SupabaseService.client
          .from('loyalty_wallets')
          .select('total_points')
          .eq('user_identifier', userId)
          .maybeSingle();

      if (response != null) {
        _points = response['total_points'] as int? ?? 0;
      } else {
        _points = 0;
      }
      _loaded = true;
    } catch (e) {
      print("Error fetching loyalty points: $e");
      _points = 0;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // این متد فعلاً کاری انجام نمی‌دهد چون امتیازها توسط مدیر اضافه می‌شوند
  // اما برای جلوگیری از ارور در checkout_screen.dart نگه داشته شده است
  Future<void> addPointsForOrder(int orderTotal) async {
    // No-op: Admin will handle points manually
  }

  // reset برای تست
  Future<void> resetPoints() async {
    _points = 0;
    notifyListeners();
  }
}