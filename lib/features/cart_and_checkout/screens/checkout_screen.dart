import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/model/address_model.dart';
import '../../../core/model/order_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../address/providers/address_provider.dart';
import '../../address/widgets/address_selector_sheet.dart';
import '../../cart_and_checkout/providers/cart_provider.dart';
import '../../loyalty/providers/loyalty_provider.dart';
import '../../orders/providers/orders_provider.dart';
import '../../orders/screens/recent_orders_screen.dart';

enum _DeliveryType { delivery, dineIn }

enum _DineInMode { takeaway, reserveTable }

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key, required this.orderNote});
  final String orderNote;

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  // ── نوع سفارش ──
  _DeliveryType _type = _DeliveryType.delivery;
  _DineInMode _dineInMode = _DineInMode.takeaway;

  // ── دلیوری ──
  AddressModel? _selectedAddress;
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _sameAsUser = false;

  // ── حضوری ──
  int? _selectedTable;

  // ── تخفیف ──
  final _discountController = TextEditingController();
  String? _appliedDiscountCode;
  int _discountAmount = 0;
  String? _discountError;
  bool _isApplyingDiscount = false;

  @override
  void dispose() {
    _discountController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  bool get _isReserving => _dineInMode == _DineInMode.reserveTable;

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

  Future<void> _applyDiscount() async {
    final code = _discountController.text.trim().toUpperCase();
    if (code.isEmpty) return;

    setState(() {
      _isApplyingDiscount = true;
      _discountError = null;
    });

    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    final cart = context.read<CartProvider>();

    if (code == 'WELCOME20') {
      setState(() {
        _appliedDiscountCode = code;
        _discountAmount = (cart.totalPrice * 0.2).round();
        _discountError = null;
        _isApplyingDiscount = false;
      });
    } else if (code == 'FREESHIP') {
      setState(() {
        _appliedDiscountCode = code;
        _discountAmount = 15000;
        _discountError = null;
        _isApplyingDiscount = false;
      });
    } else {
      setState(() {
        _appliedDiscountCode = null;
        _discountAmount = 0;
        _discountError = 'کد تخفیف معتبر نیست';
        _isApplyingDiscount = false;
      });
    }
  }

  void _removeDiscount() {
    setState(() {
      _appliedDiscountCode = null;
      _discountAmount = 0;
      _discountError = null;
      _discountController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cart = context.watch<CartProvider>();
    const deliveryFee = 15000;

    final total =
        cart.totalPrice +
        (_type == _DeliveryType.delivery ? deliveryFee : 0) -
        _discountAmount;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
            isDark ? AppColors.darkBackground : AppColors.lightBackground,
        appBar: AppBar(
          backgroundColor:
              isDark ? AppColors.darkBackground : AppColors.lightBackground,
          elevation: 0,
          title: Text(
            'تکمیل سفارش',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: isDark ? AppColors.darkText : AppColors.lightText,
            ),
          ),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_forward_rounded,
              color: isDark ? AppColors.darkText : AppColors.lightText,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
          children: [
            _SectionTitle(title: 'نوع سفارش', isDark: isDark),
            const SizedBox(height: 10),
            _DeliveryTypeSelector(
              selected: _type,
              onChanged: (t) => setState(() => _type = t),
              isDark: isDark,
            ),
            const SizedBox(height: 20),

            if (_type == _DeliveryType.delivery) ...[
              _SectionTitle(title: 'اطلاعات تحویل', isDark: isDark),
              const SizedBox(height: 10),
              _SavedAddressPicker(
                selected: _selectedAddress,
                isDark: isDark,
                onPick: (addr) => setState(() {
                  _selectedAddress = addr;
                  _addressController.text = addr.addressLine;
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
              _SectionTitle(title: 'نحوه دریافت', isDark: isDark),
              const SizedBox(height: 10),
              _DineInModeSelector(
                mode: _dineInMode,
                onChanged: (m) => setState(() {
                  _dineInMode = m;
                  if (m == _DineInMode.takeaway) _selectedTable = null;
                }),
                isDark: isDark,
              ),
              const SizedBox(height: 16),
              _SectionTitle(title: 'انتخاب میز', isDark: isDark),
              const SizedBox(height: 10),
              _TableSelector(
                selectedTable: _selectedTable,
                onSelected: (t) {
                  if (_isReserving) setState(() => _selectedTable = t);
                },
                isDark: isDark,
                disabled: !_isReserving,
              ),
            ],

            const SizedBox(height: 20),

            _SectionTitle(title: 'کد تخفیف', isDark: isDark),
            const SizedBox(height: 10),
            _DiscountBox(
              controller: _discountController,
              isDark: isDark,
              appliedCode: _appliedDiscountCode,
              discountError: _discountError,
              isLoading: _isApplyingDiscount,
              onApply: _applyDiscount,
              onRemove: _removeDiscount,
            ),

            const SizedBox(height: 20),

            _SectionTitle(title: 'خلاصه پرداخت', isDark: isDark),
            const SizedBox(height: 10),
            _OrderSummary(
              cart: cart,
              isDark: isDark,
              formatPrice: _format,
              isDelivery: _type == _DeliveryType.delivery,
              deliveryFee: deliveryFee,
              discountAmount: _discountAmount,
              total: total,
            ),
          ],
        ),
        bottomNavigationBar: _PayButton(
          total: total,
          isDark: isDark,
          formatPrice: _format,
          onPay: () => _handlePayment(context, total),
        ),
      ),
    );
  }

  bool _validate() {
    if (_type == _DeliveryType.delivery) {
      if (_addressController.text.trim().isEmpty) {
        _showError('آدرس را وارد کنید');
        return false;
      }
      if (!_sameAsUser && _phoneController.text.trim().isEmpty) {
        _showError('شماره تلفن گیرنده را وارد کنید');
        return false;
      }
    } else {
      if (_isReserving && _selectedTable == null) {
        _showError('شماره میز را انتخاب کنید');
        return false;
      }
    }
    return true;
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
      ),
    );
  }

  void _handlePayment(BuildContext context, int total) {
    if (!_validate()) return;
    _showPaymentDialog(context, total);
  }

  void _showPaymentDialog(BuildContext context, int total) {
    final cart = context.read<CartProvider>();
    final ordersProvider = context.read<OrdersProvider>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              const Text('💳', style: TextStyle(fontSize: 52)),
              const SizedBox(height: 16),
              const Text(
                'در حال اتصال به درگاه...',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                'این یه پرداخت آزمایشیه',
                style: TextStyle(fontSize: 13, color: Colors.grey[500]),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final newOrder = OrderModel(
                    id: '',
                    orderCode: '',
                    items: const [],
                    totalPrice: total,
                    status: OrderStatus.pending,
                    type: _type == _DeliveryType.delivery ? OrderType.delivery : OrderType.dineIn,
                    createdAt: DateTime.now(),
                    estimatedDelivery: DateTime.now().add(const Duration(minutes: 45)),
                    address: _type == _DeliveryType.delivery ? _addressController.text : null,
                    tableNumber: _type == _DeliveryType.dineIn ? _selectedTable : null,
                    note: widget.orderNote,
                  );

                  final success = await ordersProvider.placeOrder(newOrder, cart.items);

                  if (success && context.mounted) {
                    cart.clearCart();
                    await context.read<LoyaltyProvider>().addPointsForOrder(total);
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const RecentOrdersScreen()),
                      (route) => route.isFirst,
                    );
                  } else if (context.mounted) {
                    Navigator.pop(context);
                    _showError('خطا در ثبت سفارش. دوباره تلاش کنید.');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'پرداخت موفق ✅',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.isDark});
  final String title;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w800,
        color: isDark ? AppColors.darkText : AppColors.lightText,
      ),
    );
  }
}

