import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/model/support_model.dart';

class SupportProvider extends ChangeNotifier {
  final List<ChatMessage> _messages = [
    // پیام خوشامدگویی اولیه
    ChatMessage(
      id: '0',
      text: 'سلام! 👋 به پشتیبانی رستوران آزمایشی خوش اومدی.\nچطور می‌تونم کمکت کنم؟',
      sender: MessageSender.support,
      time: DateTime.now().subtract(const Duration(minutes: 2)),
      isRead: true,
    ),
  ];

  bool _isTyping = false;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isTyping => _isTyping;

  // پاسخ‌های Mock پشتیبانی
  static const _replies = [
    'حتماً بررسی می‌کنیم. لطفاً چند لحظه صبر کن 🙏',
    'ممنون که با ما در تماس هستی! مشکلت رو بیشتر توضیح بده.',
    'این موضوع رو به تیم مربوطه منتقل می‌کنیم ✅',
    'برای پیگیری سفارش می‌تونی به بخش «سفارشات» مراجعه کنی.',
    'اگه مشکل پرداخت داری، لطفاً کد سفارشت رو بهم بده.',
    'ببخشید بابت این تجربه ناخوشایند! جبران می‌کنیم 🌹',
    'تیم ما ظرف ۳۰ دقیقه پیگیری می‌کنه.',
    'خوشحالیم که تونستیم کمک کنیم! 😊',
  ];

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // پیام کاربر
    _messages.add(ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text.trim(),
      sender: MessageSender.user,
      time: DateTime.now(),
    ));
    notifyListeners();

    // شبیه‌سازی تایپ کردن
    _isTyping = true;
    notifyListeners();

    // تأخیر رندوم ۱ تا ۳ ثانیه
    final delay = 1000 + Random().nextInt(2000);
    await Future.delayed(Duration(milliseconds: delay));

    _isTyping = false;

    // پاسخ رندوم
    final reply = _replies[Random().nextInt(_replies.length)];
    _messages.add(ChatMessage(
      id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
      text: reply,
      sender: MessageSender.support,
      time: DateTime.now(),
    ));
    notifyListeners();
  }
}