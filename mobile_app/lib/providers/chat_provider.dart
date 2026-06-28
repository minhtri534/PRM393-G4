import 'package:flutter/material.dart';

import '../models/chat/conversation.dart';
import '../models/chat/message.dart';
import '../models/chat/send_message_request.dart';
import '../repositories/chat_repository.dart';

class ChatProvider extends ChangeNotifier {
  final ChatRepository _repo = ChatRepository();

  List<Conversation> conversations = [];
  List<ChatMessage> messages = [];

  String? activeConversationId;

  bool loading = false;

  Future<void> loadConversations() async {
    loading = true;
    notifyListeners();

    conversations = await _repo.getConversations();

    loading = false;
    notifyListeners();
  }

  Future<void> openConversation(String id) async {
    activeConversationId = id;

    loading = true;
    notifyListeners();

    messages = await _repo.getMessages(id);

    loading = false;
    notifyListeners();
  }

  Future<void> sendMessage(String text) async {
    if (activeConversationId == null) return;

    final msg = SendMessageRequest(
      conversationId: activeConversationId!,
      content: text,
    );

    await _repo.sendMessage(msg);

    messages.add(
      ChatMessage(
        id: DateTime.now().toString(),
        conversationId: activeConversationId!,
        senderName: "Me",
        content: text,
        createdAt: DateTime.now(),
        isMe: true,
      ),
    );

    notifyListeners();
  }
}