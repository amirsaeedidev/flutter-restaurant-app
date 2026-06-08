import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_colors.dart';
import 'features/cart_and_checkout/screens/cart_screen.dart';
import 'features/home/screens/home_screen.dart';
import 'features/orders/screens/recent_orders_screen.dart';
import 'shared/providers/navigation_provider.dart';

class MainWrapper extends StatelessWidget {
  const MainWrapper({super.key});

  static const List<Widget> _pages = [
    CartScreen(),
    HomeScreen(),
    RecentOrdersScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final selectedIndex = context.watch<NavigationProvider>().selectedIndex;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: IndexedStack(
          index: selectedIndex,
          children: _pages,
        ),
        bottomNavigationBar: _BottomNav(isDark: isDark),
      ),
    );
  }
}

// ── NavBar ──
class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final selectedIndex = context.watch<NavigationProvider>().selectedIndex;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 15,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _NavItem(index: 0, icon: Icons.shopping_cart_rounded, label: 'سبد خرید', selectedIndex: selectedIndex, isDark: isDark),
              _NavItem(index: 1, icon: Icons.home_rounded,          label: 'خانه',     selectedIndex: selectedIndex, isDark: isDark),
              _NavItem(index: 2, icon: Icons.receipt_long_rounded,  label: 'سفارشات',  selectedIndex: selectedIndex, isDark: isDark),
            ],
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
    required this.icon,
    required this.label,
    required this.selectedIndex,
    required this.isDark,
  });

  final int index;
  final IconData icon;
  final String label;
  final int selectedIndex;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () => context.read<NavigationProvider>().setIndex(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? Colors.white
                  : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
              size: 26,
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