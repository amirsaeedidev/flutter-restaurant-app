//import 'dart:ffi';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/model/user_model.dart';
import '../../address/providers/address_provider.dart';
import '../../address/screens/address_screen.dart';
import '../../discount/providers/discount_provider.dart';
import '../../discount/screens/discount_screen.dart';
import '../../loyalty/providers/loyalty_provider.dart';
import '../../loyalty/screens/loyalty_screen.dart';
import '../../support/screens/support_screen.dart';
import '../providers/profile_provider.dart';
import '../widgets/edit_profile_sheet.dart';
import '../screens/profile_screen.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late List<Animation<double>> _itemAnims;
  static const _itemCount = 7; // تعداد آیتم‌های منو

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // هر آیتم با تأخیر کمی بعد از قبلی میاد
    _itemAnims = List.generate(_itemCount, (i) {
      final start = i * 0.08;
      final end = (start + 0.4).clamp(0.0, 1.0);
      return CurvedAnimation(
        parent: _ctrl,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      );
    });

    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final profile = context.watch<ProfileProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final user = profile.user;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Drawer(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        child: SafeArea(
          child: Column(
            children: [
              // ── هدر + کارت شناور ویرایش پروفایل ──
              Stack(
                clipBehavior: Clip.none,
                children: [
                  GestureDetector(
  onTap: () {
    Navigator.pop(context);
    Navigator.push(
      context,
      _route(const ProfileScreen()),
    );
  },
  child: _ProfileHeader(
    user: user,
    isDark: isDark,
  ),
),
                  Positioned(
                    bottom: -30,
                    left: 16,
                    right: 16,
                    child: _EditProfileCard(isDark: isDark),
                  ),
                ],
              ),
              // فضای اشغال‌شده توسط بخش بیرون‌زده کارت
              const SizedBox(height: 30),

              // ── آیتم‌های منو با انیمیشن ──
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _AnimItem(
                      anim: _itemAnims[0],
                      child: _DrawerItem(
                        icon: Icons.stars_rounded,
                        label: 'باشگاه مشترکین',
                        trailing: Consumer<LoyaltyProvider>(
                          builder: (_, loyalty, _) => _PointsBadge(
                            points: loyalty.formatPoints(loyalty.points),
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            _route(const LoyaltyScreen()),
                          );
                        },
                        isDark: isDark,
                      ),
                    ),

                    _AnimItem(
                      anim: _itemAnims[1],
                      child: _DrawerItem(
                        icon: Icons.local_offer_rounded,
                        label: 'تخفیفات و کدهای تخفیف',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            _route(
                              ChangeNotifierProvider(
                                create: (_) => DiscountProvider(),
                                child: DiscountScreen(userId: user.id),
                              ),
                            ),
                          );
                        },
                        isDark: isDark,
                      ),
                    ),

                    _AnimItem(
                      anim: _itemAnims[2],
                      child: _DrawerItem(
                        icon: Icons.location_on_rounded,
                        label: 'آدرس‌های من',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            _route(
                              ChangeNotifierProvider.value(
                                value: context.read<AddressProvider>(),
                                child: const AddressScreen(),
                              ),
                            ),
                          );
                        },
                        isDark: isDark,
                      ),
                    ),

                    _AnimItem(
                      anim: _itemAnims[3],
                      child: _DrawerItem(
                        icon: Icons.support_agent_rounded,
                        label: 'پشتیبانی',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            _route(const SupportScreen()),
                          );
                        },
                        isDark: isDark,
                      ),
                    ),

                    Divider(
                      height: 24,
                      indent: 16,
                      endIndent: 16,
                      color: isDark
                          ? Colors.white12
                          : Colors.black.withValues(alpha: 0.08),
                    ),

                    _AnimItem(
                      anim: _itemAnims[4],
                      child: _DrawerItem(
                        icon: Icons.settings_rounded,
                        label: 'تنظیمات برنامه',
                        onTap: () => _showComingSoon(context, 'تنظیمات'),
                        isDark: isDark,
                      ),
                    ),

                    _AnimItem(
                      anim: _itemAnims[5],
                      child: _DarkModeToggle(
                        isDark: isDark,
                        onToggle: () => themeProvider.toggle(),
                      ),
                    ),

                    Divider(
                      height: 24,
                      indent: 16,
                      endIndent: 16,
                      color: isDark
                          ? Colors.white12
                          : Colors.black.withValues(alpha: 0.08),
                    ),

                    _AnimItem(
                      anim: _itemAnims[6],
                      child: _DrawerItem(
                        icon: Icons.logout_rounded,
                        label: 'خروج از حساب',
                        color: Colors.red,
                        onTap: () => _confirmSignOut(context, profile),
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
              ),

              // ── ورژن ──
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  'نسخه ۱.۰.۰',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // مسیر با Fade+Slide انیمیشن
  PageRouteBuilder _route(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, _, _) => page,
      transitionDuration: const Duration(milliseconds: 350),
      transitionsBuilder: (_, anim, _, child) {
        final fade = CurvedAnimation(parent: anim, curve: Curves.easeIn);
        final slide = Tween<Offset>(
          begin: const Offset(0.05, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic));
        return FadeTransition(
          opacity: fade,
          child: SlideTransition(position: slide, child: child),
        );
      },
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature به زودی اضافه میشه 🚀'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _confirmSignOut(BuildContext context, ProfileProvider provider) {
    showDialog(
      context: context,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('خروج از حساب'),
          content: const Text('مطمئنی می‌خوای از حساب کاربریت خارج بشی؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('انصراف'),
            ),
            ElevatedButton(
              onPressed: () {
                provider.signOut();
                Navigator.pop(context);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('خروج'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── ویجت wrapper انیمیشن آیتم ──
class _AnimItem extends StatelessWidget {
  const _AnimItem({required this.anim, required this.child});
  final Animation<double> anim;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: anim,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.15, 0),
          end: Offset.zero,
        ).animate(anim),
        child: child,
      ),
    );
  }
}

