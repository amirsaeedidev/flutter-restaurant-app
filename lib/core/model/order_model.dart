enum OrderStatus {
  pending,    // در انتظار تأیید
  confirmed,  // تأیید شده
  preparing,  // در حال آماده‌سازی
  onTheWay,   // در راه
  delivered,  // تحویل داده شد
}

enum OrderType { delivery, dineIn }

class OrderItemModel {
  final String productName;
  final int quantity;
  final int unitPrice;

  const OrderItemModel({
    required this.productName,
    required this.quantity,
    required this.unitPrice,
  });

  int get totalPrice => unitPrice * quantity;
}

class OrderModel {
  final String id;
  final String orderCode;
  final List<OrderItemModel> items;
  final int totalPrice;
  final OrderStatus status;
  final OrderType type;
  final DateTime createdAt;
  final DateTime estimatedDelivery;
  final String? address;       // فقط برای دلیوری
  final int? tableNumber;      // فقط برای حضوری
  final String note;

  const OrderModel({
    required this.id,
    required this.orderCode,
    required this.items,
    required this.totalPrice,
    required this.status,
    required this.type,
    required this.createdAt,
    required this.estimatedDelivery,
    this.address,
    this.tableNumber,
    this.note = '',
  });

  // label فارسی وضعیت
  String get statusLabel {
    switch (status) {
      case OrderStatus.pending:   return 'در انتظار تأیید';
      case OrderStatus.confirmed: return 'تأیید شده';
      case OrderStatus.preparing: return 'در حال آماده‌سازی';
      case OrderStatus.onTheWay:  return 'در راه است';
      case OrderStatus.delivered: return 'تحویل داده شد';
    }
  }

  String get statusEmoji {
    switch (status) {
      case OrderStatus.pending:   return '⏳';
      case OrderStatus.confirmed: return '✅';
      case OrderStatus.preparing: return '👨‍🍳';
      case OrderStatus.onTheWay:  return '🛵';
      case OrderStatus.delivered: return '🎉';
    }
  }

  // ایندکس مرحله فعلی (برای timeline)
  int get statusStep => status.index;
}