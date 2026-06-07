import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../providers/navigation_provider.dart';

class CustomBottomNav extends StatelessWidget {
  const CustomBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // خواندن وضعیت فعلی از پروایدر
    final selectedIndex = context.watch<NavigationProvider>().selectedIndex;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
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
              _buildNavItem(context, index: 0, icon: Icons.shopping_cart_rounded, label: 'سبد خرید', isDark: isDark, selectedIndex: selectedIndex),
              _buildNavItem(context, index: 1, icon: Icons.home_rounded, label: 'خانه', isDark: isDark, selectedIndex: selectedIndex),
              _buildNavItem(context, index: 2, icon: Icons.receipt_long_rounded, label: 'سفارشات', isDark: isDark, selectedIndex: selectedIndex),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, {
    required int index,
    required IconData icon,
    required String label,
    required bool isDark,
    required int selectedIndex,
  }) {
    final isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () {
        // تغییر تب از طریق پروایدر
        context.read<NavigationProvider>().setIndex(index);
      },
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
              color: isSelected ? Colors.white : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
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
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
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