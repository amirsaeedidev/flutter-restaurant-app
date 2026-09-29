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
    final selectedIndex =
        context.watch<NavigationProvider>().selectedIndex;

    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    // ProfileProvider فقط برای Drawer لازمه
    return ChangeNotifierProvider(
      create: (_) => ProfileProvider(),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          // باعث می‌شود Body زیر BottomNav قرار بگیرد
          // تا BackdropFilter بتواند محتوای پشت NavBar را Blur کند
          extendBody: true,

          drawer: const CustomDrawer(),

          body: IndexedStack(
            index: selectedIndex,
            children: _pages,
          ),

          bottomNavigationBar: _BottomNav(
            isDark: isDark,
          ),
        ),
      ),
    );
  }
}

// ============================================================
// Bottom Navigation - Glassmorphism
// ============================================================

class _BottomNav extends StatelessWidget {
  const _BottomNav({
    required this.isDark,
  });

  final bool isDark;

  // Grayscale واقعی برای PNG های غیرفعال
  static const List<double> _grayscaleMatrix = [
    0.2126,
    0.7152,
    0.0722,
    0,
    28,
    0.2126,
    0.7152,
    0.0722,
    0,
    28,
    0.2126,
    0.7152,
    0.0722,
    0,
    28,
    0,
    0,
    0,
    1,
    0,
  ];

  @override
  Widget build(BuildContext context) {
    final selectedIndex =
        context.watch<NavigationProvider>().selectedIndex;

    // Glow:
    // Dark Mode = سفید
    // Light Mode = AppColors.primary
    final Color glowColor =
        isDark ? Colors.white : AppColors.primary;

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
          borderRadius: BorderRadius.circular(40),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 20,
              sigmaY: 20,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                // Glass Background
                color: isDark
                    ? Colors.black.withOpacity(0.48)
                    : Colors.black.withOpacity(0.16),

                borderRadius: BorderRadius.circular(40),

                // Glass Border
                border: Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.18)
                      : Colors.white.withOpacity(0.38),
                  width: 1,
                ),

                // Soft Shadow
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(
                      isDark ? 0.32 : 0.12,
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
                  // در RTL:
                  // سبد خرید راست
                  _NavItem(
                    index: 0,
                    imagePath:
                        'assets/images/EmptyBasket.png',
                    label: 'سبد خرید',
                    selectedIndex: selectedIndex,
                    isDark: isDark,
                    grayscaleMatrix:
                        _grayscaleMatrix,
                    glowColor: glowColor,
                  ),

                  // خانه وسط
                  _NavItem(
                    index: 1,
                    imagePath:
                        'assets/images/iconhome.png',
                    label: 'خانه',
                    selectedIndex: selectedIndex,
                    isDark: isDark,
                    grayscaleMatrix:
                        _grayscaleMatrix,
                    glowColor: glowColor,
                  ),

                  // سفارشات چپ
                  _NavItem(
                    index: 2,
                    imagePath:
                        'assets/images/iconreceipt.png',
                    label: 'سفارشات',
                    selectedIndex: selectedIndex,
                    isDark: isDark,
                    grayscaleMatrix:
                        _grayscaleMatrix,
                    glowColor: glowColor,
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

// ============================================================
// هر دکمه NavBar
// ============================================================

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.index,
    required this.imagePath,
    required this.label,
    required this.selectedIndex,
    required this.isDark,
    required this.grayscaleMatrix,
    required this.glowColor,
  });

  final int index;
  final String imagePath;
  final String label;
  final int selectedIndex;
  final bool isDark;
  final List<double> grayscaleMatrix;
  final Color glowColor;

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedIndex == index;

    // Badge فقط برای سبد خرید
    final cartCount = index == 0
        ? context.watch<CartProvider>().itemCount
        : 0;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,

      onTap: () {
        context
            .read<NavigationProvider>()
            .setIndex(index);
      },

      child: AnimatedContainer(
        duration: const Duration(
          milliseconds: 350,
        ),
        curve: Curves.easeOutCubic,

        // NavItem کوچکتر شده
        padding: const EdgeInsets.symmetric(
          horizontal: 9,
          vertical: 6,
        ),

        // مهم:
        // هیچ کانتینر رنگی پشت آیتم فعال نیست
        decoration: const BoxDecoration(
          color: Colors.transparent,
        ),

        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ==================================================
            // Icon + Glow + Badge
            // ==================================================

            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                // ----------------------------------------------
                // Glow فقط پشت آیکون فعال
                // Dark = سفید
                // Light = قرمز AppColors.primary
                // ----------------------------------------------

                if (isSelected)
                  IgnorePointer(
                    child: AnimatedContainer(
                      duration: const Duration(
                        milliseconds: 350,
                      ),
                      curve: Curves.easeOutCubic,

                      width: 46,
                      height: 46,

                      decoration: BoxDecoration(
                        shape: BoxShape.circle,

                        gradient: RadialGradient(
                          colors: [
                            glowColor.withOpacity(
                              isDark ? 0.28 : 0.34,
                            ),
                            glowColor.withOpacity(
                              isDark ? 0.12 : 0.16,
                            ),
                            Colors.transparent,
                          ],
                          stops: const [
                            0.0,
                            0.46,
                            1.0,
                          ],
                        ),

                        boxShadow: [
                          BoxShadow(
                            color: glowColor.withOpacity(
                              isDark ? 0.14 : 0.20,
                            ),
                            blurRadius: 14,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),

                // ----------------------------------------------
                // Icon
                //
                // فعال:
                // رنگ اصلی PNG دست نخورده
                //
                // غیرفعال:
                // Grayscale واقعی
                // ----------------------------------------------

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
                            return Icon(
                              Icons.error_outline,
                              size: 26,
                              color: AppColors.primary,
                            );
                          },
                        )
                      : ColorFiltered(
                          colorFilter:
                              ColorFilter.matrix(
                            grayscaleMatrix,
                          ),
                          child: Opacity(
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

                // ----------------------------------------------
                // Badge
                // ----------------------------------------------

                if (cartCount > 0 && index == 0)
                  Positioned(
                    top: -4,
                    left: -4,
                    child: Container(
                      constraints:
                          const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),

                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 3,
                      ),

                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,

                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary
                                .withOpacity(0.40),
                            blurRadius: 7,
                            spreadRadius: 0,
                          ),
                        ],
                      ),

                      child: Center(
                        child: Text(
                          cartCount > 9
                              ? '9+'
                              : '$cartCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8.5,
                            fontWeight:
                                FontWeight.bold,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // ==================================================
            // Label
            //
            // رنگ متن = AppColors.primary
            // ==================================================

            AnimatedSize(
              duration: const Duration(
                milliseconds: 350,
              ),
              curve: Curves.easeOutCubic,

              child: isSelected
                  ? Padding(
                      padding:
                          const EdgeInsets.only(
                        right: 7,
                      ),
                      child: Text(
                        label,

                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight:
                              FontWeight.bold,
                          fontSize: 13,
                          height: 1.1,

                          // در Dark Mode متن همان
                          // Primary می‌ماند
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