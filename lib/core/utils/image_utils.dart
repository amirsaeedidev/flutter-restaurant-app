import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// تابع کمکی برای نمایش تصاویر با کش و fallback به Asset
/// 
/// [imageUrl] : آدرس تصویر (HTTP یا Asset محلی)
/// [width] : عرض تصویر
/// [height] : ارتفاع تصویر
/// [fit] : نحوه‌ی قرارگیری تصویر
/// [placeholderAsset] : تصویر پیش‌فرض در صورت نبود یا خطا (پیش‌فرض: assets/images/food.jpg)
Widget buildImage(
  String imageUrl, {
  double? width,
  double? height,
  BoxFit fit = BoxFit.cover,
  String placeholderAsset = 'assets/images/food.jpg', // ← تغییر: پیش‌فرض برای محصولات
}) {
  // اگر آدرس خالی بود، Asset پیش‌فرض را نشان بده
  if (imageUrl.isEmpty) {
    return Image.asset(
      placeholderAsset,
      width: width,
      height: height,
      fit: fit,
    );
  }

  // اگر آدرس اینترنتی است، از CachedNetworkImage استفاده کن
  if (imageUrl.startsWith('http')) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      // نمایش در حین بارگذاری (آفلاین یا در حال دانلود)
      placeholder: (context, url) => Image.asset(
        placeholderAsset,
        width: width,
        height: height,
        fit: fit,
      ),
      // در صورت خطا (تصویر وجود نداشت یا اینترنت قطع بود)
      errorWidget: (context, url, error) => Image.asset(
        placeholderAsset,
        width: width,
        height: height,
        fit: fit,
      ),
      // ⭐ کش کردن خودکار انجام می‌شود
      // ⭐ استفاده از حافظه‌ی کش بهینه
      memCacheWidth: width?.toInt(),
      memCacheHeight: height?.toInt(),
    );
  }

  // در غیر این صورت (فایل محلی Asset)
  return Image.asset(
    imageUrl,
    width: width,
    height: height,
    fit: fit,
  );
}