import '../../core/utils/value_parser.dart';

class ProjectModel {
  final String id;
  final String name;
  final String? guideline;
  final int status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ProjectModel({
    required this.id,
    required this.name,
    this.guideline,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) => ProjectModel(
    id: json['id']?.toString() ?? '',
    name: json['name']?.toString() ?? '',
    guideline: json['guideline']?.toString(),
    status: parseInt(json['status']) ?? 0,
    createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
    updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? ''),
  );

  bool get isArchived => status == 9;
}