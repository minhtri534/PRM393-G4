class LabelingProgressOverviewModel {
  final String projectId;
  final int totalTasks;
  final int completedTasks;
  final int submittedTasks;
  final int activeTasks;

  LabelingProgressOverviewModel({
    required this.projectId,
    required this.totalTasks,
    required this.completedTasks,
    required this.submittedTasks,
    required this.activeTasks,
  });

  factory LabelingProgressOverviewModel.fromJson(Map<String, dynamic> json) =>
      LabelingProgressOverviewModel(
        projectId: json['projectId']?.toString() ?? '',
        totalTasks: json['totalTasks'] as int? ?? 0,
        completedTasks: json['completedTasks'] as int? ?? 0,
        submittedTasks: json['submittedTasks'] as int? ?? 0,
        activeTasks: json['activeTasks'] as int? ?? 0,
      );
}