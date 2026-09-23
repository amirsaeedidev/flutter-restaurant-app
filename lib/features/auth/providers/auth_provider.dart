import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/supabase_service.dart';

enum AuthStatus {
  unknown,
  unauthenticated,
  authenticated,
}

class AuthProvider extends ChangeNotifier {
  static const _keyIsLoggedIn = 'isLoggedIn';
  static const _keyPhone = 'userPhone';

  // ============================================================
  // DEVELOPMENT TEST ACCOUNT
  // ============================================================

  static const String _testEmail = 'dev@restaurant.test';
  static const String _testPassword = 'RestaurantDev@1234';
  static const String _testCode = '1234';

  AuthStatus _status = AuthStatus.unknown;
  String _phone = '';
  bool _isLoading = false;
  String? _error;
  String? _userId;

  AuthStatus get status => _status;
  String get phone => _phone;
  String? get userId => _userId;
  bool get isLoading => _isLoading;
  String? get error => _error;

  bool get isAuthenticated =>
      _status == AuthStatus.authenticated;

  AuthProvider() {
    _checkLoginStatus();
  }

  // ============================================================
  // CHECK LOGIN STATUS
  // ============================================================

  Future<void> _checkLoginStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      _phone = prefs.getString(_keyPhone) ?? '';

      // بررسی Session واقعی Supabase
      final session =
          SupabaseService.client.auth.currentSession;

      final currentUser =
          SupabaseService.client.auth.currentUser;

      if (session != null && currentUser != null) {
        _userId = currentUser.id;
        _status = AuthStatus.authenticated;

        debugPrint('AUTH: Existing Supabase session found');
        debugPrint('AUTH USER ID: ${currentUser.id}');
      } else {
        await prefs.remove(_keyIsLoggedIn);

        _userId = null;
        _status = AuthStatus.unauthenticated;

        debugPrint('AUTH: No active session');
      }
    } catch (e, stackTrace) {
      debugPrint('AUTH CHECK ERROR: $e');
      debugPrintStack(stackTrace: stackTrace);

      _status = AuthStatus.unauthenticated;
      _userId = null;
    }

    notifyListeners();
  }

  // ============================================================
  // SEND OTP - MOCK
  // ============================================================

  Future<bool> sendOtp(String phone) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.delayed(
        const Duration(milliseconds: 500),
      );

      _phone = phone.trim();

      if (_phone.isEmpty) {
        _error = 'شماره تلفن را وارد کنید';
        return false;
      }

      debugPrint('DEV LOGIN PHONE: $_phone');
      debugPrint('DEV LOGIN CODE: $_testCode');

      return true;
    } catch (e) {
      _error = 'خطا در ارسال کد';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================================================
  // VERIFY OTP - DEVELOPMENT LOGIN
  //
  // هر شماره + کد 1234
  // وارد یک User واقعی در Supabase می‌شود.
  // ============================================================

  Future<bool> verifyOtp(String code) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // ----------------------------------------------------------
      // بررسی کد تست
      // ----------------------------------------------------------

      if (code.trim() != _testCode) {
        _error = 'کد وارد شده اشتباه است';
        return false;
      }
      // ----------------------------------------------------------
      // بررسی شماره
      // ----------------------------------------------------------

      if (_phone.trim().isEmpty) {
        _error = 'شماره تلفن وارد نشده است';
        return false;
      }

      // ----------------------------------------------------------
      // ورود به User واقعی Supabase
      // ----------------------------------------------------------

      debugPrint('========== DEV LOGIN ==========');
      debugPrint('PHONE: $_phone');
      debugPrint('EMAIL: $_testEmail');

      final response =
          await SupabaseService.client.auth.signInWithPassword(
        email: _testEmail,
        password: _testPassword,
      );

      final user = response.user;
      final session = response.session;

      // ----------------------------------------------------------
      // بررسی Session
      // ----------------------------------------------------------

      if (user == null) {
        throw Exception(
          'Supabase User ایجاد نشد',
        );
      }

      if (session == null) {
        throw Exception(
          'Supabase Session ایجاد نشد',
        );
      }

      // ----------------------------------------------------------
      // ذخیره اطلاعات
      // ----------------------------------------------------------

      _userId = user.id;

      final prefs =
          await SharedPreferences.getInstance();

      await prefs.setBool(
        _keyIsLoggedIn,
        true,
      );

      await prefs.setString(
        _keyPhone,
        _phone,
      );

      // ----------------------------------------------------------
      // Authentication موفق
      // ----------------------------------------------------------

      _status = AuthStatus.authenticated;

      debugPrint('LOGIN SUCCESS');
      debugPrint('USER ID: ${user.id}');
      debugPrint('PHONE: $_phone');
      debugPrint('SESSION: ACTIVE');
      debugPrint('==============================');

      return true;
    } catch (e, stackTrace) {
      debugPrint('========== LOGIN ERROR ==========');
      debugPrint(e.toString());
      debugPrintStack(
        stackTrace: stackTrace,
      );
      debugPrint('=================================');

      _error = e.toString();

      _status = AuthStatus.unauthenticated;
      _userId = null;

      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================================================
  // SIGN OUT
  // ============================================================

  Future<void> signOut() async {
    try {
      final prefs =
          await SharedPreferences.getInstance();

      await prefs.remove(_keyIsLoggedIn);
      await prefs.remove(_keyPhone);

      // خروج واقعی از Supabase
      await SupabaseService.client.auth.signOut();

      _status = AuthStatus.unauthenticated;
      _phone = '';
      _userId = null;
      _error = null;

      debugPrint('AUTH: Signed out');
    } catch (e, stackTrace) {
      debugPrint('SIGN OUT ERROR: $e');
      debugPrintStack(
        stackTrace: stackTrace,
      );
    }

    notifyListeners();
  }
}