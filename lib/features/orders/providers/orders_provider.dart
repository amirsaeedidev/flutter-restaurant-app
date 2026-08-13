import 'package:flutter/material.dart';
import '../../../core/model/order_model.dart';
import '../../../core/model/cart_item_model.dart';
import '../../../core/services/supabase_service.dart';

class OrdersProvider extends ChangeNotifier {
  List<OrderModel> _orders = [];
  bool _isLoading = false;
  String? _error;

  List<OrderModel> get orders => List.unmodifiable(_orders);
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<OrderModel> get activeOrders => _orders
      .where((o) => o.status != OrderStatus.delivered && o.status != OrderStatus.cancelled)
      .toList();

  List<OrderModel> get historyOrders => _orders
      .where((o) => o.status == OrderStatus.delivered || o.status == OrderStatus.cancelled)
      .toList();

  Future<void> fetchOrders() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userId = SupabaseService.client.auth.currentUser?.id;
      if (userId == null) throw Exception("کاربر لاگین نیست");

      final response = await SupabaseService.client
          .from('orders')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      _orders = (response as List).map((e) => OrderModel.fromJson(e)).toList();
    } catch (e) {
      _error = "خطا در دریافت سفارش‌ها";
      print("Error fetching orders: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  OrderModel? findById(String id) {
    try {
      return _orders.firstWhere((o) => o.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<bool> placeOrder(OrderModel order, List<CartItemModel> cartItems) async {
    try {
      final userId = SupabaseService.client.auth.currentUser?.id;
      if (userId == null) throw Exception("کاربر لاگین نیست");

      // ۱. ثبت سفارش اصلی
      final orderPayload = order.toJson();
      orderPayload['user_id'] = userId;

      final orderResponse = await SupabaseService.client
          .from('orders')
          .insert(orderPayload)
          .select()
          .single();

      final orderId = orderResponse['id'];
      final newOrder = OrderModel.fromJson(orderResponse);

      // ۲. ثبت آیتم‌های سفارش
      final itemsPayload = cartItems.map((item) => {
            'order_id': orderId,
            'product_id': item.product.id,
            'quantity': item.quantity,
            'unit_price': item.product.price,
            'total_price': item.totalPrice,
          }).toList();

      await SupabaseService.client.from('order_items').insert(itemsPayload);

      // ۳. اضافه کردن به لیست محلی برای بروزرسانی سریع UI
      _orders.insert(0, newOrder.copyWith(
        items: cartItems.map((e) => OrderItemModel(
          productId: e.product.id,
          productName: e.product.name,
          quantity: e.quantity,
          unitPrice: e.product.price,
        )).toList(),
      ));
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = "خطا در ثبت سفارش";
      print("Error placing order: $e");
      notifyListeners();
      return false;
    }
  }
}