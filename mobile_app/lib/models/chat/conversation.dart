class Conversation {
  final String id;
  final List<String> participantNames;
  final String lastMessage;
  final DateTime updatedAt;
  final int unreadCount;

  Conversation({
    required this.id,
    required this.participantNames,
    required this.lastMessage,
    required this.updatedAt,
    required this.unreadCount,
  });
}
