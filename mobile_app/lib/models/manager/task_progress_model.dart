class TaskProgressModel {
  final String projectId;
  final int total;
  final int assigned;
  final int inProgress;
  final int submitted;
  final int completed;
  final int paused;
  final int cancelled;
  final int rework;

  TaskProgressModel({
    required this.projectId,
    required this.total,
    required this.assigned,
    required this.inProgress,
    required this.submitted,
    required this.completed,
    required this.paused,
    required this.cancelled,
    required this.rework,
  });

  factory TaskProgressModel.fromJson(Map<String, dynamic> json) =>
      TaskProgressModel(
        projectId: json['projectId']?.toString() ?? '',
        total: json['total'] as int? ?? 0,
        assigned: json['assigned'] as int? ?? 0,
        inProgress: json['inProgress'] as int? ?? 0,
        submitted: json['submitted'] as int? ?? 0,
        completed: json['completed'] as int? ?? 0,
        paused: json['paused'] as int? ?? 0,
        cancelled: json['cancelled'] as int? ?? 0,
        rework: json['rework'] as int? ?? 0,
      );
}