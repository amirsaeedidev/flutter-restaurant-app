import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/model/discount_model.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/discount_provider.dart';

class DiscountScreen extends StatefulWidget {
  /// userId برای لود کدهای کاربر لازم است.
  /// cartTotal فقط وقتی این صفحه از داخل checkout باز می‌شود معنی دارد؛
  /// برای مرور ساده می‌توانی 0 بفرستی.
  const DiscountScreen({
    super.key,
    required this.userId,
    this.cartTotal = 0,
  });

  final String userId;
  final int cartTotal;

  @override
  State<DiscountScreen> createState() => _DiscountScreenState();
}

class _DiscountScreenState extends State<DiscountScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;
  final _codeCtrl = TextEditingController();
  String? _applyError;
  bool _applySuccess = false;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    // لود تخفیف‌ها بعد از اولین فریم (جلوگیری از notifyListeners حین build)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DiscountProvider>().loadDiscounts(widget.userId);
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _applyCode() async {
    final code = _codeCtrl.text.trim();
    if (code.isEmpty) return;

    final provider = context.read<DiscountProvider>();
    await provider.applyCode(
      code: code,
      cartTotal: widget.cartTotal,
      userId: widget.userId,
    );

    if (!mounted) return;

    final error = provider.applyError;
    setState(() {
      _applyError = error;
      _applySuccess = error == null && provider.hasDiscount;
    });

    if (_applySuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('کد تخفیف اعمال شد ✅'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
        ),
      );
    }
  }

  Future<void> _refresh() =>
      context.read<DiscountProvider>().reload(widget.userId);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<DiscountProvider>();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
            isDark ? AppColors.darkBackground : AppColors.lightBackground,
        appBar: AppBar(
          backgroundColor:
              isDark ? AppColors.darkBackground : AppColors.lightBackground,
          elevation: 0,
          title: Text('تخفیفات',
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
          bottom: TabBar(
            controller: _tabCtrl,
            labelColor: AppColors.primary,
            unselectedLabelColor: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            labelStyle:
                const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            tabs: [
              Tab(text: 'فعال (${provider.active.length})'),
              Tab(text: 'استفاده‌شده'),
            ],
          ),
        ),
        body: Column(
          children: [
            _ManualCodeField(
              controller: _codeCtrl,
              error: _applyError,
              success: _applySuccess,
              isDark: isDark,
              onApply: _applyCode,
              onChanged: (_) => setState(() {
                _applyError = null;
                _applySuccess = false;
              }),
            ),
            Expanded(child: _buildBody(provider, isDark)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(DiscountProvider provider, bool isDark) {
    // حالت لودینگ
    if (provider.isLoading && provider.all.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    // حالت خطا
    if (provider.loadState == DiscountLoadState.error && provider.all.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text('خطا در دریافت تخفیف‌ها',
                style: TextStyle(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary)),
            const SizedBox(height: 12),
            ElevatedButton(
                onPressed: _refresh, child: const Text('تلاش دوباره')),
          ],
        ),
      );
    }
    // محتوا
    return TabBarView(
      controller: _tabCtrl,
      children: [
        RefreshIndicator(
          onRefresh: _refresh,
          child: _DiscountList(
            discounts: provider.active,
            isDark: isDark,
            emptyText: 'کد تخفیف فعالی نداری',
            emptyEmoji: '🏷️',
          ),
        ),
        RefreshIndicator(
          onRefresh: _refresh,
          child: _DiscountList(
            discounts: provider.usedOrExpired,
            isDark: isDark,
            emptyText: 'هیچ کدی استفاده نشده',
            emptyEmoji: '📋',
          ),
        ),
      ],
    );
  }
}

// ───────────────────────── فیلد ورود کد دستی ─────────────────────────
class _ManualCodeField extends StatelessWidget {
  const _ManualCodeField({
    required this.controller,
    required this.error,
    required this.success,
    required this.isDark,
    required this.onApply,
    required this.onChanged,
  });
  final TextEditingController controller;
  final String? error;
  final bool success;
  final bool isDark;
  final VoidCallback onApply;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('کد تخفیف دارم',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkText : AppColors.lightText,
              )),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  onChanged: onChanged,
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.center,
                  textCapitalization: TextCapitalization.characters,
                  onSubmitted: (_) => onApply(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                    color: success
                        ? Colors.green
                        : (error != null
                            ? Colors.red
                            : (isDark
                                ? AppColors.darkText
                                : AppColors.lightText)),
                  ),
                  decoration: InputDecoration(
                    hintText: 'کد تخفیف',
                    hintStyle: TextStyle(
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
                        color: success
                            ? Colors.green
                            : (error != null
                                ? Colors.red
                                : AppColors.primary),
                        width: 1.5,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: onApply,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('اعمال',
                    style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          if (error != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.error_outline_rounded,
                    color: Colors.red, size: 14),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(error!,
                      style: const TextStyle(
                          color: Colors.red, fontSize: 12)),
                ),
              ],
            ),
          ],
          if (success) ...[
            const SizedBox(height: 6),
            const Row(
              children: [
                Icon(Icons.check_circle_outline_rounded,
                    color: Colors.green, size: 14),
                SizedBox(width: 4),
                Text('کد با موفقیت اعمال شد',
                    style: TextStyle(color: Colors.green, fontSize: 12)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ───────────────────────── لیست تخفیف‌ها ─────────────────────────
class _DiscountList extends StatelessWidget {
  const _DiscountList({
    required this.discounts,
    required this.isDark,
    required this.emptyText,
    required this.emptyEmoji,
  });
  final List<DiscountModel> discounts;
  final bool isDark;
  final String emptyText;
  final String emptyEmoji;

  @override
  Widget build(BuildContext context) {
    if (discounts.isEmpty) {
      // ListView لازم است تا RefreshIndicator حتی در حالت خالی کار کند
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(emptyEmoji, style: const TextStyle(fontSize: 52)),
                  const SizedBox(height: 12),
                  Text(emptyText,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      )),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
      itemCount: discounts.length,
      itemBuilder: (_, i) =>
          _DiscountCard(discount: discounts[i], isDark: isDark),
    );
  }
}

// ───────────────────────── کارت تخفیف ─────────────────────────
class _DiscountCard extends StatelessWidget {
  const _DiscountCard({required this.discount, required this.isDark});
  final DiscountModel discount;
  final bool isDark;

  Color get _statusColor {
    if (discount.isActive) return AppColors.primary;
    if (discount.isUsed) return Colors.grey;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final isActive = discount.isActive;

    return Opacity(
      opacity: isActive ? 1.0 : 0.55,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(16),
          border: isActive
              ? Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  width: 1.5)
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
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: _statusColor.withValues(alpha: 0.08),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Text(discount.emoji,
                      style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      discount.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.darkText
                            : AppColors.lightText,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      discount.isActive
                          ? 'فعال'
                          : (discount.isUsed ? 'استفاده‌شده' : 'منقضی'),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _statusColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── بدنه ──
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: _statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        discount.valueLabel,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: discount.type == DiscountType.percent
                              ? 22
                              : 14,
                          fontWeight: FontWeight.w900,
                          color: _statusColor,
                          height: 1.2,
                        ),
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
                              discount.code,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.5,
                                color: isDark
                                    ? AppColors.darkText
                                    : AppColors.lightText,
                              ),
                            ),
                            const SizedBox(width: 6),
                            if (isActive)
                              GestureDetector(
                                onTap: () {
                                  Clipboard.setData(
                                      ClipboardData(text: discount.code));
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                    content: const Text('کد کپی شد ✅'),
                                    behavior: SnackBarBehavior.floating,
                                    backgroundColor: AppColors.primary,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    margin: const EdgeInsets.fromLTRB(
                                        16, 0, 16, 80),
                                    duration: const Duration(seconds: 2),
                                  ));
                                },
                                child: Icon(Icons.copy_rounded,
                                    size: 16,
                                    color: AppColors.primary
                                        .withValues(alpha: 0.7)),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          discount.description,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 8,
                          children: [
                            if (discount.minOrderPrice != null)
                              _Tag(
                                  text:
                                      'حداقل ${_fmt(discount.minOrderPrice!)} ت',
                                  isDark: isDark),
                            if (isActive)
                              _Tag(
                                  text: discount.daysLeft > 0
                                      ? '${discount.daysLeft} روز مانده'
                                      : 'آخرین روز!',
                                  isDark: isDark,
                                  urgent: discount.daysLeft <= 1),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(int p) {
    final s = p.toString();
    final buf = StringBuffer();
    final offset = s.length % 3;
    for (int i = 0; i < s.length; i++) {
      if (i != 0 && (i - offset) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}

// ───────────────────────── تگ کوچک ─────────────────────────
class _Tag extends StatelessWidget {
  const _Tag(
      {required this.text, required this.isDark, this.urgent = false});
  final String text;
  final bool isDark;
  final bool urgent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: urgent
            ? Colors.red.withValues(alpha: 0.1)
            : (isDark
                ? Colors.white.withValues(alpha: 0.07)
                : Colors.black.withValues(alpha: 0.05)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          color: urgent
              ? Colors.red
              : (isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary),
        ),
      ),
    );
  }
}