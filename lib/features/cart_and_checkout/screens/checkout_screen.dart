import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/model/address_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../address/providers/address_provider.dart';
import '../../address/widgets/address_selector_sheet.dart';
import '../../cart_and_checkout/providers/cart_provider.dart';
import '../../loyalty/providers/loyalty_provider.dart';
import '../../orders/screens/recent_orders_screen.dart';

enum _DeliveryType { delivery, dineIn }
enum _DineInMode  { takeaway, reserveTable }  // ← جدید

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key, required this.orderNote});
  final String orderNote;

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  _DeliveryType _type       = _DeliveryType.delivery;
  _DineInMode   _dineInMode = _DineInMode.takeaway;   // ← جدید

  AddressModel? _selectedAddress;
  final _addressController = TextEditingController();
  final _phoneController   = TextEditingController();
  bool _sameAsUser = false;
  int? _selectedTable;

  @override
  void dispose() {
    _addressController.dispose();
    _phoneController.dispose();
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

  bool get _isReserving => _dineInMode == _DineInMode.reserveTable;

  @override
  Widget build(BuildContext context) {
    final isDark   = Theme.of(context).brightness == Brightness.dark;
    final cart     = context.watch<CartProvider>();
    const deliveryFee = 15000;
    final total = cart.totalPrice +
        (_type == _DeliveryType.delivery ? deliveryFee : 0);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
            isDark ? AppColors.darkBackground : AppColors.lightBackground,
        appBar: AppBar(
          backgroundColor:
              isDark ? AppColors.darkBackground : AppColors.lightBackground,
          elevation: 0,
          title: Text('تکمیل سفارش',
              style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.w900,
                color: isDark ? AppColors.darkText : AppColors.lightText,
              )),
          leading: IconButton(
            icon: Icon(Icons.arrow_forward_rounded,
                color: isDark ? AppColors.darkText : AppColors.lightText),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
          children: [

            // ── نوع سفارش (دلیوری / حضوری) ──
            _SectionTitle(title: 'نوع سفارش', isDark: isDark),
            const SizedBox(height: 10),
            _DeliveryTypeSelector(
              selected: _type,
              onChanged: (t) => setState(() => _type = t),
              isDark: isDark,
            ),
            const SizedBox(height: 20),

            // ── بدنه بر اساس نوع ──
            if (_type == _DeliveryType.delivery) ...[
              _SectionTitle(title: 'اطلاعات تحویل', isDark: isDark),
              const SizedBox(height: 10),
              _SavedAddressPicker(
                selected: _selectedAddress,
                isDark: isDark,
                onPick: (addr) => setState(() {
                  _selectedAddress = addr;
                  _addressController.text = addr.fullAddress;
                  if (addr.phone != null) {
                    _phoneController.text = addr.phone!;
                  }
                }),
              ),
              const SizedBox(height: 10),
              _DeliveryForm(
                addressController: _addressController,
                phoneController: _phoneController,
                sameAsUser: _sameAsUser,
                onSameAsUserChanged: (v) =>
                    setState(() => _sameAsUser = v ?? false),
                isDark: isDark,
              ),

            ] else ...[

              // ── حضوری: انتخاب حالت ──
              _SectionTitle(title: 'نحوه دریافت', isDark: isDark),
              const SizedBox(height: 10),
              _DineInModeSelector(
                mode: _dineInMode,
                onChanged: (m) => setState(() {
                  _dineInMode = m;
                  // وقتی takeaway انتخاب میشه، میز رو پاک کن
                  if (m == _DineInMode.takeaway) _selectedTable = null;
                }),
                isDark: isDark,
              ),
              const SizedBox(height: 16),

              // ── انتخاب میز — فقط وقتی رزرو انتخابه فعاله ──
              _SectionTitle(title: 'انتخاب میز', isDark: isDark),
              const SizedBox(height: 10),
              _TableSelector(
                selectedTable: _selectedTable,
                onSelected: (t) {
                  if (_isReserving) {
                    setState(() => _selectedTable = t);
                  }
                },
                isDark: isDark,
                disabled: !_isReserving,   // ← خاکستری وقتی takeaway
              ),
            ],

            const SizedBox(height: 20),

            // ── خلاصه پرداخت ──
            _SectionTitle(title: 'خلاصه پرداخت', isDark: isDark),
            const SizedBox(height: 10),
            _OrderSummary(
              cart: cart,
              isDark: isDark,
              formatPrice: _format,
              isDelivery: _type == _DeliveryType.delivery,
              deliveryFee: deliveryFee,
              total: total,
            ),
          ],
        ),
        bottomNavigationBar: _PayButton(
          total: total,
          isDark: isDark,
          formatPrice: _format,
          onPay: () => _handlePayment(context),
        ),
      ),
    );
  }

  // ── Validation ──
  bool _validate() {
    if (_type == _DeliveryType.delivery) {
      if (_addressController.text.trim().isEmpty) {
        _showError('آدرس را وارد کنید'); return false;
      }
      if (!_sameAsUser && _phoneController.text.trim().isEmpty) {
        _showError('شماره تلفن گیرنده را وارد کنید'); return false;
      }
    } else {
      // حضوری + رزرو میز → میز باید انتخاب شده باشه
      if (_isReserving && _selectedTable == null) {
        _showError('شماره میز را انتخاب کنید'); return false;
      }
    }
    return true;
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: Colors.red,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
    ));
  }

  void _handlePayment(BuildContext context) {
    if (!_validate()) return;
    _showPaymentDialog(context);
  }

  void _showPaymentDialog(BuildContext context) {
    final cart = context.read<CartProvider>();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              const Text('💳', style: TextStyle(fontSize: 52)),
              const SizedBox(height: 16),
              const Text('در حال اتصال به درگاه...',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text('این یه پرداخت آزمایشیه',
                  style: TextStyle(fontSize: 13, color: Colors.grey[500])),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final totalPrice = cart.totalPrice;
                  cart.clearCart();
                  await context
                      .read<LoyaltyProvider>()
                      .addPointsForOrder(totalPrice);
                  if (!context.mounted) return;
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const RecentOrdersScreen()),
                    (route) => route.isFirst,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('پرداخت موفق ✅',
                    style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────
// ویجت‌ها
// ──────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.isDark});
  final String title;
  final bool isDark;
  @override
  Widget build(BuildContext context) => Text(title,
      style: TextStyle(
        fontSize: 15, fontWeight: FontWeight.w800,
        color: isDark ? AppColors.darkText : AppColors.lightText,
      ));
}

// ── انتخابگر دلیوری / حضوری ──
class _DeliveryTypeSelector extends StatelessWidget {
  const _DeliveryTypeSelector(
      {required this.selected, required this.onChanged, required this.isDark});
  final _DeliveryType selected;
  final ValueChanged<_DeliveryType> onChanged;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
        child: _TypeCard(
          emoji: '🛵', label: 'دلیوری',
          isSelected: selected == _DeliveryType.delivery,
          onTap: () => onChanged(_DeliveryType.delivery),
          isDark: isDark,
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: _TypeCard(
          emoji: '🍽️', label: 'حضوری',
          isSelected: selected == _DeliveryType.dineIn,
          onTap: () => onChanged(_DeliveryType.dineIn),
          isDark: isDark,
        ),
      ),
    ]);
  }
}

