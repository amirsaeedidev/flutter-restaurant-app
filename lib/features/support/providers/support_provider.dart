import 'package:flutter/material.dart';
import '../../../core/model/support_model.dart';
import '../../../core/services/supabase_service.dart';

class SupportProvider extends ChangeNotifier {
  // ── لیست تیکت‌ها ──
  List<TicketModel> _tickets = [];
  bool _isLoadingTickets = false;
  
  // ── پیام‌های تیکت انتخاب شده ──
  List<TicketMessageModel> _messages = [];
  bool _isLoadingMessages = false;

  List<TicketModel> get tickets => List.unmodifiable(_tickets);
  bool get isLoadingTickets => _isLoadingTickets;

  List<TicketMessageModel> get messages => List.unmodifiable(_messages);
  bool get isLoadingMessages => _isLoadingMessages;

  // دریافت لیست تیکت‌های کاربر
  Future<void> fetchTickets() async {
    _isLoadingTickets = true;
    notifyListeners();

    try {
      final userId = SupabaseService.client.auth.currentUser?.id;
      if (userId == null) throw Exception("کاربر لاگین نیست");

      final response = await SupabaseService.client
          .from('tickets')
          .select()
          .eq('user_id', userId)
          .order('updated_at', ascending: false);

      _tickets = (response as List)
          .map((e) => TicketModel.fromJson(e))
          .toList();
    } catch (e) {
      print("Error fetching tickets: $e");
    } finally {
      _isLoadingTickets = false;
      notifyListeners();
    }
  }

  // ایجاد تیکت جدید
  Future<bool> createTicket(String subject, String message) async {
    try {
      final userId = SupabaseService.client.auth.currentUser?.id;
      if (userId == null) return false;

      // ۱. ساخت تیکت
      final ticketResponse = await SupabaseService.client
          .from('tickets')
          .insert({
            'user_id': userId,
            'subject': subject,
          })
          .select()
          .single();

      final ticketId = ticketResponse['id'];

      // ۲. ثبت اولین پیام
      await SupabaseService.client.from('ticket_messages').insert({
        'ticket_id': ticketId,
        'user_id': userId,
        'message': message,
        'is_admin': false,
      });

      // اضافه کردن به لیست محلی برای بروزرسانی سریع UI
      _tickets.insert(0, TicketModel.fromJson(ticketResponse));
      notifyListeners();
      
      return true;
    } catch (e) {
      print("Error creating ticket: $e");
      return false;
    }
  }

  // دریافت پیام‌های یک تیکت
  Future<void> fetchMessages(String ticketId) async {
    _isLoadingMessages = true;
    _messages = [];
    notifyListeners();

    try {
      final response = await SupabaseService.client
          .from('ticket_messages')
          .select()
          .eq('ticket_id', ticketId)
          .order('created_at', ascending: true);

      _messages = (response as List)
          .map((e) => TicketMessageModel.fromJson(e))
          .toList();
    } catch (e) {
      print("Error fetching messages: $e");
    } finally {
      _isLoadingMessages = false;
      notifyListeners();
    }
  }

  // ارسال پیام در یک تیکت
  Future<void> sendMessage(String ticketId, String text) async {
    if (text.trim().isEmpty) return;

    try {
      final userId = SupabaseService.client.auth.currentUser?.id;
      if (userId == null) return;

      final response = await SupabaseService.client
          .from('ticket_messages')
          .insert({
            'ticket_id': ticketId,
            'user_id': userId,
            'message': text.trim(),
            'is_admin': false,
          })
          .select()
          .single();

      _messages.add(TicketMessageModel.fromJson(response));
      
      // آپدیت زمان تیکت در دیتابیس
      await SupabaseService.client
          .from('tickets')
          .update({'updated_at': DateTime.now().toIso8601String()})
          .eq('id', ticketId);

      notifyListeners();
    } catch (e) {
      print("Error sending message: $e");
    }
  }
}