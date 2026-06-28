
class ChatMessage {
  final String id;
  final String conversationId;
  final String senderName;
  final String content;
  final DateTime createdAt;
  final bool isMe;

  ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderName,
    required this.content,
    required this.createdAt,
    required this.isMe,
  });
}