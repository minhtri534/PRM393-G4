class ChatEndpoints {
  static const String projects = '/chat/projects';
  static String projectMessages(String projectId) =>
      '/chat/projects/$projectId/messages';
  static String projectAttachment(String projectId) =>
      '/chat/projects/$projectId/messages/attachment';
  static String messageAttachment(String messageId) =>
      '/chat/messages/$messageId/attachment';
}
