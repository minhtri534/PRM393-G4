class ActivityLogModel {
  final String id;
  final String userId;
  final String? userEmail;
  final String action;
  final String? targetType;
  final String? targetId;
  final DateTime? createdAt;

  ActivityLogModel({
    required this.id,
    required this.userId,
    this.userEmail,
    required this.action,
    this.targetType,
    this.targetId,
    this.createdAt,
  });

  factory ActivityLogModel.fromJson(Map<String, dynamic> json) =>
      ActivityLogModel(
        id: json['id']?.toString() ?? '',
        userId: json['userId']?.toString() ?? '',
        userEmail: json['userEmail']?.toString(),
        action: json['action']?.toString() ?? '',
        targetType: json['targetType']?.toString(),
        targetId: json['targetId']?.toString(),
        createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      );
}
