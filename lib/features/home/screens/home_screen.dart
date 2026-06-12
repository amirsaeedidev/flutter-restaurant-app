import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/home_provider.dart';
import '../widgets/category_tabs.dart';
import '../widgets/product_grid.dart';
import 'dart:ui';

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

class _HomeView extends StatefulWidget {
  const _HomeView();

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> with TickerProviderStateMixin {
  bool _showSearch = false;
  final _searchController = TextEditingController();

  late final AnimationController _searchAnimationController;
  late final Animation<double> _searchHeightAnimation;
  late final Animation<double> _bannerOpacityAnimation;

  @override
  void initState() {
    super.initState();
    _searchAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );

    _searchHeightAnimation = Tween<double>(begin: 110, end: 60).animate(
      CurvedAnimation(
          parent: _searchAnimationController, curve: Curves.easeOutCubic),
    );

    _bannerOpacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
          parent: _searchAnimationController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchAnimationController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() => _showSearch = !_showSearch);

    if (_showSearch) {
      _searchAnimationController.forward();
      Future.delayed(const Duration(milliseconds: 180), () {
        if (mounted) FocusScope.of(context).requestFocus(FocusNode());
      });
    } else {
      _searchAnimationController.reverse();
      _searchController.clear();
      context.read<HomeProvider>().clearSearch();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── AppBar با انیمیشن نرم ──
          SliverAppBar(
            pinned: true,
            floating: true,
            snap: true,
            expandedHeight: _searchHeightAnimation.value,
            backgroundColor:
                isDark ? AppColors.darkBackground : AppColors.lightBackground,
            elevation: 0,
            // ⬅️ منو به leading (سمت راست در RTL)
            leading: _showSearch
                ? null
                : Padding(
                    padding: const EdgeInsets.only(right: 8,top: 2),
                    child: GestureDetector(
                      onTap: () => Scaffold.of(context).openDrawer(),
                      child: Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.08)
                              : Colors.black.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(
                          child: Icon(Icons.menu_rounded),
                        ),
                      ),
                    ),
                  ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              title: AnimatedSwitcher(
                duration: const Duration(milliseconds: 280),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder:
                    (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.15),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: _showSearch
                    ? _SearchField(
                        key: const ValueKey('search'),
                        controller: _searchController,
                        isDark: isDark,
                        onChanged: (q) =>
                            context.read<HomeProvider>().setSearchQuery(q),
                        onClose: _toggleSearch,
                      )
                    : Padding(
                        padding: const EdgeInsets.only(
                            right: 38), // ← فاصله‌ی جدید برای جلوگیری از هم‌پوشانی
                        child: Column(
                          key: const ValueKey('title'),
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '🍽️ منوی رستوران',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: isDark
                                    ? AppColors.darkText
                                    : AppColors.lightText,
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
              ),
            ),
            // ⬅️ actions: جستجو + نوتیفیکیشن
            actions: _showSearch
                ? []
                : [
                    IconButton(
                      icon: Icon(Icons.search_rounded,
                          color:
                              isDark ? AppColors.darkText : AppColors.lightText),
                      onPressed: _toggleSearch,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: GestureDetector(
                        onTap: () {
                          // TODO: عملکرد نوتیفیکیشن
                        },
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
                            child: Icon(Icons.notifications_rounded),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
          ),

          // ── بنر تبلیغاتی با انیمیشن Fade + Scale ──
          if (!_showSearch)
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _bannerOpacityAnimation,
                child: ScaleTransition(
                  scale: _bannerOpacityAnimation,
                  child: _PromoBanner(isDark: isDark),
                ),
              ),
            ),

          // ── تب‌های کتگوری (Sticky) ──
          SliverPersistentHeader(
            pinned: true,
            delegate: _StickyTabsDelegate(isDark: isDark),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // ── گرید محصولات ──
          const ProductGrid(),
        ],
      ),
    );
  }
}

// ── فیلد سرچ داخل AppBar ──
class _SearchField extends StatelessWidget {
  const _SearchField({
    super.key,
    required this.controller,
    required this.isDark,
    required this.onChanged,
    required this.onClose,
  });

  final TextEditingController controller;
  final bool isDark;
  final ValueChanged<String> onChanged;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: TextField(
        controller: controller,
        autofocus: true,
        textDirection: TextDirection.rtl,
        onChanged: onChanged,
        style: TextStyle(
          fontSize: 14,
          color: isDark ? AppColors.darkText : AppColors.lightText,
        ),
        decoration: InputDecoration(
          hintText: 'جستجوی غذا...',
          hintStyle: TextStyle(
            fontSize: 13,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
          prefixIcon: Icon(Icons.search_rounded,
              color: AppColors.primary, size: 20),
          suffixIcon: GestureDetector(
            onTap: onClose,
            child: Icon(Icons.close_rounded,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
                size: 20),
          ),
          filled: true,
          fillColor: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.05),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        ),
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
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 2,
            spreadRadius: 2,
            offset: const Offset(0, 10),
          ),
        ],
        image: const DecorationImage(
          image: AssetImage('assets/images/baner.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Container(
              color: Colors.black.withValues(alpha: 0.10),
            ),
            Positioned(
              left: -40,
              top: -30,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.orange.withValues(alpha: 0.18),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                  child: const SizedBox(),
                ),
              ),
            ),
            Positioned(
              right: 12,
              top: 12,
              bottom: 12,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 4, sigmaY: 2),
                  child: Container(
                    width: 150,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.4),
                          width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 20,
                          spreadRadius: 1,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '🎉 پیشنهاد ویژه',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          '۲۰٪ تخفیف\nاولین سفارش',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            height: 1.2,
                          ),
                        ),
                        SizedBox(height: 10),
                        _PromoCode(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 10,
              top: 0,
              bottom: 0,
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withValues(alpha: 0.35),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/images/soda.png',
                    scale: 22,
                  ),
                ),
              ),
            ),
          ],
        ),
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
      child: const Text('کد: FIRST20',
          style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5)),
    );
  }
}

// ── Sticky تب‌ها ──
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
              color: isDark
                  ? Colors.white10
                  : Colors.black.withValues(alpha: 0.06),
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
  bool shouldRebuild(_StickyTabsDelegate old) => old.isDark != isDark;
}