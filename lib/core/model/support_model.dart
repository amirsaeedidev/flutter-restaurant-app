enum MessageSender { user, support }

class ChatMessage {
  final String id;
  final String text;
  final MessageSender sender;
  final DateTime time;
  final bool isRead;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.sender,
    required this.time,
    this.isRead = false,
  });
}