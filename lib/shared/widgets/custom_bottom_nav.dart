import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../providers/navigation_provider.dart';

class CustomBottomNav extends StatelessWidget {
  const CustomBottomNav({super.key});

  // ==========================================================
  // Grayscale واقعی برای PNG
  // ==========================================================
  static const List<double> _grayscaleMatrix = [
    0.2126,
    0.7152,
    0.0722,
    0,
    25,
    0.2126,
    0.7152,
    0.0722,
    0,
    25,
    0.2126,
    0.7152,
    0.0722,
    0,
    25,
    0,
    0,
    0,
    1,
    0,
  ];

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    // خواندن وضعیت فعلی از Provider
    final selectedIndex =
        context.watch<NavigationProvider>().selectedIndex;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.only(
          left: 18,
          right: 18,
          top: 6,
          bottom: 12,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(42),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 20,
              sigmaY: 20,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                // ==================================================
                // Glassmorphism
                // ==================================================
                color: isDark
                    ? Colors.black.withOpacity(0.50)
                    : Colors.white.withOpacity(0.24),

                borderRadius: BorderRadius.circular(42),

                // حاشیه شیشه‌ای ظریف
                border: Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.18)
                      : Colors.white.withOpacity(0.35),
                  width: 1,
                ),

                // سایه نرم
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(
                      isDark ? 0.35 : 0.14,
                    ),
                    blurRadius: 24,
                    spreadRadius: 0,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  _buildNavItem(
                    context,
                    index: 0,
                    imagePath:
                        'assets/images/EmptyBasket.png',
                    label: 'سبد خرید',
                    isDark: isDark,
                    selectedIndex: selectedIndex,
                  ),
                  _buildNavItem(
                    context,
                    index: 1,
                    imagePath:
                        'assets/images/iconhome.png',
                    label: 'خانه',
                    isDark: isDark,
                    selectedIndex: selectedIndex,
                  ),
                  _buildNavItem(
                    context,
                    index: 2,
                    imagePath:
                        'assets/images/iconreceipt.png',
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

  Widget _buildNavItem(
    BuildContext context, {
    required int index,
    required String imagePath,
    required String label,
    required bool isDark,
    required int selectedIndex,
  }) {
    final isSelected = selectedIndex == index;

    // ==========================================================
    // Glow:
    // Dark Mode  -> سفید
    // Light Mode -> AppColors.primary
    // ==========================================================

    final Color glowColor = isDark
        ? Colors.white
        : AppColors.primary;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        // تغییر تب از طریق Provider
        context
            .read<NavigationProvider>()
            .setIndex(index);
      },
      child: AnimatedContainer(
        duration: const Duration(
          milliseconds: 350,
        ),
        curve: Curves.easeOutCubic,

        // کمی کوچک‌تر از نسخه قبلی
        padding: const EdgeInsets.symmetric(
          horizontal: 9,
          vertical: 6,
        ),

        decoration: const BoxDecoration(
          color: Colors.transparent,
        ),

        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ==================================================
            // Icon + Glow
            // ==================================================
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                // Glow فقط برای آیتم فعال
                if (isSelected)
                  IgnorePointer(
                    child: AnimatedContainer(
                      duration: const Duration(
                        milliseconds: 350,
                      ),
                      curve: Curves.easeOutCubic,
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            glowColor.withOpacity(
                              isDark ? 0.30 : 0.34,
                            ),
                            glowColor.withOpacity(
                              isDark ? 0.14 : 0.16,
                            ),
                            Colors.transparent,
                          ],
                          stops: const [
                            0.0,
                            0.45,
                            1.0,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: glowColor.withOpacity(
                              isDark ? 0.18 : 0.20,
                            ),
                            blurRadius: 16,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),

                // ==================================================
                // PNG
                // فعال:
                // رنگ اصلی خود PNG حفظ می‌شود
                //
                // غیرفعال:
                // Grayscale واقعی
                // ==================================================
                SizedBox(
                  width: 26,
                  height: 26,
                  child: isSelected
                      ? Image.asset(
                          imagePath,
                          width: 26,
                          height: 26,
                          fit: BoxFit.contain,
                          errorBuilder: (
                            context,
                            error,
                            stackTrace,
                          ) {
                            return const Icon(
                              Icons.error_outline,
                              size: 26,
                            );
                          },
                        )
                      : ColorFiltered(
                          colorFilter:
                              const ColorFilter.matrix(
                            _grayscaleMatrix,
                          ),
                          child: Opacity(
                            // شفافیت کم نیست تا آیکون واضح بماند
                            opacity: 0.92,
                            child: Image.asset(
                              imagePath,
                              width: 26,
                              height: 26,
                              fit: BoxFit.contain,
                              errorBuilder: (
                                context,
                                error,
                                stackTrace,
                              ) {
                                return const Icon(
                                  Icons.error_outline,
                                  size: 26,
                                  color: Colors.grey,
                                );
                              },
                            ),
                          ),
                        ),
                ),
              ],
            ),

            // ==================================================
            // Label
            // فعال = AppColors.primary
            // ==================================================
            AnimatedSize(
              duration: const Duration(
                milliseconds: 350,
              ),
              curve: Curves.easeOutCubic,
              child: isSelected
                  ? Padding(
                      padding: const EdgeInsets.only(
                        right: 7,
                      ),
                      child: Text(
                        label,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
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