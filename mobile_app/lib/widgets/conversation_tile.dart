import 'package:flutter/material.dart';
import '../../models/chat/conversation.dart';

class ConversationTile extends StatelessWidget {
  final Conversation conversation;
  final VoidCallback onTap;

  const ConversationTile({
    super.key,
    required this.conversation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      title: Text(conversation.participantNames.join(", ")),
      subtitle: Text(conversation.lastMessage),
      trailing: conversation.unreadCount > 0
          ? CircleAvatar(
              radius: 10,
              child: Text(
                conversation.unreadCount.toString(),
                style: const TextStyle(fontSize: 12),
              ),
            )
          : null,
    );
  }
}
