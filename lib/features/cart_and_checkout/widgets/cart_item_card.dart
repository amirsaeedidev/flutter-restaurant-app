import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/model/cart_item_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/image_utils.dart';
import '../../cart_and_checkout/providers/cart_provider.dart';

class CartItemCard extends StatelessWidget {
  const CartItemCard({super.key, required this.item});
  final CartItemModel item;

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cart = context.read<CartProvider>();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── تصویر محصول ──
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: buildImage(
              item.product.imageUrl,
              width: 64,
              height: 64,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),

          // ── اطلاعات + کنترل‌ها ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // نام + دکمه حذف
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          height: 1.4,
                          color: isDark
                              ? AppColors.darkText
                              : AppColors.lightText,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // دکمه حذف کامل
                    GestureDetector(
                      onTap: () => _confirmDelete(context, cart),
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.delete_outline_rounded,
                          color: Colors.red,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),

                // توضیحات آیتم
                if (item.note.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    '📝 ${item.note}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                ],

                const SizedBox(height: 10),

                // قیمت + کنترل تعداد
                Row(
                  children: [
                    Text(
                      _format(item.totalPrice),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    const Spacer(),
                    _QuantityRow(
                      quantity: item.quantity,
                      onDecrement: () => cart.decrement(item.product.id),
                      onIncrement: () => cart.increment(item.product.id),
                      isDark: isDark,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, CartProvider cart) {
    showDialog(
      context: context,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('حذف از سبد'),
          content: Text('«${item.product.name}» از سبد خرید حذف بشه؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('انصراف'),
            ),
            ElevatedButton(
              onPressed: () {
                cart.removeItem(item.product.id);
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
              child: const Text('حذف'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── کنترل تعداد ──
class _QuantityRow extends StatelessWidget {
  const _QuantityRow({
    required this.quantity,
    required this.onDecrement,
    required this.onIncrement,
    required this.isDark,
  });
  final int quantity;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── دکمه کاهش (فقط وقتی quantity > 1 فعال است) ──
        Opacity(
          opacity: quantity > 1 ? 1.0 : 0.3,
          child: IgnorePointer(
            ignoring: quantity <= 1,
            child: _QBtn(
              icon: Icons.remove_rounded,
              onTap: onDecrement,
              isDark: isDark,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            '$quantity',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.darkText : AppColors.lightText,
            ),
          ),
        ),
        // ── دکمه افزایش (همیشه فعال) ──
        _QBtn(
          
          icon: Icons.add_rounded,
          onTap: onIncrement,
          isDark: isDark,
          isPrimary: true,
        ),
      ],
    );
  }
}

class _QBtn extends StatelessWidget {
  const _QBtn({
    
    required this.icon,
    required this.onTap,
    required this.isDark,
    this.isPrimary = false, this.color,
  });
  final IconData icon;
  final VoidCallback onTap;
  final bool isDark;
  final bool isPrimary;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    // ── رنگ پس‌زمینه (ایمن‌ترین حالت) ──
    final bg = isPrimary
        ? AppColors.primary
        : (color?.withValues(alpha: 0.1) ??
              (isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.06)));

    // ── رنگ آیکون ──
    final iconColor = isPrimary
        ? Colors.white
        : (color ?? (isDark ? AppColors.darkText : AppColors.lightText));

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 17, color: iconColor),
      ),
    );
  }
}
