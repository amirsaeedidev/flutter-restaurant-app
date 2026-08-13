import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/supabase_service.dart';

enum AuthStatus { unknown, unauthenticated, authenticated }

class AuthProvider extends ChangeNotifier {
  static const _keyIsLoggedIn = 'isLoggedIn';
  static const _keyPhone = 'userPhone';

  AuthStatus _status = AuthStatus.unknown;
  String _phone = '';
  bool _isLoading = false;
  String? _error;
  String? _userId; // اضافه شد برای ذخیره user_id واقعی از Supabase

  AuthStatus get status => _status;
  String get phone => _phone;
  String? get userId => _userId; // در مرحله ثبت سفارش به آن نیاز خواهیم داشت
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  AuthProvider() {
    _checkLoginStatus();
  }

  // بررسی وضعیت لاگین از SharedPreferences و Supabase Session
  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;
    _phone = prefs.getString(_keyPhone) ?? '';

    // بررسی اینکه آیا سشن Supabase موجود است یا خیر
    final currentUser = SupabaseService.client.auth.currentUser;
    
    if (isLoggedIn && currentUser != null) {
      _userId = currentUser.id;
      _status = AuthStatus.authenticated;
    } else {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  // ارسال OTP (Mock — بعداً Supabase)
  Future<bool> sendOtp(String phone) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    // شبیه‌سازی تأخیر شبکه
    await Future.delayed(const Duration(seconds: 1));

    _phone = phone;
    _isLoading = false;
    notifyListeners();
    return true; // همیشه موفق — Mock
  }

  // تأیید OTP (Mock — کد صحیح: 1234)
  Future<bool> verifyOtp(String code) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800));

    if (code == '1234') {
      try {
        // دریافت یا ایجاد کاربر ناشناس در Supabase برای تولید user_id معتبر
        // این کار از خطای Foreign Key هنگام ثبت سفارش جلوگیری می‌کند
        final response = await SupabaseService.client.auth.signInAnonymously();
        _userId = response.user?.id;

        if (_userId == null) {
          throw Exception('User ID is null');
        }

        // ذخیره وضعیت لاگین محلی
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_keyIsLoggedIn, true);
        await prefs.setString(_keyPhone, _phone);

        _status = AuthStatus.authenticated;
        _isLoading = false;
        notifyListeners();
        return true;
      } catch (e) {
        _error = 'خطا در اتصال به سرور (Anonymous Auth)';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } else {
      _error = 'کد وارد شده اشتباه است';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // خروج از حساب
  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyIsLoggedIn);
    await prefs.remove(_keyPhone);
    
    // خروج از سشن Supabase
    await SupabaseService.client.auth.signOut();
    
    _status = AuthStatus.unauthenticated;
    _phone = '';
    _userId = null;
    notifyListeners();
  }
}