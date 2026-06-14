import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/model/product_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../cart_and_checkout/providers/cart_provider.dart';

// دکمه افزودن به سبد — وقتی در سبد بود به −/+ تبدیل میشه
class AddToCartButton extends StatelessWidget {
  const AddToCartButton({
    super.key,
    required this.product,
    this.size = 30,
  });

  final ProductModel product;
  final double size; // اندازه پایه دکمه‌ها

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final quantity = cart.quantityOf(product.id);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ── حالت ۱: هنوز در سبد نیست ──
    if (quantity == 0) {
      return GestureDetector(
        onTap: () => cart.addItem(product, quantity: 1),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(size * 0.27),
          ),
          child: Icon(Icons.add_rounded,
              color: Colors.white, size: size * 0.66),
        ),
      );
    }

    // ── حالت ۲: در سبد هست → −  عدد  + ──
    return Container(
      height: size,
      padding: EdgeInsets.symmetric(horizontal: size * 0.1),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(size * 0.27),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _QtyBtn(
            icon: quantity == 1
                ? Icons.delete_outline_rounded
                : Icons.remove_rounded,
            size: size,
            onTap: () => cart.decrement(product.id),
          ),
          SizedBox(
            width: size * 0.85,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: size * 0.46,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          _QtyBtn(
            icon: Icons.add_rounded,
            size: size,
            onTap: () => cart.increment(product.id),
          ),
        ],
      ),
    );
  }
}

class _QtyBtn extends StatelessWidget {
  const _QtyBtn({
    required this.icon,
    required this.size,
    required this.onTap,
  });
  final IconData icon;
  final double size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: size * 0.8,
        height: size,
        child: Icon(icon, color: Colors.white, size: size * 0.5),
      ),
    );
  }
}