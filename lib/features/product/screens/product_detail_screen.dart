import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/model/product_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/image_utils.dart'; // ← اضافه شد
import '../../cart_and_checkout/providers/cart_provider.dart';
import '../../../shared/providers/navigation_provider.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key, required this.product});
  final ProductModel product;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _showAddedSnackbar = false;
  String _snackbarMessage = '';

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.1, 0.7, curve: Curves.easeOutCubic),
    ));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _triggerAddedToCartAnimation(String message) {
    setState(() {
      _showAddedSnackbar = true;
      _snackbarMessage = message;
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _showAddedSnackbar = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cart = context.watch<CartProvider>();
    final inCart = cart.isInCart(widget.product.id);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
            isDark ? AppColors.darkBackground : AppColors.lightBackground,
        body: Stack(
          children: [
            CustomScrollView(
              slivers: [
                // Hero area with floating info card
                SliverAppBar(
                  clipBehavior: Clip.none, 
                  expandedHeight: 340,
                  pinned: false,
                  floating: false,
                  stretch: true,
                  leading: _BackButton(isDark: isDark),
                  actions: [
                    _CartBadgeButton(isDark: isDark, itemCount: cart.itemCount),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    collapseMode: CollapseMode.parallax,
                    background: _HeroSection(
                      product: widget.product,
                      isDark: isDark,
                      fadeAnimation: _fadeAnimation,
                      slideAnimation: _slideAnimation,
                    ),
                  ),
                ),
                // Content (description + reviews) without card overlap
                SliverToBoxAdapter(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: _ContentSection(
                        product: widget.product,
                        isDark: isDark,
                      ),
                    ),
                  ),
                ),
                // Bottom padding for bottom bar
                const SliverToBoxAdapter(child: SizedBox(height: 90)),
              ],
            ),

            // Custom glassmorphism snackbar
            if (_showAddedSnackbar)
              Positioned(
                bottom: 90,
                left: 20,
                right: 20,
                child: _PremiumNotification(
                  message: _snackbarMessage,
                  isDark: isDark,
                  onDismissed: () =>
                      setState(() => _showAddedSnackbar = false),
                ),
              ),
          ],
        ),
        bottomNavigationBar: _FloatingBottomBar(
          product: widget.product,
          inCart: inCart,
          isDark: isDark,
          onAddedToCart: _triggerAddedToCartAnimation,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
// Hero Section: Image + Floating Glass Card Overlap
// ─────────────────────────────────────────────────────
class _HeroSection extends StatelessWidget {
  const _HeroSection({
    required this.product,
    required this.isDark,
    required this.fadeAnimation,
    required this.slideAnimation,
  });
  final ProductModel product;
  final bool isDark;
  final Animation<double> fadeAnimation;
  final Animation<Offset> slideAnimation;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      fit: StackFit.expand,
      children: [
        // ── تغییر اصلی اینجاست ──
        buildImage(
          product.imageUrl,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          // placeholderAsset به‌صورت پیش‌فرض 'assets/images/food.jpg' است
        ),

        // Gradient overlay at bottom
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 150,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  (isDark
                          ? AppColors.darkBackground
                          : AppColors.lightBackground)
                      .withValues(alpha: 0.8),
                ],
              ),
            ),
          ),
        ),

        // Floating Glass Card
        Positioned(
          left: 16,
          right: 16,
          bottom: 5,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: SlideTransition(
              position: slideAnimation,
              child: _FloatingProductCard(product: product, isDark: isDark),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────
// Glassmorphism Product Info Card
// ─────────────────────────────────────────────────────
class _FloatingProductCard extends StatelessWidget {
  const _FloatingProductCard({required this.product, required this.isDark});
  final ProductModel product;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final subColor =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 8,
          sigmaY: 8,
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.black.withValues(alpha: 0.55)
                : Colors.white.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.15)
                  : Colors.black.withValues(alpha: 0.08),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.12),
                blurRadius: 30,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                product.name,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Price
                  Expanded(
                    child: Text(
                      '${_formatPrice(product.price)} تومان',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  // Badges
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (product.isPopular)
                        _GlassBadge(
                          icon: Icons.local_fire_department_rounded,
                          label: 'پرطرفدار',
                          color: Colors.deepOrange,
                          isDark: isDark,
                        ),
                      _GlassBadge(
                        icon: Icons.star_rounded,
                        label: product.rating.toStringAsFixed(1),
                        color: AppColors.secondary,
                        isDark: isDark,
                      ),
                      _GlassBadge(
                        icon: Icons.reviews_rounded,
                        label: '${product.reviewCount}',
                        color: subColor,
                        isDark: isDark,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatPrice(int price) {
    final s = price.toString();
    final buf = StringBuffer();
    final offset = s.length % 3;
    for (int i = 0; i < s.length; i++) {
      if (i != 0 && (i - offset) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}

// ─────────────────────────────────────────────────────
// Glass Badge Pill
// ─────────────────────────────────────────────────────
class _GlassBadge extends StatelessWidget {
  const _GlassBadge({
    required this.icon,
    required this.label,
    required this.color,
    required this.isDark,
  });
  final IconData icon;
  final String label;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: isDark ? 0.2 : 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: color.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
// Premium Glass Notification (replaces SnackBar)
// ─────────────────────────────────────────────────────
class _PremiumNotification extends StatefulWidget {
  const _PremiumNotification({
    required this.message,
    required this.isDark,
    required this.onDismissed,
  });
  final String message;
  final bool isDark;
  final VoidCallback onDismissed;

  @override
  State<_PremiumNotification> createState() => _PremiumNotificationState();
}

class _PremiumNotificationState extends State<_PremiumNotification>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, 1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _ctrl,
      curve: Curves.easeOutCubic,
    ));
    _fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
    _ctrl.forward();

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _ctrl.reverse().then((_) => widget.onDismissed());
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slide,
      child: FadeTransition(
        opacity: _fade,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: widget.isDark
                    ? const Color(0xFF1E1E1E).withValues(alpha: 0.85)
                    : Colors.white.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: widget.isDark
                      ? Colors.white.withValues(alpha: 0.15)
                      : Colors.black.withValues(alpha: 0.08),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: widget.isDark ? 0.5 : 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded,
                      color: AppColors.primary, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.message,
                      style: TextStyle(
                        color: widget.isDark
                            ? AppColors.darkText
                            : AppColors.lightText,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      _ctrl.reverse().then((_) => widget.onDismissed());
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withValues(alpha: 0.1),
                      ),
                      child: const Icon(Icons.close, size: 16, color: Colors.grey),
                    ),
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

// ─────────────────────────────────────────────────────
// Content Section: Description & Reviews
// ─────────────────────────────────────────────────────
class _ContentSection extends StatelessWidget {
  const _ContentSection({required this.product, required this.isDark});
  final ProductModel product;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -24),
      child: Container(
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.darkSurface
              : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'درباره این غذا',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkText : AppColors.lightText,
                ),
              ),
              const SizedBox(height: 12),
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
              const SizedBox(height: 28),
              _ReviewSection(product: product, isDark: isDark),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReviewSection extends StatelessWidget {
  const _ReviewSection({required this.product, required this.isDark});
  final ProductModel product;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    // static sample reviews (could come from backend)
    final reviews = [
      (name: 'علی رضایی', stars: 5, text: 'عالی بود! کیفیت گوشت فوق‌العاده.'),
      (name: 'مریم احمدی', stars: 4, text: 'خوشمزه، فقط کمی دیر رسید.'),
      (name: 'رضا کریمی', stars: 5, text: 'بهترین کباب شهر، حتماً دوباره سفارش میدم.'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'نظرات مشتریان',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkText : AppColors.lightText,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '(${product.reviewCount})',
              style: TextStyle(
                fontSize: 14,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
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
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primary.withValues(alpha: 0.15),
            child: Text(
              review.name[0],
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      review.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: isDark ? AppColors.darkText : AppColors.lightText,
                      ),
                    ),
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
                const SizedBox(height: 8),
                Text(
                  review.text,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
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

// ─────────────────────────────────────────────────────
// Floating Bottom Bar (Glassmorphism, Material 3)
// ─────────────────────────────────────────────────────
class _FloatingBottomBar extends StatelessWidget {
  const _FloatingBottomBar({
    required this.product,
    required this.inCart,
    required this.isDark,
    required this.onAddedToCart,
  });
  final ProductModel product;
  final bool inCart;
  final bool isDark;
  final Function(String message) onAddedToCart;

  String _format(int price) {
    final s = price.toString();
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
    final total = product.price;
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 30),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF121212).withValues(alpha: 0.85)
                : Colors.white.withValues(alpha: 0.85),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(
              top: BorderSide(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.15)
                    : Colors.black.withValues(alpha: 0.08),
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.6 : 0.15),
                blurRadius: 30,
                offset: const Offset(0, -8),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'قیمت',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_format(total)} تومان',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () => _showAddToCartSheet(context),
                    icon: Icon(
                      inCart
                          ? Icons.shopping_cart_rounded
                          : Icons.add_shopping_cart_rounded,
                      size: 22,
                    ),
                    label: Text(
                      inCart ? 'ویرایش سبد' : 'افزودن به سبد',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 8,
                      shadowColor: AppColors.primary.withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddToCartSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddToCartSheet(
        product: product,
        onAdded: onAddedToCart,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
// Add to Cart Bottom Sheet
// ─────────────────────────────────────────────────────
class _AddToCartSheet extends StatefulWidget {
  const _AddToCartSheet({required this.product, required this.onAdded});
  final ProductModel product;
  final Function(String) onAdded;

  @override
  State<_AddToCartSheet> createState() => _AddToCartSheetState();
}

class _AddToCartSheetState extends State<_AddToCartSheet> {
  int _quantity = 1;
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
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
        padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottomPadding),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              widget.product.name,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.darkText : AppColors.lightText,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Text(
                  'تعداد:',
                  style: TextStyle(
                    fontSize: 15,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
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
            const SizedBox(height: 20),
            TextField(
              controller: _noteController,
              maxLines: 2,
              textDirection: TextDirection.rtl,
              decoration: InputDecoration(
                hintText: 'توضیحات (مثلاً: بدون نمک، تند نباشه...)',
                hintStyle: TextStyle(
                  fontSize: 14,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
                filled: true,
                fillColor: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.black.withValues(alpha: 0.04),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _confirmAdd,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'افزودن به سبد  —  ${_format(widget.product.price)} تومان',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
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
    widget.onAdded('${widget.product.name} به سبد اضافه شد ✅');
  }
}

// ─────────────────────────────────────────────────────
// Back Button & Cart Badge
// ─────────────────────────────────────────────────────
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
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 10,
              )
            ],
          ),
          child: Icon(
            Icons.arrow_forward_rounded,
            color: isDark ? AppColors.darkText : AppColors.lightText,
            size: 22,
          ),
        ),
      ),
    );
  }
}

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
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 10,
                  )
                ],
              ),
              child: const Icon(
                Icons.shopping_cart_rounded,
                color: AppColors.primary,
                size: 22,
              ),
            ),
            if (itemCount > 0)
              Positioned(
                top: -2,
                right: -2,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$itemCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
// Quantity Control
// ─────────────────────────────────────────────────────
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
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Text(
            '$quantity',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.darkText : AppColors.lightText,
            ),
          ),
        ),
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
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isPrimary
              ? AppColors.primary
              : (isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.07)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          size: 22,
          color: isPrimary
              ? Colors.white
              : (isDark ? AppColors.darkText : AppColors.lightText),
        ),
      ),
    );
  }
}