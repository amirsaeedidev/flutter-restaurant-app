import 'package:flutter/material.dart';
import '../../../core/model/order_model.dart';
import '../../../core/theme/app_colors.dart';

class TrackingTimeline extends StatelessWidget {
  const TrackingTimeline({super.key, required this.order});
  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentStep = order.statusStep;

    // مراحل دلیوری
    final deliverySteps = [
      _Step('⏳', 'ثبت سفارش', 'سفارش شما ثبت شد'),
      _Step('✅', 'تأیید سفارش', 'رستوران سفارش را تأیید کرد'),
      _Step('👨‍🍳', 'در حال آماده‌سازی', 'آشپز داره غذاتو آماده می‌کنه'),
      _Step('🛵', 'در راه است', 'پیک داره غذا رو میاره'),
      _Step('🎉', 'تحویل داده شد', 'نوش جان!'),
    ];

    // مراحل حضوری (onTheWay نداره)
    final dineInSteps = [
      _Step('⏳', 'ثبت سفارش', 'سفارش شما ثبت شد'),
      _Step('✅', 'تأیید سفارش', 'رستوران سفارش را تأیید کرد'),
      _Step('👨‍🍳', 'در حال آماده‌سازی', 'آشپز داره غذاتو آماده می‌کنه'),
      _Step('🍽️', 'آماده سرو', 'غذا آماده‌ست، الان میاد'),
      _Step('🎉', 'تحویل داده شد', 'نوش جان!'),
    ];

    final steps = order.type == OrderType.delivery
        ? deliverySteps
        : dineInSteps;

    return Column(
      children: List.generate(steps.length, (i) {
        final isDone = i < currentStep;
        final isCurrent = i == currentStep;
        final isLast = i == steps.length - 1;

        return _TimelineItem(
          step: steps[i],
          isDone: isDone,
          isCurrent: isCurrent,
          isLast: isLast,
          isDark: isDark,
        );
      }),
    );
  }
}

class _Step {
  final String emoji;
  final String title;
  final String subtitle;
  const _Step(this.emoji, this.title, this.subtitle);
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({
    required this.step,
    required this.isDone,
    required this.isCurrent,
    required this.isLast,
    required this.isDark,
  });
  final _Step step;
  final bool isDone;
  final bool isCurrent;
  final bool isLast;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final Color dotColor = isDone
        ? Colors.green
        : isCurrent
            ? AppColors.primary
            : (isDark ? Colors.white24 : Colors.black12);

    final Color lineColor = isDone
        ? Colors.green
        : (isDark ? Colors.white12 : Colors.black12);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── خط + دایره ──
        SizedBox(
          width: 36,
          child: Column(
            children: [
              // دایره
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isDone
                      ? Colors.green
                      : isCurrent
                          ? AppColors.primary
                          : (isDark
                              ? Colors.white.withValues(alpha: 0.07)
                              : Colors.black.withValues(alpha: 0.05)),
                  shape: BoxShape.circle,
                  boxShadow: isCurrent
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.4),
                            blurRadius: 10,
                            spreadRadius: 2,
                          )
                        ]
                      : [],
                ),
                child: Center(
                  child: isDone
                      ? const Icon(Icons.check_rounded,
                          color: Colors.white, size: 18)
                      : Text(step.emoji,
                          style: TextStyle(
                              fontSize: isCurrent ? 18 : 14)),
                ),
              ),
              // خط اتصال
              if (!isLast)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  width: 2,
                  height: 40,
                  color: lineColor,
                ),
            ],
          ),
        ),

        const SizedBox(width: 14),

        // ── متن ──
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              top: 6,
              bottom: isLast ? 0 : 28,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isCurrent || isDone
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: isCurrent
                        ? AppColors.primary
                        : isDone
                            ? Colors.green
                            : (isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary),
                  ),
                ),
                if (isCurrent) ...[
                  const SizedBox(height: 3),
                  Text(
                    step.subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}