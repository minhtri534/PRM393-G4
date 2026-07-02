import 'export_config_model.dart';

class ExportModel {
  final String id;
  final String projectId;
  final String? projectName;
  final String format;
  final String? exportedByUserId;
  final String? exportedByEmail;
  final String? exportPath;
  final DateTime? createdAt;
  final ExportConfigModel? config;

  ExportModel({
    required this.id,
    required this.projectId,
    this.projectName,
    required this.format,
    this.exportedByUserId,
    this.exportedByEmail,
    this.exportPath,
    this.createdAt,
    this.config,
  });

  factory ExportModel.fromJson(Map<String, dynamic> json) => ExportModel(
    id: json['id']?.toString() ?? '',
    projectId: json['projectId']?.toString() ?? '',
    projectName: json['projectName']?.toString(),
    format: json['format']?.toString() ?? '',
    exportedByUserId: json['exportedByUserId']?.toString(),
    exportedByEmail: json['exportedByEmail']?.toString(),
    exportPath: json['exportPath']?.toString(),
    createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
    config: json['config'] != null
        ? ExportConfigModel.fromJson(json['config'] as Map<String, dynamic>)
        : null,
  );
}
