enum TicketStatus { open, answered, closed }

class TicketModel {
  final String id;
  final String subject;
  final TicketStatus status;
  final DateTime createdAt;
  final String? lastMessage;

  const TicketModel({
    required this.id,
    required this.subject,
    required this.status,
    required this.createdAt,
    this.lastMessage,
  });

  String get statusLabel {
    switch (status) {
      case TicketStatus.open: return 'باز';
      case TicketStatus.answered: return 'پاسخ داده شده';
      case TicketStatus.closed: return 'بسته شده';
    }
  }

  factory TicketModel.fromJson(Map<String, dynamic> j) => TicketModel(
        id: j['id'],
        subject: j['subject'] ?? '',
        status: _parseStatus(j['status']),
        createdAt: DateTime.parse(j['created_at']).toLocal(),
        lastMessage: j['last_message'],
      );

  static TicketStatus _parseStatus(String? s) {
    switch (s) {
      case 'answered': return TicketStatus.answered;
      case 'closed': return TicketStatus.closed;
      default: return TicketStatus.open;
    }
  }
}

class TicketMessageModel {
  final String id;
  final String message;
  final bool isAdmin;
  final DateTime createdAt;

  const TicketMessageModel({
    required this.id,
    required this.message,
    required this.isAdmin,
    required this.createdAt,
  });

  factory TicketMessageModel.fromJson(Map<String, dynamic> j) => TicketMessageModel(
        id: j['id'],
        message: j['message'] ?? '',
        isAdmin: j['is_admin'] ?? false,
        createdAt: DateTime.parse(j['created_at']).toLocal(),
      );
}