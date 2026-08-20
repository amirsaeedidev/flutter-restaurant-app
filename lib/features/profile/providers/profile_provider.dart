import 'package:flutter/material.dart';
import '../../../core/model/user_model.dart';
import '../../../core/services/supabase_service.dart';

class ProfileProvider extends ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  ProfileProvider() {
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userId = SupabaseService.client.auth.currentUser?.id;
      if (userId == null) {
        _user = null;
        return;
      }

      final response = await SupabaseService.client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response != null) {
        _user = UserModel.fromJson(response);
      }
    } catch (e) {
      _error = "خطا در دریافت اطلاعات کاربر";
      print("Error fetching profile: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateUser({String? firstName, String? lastName}) async {
    try {
      final userId = SupabaseService.client.auth.currentUser?.id;
      if (userId == null) return false;

      final payload = {
        if (firstName != null) 'first_name': firstName,
        if (lastName != null) 'last_name': lastName,
      };

      await SupabaseService.client
          .from('profiles')
          .update(payload)
          .eq('id', userId);

      _user = _user?.copyWith(
        firstName: firstName ?? _user?.firstName,
        lastName: lastName ?? _user?.lastName,
      );
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = "خطا در به‌روزرسانی پروفایل";
      print("Error updating profile: $e");
      return false;
    }
  }

  // این متد فعلاً فقط در UI فراخوانی می‌شود، عملیات اصلی در AuthProvider انجام می‌شود
  void clearUser() {
    _user = null;
    notifyListeners();
  }

  Future<void> signOut() async {
    await SupabaseService.client.auth.signOut();
    _user = null;
    notifyListeners();
  }
}