import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/loyalty_provider.dart';
import '../../../core/model/loyalty_model.dart';

class LoyaltyScreen extends StatelessWidget {
  const LoyaltyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final loyalty = context.watch<LoyaltyProvider>();

    if (!loyalty.loaded) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final level = loyalty.currentLevel;
    final isVip = level.level == MemberLevel.vip;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
            isDark ? AppColors.darkBackground : AppColors.lightBackground,
        appBar: AppBar(
          backgroundColor:
              isDark ? AppColors.darkBackground : AppColors.lightBackground,
          elevation: 0,
          title: Text(
            'باشگاه مشترکین',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: isDark ? AppColors.darkText : AppColors.lightText,
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_forward_rounded,
                color: isDark ? AppColors.darkText : AppColors.lightText),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
          children: [
            // ── کارت اصلی سطح ──
            _LevelCard(
              loyalty: loyalty,
              level: level,
              isVip: isVip,
              isDark: isDark,
            ),

            const SizedBox(height: 20),

            // ── کارت کد تخفیف ──
            _DiscountCard(
              level: level,
              isDark: isDark,
            ),

            const SizedBox(height: 20),

            // ── مزایای سطح فعلی ──
            _PerksCard(
              level: level,
              isDark: isDark,
            ),

            // ── اگه VIP نیست، مزایای VIP رو نشون بده ──
            if (!isVip) ...[
              const SizedBox(height: 20),
              _NextLevelCard(
                loyalty: loyalty,
                isDark: isDark,
              ),
            ],

            const SizedBox(height: 20),

            // ── راهنمای کسب امتیاز ──
            _EarnPointsCard(isDark: isDark),
          ],
        ),
      ),
    );
  }
}

// ── کارت اصلی ──
class _LevelCard extends StatelessWidget {
  const _LevelCard({
    required this.loyalty,
    required this.level,
    required this.isVip,
    required this.isDark,
  });
  final LoyaltyProvider loyalty;
  final LevelConfig level;
  final bool isVip;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isVip
              ? [const Color(0xFFFFB300), const Color(0xFFFF8F00)]
              : [AppColors.primary, const Color(0xFFEF5350)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isVip ? const Color(0xFFFFB300) : AppColors.primary)
                .withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // سطح
          Row(
            children: [
              Text(level.emoji,
                  style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'سطح عضویت',
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12),
                  ),
                  Text(
                    level.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // امتیاز کل
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('امتیاز شما',
                      style: TextStyle(
                          color: Colors.white70, fontSize: 12)),
                  Text(
                    loyalty.formatPoints(loyalty.points),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Progress bar
          if (!isVip) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${loyalty.formatPoints(loyalty.points)} / ${loyalty.formatPoints(loyalty.nextLevel.minPoints)}',
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 12),
                ),
                Text(
                  '${loyalty.pointsToNextLevel} امتیاز تا VIP 👑',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: loyalty.progress),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutCubic,
                builder: (_, value, _) => LinearProgressIndicator(
                  value: value,
                  minHeight: 8,
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation(Colors.white),
                ),
              ),
            ),
          ] else
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.verified_rounded,
                      color: Colors.white, size: 16),
                  SizedBox(width: 6),
                  Text('شما در بالاترین سطح هستید!',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ── کد تخفیف ──
class _DiscountCard extends StatelessWidget {
  const _DiscountCard({required this.level, required this.isDark});
  final LevelConfig level;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.secondary.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
                child: Text('🏷️', style: TextStyle(fontSize: 24))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'کد تخفیف شما',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  level.discountCode,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    color: AppColors.secondary,
                  ),
                ),
                Text(
                  '${level.discountPct.toInt()}٪ تخفیف روی همه سفارش‌ها',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          // دکمه کپی
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: level.discountCode));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('کد کپی شد ✅'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'کپی',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── مزایای سطح فعلی ──
class _PerksCard extends StatelessWidget {
  const _PerksCard({required this.level, required this.isDark});
  final LevelConfig level;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'مزایای سطح ${level.title} ${level.emoji}',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.darkText : AppColors.lightText,
            ),
          ),
          const SizedBox(height: 12),
          ...level.perks.map((perk) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Container(
                      width: 22, height: 22,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check_rounded,
                          color: AppColors.primary, size: 14),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        perk,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? AppColors.darkText
                              : AppColors.lightText,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

// ── معرفی سطح بعدی (VIP) ──
class _NextLevelCard extends StatelessWidget {
  const _NextLevelCard(
      {required this.loyalty, required this.isDark});
  final LoyaltyProvider loyalty;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final vip = levels[1];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFFB300).withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('👑', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Text(
                'سطح VIP — باز کن!',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFFFFB300),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${loyalty.formatPoints(loyalty.pointsToNextLevel)} امتیاز دیگه لازم داری',
            style: TextStyle(
              fontSize: 12,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 12),
          ...vip.perks.map((perk) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Icon(Icons.lock_outline_rounded,
                        size: 16, color: Color(0xFFFFB300)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        perk,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

// ── راهنمای کسب امتیاز ──
class _EarnPointsCard extends StatelessWidget {
  const _EarnPointsCard({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final items = [
      ('🛒', 'هر ۱۰۰۰ تومان سفارش', '۱ امتیاز'),
      ('📅', 'سفارش روزانه', 'امتیاز ۲ برابر'),
      ('⭐', 'ثبت نظر', '۵ امتیاز'),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'چطور امتیاز بگیرم؟',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.darkText : AppColors.lightText,
            ),
          ),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Text(item.$1,
                        style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item.$2,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? AppColors.darkText
                              : AppColors.lightText,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.$3,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}