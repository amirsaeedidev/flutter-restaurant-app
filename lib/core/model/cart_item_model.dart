import '../../../core/model/product_model.dart';

class CartItemModel {
  final ProductModel product;
  int quantity;
  String note; // توضیحات سفارش (مثلاً: بدون نمک)

  CartItemModel({
    required this.product,
    this.quantity = 1,
    this.note = '',
  });

  int get totalPrice => product.price * quantity;
}