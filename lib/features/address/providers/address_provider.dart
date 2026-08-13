import 'package:flutter/material.dart';
import '../../../core/model/address_model.dart';
import '../../../core/services/supabase_service.dart';

class AddressProvider extends ChangeNotifier {
  List<AddressModel> _addresses = [];
  bool _isLoading = false;
  bool _loaded = false;
  String? _error;

  List<AddressModel> get addresses => List.unmodifiable(_addresses);
  bool get isLoading => _isLoading;
  bool get loaded => _loaded;
  bool get isEmpty => _addresses.isEmpty;
  String? get error => _error;

  AddressModel? get defaultAddress {
    try {
      return _addresses.firstWhere((a) => a.isDefault);
    } catch (_) {
      return _addresses.isNotEmpty ? _addresses.first : null;
    }
  }

  AddressProvider() {
    fetchAddresses();
  }

  Future<String?> _getCurrentUserId() async {
    final user = SupabaseService.client.auth.currentUser;
    return user?.id;
  }

  // دریافت لیست آدرس‌ها از Supabase
  Future<void> fetchAddresses() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userId = await _getCurrentUserId();
      if (userId == null) throw Exception("کاربر لاگین نیست");

      final response = await SupabaseService.client
          .from('addresses')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      _addresses =
          (response as List).map((e) => AddressModel.fromJson(e)).toList();
      _loaded = true;
    } catch (e) {
      _error = "خطا در دریافت آدرس‌ها";
      print("Error fetching addresses: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // اضافه کردن آدرس جدید
  Future<bool> add(AddressModel address) async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) throw Exception("کاربر لاگین نیست");

      // اگر اولین آدرس است، پیش‌فرض شود
      final isFirst = _addresses.isEmpty;
      
      final payload = address.toJson();
      payload['user_id'] = userId;
      payload['is_default'] = isFirst;

      final response = await SupabaseService.client
          .from('addresses')
          .insert(payload)
          .select()
          .single();

      _addresses.insert(0, AddressModel.fromJson(response));
      notifyListeners();
      return true;
    } catch (e) {
      _error = "خطا در ذخیره آدرس";
      print("Error adding address: $e");
      notifyListeners();
      return false;
    }
  }

  // ویرایش آدرس
  Future<bool> update(AddressModel updated) async {
    try {
      await SupabaseService.client
          .from('addresses')
          .update(updated.toJson())
          .eq('id', updated.id);

      final i = _addresses.indexWhere((a) => a.id == updated.id);
      if (i != -1) {
        _addresses[i] = updated;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = "خطا در ویرایش آدرس";
      print("Error updating address: $e");
      notifyListeners();
      return false;
    }
  }

  // حذف آدرس
  Future<bool> remove(String id) async {
    try {
      await SupabaseService.client.from('addresses').delete().eq('id', id);
      
      final wasDefault = _addresses.any((a) => a.id == id && a.isDefault);
      _addresses.removeWhere((a) => a.id == id);
      
      // اگر آدرس پیش‌فرض حذف شد و آدرس دیگری وجود دارد، اولین آدرس پیش‌فرض شود
      if (wasDefault && _addresses.isNotEmpty) {
        await setDefault(_addresses.first.id);
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = "خطا در حذف آدرس";
      print("Error deleting address: $e");
      notifyListeners();
      return false;
    }
  }

  // تنظیم به عنوان آدرس پیش‌فرض
  Future<bool> setDefault(String id) async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) throw Exception("کاربر لاگین نیست");

      // ابتدا همه آدرس‌های کاربر را false می‌کنیم
      await SupabaseService.client
          .from('addresses')
          .update({'is_default': false})
          .eq('user_id', userId);

      // سپس آدرس مورد نظر را true می‌کنیم
      await SupabaseService.client
          .from('addresses')
          .update({'is_default': true})
          .eq('id', id);

      _addresses = _addresses
          .map((a) => a.copyWith(isDefault: a.id == id))
          .toList();
          
      notifyListeners();
      return true;
    } catch (e) {
      _error = "خطا در تنظیم آدرس پیش‌فرض";
      print("Error setting default address: $e");
      notifyListeners();
      return false;
    }
  }
}