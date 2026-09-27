import 'dart:ui';
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

    return ClipRRect(
      // برای ایجاد افکت شیشه‌ای، باید ویجت رویرو Clip بشه
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
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              // در حالت RTL، اولین فرزند سمت راست قرار می‌گیرد
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildNavItem(
                    context, 
                    index: 0, 
                    imagePath: 'assets/icons/iconshopping.png', // عکس سبد خرید
                    label: 'سبد خرید', 
                    isDark: isDark, 
                    selectedIndex: selectedIndex,
                  ),
                  _buildNavItem(
                    context, 
                    index: 1, 
                    imagePath: 'assets/icons/iconhome.png', // عکس خانه
                    label: 'خانه', 
                    isDark: isDark, 
                    selectedIndex: selectedIndex,
                  ),
                  _buildNavItem(
                    context, 
                    index: 2, 
                    imagePath: 'assets/icons/iconreceipt.png', // عکس سفارشات
                    label: 'سفارشات', 
                    isDark: isDark, 
                    selectedIndex: selectedIndex,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, {
    required int index,
    required String imagePath,
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
            Image.asset(
              imagePath,
              width: 24,
              height: 24,
              // رنگ‌آمیزی عکس: اگر فعال بود سفید، اگر غیرفعال بود خاکستری
              color: isSelected 
                  ? Colors.white 
                  : (isDark ? Colors.white54 : Colors.black54),
              // در صورتی که عکس پیدا نشد، آیکون جایگزین نشان بده تا کرش نکنه
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.error_outline,
                color: isSelected ? Colors.white : Colors.grey,
                size: 24,
              ),
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