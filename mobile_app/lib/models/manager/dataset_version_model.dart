class DatasetVersionModel {
  final String id;
  final String datasetId;
  final String versionName;
  final DateTime? createdAt;

  DatasetVersionModel({
    required this.id,
    required this.datasetId,
    required this.versionName,
    this.createdAt,
  });

  factory DatasetVersionModel.fromJson(Map<String, dynamic> json) =>
      DatasetVersionModel(
        id: json['id']?.toString() ?? '',
        datasetId: json['datasetId']?.toString() ?? '',
        versionName: json['versionName']?.toString() ?? '',
        createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      );
}