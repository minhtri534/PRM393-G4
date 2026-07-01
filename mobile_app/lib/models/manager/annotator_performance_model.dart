class AnnotatorPerformanceModel {
  final String annotatorId;
  final String annotatorEmail;
  final int assignedTasks;
  final int submittedTasks;
  final int completedTasks;

  AnnotatorPerformanceModel({
    required this.annotatorId,
    required this.annotatorEmail,
    required this.assignedTasks,
    required this.submittedTasks,
    required this.completedTasks,
  });

  factory AnnotatorPerformanceModel.fromJson(Map<String, dynamic> json) =>
      AnnotatorPerformanceModel(
        annotatorId: json['annotatorId']?.toString() ?? '',
        annotatorEmail: json['annotatorEmail']?.toString() ?? '',
        assignedTasks: json['assignedTasks'] as int? ?? 0,
        submittedTasks: json['submittedTasks'] as int? ?? 0,
        completedTasks: json['completedTasks'] as int? ?? 0,
      );
}