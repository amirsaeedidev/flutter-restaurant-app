import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/model/loyalty_model.dart';

class LoyaltyProvider extends ChangeNotifier {
  static const _keyPoints = 'loyaltyPoints';

  int _points = 0;
  bool _loaded = false;

  int get points => _points;
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
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _points = prefs.getInt(_keyPoints) ?? 1250; // مقدار Mock اولیه
    _loaded = true;
    notifyListeners();
  }

  // فراخوانی بعد از هر سفارش موفق
  Future<void> addPointsForOrder(int orderTotal) async {
    final earned = pointsForOrder(orderTotal);
    _points += earned;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyPoints, _points);
  }

  // reset برای تست
  Future<void> resetPoints() async {
    _points = 0;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyPoints, 0);
  }
}