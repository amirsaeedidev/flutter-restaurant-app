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

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
            isDark ? AppColors.darkBackground : AppColors.lightBackground,
        appBar: AppBar(
          backgroundColor:
              isDark ? AppColors.darkBackground : AppColors.lightBackground,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Text(
            'سفارشات',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: isDark ? AppColors.darkText : AppColors.lightText,
            ),
          ),
          bottom: TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            labelStyle: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w700),
            tabs: [
              Tab(
                text: provider.activeOrders.isEmpty
                    ? 'فعال'
                    : 'فعال (${provider.activeOrders.length})',
              ),
              const Tab(text: 'تاریخچه'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // ── تب سفارشات فعال ──
            _OrderList(
              orders: provider.activeOrders,
              emptyEmoji: '🍽️',
              emptyTitle: 'سفارش فعالی نداری',
              emptySubtitle: 'از منو سفارش بده 😋',
              isDark: isDark,
            ),
            // ── تب تاریخچه ──
            _OrderList(
              orders: provider.historyOrders,
              emptyEmoji: '📋',
              emptyTitle: 'هنوز سفارشی نداری',
              emptySubtitle: 'اولین سفارشت رو ثبت کن!',
              isDark: isDark,
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
  });

  final List orders;
  final String emptyEmoji;
  final String emptyTitle;
  final String emptySubtitle;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emptyEmoji, style: const TextStyle(fontSize: 60)),
            const SizedBox(height: 16),
            Text(
              emptyTitle,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.darkText : AppColors.lightText,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              emptySubtitle,
              style: TextStyle(
                fontSize: 14,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: orders.length,
      itemBuilder: (_, i) => OrderHistoryCard(order: orders[i]),
    );
  }
}