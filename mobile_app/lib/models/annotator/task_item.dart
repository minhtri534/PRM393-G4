class TaskItem {
  final String taskId;
  final String dataItemId;
  final String storageProvider;
  final String objectKey;
  final int originalWidth;
  final int originalHeight;

  TaskItem({
    required this.taskId,
    required this.dataItemId,
    required this.storageProvider,
    required this.objectKey,
    required this.originalWidth,
    required this.originalHeight,
  });

  factory TaskItem.fromJson(Map<String, dynamic> json) {
    return TaskItem(
      taskId: json['taskId'] ?? '',
      dataItemId: json['dataItemId'] ?? '',
      storageProvider: json['storageProvider'] ?? '',
      objectKey: json['objectKey'] ?? '',
      originalWidth: json['originalWidth'] ?? 0,
      originalHeight: json['originalHeight'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'taskId': taskId,
        'dataItemId': dataItemId,
        'storageProvider': storageProvider,
        'objectKey': objectKey,
        'originalWidth': originalWidth,
        'originalHeight': originalHeight,
      };
}
