class ManagerTaskModel {
  final String id;
  final String projectId;
  final String dataItemId;
  final String annotatorId;
  final String? assignedByUserId;
  final String status;
  final DateTime? assignedAt;
  final DateTime? completedAt;
  final String? dataItemObjectKey;
  final String? datasetName;
  final String? annotatorEmail;

  ManagerTaskModel({
    required this.id,
    required this.projectId,
    required this.dataItemId,
    required this.annotatorId,
    this.assignedByUserId,
    required this.status,
    this.assignedAt,
    this.completedAt,
    this.dataItemObjectKey,
    this.datasetName,
    this.annotatorEmail,
  });

  String get displayTitle {
    final key = dataItemObjectKey;
    if (key != null && key.isNotEmpty) {
      final parts = key.replaceAll('\\', '/').split('/');
      if (parts.last.isNotEmpty) return parts.last;
    }
    if (datasetName != null && datasetName!.isNotEmpty) return datasetName!;
    return 'Task ${id.length >= 8 ? id.substring(0, 8) : id}';
  }

  factory ManagerTaskModel.fromJson(Map<String, dynamic> json) =>
      ManagerTaskModel(
        id: json['id']?.toString() ?? '',
        projectId: json['projectId']?.toString() ?? '',
        dataItemId: json['dataItemId']?.toString() ?? '',
        annotatorId: json['annotatorId']?.toString() ?? '',
        assignedByUserId: json['assignedByUserId']?.toString(),
        status: json['status']?.toString() ?? '',
        assignedAt: DateTime.tryParse(json['assignedAt']?.toString() ?? ''),
        completedAt: DateTime.tryParse(json['completedAt']?.toString() ?? ''),
        dataItemObjectKey: json['dataItemObjectKey']?.toString(),
        datasetName: json['datasetName']?.toString(),
        annotatorEmail: json['annotatorEmail']?.toString(),
      );
}