import 'package:flutter/material.dart';
import '../../../core/model/order_model.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/theme/app_colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/tracking_timeline.dart';

class OrderTrackingScreen extends StatefulWidget {
  const OrderTrackingScreen({super.key, required this.order});
  final OrderModel order;

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  late OrderModel _order;
  RealtimeChannel? _channel;

  @override
  void initState() {
    super.initState();
    _order = widget.order;
    _setupRealtimeListener();
  }

  void _setupRealtimeListener() {
    // گوش دادن به تغییرات جدول orders فقط برای این سفارش خاص
    _channel = SupabaseService.client
        .channel('public:orders:id=eq.${_order.id}')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'orders',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: _order.id,
          ),
          callback: (payload) {
            if (mounted) {
              final newRecord = payload.newRecord;
              setState(() {
                // آپدیت مدل سفارش با حفظ آیتم‌های قبلی (چون در رویداد orders، items نیستند)
                _order = OrderModel.fromJson(newRecord).copyWith(
                  items: _order.items,
                );
              });
            }
          },
        )
        .subscribe();
  }

  @override
  void dispose() {
    // قطع اتصال Realtime هنگام خروج از صفحه برای جلوگیری از memory leak
    _channel?.unsubscribe();
    super.dispose();
  }

  String _format(int price) {
    final s = price.toString();
    final buf = StringBuffer();
    final offset = s.length % 3;
    for (int i = 0; i < s.length; i++) {
      if (i != 0 && (i - offset) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return '$buf تومان';
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  int _remainingMinutes() {
    final diff = _order.estimatedDelivery.difference(DateTime.now());
    return diff.isNegative ? 0 : diff.inMinutes;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDelivered = _order.status == OrderStatus.delivered;
    final isCancelled = _order.status == OrderStatus.cancelled;
    final remaining = _remainingMinutes();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
            isDark ? AppColors.darkBackground : AppColors.lightBackground,
        appBar: AppBar(
          backgroundColor:
              isDark ? AppColors.darkBackground : AppColors.lightBackground,
          elevation: 0,
          title: Text(
            'پیگیری سفارش',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: isDark ? AppColors.darkText : AppColors.lightText,
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_forward_rounded,
                color: isDark ? AppColors.darkText : AppColors.lightText),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── کارت اطلاعات اصلی ──
            _InfoCard(
              order: _order,
              isDark: isDark,
              isDelivered: isDelivered,
              isCancelled: isCancelled,
              remaining: remaining,
              formatTime: _formatTime,
            ),

            const SizedBox(height: 20),

            // ── Timeline (فقط اگر لغو نشده باشد) ──
            if (!isCancelled) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'مراحل سفارش',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.darkText : AppColors.lightText,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TrackingTimeline(order: _order),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // ── آیتم‌های سفارش ──
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'آیتم‌های سفارش',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.darkText : AppColors.lightText,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._order.items.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${item.productName} × ${item.quantity}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark
                                      ? AppColors.darkText
                                      : AppColors.lightText,
                                ),
                              ),
                            ),
                            Text(
                              _format(item.totalPrice),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      )),
                  Divider(
                      color: isDark
                          ? Colors.white12
                          : Colors.black.withValues(alpha: 0.08)),
                  Row(
                    children: [
                      Text(
                        'مبلغ کل',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.darkText
                              : AppColors.lightText,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _format(_order.totalPrice),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── کارت اطلاعات اصلی ──
class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.order,
    required this.isDark,
    required this.isDelivered,
    required this.isCancelled,
    required this.remaining,
    required this.formatTime,
  });
  final OrderModel order;
  final bool isDark;
  final bool isDelivered;
  final bool isCancelled;
  final int remaining;
  final String Function(DateTime) formatTime;

  @override
  Widget build(BuildContext context) {
    // رنگ‌بندی کارت بر اساس وضعیت
    List<Color> gradientColors;
    if (isDelivered) {
      gradientColors = [Colors.green.shade600, Colors.green.shade400];
    } else if (isCancelled) {
      gradientColors = [Colors.red.shade700, Colors.red.shade500];
    } else {
      gradientColors = [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)];
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // کد سفارش
          Row(
            children: [
              const Icon(Icons.receipt_long_rounded, color: Colors.white70, size: 16),
              const SizedBox(width: 6),
              Text(
                order.orderCode,
                style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // وضعیت اصلی
          Text(
            '${order.statusEmoji}  ${order.statusLabel}',
            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
          ),

          const SizedBox(height: 12),

          // زمان تحویل فقط اگر لغو نشده باشد
          if (!isDelivered && !isCancelled) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.access_time_rounded, color: Colors.white, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    remaining > 0
                        ? 'تحویل تا $remaining دقیقه دیگر  (${formatTime(order.estimatedDelivery)})'
                        : 'به زودی تحویل داده می‌شود',
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],

          // آدرس یا میز
          Row(
            children: [
              Icon(
                order.type == OrderType.delivery
                    ? Icons.location_on_rounded
                    : Icons.table_restaurant_rounded,
                color: Colors.white70,
                size: 16,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  order.type == OrderType.delivery
                      ? (order.address ?? '')
                      : 'میز شماره ${order.tableNumber ?? 'نامشخص'}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}