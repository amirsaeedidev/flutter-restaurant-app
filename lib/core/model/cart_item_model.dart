import 'product_model.dart';

class CartItemModel {
  final ProductModel product;
  int quantity;
  String note;

  CartItemModel({
    required this.product,
    this.quantity = 1,
    this.note = '',
  });

  int get totalPrice => product.price * quantity;
}