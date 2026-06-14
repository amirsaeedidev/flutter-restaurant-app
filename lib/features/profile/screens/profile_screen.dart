import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/model/loyalty_model.dart';
import '../../loyalty/providers/loyalty_provider.dart';
import '../../loyalty/screens/loyalty_screen.dart';
import '../../orders/providers/orders_provider.dart';
import '../../orders/screens/recent_orders_screen.dart';
import '../../orders/screens/order_tracking_screen.dart';
import '../providers/profile_provider.dart';
import '../widgets/edit_profile_sheet.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final profile = context.watch<ProfileProvider>();
    final loyalty = context.watch<LoyaltyProvider>();
    final orders = context.watch<OrdersProvider>();
    final user = profile.user;
    final level = loyalty.currentLevel;
    final isVip = level.level == MemberLevel.vip;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
            isDark ? AppColors.darkBackground : AppColors.lightBackground,
        body: CustomScrollView(
          slivers: [
            // ── SliverAppBar با هدر پروفایل ──
            SliverAppBar(
              expandedHeight: 260,
              pinned: true,
              backgroundColor: AppColors.primary,
              leading: IconButton(
                icon: const Icon(Icons.arrow_forward_rounded,
                    color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit_rounded, color: Colors.white),
                  onPressed: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => ChangeNotifierProvider.value(
                      value: profile,
                      child: const EditProfileSheet(),
                    ),
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.parallax,
                background: _ProfileHeader(
                  user: user,
                  loyalty: loyalty,
                  level: level,
                  isVip: isVip,
                  isDark: isDark,
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
                child: Column(
                  children: [
                    // ── کارت باشگاه مشترکین ──
                    _LoyaltyCard(
                      loyalty: loyalty,
                      level: level,
                      isVip: isVip,
                      isDark: isDark,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const LoyaltyScreen()),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── آمار سریع ──
                    _StatsRow(
                      orders: orders,
                      loyalty: loyalty,
                      isDark: isDark,
                    ),

                    const SizedBox(height: 16),

                    // ── سفارشات فعال ──
                    if (orders.activeOrders.isNotEmpty) ...[
                      _SectionHeader(
                        title: 'سفارشات فعال',
                        icon: '🛵',
                        isDark: isDark,
                        onSeeAll: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const RecentOrdersScreen()),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...orders.activeOrders.take(2).map(
                            (o) => _OrderSummaryCard(
                              order: o,
                              isDark: isDark,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      OrderTrackingScreen(order: o),
                                ),
                              ),
                            ),
                          ),
                      const SizedBox(height: 16),
                    ],

                    // ── آخرین سفارش‌ها ──
                    if (orders.historyOrders.isNotEmpty) ...[
                      _SectionHeader(
                        title: 'آخرین سفارش‌ها',
                        icon: '📋',
                        isDark: isDark,
                        onSeeAll: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const RecentOrdersScreen()),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...orders.historyOrders.take(3).map(
                            (o) => _OrderSummaryCard(
                              order: o,
                              isDark: isDark,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      OrderTrackingScreen(order: o),
                                ),
                              ),
                            ),
                          ),
                      const SizedBox(height: 16),
                    ],

                    // ── اگه هیچ سفارشی نیست ──
                    if (orders.orders.isEmpty)
                      _EmptyOrders(isDark: isDark),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── هدر پروفایل ──
class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.user,
    required this.loyalty,
    required this.level,
    required this.isVip,
    required this.isDark,
  });
  final user;
  final LoyaltyProvider loyalty;
  final LevelConfig level;
  final bool isVip;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isVip
              ? [const Color(0xFFFF8F00), const Color(0xFFFFB300)]
              : [AppColors.primary, const Color(0xFFEF5350)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                children: [
                  // آواتار
                  Container(
                    width: 72, height: 72,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Colors.white54, width: 2.5),
                    ),
                    child: const Center(
                      child: Text('👤',
                          style: TextStyle(fontSize: 34)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.fullName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.phone,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        // badge سطح
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                            border:
                                Border.all(color: Colors.white38),
                          ),
                          child: Text(
                            '${level.emoji}  ${level.title}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── کارت باشگاه مشترکین ──
class _LoyaltyCard extends StatelessWidget {
  const _LoyaltyCard({
    required this.loyalty,
    required this.level,
    required this.isVip,
    required this.isDark,
    required this.onTap,
  });
  final LoyaltyProvider loyalty;
  final LevelConfig level;
  final bool isVip;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isVip
                ? [const Color(0xFFFFB300), const Color(0xFFFF8F00)]
                : [AppColors.primary, const Color(0xFFEF5350)],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: (isVip
                      ? const Color(0xFFFFB300)
                      : AppColors.primary)
                  .withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Text(level.emoji,
                    style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('باشگاه مشترکین',
                          style: TextStyle(
                              color: Colors.white70, fontSize: 12)),
                      Text(level.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          )),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('امتیاز',
                        style: TextStyle(
                            color: Colors.white70, fontSize: 12)),
                    Text(
                      loyalty.formatPoints(loyalty.points),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (!isVip) ...[
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: loyalty.progress),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeOutCubic,
                  builder: (_, v, __) => LinearProgressIndicator(
                    value: v,
                    minHeight: 7,
                    backgroundColor: Colors.white24,
                    valueColor:
                        const AlwaysStoppedAnimation(Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${loyalty.formatPoints(loyalty.pointsToNextLevel)} امتیاز تا VIP 👑',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600),
                  ),
                  const Text('مشاهده جزئیات ←',
                      style: TextStyle(
                          color: Colors.white70, fontSize: 11)),
                ],
              ),
            ] else ...[
              const SizedBox(height: 10),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                    Icon(Icons.verified_rounded,
                        color: Colors.white, size: 16),
                    SizedBox(width: 4),
                    Text('بالاترین سطح عضویت',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                  ]),
                  Text('مشاهده مزایا ←',
                      style: TextStyle(
                          color: Colors.white70, fontSize: 11)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── ردیف آمار ──
class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.orders,
    required this.loyalty,
    required this.isDark,
  });
  final OrdersProvider orders;
  final LoyaltyProvider loyalty;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatBox(
            emoji: '🛒',
            label: 'کل سفارشات',
            value: '${orders.orders.length}',
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatBox(
            emoji: '🛵',
            label: 'در جریان',
            value: '${orders.activeOrders.length}',
            isDark: isDark,
            highlight: orders.activeOrders.isNotEmpty,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatBox(
            emoji: '⭐',
            label: 'امتیاز کل',
            value: loyalty.formatPoints(loyalty.points),
            isDark: isDark,
          ),
        ),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({
    required this.emoji,
    required this.label,
    required this.value,
    required this.isDark,
    this.highlight = false,
  });
  final String emoji;
  final String label;
  final String value;
  final bool isDark;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: highlight
            ? AppColors.primary.withValues(alpha: 0.1)
            : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
        borderRadius: BorderRadius.circular(14),
        border: highlight
            ? Border.all(
                color: AppColors.primary.withValues(alpha: 0.4),
                width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: highlight
                  ? AppColors.primary
                  : (isDark ? AppColors.darkText : AppColors.lightText),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── هدر بخش ──
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.isDark,
    required this.onSeeAll,
  });
  final String title;
  final String icon;
  final bool isDark;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.darkText : AppColors.lightText,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: onSeeAll,
          child: const Text(
            'همه ←',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}

// ── کارت خلاصه سفارش ──
class _OrderSummaryCard extends StatelessWidget {
  const _OrderSummaryCard({
    required this.order,
    required this.isDark,
    required this.onTap,
  });
  final order;
  final bool isDark;
  final VoidCallback onTap;

  String _format(int p) {
    final s = p.toString();
    final buf = StringBuffer();
    final offset = s.length % 3;
    for (int i = 0; i < s.length; i++) {
      if (i != 0 && (i - offset) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return '$buf تومان';
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} دقیقه پیش';
    if (diff.inHours < 24) return '${diff.inHours} ساعت پیش';
    return '${diff.inDays} روز پیش';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black
                  .withValues(alpha: isDark ? 0.2 : 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // وضعیت
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(order.statusEmoji,
                    style: const TextStyle(fontSize: 22)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.orderCode,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.darkText
                          : AppColors.lightText,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${order.items.length} آیتم  •  ${_timeAgo(order.createdAt)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _format(order.totalPrice),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    order.statusLabel,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── حالت خالی سفارشات ──
class _EmptyOrders extends StatelessWidget {
  const _EmptyOrders({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text('🍽️', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text('هنوز سفارشی ندادی!',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkText : AppColors.lightText,
              )),
          const SizedBox(height: 6),
          Text('از منوی رستوران سفارش بده 😋',
              style: TextStyle(
                fontSize: 13,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              )),
        ],
      ),
    );
  }
}