import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/home_provider.dart';
import '../widgets/category_tabs.dart';
import '../widgets/product_grid.dart';
import 'dart:ui';
import 'package:flutter/services.dart';
import '../../notifications/screens/notifications_screen.dart';

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
    final provider = context.watch<HomeProvider>();

    // ── Loading ──
    if (provider.loading && provider.categories.isEmpty && provider.banners.isEmpty) {
      return _HomeSkeleton(isDark: isDark);
    }

    // ── Error ──
    if (provider.error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('⚠️', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              Text(provider.error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.read<HomeProvider>().refresh(),
                child: const Text('تلاش مجدد'),
              ),
            ],
          ),
        ),
      );
    }

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
                          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NotificationsScreen()));
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
          if (!_showSearch && provider.banners.isNotEmpty)
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
    final banners = context.watch<HomeProvider>().banners;
    if (banners.isEmpty) return const SizedBox.shrink();
    final banner = banners.first;
    final imageUrl = banner.imageUrl.trim();
    final logoUrl = banner.logoUrl?.trim() ?? '';
    final headline = (banner.promoTitle ?? '').trim();
    final subtitle = (banner.subtitle ?? '').trim();
    final code = (banner.discountCode ?? '').trim();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.2), blurRadius: 18, offset: const Offset(0, 8))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (imageUrl.isEmpty)
              Image.asset('assets/images/baner.png', fit: BoxFit.cover)
            else
              Image.network(imageUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Image.asset('assets/images/baner.png', fit: BoxFit.cover)),
            const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.centerRight, end: Alignment.centerLeft, colors: [Color(0xD9000000), Color(0x45000000), Color(0x10000000)]))),
            Positioned(
              right: 12, top: 12, bottom: 12,
              child: Container(
                width: 170,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.17), borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.white.withValues(alpha: 0.3))),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(banner.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
                  if (headline.isNotEmpty) ...[
                    const SizedBox(height: 5),
                    Text(headline, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w900, height: 1.15)),
                  ],
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 11)),
                  ],
                  if (code.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    InkWell(
                      borderRadius: BorderRadius.circular(9),
                      onTap: () async {
                        await Clipboard.setData(ClipboardData(text: code));
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('کد تخفیف کپی شد'), behavior: SnackBarBehavior.floating));
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(9)),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          const Icon(Icons.copy_rounded, size: 13, color: AppColors.primary),
                          const SizedBox(width: 5),
                          Flexible(child: Text(code, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w900))),
                        ]),
                      ),
                    ),
                  ],
                ]),
              ),
            ),
            if (logoUrl.isNotEmpty)
              Positioned(left: 12, top: 12, child: Container(
                width: 58, height: 58, padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.92), borderRadius: BorderRadius.circular(16)),
                child: Image.network(logoUrl, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Icon(Icons.restaurant_rounded, color: AppColors.primary)),
              )),
          ],
        ),
      ),
    );
  }
}

class _HomeSkeleton extends StatelessWidget {
  const _HomeSkeleton({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final shade = isDark ? Colors.white.withValues(alpha: 0.07) : Colors.black.withValues(alpha: 0.055);
    Widget block(double height, {double? width}) => Container(height: height, width: width, decoration: BoxDecoration(color: shade, borderRadius: BorderRadius.circular(16)));
    return Scaffold(
      body: SafeArea(child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [block(44, width: 44), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [block(16, width: 160), const SizedBox(height: 8), block(10, width: 110)])), block(40, width: 40)]),
          const SizedBox(height: 20),
          block(180),
          const SizedBox(height: 18),
          Row(children: [Expanded(child: block(42)), const SizedBox(width: 10), Expanded(child: block(42)), const SizedBox(width: 10), Expanded(child: block(42))]),
          const SizedBox(height: 18),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 4,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 14, mainAxisSpacing: 14, childAspectRatio: 0.72),
            itemBuilder: (_, __) => Column(children: [Expanded(child: block(150)), const SizedBox(height: 10), block(14), const SizedBox(height: 8), block(12, width: 110)]),
          ),
        ]),
      )),
    );
  }
}

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