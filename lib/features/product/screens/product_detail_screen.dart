import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/model/product_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../cart_and_checkout/providers/cart_provider.dart';
import '../../../shared/providers/navigation_provider.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key, required this.product});
  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cart = context.watch<CartProvider>();
    final inCart = cart.isInCart(product.id);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
            isDark ? AppColors.darkBackground : AppColors.lightBackground,
        body: CustomScrollView(
          slivers: [
            // ── AppBar با تصویر ──
            SliverAppBar(
              expandedHeight: 280,
              pinned: true,
              backgroundColor:
                  isDark ? AppColors.darkSurface : AppColors.lightSurface,
              leading: _BackButton(isDark: isDark),
              actions: [
                _CartBadgeButton(isDark: isDark, itemCount: cart.itemCount),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: _ProductImage(product: product, isDark: isDark),
              ),
            ),

            // ── محتوا ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // نام + بج پرطرفدار
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            product.name,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: isDark
                                  ? AppColors.darkText
                                  : AppColors.lightText,
                              height: 1.3,
                            ),
                          ),
                        ),
                        if (product.isPopular) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: AppColors.secondary.withValues(alpha: 0.4)),
                            ),
                            child: const Text('🔥 پرطرفدار',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.secondary)),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 12),

                    // ستاره‌ها و تعداد نظر
                    _RatingRow(product: product),

                    const SizedBox(height: 16),

                    // قیمت
                    _PriceTag(price: product.price, isDark: isDark),

                    const SizedBox(height: 20),

                    // خط جدا
                    Divider(
                        color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.07)),

                    const SizedBox(height: 16),

                    // توضیحات
                    Text('درباره این غذا',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.darkText : AppColors.lightText)),
                    const SizedBox(height: 8),
                    Text(
                      product.description,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.8,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ستاره‌های ثابت (static)
                    _StaticReviewSection(product: product, isDark: isDark),
                  ],
                ),
              ),
            ),
          ],
        ),

        // ── دکمه‌های پایین ──
        bottomNavigationBar: _BottomButtons(
          product: product,
          inCart: inCart,
          isDark: isDark,
        ),
      ),
    );
  }
}

// ── تصویر محصول ──
class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.product, required this.isDark});
  final ProductModel product;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isDark
          ? Colors.white.withValues(alpha: 0.04)
          : AppColors.primary.withValues(alpha: 0.06),
      child: Center(
        child: Text(
          _emojiForCategory(product.categoryId),
          style: const TextStyle(fontSize: 110),
        ),
      ),
    );
  }

  String _emojiForCategory(String id) {
    switch (id) {
      case '1': return '🍢';
      case '2': return '🥗';
      case '3': return '🥤';
      default:  return '🍽️';
    }
  }
}

// ── دکمه برگشت ──
class _BackButton extends StatelessWidget {
  const _BackButton({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8)],
          ),
          child: Icon(Icons.arrow_forward_rounded,
              color: isDark ? AppColors.darkText : AppColors.lightText, size: 20),
        ),
      ),
    );
  }
}

// ── آیکون سبد با badge ──
class _CartBadgeButton extends StatelessWidget {
  const _CartBadgeButton({required this.isDark, required this.itemCount});
  final bool isDark;
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: GestureDetector(
        onTap: () => context.read<NavigationProvider>().setIndex(0),
        child: Stack(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8)],
              ),
              child: const Icon(Icons.shopping_cart_rounded,
                  color: AppColors.primary, size: 20),
            ),
            if (itemCount > 0)
              Positioned(
                top: 0, left: 0,
                child: Container(
                  width: 16, height: 16,
                  decoration: const BoxDecoration(
                      color: AppColors.primary, shape: BoxShape.circle),
                  child: Center(
                    child: Text('$itemCount',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── ردیف ستاره‌ها ──
class _RatingRow extends StatelessWidget {
  const _RatingRow({required this.product});
  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ...List.generate(5, (i) {
          final full = i < product.rating.floor();
          final half = !full && i < product.rating;
          return Icon(
            full ? Icons.star_rounded : (half ? Icons.star_half_rounded : Icons.star_outline_rounded),
            color: AppColors.secondary,
            size: 20,
          );
        }),
        const SizedBox(width: 6),
        Text(
          product.rating.toStringAsFixed(1),
          style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.secondary),
        ),
        const SizedBox(width: 4),
        Text(
          '(${product.reviewCount} نظر)',
          style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary),
        ),
      ],
    );
  }
}

// ── قیمت ──
class _PriceTag extends StatelessWidget {
  const _PriceTag({required this.price, required this.isDark});
  final int price;
  final bool isDark;

  String _format(int p) {
    final s = p.toString();
    final buf = StringBuffer();
    final offset = s.length % 3;
    for (int i = 0; i < s.length; i++) {
      if (i != 0 && (i - offset) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('قیمت:',
            style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
        const SizedBox(width: 8),
        Text(
          '${_format(price)} تومان',
          style: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.primary),
        ),
      ],
    );
  }
}

