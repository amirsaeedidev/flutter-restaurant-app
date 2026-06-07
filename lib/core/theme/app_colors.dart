import 'package:flutter/material.dart';

class AppColors {
  // --- رنگ‌های اصلی (قابل تغییر به راحتی) ---
  // برای تغییر تم کل برنامه به آبی، فقط این کد رنگ رو عوض کن
  static const Color primary = Color(0xFFE53935); // قرمز اشتهاآور و رستورانی
  static const Color secondary = Color(0xFFFFC107); // زرد خردلی (عالی برای ستاره امتیاز و آیکون‌ها)

  // --- تم روشن (روز) ---
  static const Color lightBackground = Color(0xFFF5F5F5); // سفید مایل به خاکستری (چشم رو اذیت نمی‌کنه)
  static const Color lightSurface = Colors.white; // سفید خالص برای پس‌زمینه کارت‌های غذا
  static const Color lightText = Color(0xFF212121); // مشکی نرم برای متن اصلی
  static const Color lightTextSecondary = Color(0xFF757575); // خاکستری برای توضیحات غذا

  // --- تم تاریک (شب) ---
  static const Color darkBackground = Color(0xFF121212); // مشکی استاندارد متریال گوگل
  static const Color darkSurface = Color(0xFF1E1E1E); // خاکستری خیلی تیره برای کارت‌های غذا
  static const Color darkText = Color(0xFFE0E0E0); // سفید استخوانی برای متن اصلی
  static const Color darkTextSecondary = Color(0xFFAAAAAA); // خاکستری روشن برای توضیحات
}