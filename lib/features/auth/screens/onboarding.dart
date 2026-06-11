import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'login_screen.dart';

// ── مدل هر اسلاید ──
class _Slide {
  final String emoji;
  final String title;
  final String subtitle;
  final Color bgLight;
  final Color bgDark;

  const _Slide({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.bgLight,
    required this.bgDark,
  });
}

const _slides = [
  _Slide(
    emoji: '🍽️',
    title: 'بهترین غذاها\nدر یک کلیک',
    subtitle: 'از کباب‌های سنتی تا پیش‌غذاهای خاص،\nهمه‌چیز در منوی ما منتظرته.',
    bgLight: Color(0xFFFFF3F3),
    bgDark: Color(0xFF1A0A0A),
  ),
  _Slide(
    emoji: '🛵',
    title: 'تحویل سریع\nدر کمترین زمان',
    subtitle: 'سفارش دلیوری یا حضوری —\nغذات گرم و تازه می‌رسه.',
    bgLight: Color(0xFFFFF8EC),
    bgDark: Color(0xFF1A1200),
  ),
  _Slide(
    emoji: '⭐',
    title: 'باشگاه مشترکین\nو تخفیف‌های ویژه',
    subtitle: 'با هر سفارش امتیاز جمع کن\nو از تخفیف‌های اختصاصی لذت ببر.',
    bgLight: Color(0xFFF3F7FF),
    bgDark: Color(0xFF08101A),
  ),
];

