class NotificationModel {
  final String id;
  final String type;
  final String title;
  final String? body;
  final String? projectId;
  final String? projectName;
  final String? actorUserId;
  final String? actorFullName;
  final String? relatedEntityId;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    this.body,
    this.projectId,
    this.projectName,
    this.actorUserId,
    this.actorFullName,
    this.relatedEntityId,
    required this.isRead,
    required this.createdAt,
  });

  bool get isChatMessage => type == 'chat_message';
  bool get isProjectAnnounce => type == 'project_announce';
  bool get isProjectAssigned => type == 'project_assigned';

  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      id: id,
      type: type,
      title: title,
      body: body,
      projectId: projectId,
      projectName: projectName,
      actorUserId: actorUserId,
      actorFullName: actorFullName,
      relatedEntityId: relatedEntityId,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString(),
      projectId: json['projectId']?.toString(),
      projectName: json['projectName']?.toString(),
      actorUserId: json['actorUserId']?.toString(),
      actorFullName: json['actorFullName']?.toString(),
      relatedEntityId: json['relatedEntityId']?.toString(),
      isRead: json['isRead'] == true,
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}
