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

  // ثبت سفارش از طریق RPC (Transactional & Secure)
  Future<bool> placeOrder(OrderModel order, List<CartItemModel> cartItems, String? discountCode) async {
    try {
      final userId = SupabaseService.client.auth.currentUser?.id;
      if (userId == null) throw Exception("کاربر لاگین نیست");

      // مپ کردن آیتم‌های سبد برای ارسال به RPC
      final itemsPayload = cartItems.map((item) => {
            'product_id': item.product.id,
            'quantity': item.quantity,
          }).toList();

      // فراخوانی تابع place_order در دیتابیس
      final response = await SupabaseService.client.rpc(
        'place_order',
        params: {
          'p_order_type': order.type == OrderType.delivery ? 'delivery' : 'dine_in',
          'p_items': itemsPayload,
          'p_address_line': order.address,
          'p_table_number': order.tableNumber,
          'p_note': order.note,
          'p_discount_code': discountCode,
        },
      );

      // پاسخ RPC می‌تواند شامل جزئیات سفارش ثبت شده باشد
      // فرض می‌کنیم پاسخ ساختار مشابه order را دارد
      if (response != null) {
         final newOrder = OrderModel.fromJson(response as Map<String, dynamic>).copyWith(
           items: cartItems.map((e) => OrderItemModel(
             productId: e.product.id,
             productName: e.product.name,
             quantity: e.quantity,
             unitPrice: e.product.price,
           )).toList(),
         );
         _orders.insert(0, newOrder);
         notifyListeners();
      }

      return true;
    } catch (e) {
      _error = "خطا در ثبت سفارش: ${e.toString()}";
      print("Error placing order: $e");
      notifyListeners();
      return false;
    }
  }
}