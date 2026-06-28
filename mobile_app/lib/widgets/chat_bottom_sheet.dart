import 'package:flutter/material.dart';
import 'conversation_list_screen.dart';

class ChatBottomSheet {
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return const SizedBox(
          height: 600,
          child: ConversationListScreen(),
        );
      },
    );
  }
}