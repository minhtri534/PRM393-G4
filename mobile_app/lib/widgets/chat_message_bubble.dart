import 'package:flutter/material.dart';
import '../../models/chat/message.dart';

class ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatMessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final align =
        message.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;

    final color =
        message.isMe ? Colors.blue : Colors.grey.shade300;

    final textColor =
        message.isMe ? Colors.white : Colors.black87;

    return Column(
      crossAxisAlignment: align,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.all(10),
          constraints: const BoxConstraints(maxWidth: 260),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            message.content,
            style: TextStyle(color: textColor),
          ),
        )
      ],
    );
  }
}