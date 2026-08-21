import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/model/support_model.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/support_provider.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    
    // بارگذاری تیکت‌ها پس از اولین فریم
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SupportProvider>().fetchTickets();
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
            isDark ? AppColors.darkBackground : AppColors.lightBackground,
        appBar: AppBar(
          backgroundColor:
              isDark ? AppColors.darkBackground : AppColors.lightBackground,
          elevation: 0,
          title: Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('🎧', style: TextStyle(fontSize: 18)),
                ),
              ),
              const SizedBox(width: 10),
              Text('پشتیبانی',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: isDark ? AppColors.darkText : AppColors.lightText,
                  )),
            ],
          ),
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
            labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            tabs: const [
              Tab(text: '🎫 تیکت‌ها'),
              Tab(text: '📞 تماس با ما'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabCtrl,
          children: [
            _TicketsTab(isDark: isDark),
            _ContactTab(isDark: isDark),
          ],
        ),
      ),
    );
  }
}

// ── تب تیکت‌ها ──
class _TicketsTab extends StatelessWidget {
  const _TicketsTab({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SupportProvider>();

    if (provider.isLoadingTickets && provider.tickets.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.tickets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🎫', style: TextStyle(fontSize: 60)),
            const SizedBox(height: 16),
            Text('تیکتی ثبت نشده',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.darkText : AppColors.lightText,
                )),
            const SizedBox(height: 8),
            Text('اگر سوالی داری یک تیکت جدید بساز',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                )),
          ],
        ),
      );
    }

    return Stack(
      children: [
        ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
          itemCount: provider.tickets.length,
          itemBuilder: (_, i) {
            final ticket = provider.tickets[i];
            return _TicketCard(
              ticket: ticket,
              isDark: isDark,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChangeNotifierProvider.value(
                      value: provider,
                      child: _TicketDetailScreen(ticket: ticket),
                    ),
                  ),
                );
              },
            );
          },
        ),
        Positioned(
          bottom: 20,
          left: 20,
          right: 20,
          child: ElevatedButton.icon(
            onPressed: () => _showCreateTicketDialog(context),
            icon: const Icon(Icons.add_rounded),
            label: const Text('تیکت جدید', style: TextStyle(fontWeight: FontWeight.w700)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        )
      ],
    );
  }

  void _showCreateTicketDialog(BuildContext context) {
    final subjectCtrl = TextEditingController();
    final messageCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('تیکت جدید'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: subjectCtrl,
                  decoration: const InputDecoration(hintText: 'موضوع'),
                  validator: (v) => v!.isEmpty ? 'موضوع را وارد کنید' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: messageCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(hintText: 'پیام شما'),
                  validator: (v) => v!.isEmpty ? 'پیام را وارد کنید' : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('انصراف'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final success = await context.read<SupportProvider>().createTicket(
                        subjectCtrl.text,
                        messageCtrl.text,
                      );
                  if (context.mounted) {
                    Navigator.pop(context);
                    if (!success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('خطا در ایجاد تیکت')),
                      );
                    }
                  }
                }
              },
              child: const Text('ثبت'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── کارت تیکت ──
class _TicketCard extends StatelessWidget {
  const _TicketCard({required this.ticket, required this.isDark, required this.onTap});
  final TicketModel ticket;
  final bool isDark;
  final VoidCallback onTap;

  Color _statusColor() {
    switch (ticket.status) {
      case TicketStatus.open: return Colors.orange;
      case TicketStatus.answered: return Colors.green;
      case TicketStatus.closed: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _statusColor().withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: _statusColor().withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.receipt_long_rounded, color: _statusColor(), size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ticket.subject,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.darkText : AppColors.lightText,
                      )),
                  const SizedBox(height: 4),
                  Text(ticket.statusLabel,
                      style: TextStyle(
                        fontSize: 12,
                        color: _statusColor(),
                      )),
                ],
              ),
            ),
            Icon(Icons.arrow_back_ios_rounded,
                size: 14,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
          ],
        ),
      ),
    );
  }
}

// ── صفحه جزئیات تیکت ──
class _TicketDetailScreen extends StatefulWidget {
  const _TicketDetailScreen({required this.ticket});
  final TicketModel ticket;

