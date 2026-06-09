import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/profile_provider.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<ProfileProvider>();
    final user = provider.user;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Drawer(
        backgroundColor:
            isDark ? AppColors.darkSurface : AppColors.lightSurface,
        child: SafeArea(
          child: Column(
            children: [
              // ── هدر پروفایل ──
              _ProfileHeader(user: user, isDark: isDark),

              const SizedBox(height: 8),

              // ── منوی دسترسی‌ها ──
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _DrawerItem(
                      icon: Icons.stars_rounded,
                      label: 'باشگاه مشترکین',
                      trailing: _PointsBadge(points: user.formattedPoints),
                      onTap: () => _showComingSoon(context, 'باشگاه مشترکین'),
                      isDark: isDark,
                    ),
                    _DrawerItem(
                      icon: Icons.local_offer_rounded,
                      label: 'تخفیفات و کدهای تخفیف',
                      onTap: () => _showComingSoon(context, 'تخفیفات'),
                      isDark: isDark,
                    ),
                    _DrawerItem(
                      icon: Icons.location_on_rounded,
                      label: 'آدرس‌های من',
                      onTap: () => _showComingSoon(context, 'آدرس‌ها'),
                      isDark: isDark,
                    ),
                    _DrawerItem(
                      icon: Icons.support_agent_rounded,
                      label: 'پشتیبانی',
                      onTap: () => _showComingSoon(context, 'پشتیبانی'),
                      isDark: isDark,
                    ),

                    Divider(
                      height: 24,
                      indent: 16,
                      endIndent: 16,
                      color: isDark
                          ? Colors.white12
                          : Colors.black.withValues(alpha: 0.08),
                    ),

                    // ── تنظیمات ──
                    _DrawerItem(
                      icon: Icons.settings_rounded,
                      label: 'تنظیمات برنامه',
                      onTap: () => _showComingSoon(context, 'تنظیمات'),
                      isDark: isDark,
                    ),
                    // سوییچ حالت روز/شب
                    _DarkModeToggle(provider: provider, isDark: isDark),

                    Divider(
                      height: 24,
                      indent: 16,
                      endIndent: 16,
                      color: isDark
                          ? Colors.white12
                          : Colors.black.withValues(alpha: 0.08),
                    ),

                    // ── خروج ──
                    _DrawerItem(
                      icon: Icons.logout_rounded,
                      label: 'خروج از حساب',
                      color: Colors.red,
                      onTap: () => _confirmSignOut(context, provider),
                      isDark: isDark,
                    ),
                  ],
                ),
              ),

              // ── ورژن اپ ──
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('خروج'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── هدر پروفایل ──
class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.user, required this.isDark});
  final user;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // آواتار
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white38, width: 2),
            ),
            child: const Center(
              child: Text('👤', style: TextStyle(fontSize: 30)),
            ),
          ),
          const SizedBox(height: 12),
          // نام
          Text(
            user.fullName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          // شماره
          Text(
            user.phone,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          // امتیاز
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('⭐', style: TextStyle(fontSize: 13)),
                const SizedBox(width: 5),
                Text(
                  '${user.formattedPoints} امتیاز',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
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
    final itemColor = color ??
        (isDark ? AppColors.darkText : AppColors.lightText);

    return ListTile(
      onTap: onTap,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: (color ?? AppColors.primary).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon,
            color: color ?? AppColors.primary, size: 20),
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
          Icon(Icons.arrow_back_ios_rounded,
              size: 14,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary),
    );
  }
}

// ── سوییچ حالت تاریک/روشن ──
class _DarkModeToggle extends StatelessWidget {
  const _DarkModeToggle(
      {required this.provider, required this.isDark});
  final ProfileProvider provider;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
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
        isDark ? 'حالت شب' : 'حالت روز',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isDark ? AppColors.darkText : AppColors.lightText,
        ),
      ),
      trailing: Switch.adaptive(
        value: isDark,
        onChanged: (_) => provider.toggleDarkMode(),
        activeColor: AppColors.primary,
      ),
    );
  }
}

// ── badge امتیاز ──
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
        border:
            Border.all(color: AppColors.secondary.withValues(alpha: 0.4)),
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