// ── انتخابگر حالت حضوری ──
class _DineInModeSelector extends StatelessWidget {
  const _DineInModeSelector(
      {required this.mode, required this.onChanged, required this.isDark});
  final _DineInMode mode;
  final ValueChanged<_DineInMode> onChanged;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
        child: _ModeCard(
          emoji: '🥡',
          label: 'فقط غذا\nمی‌برم',
          isSelected: mode == _DineInMode.takeaway,
          // فقط وقتی رزرو فعاله، این خاکستریه (نه وقتی خودش انتخابه)
          isDisabled: mode == _DineInMode.reserveTable,
          onTap: () => onChanged(_DineInMode.takeaway),
          isDark: isDark,
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: _ModeCard(
          emoji: '🪑',
          label: 'رزرو میز\nو نشستن',
          isSelected: mode == _DineInMode.reserveTable,
          // فقط وقتی takeaway فعاله و این انتخاب نشده، خاکستریه
          isDisabled: mode == _DineInMode.takeaway,
          onTap: () => onChanged(_DineInMode.reserveTable),
          isDark: isDark,
        ),
      ),
    ]);
  }
}

class _TypeCard extends StatelessWidget {
  const _TypeCard({
    required this.emoji, required this.label,
    required this.isSelected, required this.onTap, required this.isDark,
  });
  final String emoji, label;
  final bool isSelected, isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary
              : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary
                : (isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.08)),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 10, offset: const Offset(0, 4))]
              : [],
        ),
        child: Column(children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 6),
          Text(label, style: TextStyle(
            fontSize: 14, fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white
                : (isDark ? AppColors.darkText : AppColors.lightText),
          )),
        ]),
      ),
    );
  }
}