  @override
  State<_TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<_TicketDetailScreen> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SupportProvider>().fetchMessages(widget.ticket.id);
    });
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<SupportProvider>();

    if (provider.messages.isNotEmpty) {
      _scrollToBottom();
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        appBar: AppBar(
          backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
          elevation: 0,
          title: Text(widget.ticket.subject,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.darkText : AppColors.lightText,
              )),
          leading: IconButton(
            icon: Icon(Icons.arrow_forward_rounded,
                color: isDark ? AppColors.darkText : AppColors.lightText),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: provider.isLoadingMessages && provider.messages.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      controller: _scrollCtrl,
                      padding: const EdgeInsets.all(16),
                      itemCount: provider.messages.length,
                      itemBuilder: (_, i) {
                        final msg = provider.messages[i];
                        return _MessageBubble(message: msg, isDark: isDark);
                      },
                    ),
            ),
            _MessageInput(
              controller: _msgCtrl,
              isDark: isDark,
              onSend: () {
                final text = _msgCtrl.text.trim();
                if (text.isNotEmpty) {
                  provider.sendMessage(widget.ticket.id, text);
                  _msgCtrl.clear();
                  _scrollToBottom();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ── حباب پیام ──
class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.isDark});
  final TicketMessageModel message;
  final bool isDark;

  String _timeStr(DateTime t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final isUser = !message.isAdmin;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 32, height: 32,
              margin: const EdgeInsets.only(left: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('🎧', style: TextStyle(fontSize: 15)),
              ),
            ),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.start : CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isUser
                        ? AppColors.primary
                        : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
                    borderRadius: BorderRadius.only(
                      topRight: const Radius.circular(18),
                      topLeft: const Radius.circular(18),
                      bottomRight: Radius.circular(isUser ? 4 : 18),
                      bottomLeft: Radius.circular(isUser ? 18 : 4),
                    ),
                  ),
                  child: Text(
                    message.message,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: isUser ? Colors.white : (isDark ? AppColors.darkText : AppColors.lightText),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _timeStr(message.createdAt),
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── فیلد ارسال پیام ──
class _MessageInput extends StatelessWidget {
  const _MessageInput({
    required this.controller,
    required this.isDark,
    required this.onSend,
  });
  final TextEditingController controller;
  final bool isDark;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 10, 16, 10 + MediaQuery.of(context).viewInsets.bottom),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.07),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              textDirection: TextDirection.rtl,
              maxLines: 3,
              minLines: 1,
              onSubmitted: (_) => onSend(),
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.darkText : AppColors.lightText,
              ),
              decoration: InputDecoration(
                hintText: 'پاسخ خود را بنویسید...',
                hintStyle: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
                filled: true,
                fillColor: isDark
                    ? Colors.white.withValues(alpha: 0.07)
                    : Colors.black.withValues(alpha: 0.04),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: onSend,
            child: Container(
              width: 46, height: 46,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── تب تماس با ما (بدون تغییر) ──
class _ContactTab extends StatelessWidget {
  const _ContactTab({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 8),

        // ── بنر ──
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, const Color(0xFFEF5350)],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const Text('🎧', style: TextStyle(fontSize: 40)),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('۲۴ ساعته در کنارتیم',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        )),
                    SizedBox(height: 4),
                    Text('تیم پشتیبانی آماده پاسخگوییه',
                        style: TextStyle(color: Colors.white70, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // ── راه‌های ارتباطی ──
        _ContactCard(
          emoji: '📞',
          title: 'تلفن پشتیبانی',
          subtitle: '021 - 1234 - 5678',
          badge: 'شنبه تا پنج‌شنبه ۸ تا ۲۲',
          color: Colors.green,
          isDark: isDark,
          onTap: () => _showCallDialog(context),
        ),

        const SizedBox(height: 12),

        _ContactCard(
          emoji: '📱',
          title: 'واتساپ',
          subtitle: '09121234567',
          badge: '۲۴ ساعته',
          color: const Color(0xFF25D366),
          isDark: isDark,
          onTap: () => _showSnack(context, 'واتساپ: 09121234567'),
        ),

        const SizedBox(height: 12),

        _ContactCard(
          emoji: '📧',
          title: 'ایمیل',
          subtitle: 'support@restaurant.ir',
          badge: 'پاسخ تا ۲۴ ساعت',
          color: AppColors.primary,
          isDark: isDark,
          onTap: () => _showSnack(context, 'ایمیل: support@restaurant.ir'),
        ),

        const SizedBox(height: 12),

        _ContactCard(
          emoji: '📍',
          title: 'آدرس رستوران',
          subtitle: 'تهران، خیابان ولیعصر، پلاک ۱',
          badge: 'شنبه تا جمعه ۱۲ تا ۲۳',
          color: AppColors.secondary,
          isDark: isDark,
          onTap: () {},
        ),

        const SizedBox(height: 20),

        // ── ساعات کاری ──
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('⏰ ساعات کاری',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.darkText : AppColors.lightText,
                  )),
              const SizedBox(height: 12),
              ...[
                ('شنبه تا پنج‌شنبه', '۱۲:۰۰ — ۲۳:۰۰'),
                ('جمعه', '۱۳:۰۰ — ۲۳:۰۰'),
                ('تعطیلات رسمی', '۱۴:۰۰ — ۲۲:۰۰'),
              ].map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Text(item.$1,
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? AppColors.darkText : AppColors.lightText,
                            )),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(item.$2,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              )),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ],
    );
  }

  void _showCallDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('تماس با پشتیبانی'),
          content: const Text('021 - 1234 - 5678'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('بستن'),
            ),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.phone_rounded, size: 18),
              label: const Text('تماس'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
    ));
  }
}

// ── کارت راه ارتباطی ──
class _ContactCard extends StatelessWidget {
  const _ContactCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.color,
    required this.isDark,
    required this.onTap,
  });
  final String emoji;
  final String title;
  final String subtitle;
  final String badge;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
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
        child: Row(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 24)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.darkText : AppColors.lightText,
                      )),
                  const SizedBox(height: 3),
                  Text(subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: color,
                      )),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(badge,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: color,
                  )),
            ),
          ],
        ),
      ),
    );
  }
}