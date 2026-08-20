enum MemberLevel { normal, vip }

class LevelConfig {
  final MemberLevel level;
  final String title;
  final String emoji;
  final int minPoints;       // حداقل امتیاز برای این سطح
  final int maxPoints;       // حداکثر — برای progress bar
  final double discountPct;  // درصد تخفیف
  final String discountCode;
  final List<String> perks;  // مزایا

  const LevelConfig({
    required this.level,
    required this.title,
    required this.emoji,
    required this.minPoints,
    required this.maxPoints,
    required this.discountPct,
    required this.discountCode,
    required this.perks,
  });
}

const levels = [
  LevelConfig(
    level: MemberLevel.normal,
    title: 'عضو عادی',
    emoji: '🥉',
    minPoints: 0,
    maxPoints: 2000,
    discountPct: 5,
    discountCode: 'MEMBER5',
    perks: [
      'تخفیف ۵٪ روی همه سفارش‌ها',
      'دسترسی به پیشنهادات ویژه هفتگی',
      'اطلاع‌رسانی منوی روز',
    ],
  ),
  LevelConfig(
    level: MemberLevel.vip,
    title: 'عضو VIP',
    emoji: '👑',
    minPoints: 2000,
    maxPoints: 2000, // چون بالاترین سطح است
    discountPct: 15,
    discountCode: 'VIP15',
    perks: [
      'تخفیف ۱۵٪ روی همه سفارش‌ها',
      'اولویت در صف دلیوری',
      'ارسال رایگان برای همیشه',
      'دسترسی به آیتم‌های مخصوص VIP',
      'هدیه تولد اختصاصی 🎂',
    ],
  ),
];

LevelConfig levelOf(int points) =>
    points >= 2000 ? levels[1] : levels[0];

// تابع pointsForOrder حذف شد چون امتیازها توسط مدیر به صورت دستی اضافه می‌شوند.