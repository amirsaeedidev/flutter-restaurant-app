import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/home_provider.dart';
import '../widgets/category_tabs.dart';
import '../widgets/product_grid.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeProvider(),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── AppBar چسبنده ──
          SliverAppBar(
            pinned: true,
            floating: true,
            snap: true,
            expandedHeight: 110,
            backgroundColor:
                isDark ? AppColors.darkBackground : AppColors.lightBackground,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              title: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🍽️ منوی رستوران',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: isDark ? AppColors.darkText : AppColors.lightText,
                    ),
                  ),
                  Text(
                    'بهترین غذاها در یک کلیک',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              // دکمه جستجو (آینده)
              IconButton(
                icon: Icon(
                  Icons.search_rounded,
                  color: isDark ? AppColors.darkText : AppColors.lightText,
                ),
                onPressed: () {},
              ),
              // دکمه پروفایل / Drawer
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: GestureDetector(
                  onTap: () => Scaffold.of(context).openDrawer(),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.black.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Text('👤', style: TextStyle(fontSize: 18)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),

          // ── بنر تبلیغاتی ساده ──
          SliverToBoxAdapter(
            child: _PromoBanner(isDark: isDark),
          ),

          // ── تب‌های کتگوری (Sticky) ──
          SliverPersistentHeader(
            pinned: true,
            delegate: _StickyTabsDelegate(isDark: isDark),
          ),

          // ── فاصله بالای گرید ──
          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // ── گرید محصولات ──
          const ProductGrid(),
        ],
      ),
    );
  }
}

// ── بنر تبلیغاتی ──
class _PromoBanner extends StatelessWidget {
  const _PromoBanner({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      height: 130,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withRed(200).withValues(alpha: 0.85),
          ],
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          // متن بنر
          const Positioned(
            right: 20,
            top: 0,
            bottom: 0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🎉 پیشنهاد ویژه',
                  style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 4),
                Text(
                  '۲۰٪ تخفیف\nاولین سفارش',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 8),
                _PromoCode(),
              ],
            ),
          ),
          // ایموجی تزئینی
          const Positioned(
            left: 20,
            top: 10,
            bottom: 10,
            child: Center(
              child: Text('🍖', style: TextStyle(fontSize: 72)),
            ),
          ),
        ],
      ),
    );
  }
}

class _PromoCode extends StatelessWidget {
  const _PromoCode();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white38),
      ),
      child: const Text(
        'کد: FIRST20',
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ── Delegate برای چسباندن تب‌ها هنگام اسکرول ──
class _StickyTabsDelegate extends SliverPersistentHeaderDelegate {
  const _StickyTabsDelegate({required this.isDark});
  final bool isDark;

  @override
  double get minExtent => 64;
  @override
  double get maxExtent => 64;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      child: Column(
        children: [
          if (overlapsContent)
            Divider(
              height: 1,
              color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06),
            ),
          const Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: CategoryTabs(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_StickyTabsDelegate oldDelegate) =>
      oldDelegate.isDark != isDark;
}