class _DeliveryTypeSelector extends StatelessWidget {
  const _DeliveryTypeSelector({
    required this.selected,
    required this.onChanged,
    required this.isDark,
  });
  final _DeliveryType selected;
  final ValueChanged<_DeliveryType> onChanged;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _TypeCard(
            emoji: '🛵',
            label: 'دلیوری',
            isSelected: selected == _DeliveryType.delivery,
            onTap: () => onChanged(_DeliveryType.delivery),
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _TypeCard(
            emoji: '🍽️',
            label: 'حضوری',
            isSelected: selected == _DeliveryType.dineIn,
            onTap: () => onChanged(_DeliveryType.dineIn),
            isDark: isDark,
          ),
        ),
      ],
    );
  }
}

class _TypeCard extends StatelessWidget {
  const _TypeCard({
    required this.emoji,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
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
          color: isSelected
              ? AppColors.primary
              : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark
                    ? Colors.white12
                    : Colors.black.withValues(alpha: 0.08)),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isSelected
                    ? Colors.white
                    : (isDark ? AppColors.darkText : AppColors.lightText),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DineInModeSelector extends StatelessWidget {
  const _DineInModeSelector({
    required this.mode,
    required this.onChanged,
    required this.isDark,
  });
  final _DineInMode mode;
  final ValueChanged<_DineInMode> onChanged;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ModeCard(
            emoji: '🥡',
            label: 'فقط غذا\nمی‌برم',
            isSelected: mode == _DineInMode.takeaway,
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
            isDisabled: mode == _DineInMode.takeaway,
            onTap: () => onChanged(_DineInMode.reserveTable),
            isDark: isDark,
          ),
        ),
      ],
    );
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.emoji,
    required this.label,
    required this.isSelected,
    required this.isDisabled,
    required this.onTap,
    required this.isDark,
  });
  final String emoji, label;
  final bool isSelected, isDisabled, isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isDisabled
              ? (isDark
                  ? Colors.white.withValues(alpha: 0.03)
                  : Colors.black.withValues(alpha: 0.03))
              : (isSelected
                  ? AppColors.primary
                  : (isDark
                      ? AppColors.darkSurface
                      : AppColors.lightSurface)),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDisabled
                ? (isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.black.withValues(alpha: 0.04))
                : (isSelected
                    ? AppColors.primary
                    : (isDark
                        ? Colors.white12
                        : Colors.black.withValues(alpha: 0.08))),
            width: 1.5,
          ),
          boxShadow: isSelected && !isDisabled
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Opacity(
          opacity: isDisabled ? 0.35 : 1.0,
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                  color: isSelected && !isDisabled
                      ? Colors.white
                      : (isDark ? AppColors.darkText : AppColors.lightText),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
  final bool disabled;

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
                  return GestureDetector(
                    onTap: () => onSelected(table),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : (isDark
                                ? Colors.white.withValues(alpha: 0.07)
                                : Colors.black.withValues(alpha: 0.05)),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : Colors.transparent,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '$table',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: isSelected
                                ? Colors.white
                                : (isDark
                                    ? AppColors.darkText
                                    : AppColors.lightText),
                          ),
                        ),
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

