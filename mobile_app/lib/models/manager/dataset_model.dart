class DatasetModel {
  final String id;
  final String projectId;
  final String? projectName;
  final String name;
  final int? totalItems;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  DatasetModel({
    required this.id,
    required this.projectId,
    this.projectName,
    required this.name,
    this.totalItems,
    this.createdAt,
    this.updatedAt,
  });

  factory DatasetModel.fromJson(Map<String, dynamic> json) => DatasetModel(
    id: json['id']?.toString() ?? '',
    projectId: json['projectId']?.toString() ?? '',
    projectName: json['projectName']?.toString(),
    name: json['name']?.toString() ?? '',
    totalItems: json['totalItems'] as int?,
    createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
    updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? ''),
  );
}
