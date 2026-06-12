import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/model/address_model.dart';

class AddressProvider extends ChangeNotifier {
  static const _key = 'addresses';
  List<AddressModel> _addresses = [];
  bool _loaded = false;

  List<AddressModel> get addresses => List.unmodifiable(_addresses);
  bool get loaded => _loaded;
  bool get isEmpty => _addresses.isEmpty;

  AddressModel? get defaultAddress {
    try {
      return _addresses.firstWhere((a) => a.isDefault);
    } catch (_) {
      return _addresses.isNotEmpty ? _addresses.first : null;
    }
  }

  AddressProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw != null) {
      final list = (jsonDecode(raw) as List)
          .map((e) => AddressModel.fromJson(e))
          .toList();
      _addresses = list;
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(_addresses.map((a) => a.toJson()).toList()),
    );
  }

  Future<void> add(AddressModel address) async {
    // اگه اولین آدرسه، default بشه
    final isFirst = _addresses.isEmpty;
    _addresses.add(address.copyWith(isDefault: isFirst));
    notifyListeners();
    await _save();
  }

  Future<void> update(AddressModel updated) async {
    final i = _addresses.indexWhere((a) => a.id == updated.id);
    if (i != -1) {
      _addresses[i] = updated;
      notifyListeners();
      await _save();
    }
  }

  Future<void> remove(String id) async {
    final wasDefault = _addresses.any((a) => a.id == id && a.isDefault);
    _addresses.removeWhere((a) => a.id == id);
    // اگه default حذف شد، اولی رو default کن
    if (wasDefault && _addresses.isNotEmpty) {
      _addresses[0] = _addresses[0].copyWith(isDefault: true);
    }
    notifyListeners();
    await _save();
  }

  Future<void> setDefault(String id) async {
    _addresses = _addresses
        .map((a) => a.copyWith(isDefault: a.id == id))
        .toList();
    notifyListeners();
    await _save();
  }
}