// ── بخش نظرات استاتیک ──
class _StaticReviewSection extends StatelessWidget {
  const _StaticReviewSection({required this.product, required this.isDark});
  final ProductModel product;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    // نظرات ساختگی ثابت
    final reviews = [
      (name: 'علی رضایی', stars: 5, text: 'عالی بود! کیفیت گوشت فوق‌العاده.'),
      (name: 'مریم احمدی', stars: 4, text: 'خوشمزه، فقط کمی دیر رسید.'),
      (name: 'رضا کریمی', stars: 5, text: 'بهترین کباب شهر، حتماً دوباره سفارش میدم.'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('نظرات مشتریان',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkText : AppColors.lightText)),
        const SizedBox(height: 12),
        ...reviews.map((r) => _ReviewCard(review: r, isDark: isDark)),
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review, required this.isDark});
  final ({String name, int stars, String text}) review;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(review.name,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.darkText : AppColors.lightText)),
              const Spacer(),
              Row(
                children: List.generate(
                  review.stars,
                  (_) => const Icon(Icons.star_rounded,
                      color: AppColors.secondary, size: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(review.text,
              style: TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary)),
        ],
      ),
    );
  }
}

// ── دکمه‌های پایین: برگشت به منو + افزودن به سبد ──
class _BottomButtons extends StatelessWidget {
  const _BottomButtons({
    required this.product,
    required this.inCart,
    required this.isDark,
  });
  final ProductModel product;
  final bool inCart;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.07),
              blurRadius: 16,
              offset: const Offset(0, -4)),
        ],
      ),
      child: Row(
        children: [
          // برگشت به منو
          Expanded(
            flex: 2,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_forward_rounded, size: 18),
              label: const Text('برگشت به منو'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // افزودن به سبد
          Expanded(
            flex: 3,
            child: ElevatedButton.icon(
              onPressed: () => _showAddToCartSheet(context),
              icon: Icon(inCart
                  ? Icons.shopping_cart_rounded
                  : Icons.add_shopping_cart_rounded, size: 20),
              label: Text(inCart ? 'مشاهده / ویرایش سبد' : 'افزودن به سبد'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddToCartSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddToCartSheet(product: product),
    );
  }
}

// ── Bottom Sheet افزودن به سبد ──
class _AddToCartSheet extends StatefulWidget {
  const _AddToCartSheet({required this.product});
  final ProductModel product;

  @override
  State<_AddToCartSheet> createState() => _AddToCartSheetState();
}

class _AddToCartSheetState extends State<_AddToCartSheet> {
  int _quantity = 1;
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // اگه قبلاً در سبد بوده، تعداد و توضیحات قبلی رو بیار
    final cart = context.read<CartProvider>();
    _quantity = cart.quantityOf(widget.product.id).clamp(1, 99);
    _noteController.text = cart.noteOf(widget.product.id);
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  String _format(int p) {
    final s = (p * _quantity).toString();
    final buf = StringBuffer();
    final offset = s.length % 3;
    for (int i = 0; i < s.length; i++) {
      if (i != 0 && (i - offset) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomPadding),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // handle
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // نام غذا
            Text(widget.product.name,
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.darkText : AppColors.lightText)),
            const SizedBox(height: 20),

            // انتخاب تعداد
            Row(
              children: [
                Text('تعداد:',
                    style: TextStyle(
                        fontSize: 14,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary)),
                const Spacer(),
                _QuantityControl(
                  quantity: _quantity,
                  onDecrement: () {
                    if (_quantity > 1) setState(() => _quantity--);
                  },
                  onIncrement: () => setState(() => _quantity++),
                  isDark: isDark,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // توضیحات سفارش
            TextField(
              controller: _noteController,
              maxLines: 2,
              textDirection: TextDirection.rtl,
              decoration: InputDecoration(
                hintText: 'توضیحات (مثلاً: بدون نمک، تند نباشه...)',
                hintStyle: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary),
                filled: true,
                fillColor: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.black.withValues(alpha: 0.04),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
            const SizedBox(height: 20),

            // دکمه تأیید + جمع قیمت
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _confirmAdd,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(
                  'افزودن به سبد  —  ${_format(widget.product.price)} تومان',
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmAdd() {
    context.read<CartProvider>().addItem(
          widget.product,
          quantity: _quantity,
          note: _noteController.text.trim(),
        );
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.product.name} به سبد اضافه شد ✅'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
      ),
    );
  }
}

// ── کنترل تعداد (− عدد +) ──
class _QuantityControl extends StatelessWidget {
  const _QuantityControl({
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
      children: [
        _QBtn(icon: Icons.remove_rounded, onTap: onDecrement, isDark: isDark),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('$quantity',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.darkText : AppColors.lightText)),
        ),
        _QBtn(icon: Icons.add_rounded, onTap: onIncrement, isDark: isDark, isPrimary: true),
      ],
    );
  }
}

class _QBtn extends StatelessWidget {
  const _QBtn({
    required this.icon,
    required this.onTap,
    required this.isDark,
    this.isPrimary = false,
  });
  final IconData icon;
  final VoidCallback onTap;
  final bool isDark;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: isPrimary
              ? AppColors.primary
              : (isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.07)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon,
            size: 20,
            color: isPrimary
                ? Colors.white
                : (isDark ? AppColors.darkText : AppColors.lightText)),
      ),
    );
  }
}