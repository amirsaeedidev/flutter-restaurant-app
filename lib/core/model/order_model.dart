enum OrderStatus {
  pending,    // در انتظار تأیید
  confirmed,  // تأیید شده
  preparing,  // در حال آماده‌سازی
  onTheWay,   // در راه
  delivered,  // تحویل داده شد
  cancelled,  // لغو شده
}

enum OrderType { delivery, dineIn }

class OrderItemModel {
  final String productId;
  final String productName;
  final int quantity;
  final int unitPrice;

  const OrderItemModel({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
  });

  int get totalPrice => unitPrice * quantity;

  Map<String, dynamic> toJson(String orderId) => {
        'order_id': orderId,
        'product_id': productId,
        'quantity': quantity,
        'unit_price': unitPrice,
        'total_price': totalPrice,
      };

  factory OrderItemModel.fromJson(Map<String, dynamic> j) => OrderItemModel(
        productId: j['product_id'] ?? '',
        productName: j['product_name'] ?? '',
        quantity: j['quantity'] ?? 1,
        unitPrice: j['unit_price'] ?? 0,
      );
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

  OrderModel copyWith({
    String? id,
    String? orderCode,
    List<OrderItemModel>? items,
    int? totalPrice,
    OrderStatus? status,
    OrderType? type,
    DateTime? createdAt,
    DateTime? estimatedDelivery,
    String? address,
    int? tableNumber,
    String? note,
  }) {
    return OrderModel(
      id: id ?? this.id,
      orderCode: orderCode ?? this.orderCode,
      items: items ?? this.items,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      estimatedDelivery: estimatedDelivery ?? this.estimatedDelivery,
      address: address ?? this.address,
      tableNumber: tableNumber ?? this.tableNumber,
      note: note ?? this.note,
    );
  }

  // مپ کردن داده‌ها برای ارسال به Supabase
  Map<String, dynamic> toJson() => {
        'order_type': type == OrderType.delivery ? 'delivery' : 'pickup',
        'status': 'pending',
        'total_amount': totalPrice,
        'estimated_ready_minutes': estimatedDelivery.difference(createdAt).inMinutes,
        'address_line': address,
        'table_number': tableNumber,
        'note': note,
      };

  // مپ کردن داده‌های دریافتی از Supabase
  factory OrderModel.fromJson(Map<String, dynamic> j) => OrderModel(
        id: j['id'],
        orderCode: j['order_code'] ?? j['id'].substring(0, 8).toUpperCase(),
        items: [], // آیتم‌ها در یک کوئری جداگانه یا join خوانده می‌شوند
        totalPrice: j['total_amount'] ?? 0,
        status: _parseStatus(j['status']),
        type: _parseType(j['order_type']),
        createdAt: DateTime.parse(j['created_at']),
        estimatedDelivery: DateTime.parse(j['created_at']).add(Duration(minutes: j['estimated_ready_minutes'] ?? 0)),
        address: j['address_line'],
        tableNumber: j['table_number'],
        note: j['note'] ?? '',
      );

  static OrderStatus _parseStatus(String? s) {
    switch (s) {
      case 'confirmed': return OrderStatus.confirmed;
      case 'preparing': return OrderStatus.preparing;
      case 'ready':
      case 'out_for_delivery': return OrderStatus.onTheWay;
      case 'completed': return OrderStatus.delivered;
      case 'cancelled': return OrderStatus.cancelled;
      default: return OrderStatus.pending;
    }
  }

  static OrderType _parseType(String? s) {
    return s == 'pickup' ? OrderType.dineIn : OrderType.delivery;
  }

  String get statusLabel {
    switch (status) {
      case OrderStatus.pending:   return 'در انتظار تأیید';
      case OrderStatus.confirmed: return 'تأیید شده';
      case OrderStatus.preparing: return 'در حال آماده‌سازی';
      case OrderStatus.onTheWay:  return 'در راه است';
      case OrderStatus.delivered: return 'تحویل داده شد';
      case OrderStatus.cancelled: return 'لغو شده';
    }
  }

  String get statusEmoji {
    switch (status) {
      case OrderStatus.pending:   return '⏳';
      case OrderStatus.confirmed: return '✅';
      case OrderStatus.preparing: return '👨‍🍳';
      case OrderStatus.onTheWay:  return '🛵';
      case OrderStatus.delivered: return '🎉';
      case OrderStatus.cancelled: return '❌';
    }
  }

  int get statusStep => status.index;
}