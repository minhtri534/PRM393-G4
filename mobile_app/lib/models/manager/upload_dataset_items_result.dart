class UploadDatasetItemsResult {
  final String datasetId;
  final int createdCount;

  UploadDatasetItemsResult({
    required this.datasetId,
    required this.createdCount,
  });

  factory UploadDatasetItemsResult.fromJson(Map<String, dynamic> json) =>
      UploadDatasetItemsResult(
        datasetId: json['datasetId']?.toString() ?? '',
        createdCount: json['createdCount'] as int? ?? 0,
      );
}