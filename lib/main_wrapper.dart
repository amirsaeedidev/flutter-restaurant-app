import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_colors.dart';
import 'features/cart_and_checkout/providers/cart_provider.dart';
import 'features/cart_and_checkout/screens/cart_screen.dart';
import 'features/home/screens/home_screen.dart';
import 'features/orders/screens/recent_orders_screen.dart';
import 'features/profile/providers/profile_provider.dart';
import 'features/profile/widgets/custom_drawer.dart';
import 'shared/providers/navigation_provider.dart';

class MainWrapper extends StatelessWidget {
  const MainWrapper({super.key});

  static final List<Widget> _pages = [
    const CartScreen(),
    const HomeScreen(),
    const RecentOrdersScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final selectedIndex = context.watch<NavigationProvider>().selectedIndex;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ProfileProvider فقط برای Drawer لازمه — اینجا provide میشه
    return ChangeNotifierProvider(
      create: (_) => ProfileProvider(),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Builder(
          // Builder یه context جدید میده که ProfileProvider رو داره
          builder: (ctx) => Scaffold(
            drawer: const CustomDrawer(),
            body: IndexedStack(
              index: selectedIndex,
              children: _pages,
            ),
            bottomNavigationBar: _BottomNav(isDark: isDark),
          ),
        ),
      ),
    );
  }
}

// ── NavBar (استایل شیشه مات) ──
class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final selectedIndex = context.watch<NavigationProvider>().selectedIndex;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          decoration: BoxDecoration(
            // رنگ پس‌زمینه نیمه‌شفاف برای افکت شیشه مات
            color: isDark
                ? Colors.black.withOpacity(0.6)
                : Colors.white.withOpacity(0.7),
            border: Border(
              top: BorderSide(
                color: isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.05),
                width: 1,
              ),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // در حالت RTL: سبد خرید راست، خانه وسط، سفارشات چپ
                  _NavItem(
                    index: 0,
                    imagePath: 'assets/icons/shopping.png', // عکس سبد خرید
                    label: 'سبد خرید',
                    selectedIndex: selectedIndex,
                    isDark: isDark,
                  ),
                  _NavItem(
                    index: 1,
                    imagePath: 'assets/icons/home.png', // عکس خانه
                    label: 'خانه',
                    selectedIndex: selectedIndex,
                    isDark: isDark,
                  ),
                  _NavItem(
                    index: 2,
                    imagePath: 'assets/icons/receipt.png', // عکس سفارشات
                    label: 'سفارشات',
                    selectedIndex: selectedIndex,
                    isDark: isDark,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── هر دکمه NavBar ──
class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.index,
    required this.imagePath,
    required this.label,
    required this.selectedIndex,
    required this.isDark,
  });

  final int index;
  final String imagePath;
  final String label;
  final int selectedIndex;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedIndex == index;
    // badge فقط برای سبد خرید (index 0)
    final cartCount =
        index == 0 ? context.watch<CartProvider>().itemCount : 0;

    return GestureDetector(
      onTap: () => context.read<NavigationProvider>().setIndex(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // عکس + badge
            Stack(
              clipBehavior: Clip.none,
              children: [
                Image.asset(
                  imagePath,
                  width: 26,
                  height: 26,
                  // رنگ‌آمیزی عکس: اگر فعال بود سفید، اگر غیرفعال بود خاکستری
                  color: isSelected
                      ? Colors.white
                      : (isDark
                          ? Colors.white54
                          : Colors.black54),
                  // در صورتی که عکس پیدا نشد، آیکون جایگزین نشان بده تا کرش نکنه
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.error_outline,
                    color: isSelected ? Colors.white : Colors.grey,
                    size: 26,
                  ),
                ),
                if (cartCount > 0 && !isSelected)
                  Positioned(
                    top: -4,
                    left: -4,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          cartCount > 9 ? '9+' : '$cartCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
              child: isSelected
                  ? Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Text(
                        label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}