// ── هدر پروفایل (بازطراحی‌شده) ──
class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.user, required this.isDark});
  final UserModel user;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      // فضای داخلی بیشتر در پایین برای قرارگیری کارت شناور
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? const [
                  Color(0xFF1C1C1C),
                  Color(0xFF2D0A0A),
                  Color(0xFF4A0000),
                ]
              : const [Color(0xFFFF5722), Color(0xFFD84315)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // آواتار
          CircleAvatar(
            radius: 32,
            backgroundColor: Colors.white.withValues(alpha: 0.25),
            child: Text(
              user.fullName.isNotEmpty ? user.fullName[0] : '👤',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // نشان امتیاز (مستقیم زیر آواتار)
          Consumer<LoyaltyProvider>(
            builder: (_, loyalty, _) => _PremiumPointsBadge(
              points: loyalty.formatPoints(loyalty.points),
            ),
          ),
          const SizedBox(height: 12),

          // نام و شماره تلفن
          Text(
            user.fullName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user.phone,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

// ── نشان امتیاز پرمیوم داخل هدر ──
class _PremiumPointsBadge extends StatelessWidget {
  const _PremiumPointsBadge({required this.points});
  final String points;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
          const SizedBox(width: 6),
          Text(
            '$points امتیاز',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ── کارت شناور ویرایش پروفایل با افکت گلس ──
class _EditProfileCard extends StatelessWidget {
  const _EditProfileCard({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
  final result = await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => ChangeNotifierProvider.value(
      value: context.read<ProfileProvider>(),
      child: const EditProfileSheet(),
    ),
  );

  if (context.mounted && result == true) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ProfileScreen(),
      ),
    );
  }
},
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF232323).withValues(alpha: 0.85)
                    : Colors.white.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.12)
                      : Colors.black.withValues(alpha: 0.06),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.person_outline_rounded,
                      size: 20,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'ویرایش اطلاعات پروفایل',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : AppColors.lightText,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.edit_rounded,
                    size: 18,
                    color: isDark
                        ? Colors.white70
                        : AppColors.lightTextSecondary,
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

// ── آیتم منو ──
class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isDark,
    this.trailing,
    this.color,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDark;
  final Widget? trailing;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final itemColor =
        color ?? (isDark ? AppColors.darkText : AppColors.lightText);

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: (color ?? AppColors.primary).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color ?? AppColors.primary, size: 20),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: itemColor,
        ),
      ),
      trailing: trailing ??
          Icon(
            Icons.arrow_back_ios_rounded,
            size: 14,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
    );
  }
}

// ── سوییچ dark mode ──
class _DarkModeToggle extends StatelessWidget {
  const _DarkModeToggle({required this.isDark, required this.onToggle});
  final bool isDark;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
          color: AppColors.primary,
          size: 20,
        ),
      ),
      title: Text(
        isDark ? 'حالت شب فعاله' : 'حالت روز فعاله',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isDark ? AppColors.darkText : AppColors.lightText,
        ),
      ),
      trailing: Switch.adaptive(
        value: isDark,
        onChanged: (_) => onToggle(),
        activeColor: AppColors.primary,
      ),
    );
  }
}

// ── badge امتیاز در منو (بدون تغییر) ──
class _PointsBadge extends StatelessWidget {
  const _PointsBadge({required this.points});
  final String points;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.4)),
      ),
      child: Text(
        '$points ⭐',
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.secondary,
        ),
      ),
    );
  }
}