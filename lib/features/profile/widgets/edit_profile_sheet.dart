import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/profile_provider.dart';

class EditProfileSheet extends StatefulWidget {
  const EditProfileSheet({super.key});

  @override
  State<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<EditProfileSheet>
    with SingleTickerProviderStateMixin {
  late TextEditingController _firstNameCtrl;
  late TextEditingController _lastNameCtrl;
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    final user = context.read<ProfileProvider>().user;
    _firstNameCtrl = TextEditingController(text: user!.firstName);
    _lastNameCtrl = TextEditingController(text: user.lastName);

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scaleAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutBack,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    context.read<ProfileProvider>().updateUser(
          firstName: _firstNameCtrl.text.trim(),
          lastName: _lastNameCtrl.text.trim(),
        );
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text('پروفایل با موفقیت بروز شد'),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primary,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + bottomPadding),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
              blurRadius: 30,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── handle ──
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ── هدر: عنوان + دکمه بستن ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.edit_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'ویرایش پروفایل',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color:
                              isDark ? AppColors.darkText : AppColors.lightText,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.06)
                            : Colors.black.withValues(alpha: 0.05),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── آواتار (با ScaleTransition) ──
              Center(
                child: ScaleTransition(
                  scale: _scaleAnim,
                  child: Stack(
                    children: [
                      // هاله دور آواتار
                      Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppColors.primary.withValues(alpha: 0.25),
                              AppColors.primary.withValues(alpha: 0),
                            ],
                          ),
                        ),
                      ),
                      // دایره اصلی آواتار
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          width: 86,
                          height: 86,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.4),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    AppColors.primary.withValues(alpha: 0.2),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.person_rounded,
                              size: 44,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                      // دکمه دوربین
                      Positioned(
                        bottom: 6,
                        left: 6,
                        child: GestureDetector(
                          onTap: () {
                            // TODO: آپلود عکس
                          },
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isDark
                                    ? AppColors.darkSurface
                                    : AppColors.lightSurface,
                                width: 2.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      AppColors.primary.withValues(alpha: 0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ── فیلد نام ──
              _Field(
                controller: _firstNameCtrl,
                label: 'نام',
                hint: 'مثلاً علی',
                icon: Icons.person_outline_rounded,
                isDark: isDark,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'نام را وارد کنید'
                    : null,
              ),
              const SizedBox(height: 14),

              // ── فیلد فامیلی ──
              _Field(
                controller: _lastNameCtrl,
                label: 'نام خانوادگی',
                hint: 'مثلاً رضایی',
                icon: Icons.badge_outlined,
                isDark: isDark,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'نام خانوادگی را وارد کنید'
                    : null,
              ),
              const SizedBox(height: 28),

              // ── دکمه ذخیره ──
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.check_rounded, size: 22),
                      SizedBox(width: 8),
                      Text(
                        'ذخیره تغییرات',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════
// ویجت فیلد بهینه‌شده
// ════════════════════════════════════════
class _Field extends StatefulWidget {
  const _Field({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    required this.isDark,
    required this.validator,
  });
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool isDark;
  final String? Function(String?) validator;

  @override
  State<_Field> createState() => _FieldState();
}

class _FieldState extends State<_Field> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (focused) => setState(() => _isFocused = focused),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        transform: Transform.translate(
          offset: Offset(0, _isFocused ? -2 : 0),
        ).transform,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── لیبل با آیکون ──
            Row(
              children: [
                Icon(
                  widget.icon,
                  size: 14,
                  color: _isFocused
                      ? AppColors.primary
                      : (widget.isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary),
                ),
                const SizedBox(width: 5),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _isFocused
                        ? AppColors.primary
                        : (widget.isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary),
                  ),
                  child: Text(widget.label),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // ── فیلد ورودی ──
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                boxShadow: _isFocused
                    ? [
                        BoxShadow(
                          color:
                              AppColors.primary.withValues(alpha: 0.15),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: TextFormField(
                controller: widget.controller,
                validator: widget.validator,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: widget.isDark
                      ? AppColors.darkText
                      : AppColors.lightText,
                ),
                decoration: InputDecoration(
                  hintText: widget.hint,
                  hintStyle: TextStyle(
                    color: widget.isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                  filled: true,
                  fillColor: widget.isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : Colors.black.withValues(alpha: 0.03),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: widget.isDark
                          ? Colors.white12
                          : Colors.black.withValues(alpha: 0.05),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                        color: AppColors.primary, width: 1.8),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                        const BorderSide(color: Colors.red, width: 1.2),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                        const BorderSide(color: Colors.red, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
