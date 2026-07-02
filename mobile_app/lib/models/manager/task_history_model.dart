class TaskHistoryModel {
  final String id;
  final String taskId;
  final String? oldStatus;
  final String? newStatus;
  final String changedByUserId;
  final DateTime? changedAt;

  TaskHistoryModel({
    required this.id,
    required this.taskId,
    this.oldStatus,
    this.newStatus,
    required this.changedByUserId,
    this.changedAt,
  });

  factory TaskHistoryModel.fromJson(Map<String, dynamic> json) =>
      TaskHistoryModel(
        id: json['id']?.toString() ?? '',
        taskId: json['taskId']?.toString() ?? '',
        oldStatus: json['oldStatus']?.toString(),
        newStatus: json['newStatus']?.toString(),
        changedByUserId: json['changedByUserId']?.toString() ?? '',
        changedAt: DateTime.tryParse(json['changedAt']?.toString() ?? ''),
      );
}
