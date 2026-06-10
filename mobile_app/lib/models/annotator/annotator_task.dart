class AnnotatorTask {
  final String id;
  final String projectId;
  final String dataItemId;
  final String status;
  final DateTime? assignedAt;
  final DateTime? completedAt;

  AnnotatorTask({
    required this.id,
    required this.projectId,
    required this.dataItemId,
    required this.status,
    this.assignedAt,
    this.completedAt,
  });

  factory AnnotatorTask.fromJson(Map<String, dynamic> json) {
    return AnnotatorTask(
      id: json['id'] ?? '',
      projectId: json['projectId'] ?? '',
      dataItemId: json['dataItemId'] ?? '',
      status: json['status'] ?? '',
      assignedAt: json['assignedAt'] != null
          ? DateTime.tryParse(json['assignedAt'])
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.tryParse(json['completedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'projectId': projectId,
        'dataItemId': dataItemId,
        'status': status,
        'assignedAt': assignedAt?.toIso8601String(),
        'completedAt': completedAt?.toIso8601String(),
      };
}
