import '../../core/constants/environment.dart';

class MyProjectSummaryModel {
  final String id;
  final String name;
  final String? guideline;
  final int todoTaskCount;
  final int doneTaskCount;
  final DateTime? lastChatMessageAt;
  final String? lastChatMessagePreview;

  MyProjectSummaryModel({
    required this.id,
    required this.name,
    this.guideline,
    required this.todoTaskCount,
    required this.doneTaskCount,
    this.lastChatMessageAt,
    this.lastChatMessagePreview,
  });

  factory MyProjectSummaryModel.fromJson(Map<String, dynamic> json) {
    return MyProjectSummaryModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      guideline: json['guideline']?.toString(),
      todoTaskCount: int.tryParse(json['todoTaskCount']?.toString() ?? '') ?? 0,
      doneTaskCount: int.tryParse(json['doneTaskCount']?.toString() ?? '') ?? 0,
      lastChatMessageAt: DateTime.tryParse(
        json['lastChatMessageAt']?.toString() ?? '',
      ),
      lastChatMessagePreview: json['lastChatMessagePreview']?.toString(),
    );
  }
}

class ChatMessageModel {
  final String id;
  final String projectId;
  final String senderUserId;
  final String senderFullName;
  final String messageType;
  final String? content;
  final String? attachmentFileName;
  final String? attachmentContentType;
  final int? attachmentSizeBytes;
  final String? attachmentUrl;
  final DateTime createdAt;

  ChatMessageModel({
    required this.id,
    required this.projectId,
    required this.senderUserId,
    required this.senderFullName,
    required this.messageType,
    this.content,
    this.attachmentFileName,
    this.attachmentContentType,
    this.attachmentSizeBytes,
    this.attachmentUrl,
    required this.createdAt,
  });

  bool get isText => messageType.toLowerCase() == 'text';
  bool get isImage => messageType.toLowerCase() == 'image';
  bool get isFile => messageType.toLowerCase() == 'file';

  String? resolveAttachmentUrl() {
    final raw = attachmentUrl;
    if (raw == null || raw.trim().isEmpty) return null;
    if (raw.startsWith('http://') || raw.startsWith('https://')) {
      return raw;
    }
    return '${Environment.apiOrigin}$raw';
  }

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id']?.toString() ?? '',
      projectId: json['projectId']?.toString() ?? '',
      senderUserId: json['senderUserId']?.toString() ?? '',
      senderFullName: json['senderFullName']?.toString() ?? 'Unknown',
      messageType: json['messageType']?.toString() ?? 'text',
      content: json['content']?.toString(),
      attachmentFileName: json['attachmentFileName']?.toString(),
      attachmentContentType: json['attachmentContentType']?.toString(),
      attachmentSizeBytes: int.tryParse(
        json['attachmentSizeBytes']?.toString() ?? '',
      ),
      attachmentUrl: json['attachmentUrl']?.toString(),
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}