// ── کارت حالت حضوری (با disabled) ──
class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.emoji, required this.label,
    required this.isSelected, required this.isDisabled,
    required this.onTap, required this.isDark,
  });
  final String emoji, label;
  final bool isSelected, isDisabled, isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // ← همیشه قابل کلیکه، isDisabled فقط ظاهره
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isDisabled
              ? (isDark ? Colors.white.withValues(alpha: 0.03)
                        : Colors.black.withValues(alpha: 0.03))
              : (isSelected ? AppColors.primary
                  : (isDark ? AppColors.darkSurface : AppColors.lightSurface)),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDisabled
                ? (isDark ? Colors.white.withValues(alpha: 0.06)
                          : Colors.black.withValues(alpha: 0.04))
                : (isSelected ? AppColors.primary
                    : (isDark ? Colors.white12
                              : Colors.black.withValues(alpha: 0.08))),
            width: 1.5,
          ),
          boxShadow: isSelected && !isDisabled
              ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 10, offset: const Offset(0, 4))]
              : [],
        ),
        child: Opacity(
          opacity: isDisabled ? 0.35 : 1.0,
          child: Column(children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 6),
            Text(label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w700, height: 1.3,
                color: isSelected && !isDisabled ? Colors.white
                    : (isDark ? AppColors.darkText : AppColors.lightText),
              )),
          ]),
        ),
      ),
    );
  }
}

// ── انتخابگر شماره میز (با disabled) ──
class _TableSelector extends StatelessWidget {
  const _TableSelector({
    required this.selectedTable,
    required this.onSelected,
    required this.isDark,
    this.disabled = false,
  });
  final int? selectedTable;
  final ValueChanged<int> onSelected;
  final bool isDark;
  final bool disabled;  // ← جدید

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: disabled ? 0.35 : 1.0,
      child: IgnorePointer(
        ignoring: disabled,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: BorderRadius.circular(14),
            border: disabled
                ? Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.black.withValues(alpha: 0.04),
                  )
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                disabled
                    ? 'برای انتخاب میز، گزینه «رزرو میز» را انتخاب کنید'
                    : 'شماره میز خود را انتخاب کنید:',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(20, (i) {
                  final table = i + 1;
                  final isSelected = selectedTable == table;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : (isDark
                              ? Colors.white.withValues(alpha: 0.07)
                              : Colors.black.withValues(alpha: 0.05)),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : Colors.transparent,
                      ),
                    ),
                    child: GestureDetector(
                      onTap: () => onSelected(table),
                      child: Center(
                        child: Text('$table',
                          style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700,
                            color: isSelected ? Colors.white
                                : (isDark ? AppColors.darkText : AppColors.lightText),
                          )),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── فرم دلیوری ──
class _DeliveryForm extends StatelessWidget {
  const _DeliveryForm({
    required this.addressController, required this.phoneController,
    required this.sameAsUser, required this.onSameAsUserChanged,
    required this.isDark,
  });
  final TextEditingController addressController, phoneController;
  final bool sameAsUser, isDark;
  final ValueChanged<bool?> onSameAsUserChanged;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      _InputField(
        controller: addressController,
        hint: 'آدرس کامل (خیابان، کوچه، پلاک...)',
        icon: Icons.location_on_rounded,
        isDark: isDark,
        maxLines: 2,
      ),
      const SizedBox(height: 12),
      GestureDetector(
        onTap: () => onSameAsUserChanged(!sameAsUser),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: sameAsUser ? AppColors.primary
                  : (isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.08)),
            ),
          ),
          child: Row(children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22, height: 22,
              decoration: BoxDecoration(
                color: sameAsUser ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                    color: sameAsUser ? AppColors.primary : Colors.grey, width: 2),
              ),
              child: sameAsUser
                  ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
                  : null,
            ),
            const SizedBox(width: 10),
            Text('گیرنده خودمم — شماره لازم نیست',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppColors.darkText : AppColors.lightText,
                )),
          ]),
        ),
      ),
      if (!sameAsUser) ...[
        const SizedBox(height: 12),
        _InputField(
          controller: phoneController,
          hint: 'شماره تلفن گیرنده',
          icon: Icons.phone_rounded,
          isDark: isDark,
          keyboardType: TextInputType.phone,
        ),
      ],
    ]);
  }
}

