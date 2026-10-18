import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/supabase_service.dart';
import '../../../core/theme/app_colors.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final SupabaseClient _client = SupabaseService.client;
  List<Map<String, dynamic>> _notifications = [];
  bool _loading = true;
  String? _error;
  RealtimeChannel? _channel;
  String? _userId;

  int get _unreadCount => _notifications.where((item) => item['is_read'] != true).length;

  @override
  void initState() {
    super.initState();
    _userId = _client.auth.currentUser?.id;
    if (_userId != null) {
      _subscribe();
      unawaited(_load());
    } else {
      _loading = false;
      _error = 'برای مشاهده اعلان‌ها ابتدا وارد حساب کاربری شوید.';
    }
  }

  void _subscribe() {
    final userId = _userId;
    if (userId == null) return;
    _channel = _client.channel('customer-notifications-$userId')
      ..onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'customer_notifications',
        filter: PostgresChangeFilter(type: PostgresChangeFilterType.eq, column: 'user_id', value: userId),
        callback: (_) => unawaited(_load(silent: true)),
      )
      ..subscribe();
  }

  Future<void> _load({bool silent = false}) async {
    final userId = _userId;
    if (userId == null) return;
    if (!silent && mounted) setState(() { _loading = true; _error = null; });
    try {
      final rows = await _client
          .from('customer_notifications')
          .select('id, title, body, notification_type, entity_table, entity_id, is_read, read_at, created_at')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(100);
      if (!mounted) return;
      setState(() {
        _notifications = (rows as List).map((row) => Map<String, dynamic>.from(row as Map)).toList(growable: true);
        _error = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'دریافت اعلان‌ها انجام نشد. اتصال را بررسی و دوباره تلاش کنید.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _markRead(Map<String, dynamic> notification) async {
    if (notification['is_read'] == true) return;
    final userId = _userId;
    final id = notification['id']?.toString();
    if (userId == null || id == null) return;
    try {
      final readAt = DateTime.now().toUtc().toIso8601String();
      await _client.from('customer_notifications').update({'is_read': true, 'read_at': readAt}).eq('id', id).eq('user_id', userId);
      if (!mounted) return;
      setState(() {
        final index = _notifications.indexWhere((item) => item['id'].toString() == id);
        if (index != -1) {
          _notifications[index]['is_read'] = true;
          _notifications[index]['read_at'] = readAt;
        }
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('علامت‌گذاری اعلان انجام نشد.')));
    }
  }

  Future<void> _markAllRead() async {
    final userId = _userId;
    if (userId == null || _unreadCount == 0) return;
    try {
      final readAt = DateTime.now().toUtc().toIso8601String();
      await _client.from('customer_notifications').update({'is_read': true, 'read_at': readAt}).eq('user_id', userId).eq('is_read', false);
      if (!mounted) return;
      setState(() {
        for (final item in _notifications) {
          item['is_read'] = true;
          item['read_at'] = readAt;
        }
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('به‌روزرسانی اعلان‌ها انجام نشد.')));
    }
  }

  @override
  void dispose() {
    final channel = _channel;
    if (channel != null) unawaited(_client.removeChannel(channel));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final foreground = isDark ? AppColors.darkText : AppColors.lightText;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        appBar: AppBar(
          title: const Text('اعلان‌ها'),
          backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
          foregroundColor: foreground,
          elevation: 0,
          actions: [
            if (_unreadCount > 0) TextButton(onPressed: _markAllRead, child: const Text('خواندن همه')),
            IconButton(tooltip: 'تازه‌سازی', onPressed: () => unawaited(_load()), icon: const Icon(Icons.refresh_rounded)),
          ],
        ),
        body: _loading
            ? ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: 5,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, __) => Container(
                  height: 96,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(18)),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [_SkeletonBar(width: 150, height: 14), SizedBox(height: 12), _SkeletonBar(width: double.infinity, height: 10), SizedBox(height: 8), _SkeletonBar(width: 200, height: 10)],
                  ),
                ),
              )
            : _error != null
                ? Center(child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.cloud_off_rounded, size: 44),
                      const SizedBox(height: 12),
                      Text(_error!, textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      FilledButton.icon(onPressed: () => unawaited(_load()), icon: const Icon(Icons.refresh_rounded), label: const Text('تلاش مجدد')),
                    ]),
                  ))
                : _notifications.isEmpty
                    ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.notifications_none_rounded, size: 58, color: foreground.withValues(alpha: 0.45)),
                        const SizedBox(height: 12),
                        Text('فعلاً اعلانی ندارید', style: TextStyle(color: foreground, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Text('اعلان‌های سفارش و تخفیف در این صفحه نمایش داده می‌شوند.', style: TextStyle(color: foreground.withValues(alpha: 0.65)), textAlign: TextAlign.center),
                      ]))
                    : RefreshIndicator(
                        onRefresh: _load,
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                          itemCount: _notifications.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final item = _notifications[index];
                            final isRead = item['is_read'] == true;
                            final type = (item['notification_type'] ?? 'general').toString();
                            final icon = switch (type) {
                              'order' => Icons.receipt_long_rounded,
                              'discount' => Icons.local_offer_rounded,
                              'wallet' => Icons.account_balance_wallet_rounded,
                              'reservation' => Icons.event_available_rounded,
                              _ => Icons.notifications_active_rounded,
                            };
                            final created = DateTime.tryParse((item['created_at'] ?? '').toString())?.toLocal();
                            return Material(
                              color: surface,
                              borderRadius: BorderRadius.circular(18),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(18),
                                onTap: () => _markRead(item),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Container(width: 44, height: 44, decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: AppColors.primary)),
                                    const SizedBox(width: 12),
                                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      Row(children: [
                                        Expanded(child: Text((item['title'] ?? 'اعلان').toString(), style: TextStyle(fontWeight: FontWeight.w800, color: foreground))),
                                        if (!isRead) Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
                                      ]),
                                      if ((item['body'] ?? '').toString().trim().isNotEmpty) ...[
                                        const SizedBox(height: 5),
                                        Text(item['body'].toString(), style: TextStyle(color: foreground.withValues(alpha: 0.75), height: 1.5)),
                                      ],
                                      if (created != null) ...[
                                        const SizedBox(height: 8),
                                        Text('${created.year}/${created.month.toString().padLeft(2, '0')}/${created.day.toString().padLeft(2, '0')}  ${created.hour.toString().padLeft(2, '0')}:${created.minute.toString().padLeft(2, '0')}', style: TextStyle(fontSize: 11, color: foreground.withValues(alpha: 0.55))),
                                      ],
                                    ])),
                                  ]),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
      ),
    );
  }
}

class _SkeletonBar extends StatelessWidget {
  const _SkeletonBar({required this.width, required this.height});
  final double width;
  final double height;
  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(8),
    ),
  );
}
