import 'package:flutter/material.dart';
import '../../../core/model/order_model.dart';

class OrdersProvider extends ChangeNotifier {
  // سفارشات Mock برای نمایش
  final List<OrderModel> _orders = [
    OrderModel(
      id: '1',
      orderCode: 'RST-۱۴۰۳-۰۰۱',
      items: const [
        OrderItemModel(productName: 'چلو کباب کوبیده مخصوص', quantity: 2, unitPrice: 250000),
        OrderItemModel(productName: 'دوغ آبعلی شیشه‌ای', quantity: 2, unitPrice: 25000),
      ],
      totalPrice: 565000,
      status: OrderStatus.onTheWay,
      type: OrderType.delivery,
      createdAt: DateTime.now().subtract(const Duration(minutes: 25)),
      estimatedDelivery: DateTime.now().add(const Duration(minutes: 15)),
      address: 'تهران، خیابان ولیعصر، پلاک ۱۲',
      note: 'زودتر بیارید ممنون',
    ),
    OrderModel(
      id: '2',
      orderCode: 'RST-۱۴۰۳-۰۰۲',
      items: const [
        OrderItemModel(productName: 'کباب شیشلیک شاندیز', quantity: 1, unitPrice: 650000),
        OrderItemModel(productName: 'زیتون پرورده رودبار', quantity: 1, unitPrice: 85000),
      ],
      totalPrice: 735000,
      status: OrderStatus.delivered,
      type: OrderType.dineIn,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      estimatedDelivery: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
      tableNumber: 7,
    ),
    OrderModel(
      id: '3',
      orderCode: 'RST-۱۴۰۳-۰۰۳',
      items: const [
        OrderItemModel(productName: 'چلو جوجه کباب زعفرانی', quantity: 3, unitPrice: 220000),
      ],
      totalPrice: 675000,
      status: OrderStatus.preparing,
      type: OrderType.delivery,
      createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
      estimatedDelivery: DateTime.now().add(const Duration(minutes: 35)),
      address: 'تهران، خیابان شریعتی، کوچه گلها، پلاک ۴',
    ),
  ];

  List<OrderModel> get orders => List.unmodifiable(_orders);

  // سفارش‌های فعال (تحویل نشده)
  List<OrderModel> get activeOrders => _orders
      .where((o) => o.status != OrderStatus.delivered)
      .toList();

  // تاریخچه (تحویل داده شده)
  List<OrderModel> get historyOrders => _orders
      .where((o) => o.status == OrderStatus.delivered)
      .toList();

  OrderModel? findById(String id) {
    try {
      return _orders.firstWhere((o) => o.id == id);
    } catch (_) {
      return null;
    }
  }

  // افزودن سفارش جدید (بعد از checkout)
  void addOrder(OrderModel order) {
    _orders.insert(0, order);
    notifyListeners();
  }
}