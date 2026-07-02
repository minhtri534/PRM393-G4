class SendMessageRequest {
  final String conversationId;
  final String content;

  SendMessageRequest({required this.conversationId, required this.content});

  Map<String, dynamic> toJson() {
    return {"conversationId": conversationId, "content": content};
  }
}
