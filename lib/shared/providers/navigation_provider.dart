import 'package:flutter/material.dart';

class NavigationProvider extends ChangeNotifier {
  // عدد ۱ یعنی صفحه خانه به صورت پیش‌فرض باز باشد
  int _selectedIndex = 1;

  int get selectedIndex => _selectedIndex;

  void setIndex(int index) {
    _selectedIndex = index;
    notifyListeners(); // به کل برنامه خبر میده که تب عوض شد
  }
}