class _DeliveryForm extends StatefulWidget {
  const _DeliveryForm({
    required this.addressController,
    required this.phoneController,
    required this.sameAsUser,
    required this.onSameAsUserChanged,
    required this.isDark,
  });
  final TextEditingController addressController;
  final TextEditingController phoneController;
  final bool sameAsUser;
  final ValueChanged<bool?> onSameAsUserChanged;
  final bool isDark;

  @override
  State<_DeliveryForm> createState() => _DeliveryFormState();
}

class _DeliveryFormState extends State<_DeliveryForm> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: widget.addressController,
          maxLines: 2,
          textDirection: TextDirection.rtl,
          decoration: _inputDeco(
            'آدرس کامل (خیابان، کوچه، پلاک...)',
            Icons.location_on_rounded,
            widget.isDark,
          ),
        ),

        const SizedBox(height: 12),

        GestureDetector(
          onTap: () => widget.onSameAsUserChanged(!widget.sameAsUser),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: widget.isDark
                  ? AppColors.darkSurface
                  : AppColors.lightSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: widget.sameAsUser
                    ? AppColors.primary
                    : (widget.isDark
                        ? Colors.white12
                        : Colors.black.withValues(alpha: 0.08)),
              ),
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: widget.sameAsUser
                        ? AppColors.primary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: widget.sameAsUser
                          ? AppColors.primary
                          : Colors.grey,
                      width: 2,
                    ),
                  ),
                  child: widget.sameAsUser
                      ? const Icon(Icons.check_rounded,
                          color: Colors.white, size: 14)
                      : null,
                ),
                const SizedBox(width: 10),
                Text(
                  'گیرنده خودمم — شماره لازم نیست',
                  style: TextStyle(
                    fontSize: 13,
                    color: widget.isDark
                        ? AppColors.darkText
                        : AppColors.lightText,
                  ),
                ),
              ],
            ),
          ),
        ),

        if (!widget.sameAsUser) ...[
          const SizedBox(height: 12),
          TextField(
            controller: widget.phoneController,
            keyboardType: TextInputType.phone,
            textDirection: TextDirection.ltr,
            decoration: _inputDeco(
              'شماره تلفن گیرنده',
              Icons.phone_rounded,
              widget.isDark,
            ),
          ),
        ],
      ],
    );
  }

  InputDecoration _inputDeco(String hint, IconData icon, bool isDark) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        fontSize: 13,
        color: isDark
            ? AppColors.darkTextSecondary
            : AppColors.lightTextSecondary,
      ),
      prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
      filled: true,
      fillColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDark
              ? Colors.white12
              : Colors.black.withValues(alpha: 0.08),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }
}

