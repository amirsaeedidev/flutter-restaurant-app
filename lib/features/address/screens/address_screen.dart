import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/model/address_model.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/address_provider.dart';

class AddressScreen extends StatelessWidget {
  const AddressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<AddressProvider>();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
            isDark ? AppColors.darkBackground : AppColors.lightBackground,
        appBar: AppBar(
          backgroundColor:
              isDark ? AppColors.darkBackground : AppColors.lightBackground,
          elevation: 0,
          title: Text('آدرس‌های من',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: isDark ? AppColors.darkText : AppColors.lightText,
              )),
          leading: IconButton(
            icon: Icon(Icons.arrow_forward_rounded,
                color: isDark ? AppColors.darkText : AppColors.lightText),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            TextButton.icon(
              onPressed: () => _showAddressSheet(context, null),
              icon: const Icon(Icons.add_rounded,
                  color: AppColors.primary, size: 20),
              label: const Text('جدید',
                  style: TextStyle(
                      color: AppColors.primary, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
        body: !provider.loaded
            ? const Center(child: CircularProgressIndicator())
            : provider.isEmpty
                ? _EmptyState(isDark: isDark)
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    itemCount: provider.addresses.length,
                    itemBuilder: (_, i) => _AddressCard(
                      address: provider.addresses[i],
                      isDark: isDark,
                      onEdit: () => _showAddressSheet(
                          context, provider.addresses[i]),
                      onDelete: () => _confirmDelete(
                          context, provider, provider.addresses[i]),
                      onSetDefault: () =>
                          provider.setDefault(provider.addresses[i].id),
                    ),
                  ),
        floatingActionButton: provider.isEmpty
            ? null
            : FloatingActionButton.extended(
                onPressed: () => _showAddressSheet(context, null),
                backgroundColor: AppColors.primary,
                icon: const Icon(Icons.add_rounded, color: Colors.white),
                label: const Text('افزودن آدرس',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w700)),
              ),
      ),
    );
  }

  void _showAddressSheet(BuildContext context, AddressModel? existing) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<AddressProvider>(),
        child: AddressFormSheet(existing: existing),
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, AddressProvider p, AddressModel a) {
    showDialog(
      context: context,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('حذف آدرس'),
          content: Text('«${a.title}» حذف بشه؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('انصراف'),
            ),
            ElevatedButton(
              onPressed: () {
                p.remove(a.id);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('حذف'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── کارت آدرس ──
class _AddressCard extends StatelessWidget {
  const _AddressCard({
    required this.address,
    required this.isDark,
    required this.onEdit,
    required this.onDelete,
    required this.onSetDefault,
  });
  final AddressModel address;
  final bool isDark;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onSetDefault;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: address.isDefault
            ? Border.all(
                color: AppColors.primary.withValues(alpha: 0.5), width: 1.5)
            : null,
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
          // ── هدر ──
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: Row(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.location_on_rounded,
                      color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(address.title,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: isDark
                                    ? AppColors.darkText
                                    : AppColors.lightText,
                              )),
                          if (address.isDefault) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color:
                                    AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text('پیش‌فرض',
                                  style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary)),
                            ),
                          ],
                        ],
                      ),
                      if (address.phone != null) ...[
                        const SizedBox(height: 2),
                        Text(address.phone!,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            )),
                      ],
                    ],
                  ),
                ),
                // منوی سه‌نقطه
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert_rounded,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  onSelected: (v) {
                    if (v == 'edit') onEdit();
                    if (v == 'delete') onDelete();
                    if (v == 'default') onSetDefault();
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(children: [
                        Icon(Icons.edit_rounded, size: 18),
                        SizedBox(width: 8),
                        Text('ویرایش'),
                      ]),
                    ),
                    if (!address.isDefault)
                      const PopupMenuItem(
                        value: 'default',
                        child: Row(children: [
                          Icon(Icons.check_circle_outline_rounded,
                              size: 18, color: AppColors.primary),
                          SizedBox(width: 8),
                          Text('پیش‌فرض کن'),
                        ]),
                      ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(children: [
                        Icon(Icons.delete_outline_rounded,
                            size: 18, color: Colors.red),
                        SizedBox(width: 8),
                        Text('حذف',
                            style: TextStyle(color: Colors.red)),
                      ]),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // ── آدرس کامل ──
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
            child: Text(
              address.addressLine,
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── حالت خالی ──
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('📍', style: TextStyle(fontSize: 60)),
          const SizedBox(height: 16),
          Text('آدرسی ثبت نشده',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.darkText : AppColors.lightText,
              )),
          const SizedBox(height: 8),
          Text('اولین آدرس خودت رو اضافه کن',
              style: TextStyle(
                fontSize: 14,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              )),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => ChangeNotifierProvider.value(
                  value: context.read<AddressProvider>(),
                  child: const AddressFormSheet(existing: null),
                ),
              );
            },
            icon: const Icon(Icons.add_rounded),
            label: const Text('افزودن آدرس'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── فرم افزودن / ویرایش آدرس ──
class AddressFormSheet extends StatefulWidget {
  const AddressFormSheet({super.key, required this.existing});
  final AddressModel? existing;

  @override
  State<AddressFormSheet> createState() => _AddressFormSheetState();
}

class _AddressFormSheetState extends State<AddressFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _phoneCtrl;

  final _titles = ['خونه', 'محل کار', 'منزل والدین', 'دیگر'];
  late String _selectedTitle;

  @override
  void initState() {
    super.initState();
    _selectedTitle =
        widget.existing?.title ?? _titles[0];
    _titleCtrl = TextEditingController(
        text: widget.existing?.title ?? '');
    _addressCtrl = TextEditingController(
        text: widget.existing?.addressLine ?? '');
    _phoneCtrl = TextEditingController(
        text: widget.existing?.phone ?? '');
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<AddressProvider>();
    final address = AddressModel(
      id: widget.existing?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      title: _selectedTitle == 'دیگر'
          ? (_titleCtrl.text.trim().isNotEmpty
              ? _titleCtrl.text.trim()
              : 'آدرس من')
          : _selectedTitle,
      addressLine: _addressCtrl.text.trim(),
      phone: _phoneCtrl.text.trim().isNotEmpty
          ? _phoneCtrl.text.trim()
          : null,
      isDefault: widget.existing?.isDefault ?? false,
    );
    if (widget.existing == null) {
      await provider.add(address);
    } else {
      await provider.update(address);
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottom),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Form(
          key: _formKey,
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

              Text(
                widget.existing == null
                    ? 'افزودن آدرس جدید'
                    : 'ویرایش آدرس',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.darkText : AppColors.lightText,
                ),
              ),
              const SizedBox(height: 20),

              // ── انتخاب نوع آدرس ──
              Text('نوع آدرس',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  )),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _titles.map((t) {
                  final sel = _selectedTitle == t;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedTitle = t),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: sel
                            ? AppColors.primary
                            : (isDark
                                ? Colors.white.withValues(alpha: 0.07)
                                : Colors.black.withValues(alpha: 0.05)),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: sel
                              ? AppColors.primary
                              : Colors.transparent,
                        ),
                      ),
                      child: Text(t,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: sel
                                ? Colors.white
                                : (isDark
                                    ? AppColors.darkText
                                    : AppColors.lightText),
                          )),
                    ),
                  );
                }).toList(),
              ),

              // فیلد اسم دلخواه اگه «دیگر» انتخاب شد
              if (_selectedTitle == 'دیگر') ...[
                const SizedBox(height: 12),
                _FormField(
                  controller: _titleCtrl,
                  hint: 'مثلاً: خونه دوست',
                  isDark: isDark,
                ),
              ],

              const SizedBox(height: 16),

              // ── آدرس کامل ──
              Text('آدرس کامل',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  )),
              const SizedBox(height: 8),
              TextFormField(
                controller: _addressCtrl,
                maxLines: 3,
                textDirection: TextDirection.rtl,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'آدرس را وارد کنید'
                    : null,
                style: TextStyle(
                  fontSize: 14,
                  color:
                      isDark ? AppColors.darkText : AppColors.lightText,
                ),
                decoration: _inputDeco(
                  'خیابان، کوچه، پلاک، واحد...',
                  isDark,
                  Icons.location_on_rounded,
                ),
              ),

              const SizedBox(height: 12),

              // ── شماره تلفن ──
              Text('شماره تلفن گیرنده (اختیاری)',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  )),
              const SizedBox(height: 8),
              TextFormField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                textDirection: TextDirection.ltr,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 14,
                  color:
                      isDark ? AppColors.darkText : AppColors.lightText,
                ),
                decoration: _inputDeco(
                  '09xxxxxxxxx',
                  isDark,
                  Icons.phone_rounded,
                ),
              ),

              const SizedBox(height: 24),

              // دکمه ذخیره
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(
                    widget.existing == null ? 'افزودن آدرس' : 'ذخیره',
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDeco(
      String hint, bool isDark, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: isDark
            ? AppColors.darkTextSecondary
            : AppColors.lightTextSecondary,
      ),
      prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
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
        borderSide:
            const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }
}

class _FormField extends StatelessWidget {
  const _FormField({
    required this.controller,
    required this.hint,
    required this.isDark,
  });
  final TextEditingController controller;
  final String hint;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textDirection: TextDirection.rtl,
      style: TextStyle(
          fontSize: 14,
          color: isDark ? AppColors.darkText : AppColors.lightText),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
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
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      ),
    );
  }
}