// ── Splash ──
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<double> _scale;
  late final Animation<Color?> _bg;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));

    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _scale = Tween(begin: 0.7, end: 1.0).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _bg = ColorTween(begin: AppColors.primary, end: Colors.transparent)
        .animate(CurvedAnimation(
            parent: _ctrl,
            curve: const Interval(0.4, 1.0, curve: Curves.easeInOut)));

    _ctrl.forward();
    Future.delayed(const Duration(milliseconds: 2200), _goOnboarding);
  }

  void _goOnboarding() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (_, _, _) => const OnboardingScreen(),
        transitionsBuilder: (_, anim, _, child) => FadeTransition(
          opacity: CurvedAnimation(parent: anim, curve: Curves.easeInOut),
          child: child,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, _) => Scaffold(
        backgroundColor: Color.lerp(
          AppColors.primary,
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
          Curves.easeInOut.transform(_ctrl.value.clamp(0.4, 1.0) - 0.4) * (1 / 0.6),
        ),
        body: Stack(
          children: [
            Center(
              child: FadeTransition(
                opacity: _fade,
                child: ScaleTransition(
                  scale: _scale,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _LogoBox(size: 110, fontSize: 56),
                      const SizedBox(height: 24),
                      _AnimText(
                        t: _ctrl.value,
                        text: 'رستوران آزمایشی',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: _ctrl.value < 0.55
                              ? Colors.white
                              : (isDark
                                  ? AppColors.darkText
                                  : AppColors.lightText),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _AnimText(
                        t: _ctrl.value,
                        text: 'بهترین غذاها در یک کلیک',
                        style: TextStyle(
                          fontSize: 14,
                          color: _ctrl.value < 0.55
                              ? Colors.white70
                              : (isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary),
                        ),
                      ),
                      const SizedBox(height: 48),
                      SizedBox(
                        width: 24, height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: _ctrl.value < 0.55
                              ? Colors.white54
                              : AppColors.primary.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // دکمه رد کردن
            Positioned(
              top: MediaQuery.of(context).padding.top + 12,
              left: 16,
              child: FadeTransition(
                opacity: _fade,
                child: _SkipBtn(
                  bright: _ctrl.value < 0.55,
                  isDark: isDark,
                  onTap: _goOnboarding,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Onboarding ──
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final _pageCtrl = PageController();
  int _page = 0;

  // کنترلر انیمیشن برای محتوای هر اسلاید
  late AnimationController _contentCtrl;
  late Animation<double> _contentFade;
  late Animation<Offset> _contentSlide;

  @override
  void initState() {
    super.initState();
    _initContentAnim();
  }

  void _initContentAnim() {
    _contentCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _contentFade =
        CurvedAnimation(parent: _contentCtrl, curve: Curves.easeOut);
    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _contentCtrl, curve: Curves.easeOutCubic));
    _contentCtrl.forward();
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  Future<void> _next() async {
    if (_page < _slides.length - 1) {
      // خروج محتوای فعلی
      await _contentCtrl.reverse();
      setState(() => _page++);
      _pageCtrl.animateToPage(
        _page,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
      _contentCtrl.forward(from: 0);
    } else {
      _goLogin();
    }
  }

  void _goLogin() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, _, _) => const LoginScreen(),
        transitionsBuilder: (_, anim, _, child) {
          final slide = Tween<Offset>(
            begin: const Offset(-1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeInOutCubic));
          return FadeTransition(
            opacity: anim,
            child: SlideTransition(position: slide, child: child),
          );
        },
      ),
    );
  }

  void _onPageChanged(int p) {
    _contentCtrl.forward(from: 0);
    setState(() => _page = p);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final slide = _slides[_page];
    final bg = isDark ? slide.bgDark : slide.bgLight;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        color: bg,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Column(
              children: [
                // ── دکمه رد کردن ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _SkipBtn(
                        bright: false,
                        isDark: isDark,
                        onTap: _goLogin,
                      ),
                    ],
                  ),
                ),

                // ── اسلایدها ──
                Expanded(
                  child: PageView.builder(
                    controller: _pageCtrl,
                    onPageChanged: _onPageChanged,
                    itemCount: _slides.length,
                    itemBuilder: (_, i) => _SlideView(
                      slide: _slides[i],
                      isDark: isDark,
                      fadeAnim: _contentFade,
                      slideAnim: _contentSlide,
                      isActive: i == _page,
                    ),
                  ),
                ),

                // ── Indicator + دکمه ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Dot Indicator
                      _DotIndicator(
                          current: _page, count: _slides.length),

                      // دکمه بعدی / ورود
                      _NextButton(
                        isLast: _page == _slides.length - 1,
                        onTap: _next,
                      ),
                    ],
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

// ── اسلاید ──
class _SlideView extends StatelessWidget {
  const _SlideView({
    required this.slide,
    required this.isDark,
    required this.fadeAnim,
    required this.slideAnim,
    required this.isActive,
  });
  final _Slide slide;
  final bool isDark;
  final Animation<double> fadeAnim;
  final Animation<Offset> slideAnim;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: FadeTransition(
        opacity: fadeAnim,
        child: SlideTransition(
          position: slideAnim,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ایموجی بزرگ
              Container(
                width: 160, height: 160,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    slide.emoji,
                    style: const TextStyle(fontSize: 80),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              // عنوان
              Text(
                slide.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  height: 1.35,
                  color: isDark ? AppColors.darkText : AppColors.lightText,
                ),
              ),
              const SizedBox(height: 16),
              // زیرعنوان
              Text(
                slide.subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.7,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Dot Indicator ──
class _DotIndicator extends StatelessWidget {
  const _DotIndicator({required this.current, required this.count});
  final int current;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (i) {
        final isActive = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOutCubic,
          margin: const EdgeInsets.only(left: 6),
          width: isActive ? 28 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.primary
                : AppColors.primary.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

// ── دکمه بعدی ──
class _NextButton extends StatelessWidget {
  const _NextButton({required this.isLast, required this.onTap});
  final bool isLast;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(
          horizontal: isLast ? 24 : 0,
          vertical: 14,
        ),
        width: isLast ? null : 56,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(isLast ? 16 : 28),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: isLast
            ? const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('شروع کن',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      )),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_back_ios_rounded,
                      color: Colors.white, size: 16),
                ],
              )
            : const Icon(Icons.arrow_back_ios_rounded,
                color: Colors.white, size: 20),
      ),
    );
  }
}

// ── لوگو ──
class _LogoBox extends StatelessWidget {
  const _LogoBox({required this.size, required this.fontSize});
  final double size;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(size * 0.25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Center(
        child: Text('🍽️', style: TextStyle(fontSize: fontSize)),
      ),
    );
  }
}

// ── متن با انیمیشن رنگ ──
class _AnimText extends StatelessWidget {
  const _AnimText(
      {required this.t, required this.text, required this.style});
  final double t;
  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return AnimatedDefaultTextStyle(
      duration: const Duration(milliseconds: 400),
      style: style,
      child: Text(text, textAlign: TextAlign.center),
    );
  }
}

// ── دکمه Skip ──
class _SkipBtn extends StatelessWidget {
  const _SkipBtn({
    required this.bright,
    required this.isDark,
    required this.onTap,
  });
  final bool bright;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: bright
              ? Colors.white.withValues(alpha: 0.2)
              : (isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.06)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'رد کردن',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: bright
                    ? Colors.white
                    : (isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary),
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_back_ios_rounded,
              size: 12,
              color: bright
                  ? Colors.white
                  : (isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary),
            ),
          ],
        ),
      ),
    );
  }
}