class _SavedAddressPicker extends StatelessWidget {
  const _SavedAddressPicker({
    required this.selected,
    required this.isDark,
    required this.onPick,
  });
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
            color: selected != null
                ? AppColors.primary
                : (isDark
                    ? Colors.white12
                    : Colors.black.withValues(alpha: 0.08)),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.location_on_rounded,
              color: selected != null ? AppColors.primary : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                selected?.addressLine ?? 'انتخاب از آدرس‌های ذخیره‌شده',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  color: selected != null
                      ? (isDark ? AppColors.darkText : AppColors.lightText)
                      : (isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary),
                ),
              ),
            ),
            Icon(
              Icons.arrow_drop_down_rounded,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _DiscountBox extends StatefulWidget {
  const _DiscountBox({
    required this.controller,
    required this.isDark,
    required this.onApply,
    required this.onRemove,
    this.appliedCode,
    this.discountError,
    this.isLoading = false,
  });

  final TextEditingController controller;
  final bool isDark;
  final VoidCallback onApply;
  final VoidCallback onRemove;
  final String? appliedCode;
  final String? discountError;
  final bool isLoading;

  @override
  State<_DiscountBox> createState() => _DiscountBoxState();
}

class _DiscountBoxState extends State<_DiscountBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _shakeCtrl;
  late Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
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
  void didUpdateWidget(_DiscountBox old) {
    super.didUpdateWidget(old);
    if (widget.discountError != null &&
        widget.discountError != old.discountError) {
      _shakeCtrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: widget.appliedCode != null
                ? Colors.green.withValues(alpha: 0.5)
                : widget.discountError != null
                    ? Colors.red.withValues(alpha: 0.4)
                    : (widget.isDark
                        ? Colors.white12
                        : Colors.black.withValues(alpha: 0.07)),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('🏷️', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 6),
                Text(
                  'کد تخفیف دارم',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: widget.isDark
                        ? AppColors.darkText
                        : AppColors.lightText,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            if (widget.appliedCode != null)
              _AppliedChip(
                code: widget.appliedCode!,
                isDark: widget.isDark,
                onRemove: widget.onRemove,
              )
            else
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: widget.controller,
                      textDirection: TextDirection.ltr,
                      textCapitalization: TextCapitalization.characters,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                        color: widget.discountError != null
                            ? Colors.red
                            : (widget.isDark
                                ? AppColors.darkText
                                : AppColors.lightText),
                      ),
                      onChanged: (_) {},
                      onSubmitted: (_) => widget.onApply(),
                      decoration: InputDecoration(
                        hintText: 'کد تخفیف',
                        hintStyle: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0,
                          color: widget.isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                        filled: true,
                        fillColor: widget.isDark
                            ? Colors.white.withValues(alpha: 0.06)
                            : Colors.black.withValues(alpha: 0.04),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: widget.discountError != null
                                ? Colors.red
                                : AppColors.primary,
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
                      onPressed: widget.isLoading ? null : widget.onApply,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding:
                            const EdgeInsets.symmetric(horizontal: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: widget.isLoading
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
              ),

            if (widget.discountError != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    color: Colors.red,
                    size: 14,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    widget.discountError!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AppliedChip extends StatelessWidget {
  const _AppliedChip({
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
        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded,
              color: Colors.green, size: 18),
          const SizedBox(width: 8),
          Text(
            code,
            style: const TextStyle(
              fontSize: 14,
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
              child: const Icon(Icons.close_rounded,
                  size: 16, color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderSummary extends StatelessWidget {
  const _OrderSummary({
    required this.cart,
    required this.isDark,
    required this.formatPrice,
    required this.isDelivery,
    required this.deliveryFee,
    required this.discountAmount,
    required this.total,
  });
  final CartProvider cart;
  final bool isDark, isDelivery;
  final String Function(int) formatPrice;
  final int deliveryFee, discountAmount, total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          _SummaryRow(
            label: 'تعداد آیتم‌ها',
            value: '${cart.itemCount} عدد',
            isDark: isDark,
          ),
          const SizedBox(height: 8),
          _SummaryRow(
            label: 'جمع سفارش',
            value: formatPrice(cart.totalPrice),
            isDark: isDark,
          ),
          if (isDelivery) ...[
            const SizedBox(height: 8),
            _SummaryRow(
              label: 'هزینه ارسال',
              value: formatPrice(deliveryFee),
              isDark: isDark,
            ),
          ],
          if (discountAmount > 0) ...[
            const SizedBox(height: 8),
            _SummaryRow(
              label: 'تخفیف',
              value: '− ${formatPrice(discountAmount)}',
              isDark: isDark,
              valueColor: Colors.green,
            ),
          ],
          Divider(
            height: 20,
            color: isDark
                ? Colors.white12
                : Colors.black.withValues(alpha: 0.08),
          ),
          _SummaryRow(
            label: 'مبلغ نهایی',
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
    this.valueColor,
  });
  final String label, value;
  final bool isDark, isBold;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final defaultColor =
        isBold ? AppColors.primary : (isDark ? AppColors.darkText : AppColors.lightText);

    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 14 : 13,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
            color: isBold
                ? (isDark ? AppColors.darkText : AppColors.lightText)
                : (isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary),
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 16 : 13,
            fontWeight: isBold ? FontWeight.w900 : FontWeight.w600,
            color: valueColor ?? defaultColor,
          ),
        ),
      ],
    );
  }
}

class _PayButton extends StatelessWidget {
  const _PayButton({
    required this.total,
    required this.isDark,
    required this.formatPrice,
    required this.onPay,
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
        child: ElevatedButton.icon(
          onPressed: onPay,
          icon: const Icon(Icons.payment_rounded, size: 20),
          label: Text(
            'پرداخت  —  ${formatPrice(total)}',
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.w800),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 15),
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ),
    );
  }
}