// ── پیکر آدرس ذخیره‌شده ──
class _SavedAddressPicker extends StatelessWidget {
  const _SavedAddressPicker(
      {required this.selected, required this.isDark, required this.onPick});
  final AddressModel? selected;
  final bool isDark;
  final ValueChanged<AddressModel> onPick;

  @override
  Widget build(BuildContext context) {
    final provider = context.read<AddressProvider>();
    if (provider.isEmpty) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => ChangeNotifierProvider.value(
          value: provider,
          child: AddressSelectorSheet(onSelected: onPick),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected != null ? AppColors.primary
                : (isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.08)),
          ),
        ),
        child: Row(children: [
          Icon(Icons.location_on_rounded,
              color: selected != null ? AppColors.primary : Colors.grey, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              selected?.fullAddress ?? 'انتخاب از آدرس‌های ذخیره‌شده',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                color: selected != null
                    ? (isDark ? AppColors.darkText : AppColors.lightText)
                    : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
              ),
            ),
          ),
          Icon(Icons.arrow_drop_down_rounded,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
        ]),
      ),
    );
  }
}

// ── فیلد ورودی ──
class _InputField extends StatelessWidget {
  const _InputField({
    required this.controller, required this.hint,
    required this.icon, required this.isDark,
    this.maxLines = 1, this.keyboardType,
  });
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool isDark;
  final int maxLines;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      textDirection: TextDirection.rtl,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          fontSize: 13,
          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
        ),
        prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
        filled: true,
        fillColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }
}

// ── خلاصه سفارش ──
class _OrderSummary extends StatelessWidget {
  const _OrderSummary({
    required this.cart, required this.isDark, required this.formatPrice,
    required this.isDelivery, required this.deliveryFee, required this.total,
  });
  final CartProvider cart;
  final bool isDark, isDelivery;
  final String Function(int) formatPrice;
  final int deliveryFee, total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(children: [
        _Row(label: 'تعداد آیتم‌ها', value: '${cart.itemCount} عدد', isDark: isDark),
        const SizedBox(height: 8),
        _Row(label: 'جمع سفارش', value: formatPrice(cart.totalPrice), isDark: isDark),
        if (isDelivery) ...[
          const SizedBox(height: 8),
          _Row(label: 'هزینه ارسال', value: formatPrice(deliveryFee), isDark: isDark),
        ],
        Divider(height: 20,
            color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.08)),
        _Row(label: 'مبلغ نهایی', value: formatPrice(total), isDark: isDark, isBold: true),
      ]),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.label, required this.value,
    required this.isDark, this.isBold = false,
  });
  final String label, value;
  final bool isDark, isBold;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Text(label, style: TextStyle(
        fontSize: isBold ? 14 : 13,
        fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
        color: isBold ? (isDark ? AppColors.darkText : AppColors.lightText)
            : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
      )),
      const Spacer(),
      Text(value, style: TextStyle(
        fontSize: isBold ? 16 : 13,
        fontWeight: isBold ? FontWeight.w900 : FontWeight.w600,
        color: isBold ? AppColors.primary
            : (isDark ? AppColors.darkText : AppColors.lightText),
      )),
    ]);
  }
}

// ── دکمه پرداخت ──
class _PayButton extends StatelessWidget {
  const _PayButton({
    required this.total, required this.isDark,
    required this.formatPrice, required this.onPay,
  });
  final int total;
  final bool isDark;
  final String Function(int) formatPrice;
  final VoidCallback onPay;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        boxShadow: [BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
          blurRadius: 16, offset: const Offset(0, -4),
        )],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: onPay,
          icon: const Icon(Icons.payment_rounded, size: 20),
          label: Text('پرداخت  —  ${formatPrice(total)}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 15),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ),
    );
  }
}