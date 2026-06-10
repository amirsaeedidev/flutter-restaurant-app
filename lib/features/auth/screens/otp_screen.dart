import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../main_wrapper.dart';
import '../providers/auth_provider.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key, required this.phone});
  final String phone;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  // 4 فیلد جداگانه برای هر رقم
  final List<TextEditingController> _controllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(4, (_) => FocusNode());

  // تایمر ۲ دقیقه
  static const _timerSeconds = 120;
  int _remaining = _timerSeconds;
  Timer? _timer;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
    // فوکوس روی اولین فیلد
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => _focusNodes[0].requestFocus());
  }

  void _startTimer() {
    _remaining = _timerSeconds;
    _canResend = false;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_remaining <= 0) {
        t.cancel();
        setState(() => _canResend = true);
      } else {
        setState(() => _remaining--);
      }
    });
  }

  String get _timerText {
    final m = (_remaining ~/ 60).toString().padLeft(2, '0');
    final s = (_remaining % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String get _otpCode =>
      _controllers.map((c) => c.text).join();

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  // وقتی یه رقم وارد شد، فوکوس بره رقم بعدی
  void _onChanged(String value, int index) {
    if (value.length == 1 && index < 3) {
      _focusNodes[index + 1].requestFocus();
    }
    // اگه همه رقم‌ها پر شد، submit کن
    if (_otpCode.length == 4) _verify();
  }

  // وقتی backspace زده شد
  void _onKeyEvent(KeyEvent event, int index) {
    if (event is KeyDownEvent &&
        event.logicalKey.keyLabel == 'Backspace' &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  Future<void> _verify() async {
    if (_otpCode.length < 4) return;

    final auth = context.read<AuthProvider>();
    final success = await auth.verifyOtp(_otpCode);

    if (!mounted) return;

    if (success) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainWrapper()),
        (route) => false,
      );
    } else {
      // پاک کردن فیلدها و فوکوس اول
      for (final c in _controllers) c.clear();
      _focusNodes[0].requestFocus();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error ?? 'کد اشتباه است'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
        ),
      );
    }
  }

  Future<void> _resend() async {
    if (!_canResend) return;
    final auth = context.read<AuthProvider>();
    await auth.sendOtp(widget.phone);
    _startTimer();
    for (final c in _controllers) c.clear();
    _focusNodes[0].requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = context.watch<AuthProvider>();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
            isDark ? AppColors.darkBackground : AppColors.lightBackground,
        appBar: AppBar(
          backgroundColor:
              isDark ? AppColors.darkBackground : AppColors.lightBackground,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_forward_rounded,
                color: isDark ? AppColors.darkText : AppColors.lightText),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                // ── آیکون ──
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Center(
                    child: Text('📱', style: TextStyle(fontSize: 36)),
                  ),
                ),

                const SizedBox(height: 24),

                // ── عنوان ──
                Text(
                  'کد تأیید',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: isDark ? AppColors.darkText : AppColors.lightText,
                  ),
                ),
                const SizedBox(height: 8),
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                    children: [
                      const TextSpan(text: 'کد ۴ رقمی ارسال‌شده به '),
                      TextSpan(
                        text: widget.phone,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      ),
                      const TextSpan(text: ' را وارد کن'),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // راهنمای Mock
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: AppColors.secondary.withValues(alpha: 0.3)),
                  ),
                  child: const Row(
                    children: [
                      Text('💡', style: TextStyle(fontSize: 14)),
                      SizedBox(width: 6),
                      Text(
                        'کد آزمایشی:  1234',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 36),

                // ── ۴ فیلد OTP ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(4, (i) => _OtpBox(
                    controller: _controllers[i],
                    focusNode: _focusNodes[i],
                    isDark: isDark,
                    onChanged: (v) => _onChanged(v, i),
                    onKeyEvent: (e) => _onKeyEvent(e, i),
                  )),
                ),

                const SizedBox(height: 32),

                // ── تایمر + ارسال مجدد ──
                Center(
                  child: _canResend
                      ? TextButton(
                          onPressed: auth.isLoading ? null : _resend,
                          child: const Text(
                            'ارسال مجدد کد',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.timer_outlined,
                                size: 16,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary),
                            const SizedBox(width: 6),
                            Text(
                              'ارسال مجدد تا $_timerText',
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                ),

                const SizedBox(height: 24),

                // ── دکمه تأیید ──
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        (auth.isLoading || _otpCode.length < 4)
                            ? null
                            : _verify,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          AppColors.primary.withValues(alpha: 0.4),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: auth.isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'تأیید و ورود',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w800),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── هر باکس OTP ──
class _OtpBox extends StatelessWidget {
  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.isDark,
    required this.onChanged,
    required this.onKeyEvent,
  });
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isDark;
  final ValueChanged<String> onChanged;
  final ValueChanged<KeyEvent> onKeyEvent;

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: onKeyEvent,
      child: SizedBox(
        width: 68,
        height: 68,
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          maxLength: 1,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          onChanged: onChanged,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.darkText : AppColors.lightText,
          ),
          decoration: InputDecoration(
            counterText: '',
            filled: true,
            fillColor:
                isDark ? AppColors.darkSurface : AppColors.lightSurface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: isDark
                    ? Colors.white12
                    : Colors.black.withValues(alpha: 0.1),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
      ),
    );
  }
}