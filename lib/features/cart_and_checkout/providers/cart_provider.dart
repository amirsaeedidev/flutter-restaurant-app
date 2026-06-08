import 'package:flutter/material.dart';
import '../../../core/model/product_model.dart';
import '../../../core/model/cart_item_model.dart';

class CartProvider extends ChangeNotifier {
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

  void addItem(ProductModel product, {int quantity = 1, String note = ''}) {
    final index = _items.indexWhere((e) => e.product.id == product.id);
    if (index == -1) {
      _items.add(CartItemModel(product: product, quantity: quantity, note: note));
    } else {
      _items[index].quantity += quantity;
      if (note.isNotEmpty) _items[index].note = note;
    }
    notifyListeners();
  }

  void increment(String productId) {
    final index = _items.indexWhere((e) => e.product.id == productId);
    if (index != -1) {
      _items[index].quantity++;
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
      notifyListeners();
    }
  }

  void removeItem(String productId) {
    _items.removeWhere((e) => e.product.id == productId);
    notifyListeners();
  }

  void updateNote(String productId, String note) {
    final index = _items.indexWhere((e) => e.product.id == productId);
    if (index != -1) {
      _items[index].note = note;
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}