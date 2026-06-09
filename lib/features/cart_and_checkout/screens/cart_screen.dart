import 'package:flutter/material.dart';
import 'package:my_project/features/cart_and_checkout/screens/checkout_screen.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../cart_and_checkout/providers/cart_provider.dart';
import '../../cart_and_checkout/widgets/cart_item_card.dart';
//import '../../../core/model/cart_item_model.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

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
    final cart = context.watch<CartProvider>();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
            isDark ? AppColors.darkBackground : AppColors.lightBackground,

        // ── AppBar ──
        appBar: AppBar(
          backgroundColor:
              isDark ? AppColors.darkBackground : AppColors.lightBackground,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Text(
            'سبد خرید',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: isDark ? AppColors.darkText : AppColors.lightText,
            ),
          ),
          actions: [
            if (cart.items.isNotEmpty)
              TextButton.icon(
                onPressed: () => _confirmClearCart(context, cart),
                icon: const Icon(Icons.delete_sweep_rounded,
                    color: Colors.red, size: 20),
                label: const Text('پاک کردن',
                    style: TextStyle(color: Colors.red, fontSize: 13)),
              ),
          ],
        ),

        body: cart.items.isEmpty
            ? _EmptyCart(isDark: isDark)
            : _CartContent(
                cart: cart,
                noteController: _noteController,
                isDark: isDark,
                formatPrice: _format,
              ),

        // ── دکمه پرداخت ──
        bottomNavigationBar: cart.items.isEmpty
            ? null
            : _CheckoutBar(
                cart: cart,
                isDark: isDark,
                formatPrice: _format,
                noteController: _noteController,
              ),
      ),
    );
  }

  void _confirmClearCart(BuildContext context, CartProvider cart) {
    showDialog(
      context: context,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('پاک کردن سبد'),
          content: const Text('همه آیتم‌ها از سبد خرید حذف بشن؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('انصراف'),
            ),
            ElevatedButton(
              onPressed: () {
                cart.clearCart();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('پاک کن'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── سبد خالی ──
class _EmptyCart extends StatelessWidget {
  const _EmptyCart({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🛒', style: TextStyle(fontSize: 72)),
          const SizedBox(height: 16),
          Text(
            'سبد خریدت خالیه!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.darkText : AppColors.lightText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'از منو یه غذای خوشمزه انتخاب کن 😋',
            style: TextStyle(
              fontSize: 14,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── محتوای سبد ──
class _CartContent extends StatelessWidget {
  const _CartContent({
    required this.cart,
    required this.noteController,
    required this.isDark,
    required this.formatPrice,
  });
  final CartProvider cart;
  final TextEditingController noteController;
  final bool isDark;
  final String Function(int) formatPrice;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
      children: [
        // ── لیست آیتم‌ها ──
        ...cart.items.map((item) => CartItemCard(item: item)),

        const SizedBox(height: 8),

        // ── توضیحات کل سفارش ──
        _OrderNoteField(controller: noteController, isDark: isDark),

        const SizedBox(height: 16),

        // ── خلاصه قیمت ──
        _PriceSummary(cart: cart, isDark: isDark, formatPrice: formatPrice),
      ],
    );
  }
}

// ── فیلد توضیحات کل سفارش ──
class _OrderNoteField extends StatelessWidget {
  const _OrderNoteField({
    required this.controller,
    required this.isDark,
  });
  final TextEditingController controller;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('📝', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text(
                'توضیحات سفارش',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkText : AppColors.lightText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: controller,
            maxLines: 3,
            textDirection: TextDirection.rtl,
            decoration: InputDecoration(
              hintText:
                  'مثلاً: غذا رو تند بیارید، بدون نوشابه، زودتر آماده بشه...',
              hintStyle: TextStyle(
                fontSize: 12.5,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
              filled: true,
              fillColor: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.03),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
        ],
      ),
    );
  }
}

// ── خلاصه قیمت ──
class _PriceSummary extends StatelessWidget {
  const _PriceSummary({
    required this.cart,
    required this.isDark,
    required this.formatPrice,
  });
  final CartProvider cart;
  final bool isDark;
  final String Function(int) formatPrice;

  @override
  Widget build(BuildContext context) {
    const deliveryFee = 15000;
    final total = cart.totalPrice + deliveryFee;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _SummaryRow(
            label: 'جمع سفارش',
            value: formatPrice(cart.totalPrice),
            isDark: isDark,
          ),
          const SizedBox(height: 8),
          _SummaryRow(
            label: 'هزینه ارسال',
            value: formatPrice(deliveryFee),
            isDark: isDark,
          ),
          Divider(
            height: 20,
            color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.08),
          ),
          _SummaryRow(
            label: 'مبلغ قابل پرداخت',
            value: formatPrice(total),
            isDark: isDark,
            isBold: true,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    required this.isDark,
    this.isBold = false,
  });
  final String label;
  final String value;
  final bool isDark;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    final color = isDark ? AppColors.darkText : AppColors.lightText;
    final secondaryColor =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 14 : 13,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
            color: isBold ? color : secondaryColor,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 15 : 13,
            fontWeight: isBold ? FontWeight.w900 : FontWeight.w600,
            color: isBold ? AppColors.primary : color,
          ),
        ),
      ],
    );
  }
}

// ── نوار پایین: دکمه پرداخت ──
class _CheckoutBar extends StatelessWidget {
  const _CheckoutBar({
    required this.cart,
    required this.isDark,
    required this.formatPrice,
    required this.noteController,
  });
  final CartProvider cart;
  final bool isDark;
  final String Function(int) formatPrice;
  final TextEditingController noteController;

  @override
  Widget build(BuildContext context) {
    const deliveryFee = 15000;
    final total = cart.totalPrice + deliveryFee;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CheckoutScreen(
                  orderNote: noteController.text.trim(),
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 15),
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
          child: Text(
            'ادامه  —  ${formatPrice(total)}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
        ),
      ),
    );
  }
}