import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class RatingStars extends StatelessWidget {
  const RatingStars({
    super.key,
    required this.rating,
    this.size = 16,
    this.showValue = true,
    this.reviewCount,
  });

  final double rating;       // مثلاً 4.5
  final double size;         // اندازه هر ستاره
  final bool showValue;      // نمایش عدد رتبه (4.5)
  final int? reviewCount;    // تعداد نظرات — اگه نال باشه نشون داده نمیشه

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(5, (i) {
          final full = i < rating.floor();
          final half = !full && i < rating; // نیم‌ستاره
          return Icon(
            full
                ? Icons.star_rounded
                : (half ? Icons.star_half_rounded : Icons.star_outline_rounded),
            color: AppColors.secondary,
            size: size,
          );
        }),
        if (showValue) ...[
          SizedBox(width: size * 0.3),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              fontSize: size * 0.85,
              fontWeight: FontWeight.w700,
              color: AppColors.secondary,
            ),
          ),
        ],
        if (reviewCount != null) ...[
          SizedBox(width: size * 0.25),
          Text(
            '($reviewCount)',
            style: TextStyle(
              fontSize: size * 0.75,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ],
    );
  }
}