import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/orders_provider.dart';
import '../widgets/order_history_card.dart';

class RecentOrdersScreen extends StatelessWidget {
  const RecentOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OrdersProvider(),
      child: const _OrdersView(),
    );
  }
}

class _OrdersView extends DefaultTabController {
  const _OrdersView() : super(length: 2, child: const _Body());
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<OrdersProvider>();

    // تعریف رنگ‌ها برای استفاده آسان‌تر
    final backgroundColor =
        isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final surfaceColor =
        isDark ? const Color(0xFF1E1E1E) : Colors.white; // رنگ کارت‌ها و تب‌ها
    final primaryColor = AppColors.primary;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final textSecondaryColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: backgroundColor,
        // استفاده از appBar شفاف برای اعمال سایه سفارشی
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          // flexibleSpace برای اعمال پس‌زمینه رنگی بهAppBar اصلی
          flexibleSpace: Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha:0.3)
                      : Colors.black.withValues(alpha:0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.only(right: 16, left: 16, top: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'سفارشات',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: textColor,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
          // بخش پایین که شامل تب‌ها است را در کانتینر جداگانه با سایه قرار می‌دهیم
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Container(
              color: backgroundColor,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withValues(alpha:0.2)
                          : Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TabBar(
                  dividerColor: Colors.transparent,
                  labelColor: primaryColor,
                  unselectedLabelColor: textSecondaryColor,
                  indicatorColor: Colors.transparent,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    color: isDark
                        ? primaryColor.withValues(alpha:0.15)
                        : primaryColor.withValues(alpha:0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  labelStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  tabs: [
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('فعال'),
                          if (provider.activeOrders.isNotEmpty) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${provider.activeOrders.length}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          ],
                        ],
                      ),
                    ),
                    const Tab(text: 'تاریخچه'),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            // ── تب سفارشات فعال ──
            _OrderList(
              orders: provider.activeOrders,
              emptyEmoji: '🍽️',
              emptyTitle: 'سفارش فعالی نداری',
              emptySubtitle: 'یه نگاه به منو بنداز و خوشمزه‌ترین غذا رو انتخاب کن 😋',
              isDark: isDark,
              surfaceColor: surfaceColor,
              textColor: textColor,
              textSecondaryColor: textSecondaryColor,
            ),
            // ── تب تاریخچه ──
            _OrderList(
              orders: provider.historyOrders,
              emptyEmoji: '📋',
              emptyTitle: 'هنوز سفارشی نداری',
              emptySubtitle: 'اولین تجربه غذایی خوشمزه رو همین الان شروع کن!',
              isDark: isDark,
              surfaceColor: surfaceColor,
              textColor: textColor,
              textSecondaryColor: textSecondaryColor,
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderList extends StatelessWidget {
  const _OrderList({
    required this.orders,
    required this.emptyEmoji,
    required this.emptyTitle,
    required this.emptySubtitle,
    required this.isDark,
    required this.surfaceColor,
    required this.textColor,
    required this.textSecondaryColor,
  });

  final List orders;
  final String emptyEmoji;
  final String emptyTitle;
  final String emptySubtitle;
  final bool isDark;
  final Color surfaceColor;
  final Color textColor;
  final Color textSecondaryColor;

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha:0.3)
                      : Colors.black.withValues(alpha:0.03),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // افکت نرم برای ایموجی
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha:0.05)
                        : AppColors.primary.withValues(alpha:0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    emptyEmoji,
                    style: const TextStyle(fontSize: 50),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  emptyTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  emptySubtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: textSecondaryColor,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 100), // فاصله بالاتر برای زیبایی
      physics: const BouncingScrollPhysics(), // اسکرول نرم‌تر
      itemCount: orders.length,
      itemBuilder: (_, i) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: OrderHistoryCard(order: orders[i]),
      ),
    );
  }
}