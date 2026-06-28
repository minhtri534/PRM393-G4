import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/chat_provider.dart';
import '../../widgets/chat/chat_message_bubble.dart';
import '../../widgets/chat/chat_input.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Chat"),
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: provider.messages.length,
                  itemBuilder: (context, index) {
                    return ChatMessageBubble(
                      message: provider.messages[index],
                    );
                  },
                ),
              ),

              ChatInput(
                onSend: (text) {
                  provider.sendMessage(text);
                },
              )
            ],
          ),
        );
      },
    );
  }
}