class InconsistentLabelModel {
  final String annotationId;
  final String taskId;
  final String labelId;
  final String issue;

  InconsistentLabelModel({
    required this.annotationId,
    required this.taskId,
    required this.labelId,
    required this.issue,
  });

  factory InconsistentLabelModel.fromJson(Map<String, dynamic> json) =>
      InconsistentLabelModel(
        annotationId: json['annotationId']?.toString() ?? '',
        taskId: json['taskId']?.toString() ?? '',
        labelId: json['labelId']?.toString() ?? '',
        issue: json['issue']?.toString() ?? '',
      );
}
