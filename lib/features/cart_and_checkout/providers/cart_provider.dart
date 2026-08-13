import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/model/product_model.dart';
import '../../../core/model/cart_item_model.dart';

class CartProvider extends ChangeNotifier {
  static const _keyCart = 'cart_items';
  final List<CartItemModel> _items = [];

  List<CartItemModel> get items => List.unmodifiable(_items);
  int get itemCount => _items.fold(0, (sum, e) => sum + e.quantity);
  int get totalPrice => _items.fold(0, (sum, e) => sum + e.totalPrice);

  bool isInCart(String productId) =>
      _items.any((e) => e.product.id == productId);

  int quantityOf(String productId) {
    final index = _items.indexWhere((e) => e.product.id == productId);
    return index == -1 ? 0 : _items[index].quantity;
  }

  String noteOf(String productId) {
    final index = _items.indexWhere((e) => e.product.id == productId);
    return index == -1 ? '' : _items[index].note;
  }

  CartProvider() {
    _loadCartFromPrefs();
  }

  // بارگذاری سبد خرید از حافظه محلی
  Future<void> _loadCartFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_keyCart);
      if (raw != null) {
        final list = jsonDecode(raw) as List;
        _items.clear();
        _items.addAll(list.map((e) => CartItemModel.fromJson(e)).toList());
        notifyListeners();
      }
    } catch (e) {
      print("Error loading cart: $e");
    }
  }

  // ذخیره سبد خرید در حافظه محلی
  Future<void> _saveCartToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = jsonEncode(_items.map((e) => e.toJson()).toList());
      await prefs.setString(_keyCart, raw);
    } catch (e) {
      print("Error saving cart: $e");
    }
  }

  void addItem(ProductModel product, {int quantity = 1, String note = ''}) {
    final index = _items.indexWhere((e) => e.product.id == product.id);
    if (index == -1) {
      _items.add(CartItemModel(product: product, quantity: quantity, note: note));
    } else {
      _items[index].quantity += quantity;
      if (note.isNotEmpty) _items[index].note = note;
    }
    _saveCartToPrefs();
    notifyListeners();
  }

  void increment(String productId) {
    final index = _items.indexWhere((e) => e.product.id == productId);
    if (index != -1) {
      _items[index].quantity++;
      _saveCartToPrefs();
      notifyListeners();
    }
  }

  void decrement(String productId) {
    final index = _items.indexWhere((e) => e.product.id == productId);
    if (index != -1) {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
      } else {
        _items.removeAt(index);
      }
      _saveCartToPrefs();
      notifyListeners();
    }
  }

  void removeItem(String productId) {
    _items.removeWhere((e) => e.product.id == productId);
    _saveCartToPrefs();
    notifyListeners();
  }

  void updateNote(String productId, String note) {
    final index = _items.indexWhere((e) => e.product.id == productId);
    if (index != -1) {
      _items[index].note = note;
      _saveCartToPrefs();
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    _saveCartToPrefs();
    notifyListeners();
  }
}