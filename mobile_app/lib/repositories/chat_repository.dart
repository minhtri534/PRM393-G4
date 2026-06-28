import 'dart:async';

import '../models/chat/conversation.dart';
import '../models/chat/message.dart';
import '../models/chat/send_message_request.dart';

class ChatRepository {
  Future<List<Conversation>> getConversations() async {
    await Future.delayed(const Duration(milliseconds: 600));

    return [
      Conversation(
        id: "1",
        participantNames: ["Manager", "John"],
        lastMessage: "Please update dataset",
        updatedAt: DateTime.now(),
        unreadCount: 2,
      ),
      Conversation(
        id: "2",
        participantNames: ["Manager", "Anna"],
        lastMessage: "Task completed",
        updatedAt: DateTime.now(),
        unreadCount: 0,
      ),
    ];
  }

  Future<List<ChatMessage>> getMessages(String conversationId) async {
    await Future.delayed(const Duration(milliseconds: 500));

    return [
      ChatMessage(
        id: "m1",
        conversationId: conversationId,
        senderName: "Manager",
        content: "Hello, how is your task?",
        createdAt: DateTime.now(),
        isMe: false,
      ),
      ChatMessage(
        id: "m2",
        conversationId: conversationId,
        senderName: "Me",
        content: "I'm working on it",
        createdAt: DateTime.now(),
        isMe: true,
      ),
    ];
  }

  Future<void> sendMessage(SendMessageRequest request) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }
}