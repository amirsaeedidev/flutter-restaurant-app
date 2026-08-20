// features/cart_and_checkout/widgets/discount_box.dart

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../discount/providers/discount_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class DiscountBox extends StatefulWidget {
  const DiscountBox({
    super.key,
    required this.isDark,
    required this.onDiscountApplied,
    required this.cartTotal,
  });

  final bool isDark;

  /// مقدار کل سبد خرید (تومان)
  final int cartTotal;

  /// callback — مقدار تخفیف (تومان) رو برمیگردونه
  /// اگه کد حذف بشه، صفر برمیگردونه
  final ValueChanged<int> onDiscountApplied;

  @override
  State<DiscountBox> createState() => _DiscountBoxState();
}

class _DiscountBoxState extends State<DiscountBox>
    with SingleTickerProviderStateMixin {
  final _codeController = TextEditingController();
  final _focusNode = FocusNode();

  late AnimationController _shakeCtrl;
  late Animation<double> _shakeAnim;

  String? _appliedCode;
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _shakeAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -8), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -8, end: 8), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8, end: -6), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -6, end: 6), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 6, end: 0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _codeController.dispose();
    _focusNode.dispose();
    _shakeCtrl.dispose();
    super.dispose();
  }

  // ── اعمال کد تخفیف ──
  Future<void> _applyCode() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) return;

    // جلوگیری از درخواست همزمان
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final provider = context.read<DiscountProvider>();

    // اعمال کد (بدون userId)
    await provider.applyCode(
      code: code,
      cartTotal: widget.cartTotal,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    // بررسی نتیجه اعمال کد
    if (provider.applyError != null) {
      setState(() {
        _errorMessage = provider.applyError;
        _appliedCode = null;
      });
      _shakeCtrl.forward(from: 0);
      widget.onDiscountApplied(0);
      return;
    }

    // کد با موفقیت اعمال شد
    if (provider.hasDiscount && provider.appliedDiscount != null) {
      setState(() {
        _appliedCode = code.toUpperCase();
        _errorMessage = null;
      });

      _focusNode.unfocus();

      // ارسال مبلغ تخفیف به والد
      widget.onDiscountApplied(provider.discountAmount);
    } else {
      // حالت غیرمنتظره
      setState(() {
        _errorMessage = 'خطا در اعمال کد تخفیف';
        _appliedCode = null;
      });
      widget.onDiscountApplied(0);
    }
  }

  // ── حذف کد اعمال‌شده ──
  void _removeCode() {
    final provider = context.read<DiscountProvider>();
    provider.removeDiscount();

    setState(() {
      _appliedCode = null;
      _errorMessage = null;
      _codeController.clear();
    });
    widget.onDiscountApplied(0);
  }

  @override
  Widget build(BuildContext context) {
    // گوش‌دادن به تغییرات provider
    return Consumer<DiscountProvider>(
      builder: (context, provider, child) {
        // همگام‌سازی وضعیت محلی با provider
        final hasDiscount = provider.hasDiscount;
        final appliedDiscount = provider.appliedDiscount;

        if (hasDiscount && appliedDiscount != null && _appliedCode == null) {
          // اگر provider تخفیف دارد اما وضعیت محلی خالی است
          _appliedCode = appliedDiscount.code;
        }

        if (!hasDiscount && _appliedCode != null) {
          // اگر provider تخفیف ندارد اما وضعیت محلی پر است
          _appliedCode = null;
        }

        // نمایش خطاهای provider در صورت نیاز
        if (provider.applyError != null && _errorMessage == null) {
          _errorMessage = provider.applyError;
        }

        return AnimatedBuilder(
          animation: _shakeAnim,
          builder: (_, child) => Transform.translate(
            offset: Offset(_shakeAnim.value, 0),
            child: child,
          ),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: widget.isDark
                  ? AppColors.darkSurface
                  : AppColors.lightSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _appliedCode != null
                    ? Colors.green.withValues(alpha: 0.5)
                    : _errorMessage != null
                        ? Colors.red.withValues(alpha: 0.4)
                        : (widget.isDark
                            ? Colors.white12
                            : Colors.black.withValues(alpha: 0.07)),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: _appliedCode != null
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.black.withValues(
                          alpha: widget.isDark ? 0.2 : 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── عنوان ──
                Row(
                  children: [
                    const Text('🏷️', style: TextStyle(fontSize: 15)),
                    const SizedBox(width: 6),
                    Text(
                      'کد تخفیف',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: widget.isDark
                            ? AppColors.darkText
                            : AppColors.lightText,
                      ),
                    ),
                    // نمایش مبلغ تخفیف
                    if (_appliedCode != null) ...[
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${NumberFormat('#,###').format(provider.discountAmount)} تومان',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 10),

                // ── وضعیت: کد اعمال‌شده ──
                if (_appliedCode != null)
                  _AppliedCodeChip(
                    code: _appliedCode!,
                    isDark: widget.isDark,
                    onRemove: _removeCode,
                  )
                else
                  // ── وضعیت: فرم ورود کد ──
                  _CodeInputRow(
                    controller: _codeController,
                    focusNode: _focusNode,
                    isDark: widget.isDark,
                    isLoading: _isLoading || provider.isApplying,
                    hasError: _errorMessage != null,
                    onApply: _applyCode,
                    onChanged: (_) {
                      if (_errorMessage != null) {
                        setState(() => _errorMessage = null);
                      }
                    },
                  ),

                // ── پیام خطا ──
                if (_errorMessage != null) ...[
                  const SizedBox(height: 8),
                  _ErrorRow(message: _errorMessage!),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── ردیف ورود کد ──
class _CodeInputRow extends StatelessWidget {
  const _CodeInputRow({
    required this.controller,
    required this.focusNode,
    required this.isDark,
    required this.isLoading,
    required this.hasError,
    required this.onApply,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isDark;
  final bool isLoading;
  final bool hasError;
  final VoidCallback onApply;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            
            textCapitalization: TextCapitalization.characters,
            onChanged: onChanged,
            onSubmitted: (_) => onApply(),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
              color: hasError
                  ? Colors.red
                  : (isDark ? AppColors.darkText : AppColors.lightText),
            ),
            decoration: InputDecoration(
              hintText: 'کد تخفیف',
              hintStyle: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                letterSpacing: 0,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
              filled: true,
              fillColor: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.black.withValues(alpha: 0.04),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: hasError ? Colors.red : AppColors.primary,
                  width: 1.5,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          height: 46,
          child: ElevatedButton(
            onPressed: isLoading ? null : onApply,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'اعمال',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

// ── chip کد اعمال‌شده ──
class _AppliedCodeChip extends StatelessWidget {
  const _AppliedCodeChip({
    required this.code,
    required this.isDark,
    required this.onRemove,
  });

  final String code;
  final bool isDark;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.green.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_rounded,
            color: Colors.green,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            code,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
              color: Colors.green,
            ),
          ),
          const SizedBox(width: 6),
          const Text(
            'اعمال شد ✅',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.green,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.close_rounded,
                size: 16,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── پیام خطا ──
class _ErrorRow extends StatelessWidget {
  const _ErrorRow({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.error_outline_rounded,
          color: Colors.red,
          size: 14,
        ),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            message,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.red,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}