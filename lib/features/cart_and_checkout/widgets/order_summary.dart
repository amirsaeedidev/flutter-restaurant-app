import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// ویجت خلاصه سفارش — قابل استفاده مجدد در Cart و Checkout
class OrderSummaryWidget extends StatelessWidget {
  const OrderSummaryWidget({
    super.key,
    required this.itemCount,
    required this.subtotal,
    required this.deliveryFee,
    required this.discountAmount,
    required this.total,
    required this.isDark,
  });

  final int itemCount;
  final int subtotal;
  final int deliveryFee;
  final int discountAmount;
  final int total;
  final bool isDark;

  /// قالب‌بندی عدد با جداکننده هزارگان + پسوند تومان
  String _format(int price) {
    final s = price.toString();
    final buf = StringBuffer();
    final offset = s.length % 3;
    for (int i = 0; i < s.length; i++) {
      if (i != 0 && (i - offset) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return '$buf تومان';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── عنوان بخش ──
          Row(
            children: [
              const Text('🧾', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text(
                'خلاصه سفارش',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.darkText : AppColors.lightText,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ── تعداد آیتم‌ها ──
          _OrderRow(
            label: 'تعداد آیتم‌ها',
            value: '$itemCount عدد',
            isDark: isDark,
          ),

          const SizedBox(height: 10),

          // ── جمع سفارش ──
          _OrderRow(
            label: 'جمع سفارش',
            value: _format(subtotal),
            isDark: isDark,
          ),

          const SizedBox(height: 10),

          // ── هزینه ارسال ──
          _OrderRow(
            label: 'هزینه ارسال',
            value: deliveryFee == 0 ? 'رایگان 🎉' : _format(deliveryFee),
            isDark: isDark,
            valueColor: deliveryFee == 0 ? Colors.green : null,
          ),

          // ── تخفیف (فقط وقتی > 0) ──
          if (discountAmount > 0) ...[
            const SizedBox(height: 10),
            _OrderRow(
              label: 'تخفیف',
              value: '− ${_format(discountAmount)}',
              isDark: isDark,
              valueColor: Colors.green,
              labelIcon: Icons.local_offer_rounded,
              labelIconColor: Colors.green,
            ),
          ],

          // ── خط جداکننده ──
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Divider(
              height: 1,
              color: isDark
                  ? Colors.white12
                  : Colors.black.withValues(alpha: 0.08),
            ),
          ),

          // ── مبلغ نهایی ──
          _OrderRow(
            label: 'مبلغ نهایی',
            value: _format(total),
            isDark: isDark,
            isBold: true,
            valueColor: AppColors.primary,
            labelFontSize: 14,
            valueFontSize: 16,
          ),
        ],
      ),
    );
  }
}

/// ردیف داخلی قابل استفاده مجدد برای هر آیتم خلاصه
class _OrderRow extends StatelessWidget {
  const _OrderRow({
    required this.label,
    required this.value,
    required this.isDark,
    this.isBold = false,
    this.valueColor,
    this.labelFontSize = 13,
    this.valueFontSize = 13,
    this.labelIcon,
    this.labelIconColor,
  });

  final String label;
  final String value;
  final bool isDark;
  final bool isBold;
  final Color? valueColor;
  final double labelFontSize;
  final double valueFontSize;
  final IconData? labelIcon;
  final Color? labelIconColor;

  @override
  Widget build(BuildContext context) {
    final labelColor = isBold
        ? (isDark ? AppColors.darkText : AppColors.lightText)
        : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary);

    final resolvedValueColor = valueColor ??
        (isBold
            ? AppColors.primary
            : (isDark ? AppColors.darkText : AppColors.lightText));

    return Row(
      children: [
        // آیکون اختیاری کنار لیبل
        if (labelIcon != null) ...[
          Icon(
            labelIcon,
            size: 14,
            color: labelIconColor ??
                (isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary),
          ),
          const SizedBox(width: 4),
        ],

        // لیبل
        Text(
          label,
          style: TextStyle(
            fontSize: labelFontSize,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
            color: labelColor,
          ),
        ),

        const Spacer(),

        // مقدار
        Text(
          value,
          style: TextStyle(
            fontSize: valueFontSize,
            fontWeight: isBold ? FontWeight.w900 : FontWeight.w600,
            color: resolvedValueColor,
          ),
        ),
      ],
    );
  }
}