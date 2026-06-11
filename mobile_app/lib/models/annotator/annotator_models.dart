import '../../core/utils/task_display_utils.dart';

class AnnotatorTaskModel {
  final String id;
  final String projectId;
  final String dataItemId;
  final String status;
  final DateTime? assignedAt;
  final DateTime? completedAt;
  final String? projectName;
  final String? dataItemObjectKey;
  final String? datasetName;

  AnnotatorTaskModel({
    required this.id,
    required this.projectId,
    required this.dataItemId,
    required this.status,
    this.assignedAt,
    this.completedAt,
    this.projectName,
    this.dataItemObjectKey,
    this.datasetName,
  });

  String get displayTitle => TaskDisplayUtils.taskTitle(
        objectKey: dataItemObjectKey,
        datasetName: datasetName,
        projectName: projectName,
        fallbackId: id,
      );

  String get displaySubtitle => TaskDisplayUtils.taskSubtitle(
        projectName: projectName,
        datasetName: datasetName,
        status: status,
      );

  factory AnnotatorTaskModel.fromJson(Map<String, dynamic> json) {
    return AnnotatorTaskModel(
      id: json['id']?.toString() ?? '',
      projectId: json['projectId']?.toString() ?? '',
      dataItemId: json['dataItemId']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      assignedAt: DateTime.tryParse(json['assignedAt']?.toString() ?? ''),
      completedAt: DateTime.tryParse(json['completedAt']?.toString() ?? ''),
      projectName: json['projectName']?.toString(),
      dataItemObjectKey: json['dataItemObjectKey']?.toString(),
      datasetName: json['datasetName']?.toString(),
    );
  }

  AnnotatorTaskModel copyWith({
    String? id,
    String? projectId,
    String? dataItemId,
    String? status,
    DateTime? assignedAt,
    DateTime? completedAt,
    String? projectName,
    String? dataItemObjectKey,
    String? datasetName,
  }) {
    return AnnotatorTaskModel(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      dataItemId: dataItemId ?? this.dataItemId,
      status: status ?? this.status,
      assignedAt: assignedAt ?? this.assignedAt,
      completedAt: completedAt ?? this.completedAt,
      projectName: projectName ?? this.projectName,
      dataItemObjectKey: dataItemObjectKey ?? this.dataItemObjectKey,
      datasetName: datasetName ?? this.datasetName,
    );
  }
}

class AnnotatorTaskItemModel {
  final String taskId;
  final String dataItemId;
  final String storageProvider;
  final String objectKey;
  final int originalWidth;
  final int originalHeight;

  AnnotatorTaskItemModel({
    required this.taskId,
    required this.dataItemId,
    required this.storageProvider,
    required this.objectKey,
    required this.originalWidth,
    required this.originalHeight,
  });

  String get fileName =>
      TaskDisplayUtils.fileNameFromObjectKey(objectKey);

  factory AnnotatorTaskItemModel.fromJson(Map<String, dynamic> json) {
    return AnnotatorTaskItemModel(
      taskId: json['taskId']?.toString() ?? '',
      dataItemId: json['dataItemId']?.toString() ?? '',
      storageProvider: json['storageProvider']?.toString() ?? '',
      objectKey: json['objectKey']?.toString() ?? '',
      originalWidth: json['originalWidth'] as int? ?? 0,
      originalHeight: json['originalHeight'] as int? ?? 0,
    );
  }
}

class AnnotatorLabelModel {
  final String id;
  final String name;
  final int yoloClassId;

  AnnotatorLabelModel({
    required this.id,
    required this.name,
    required this.yoloClassId,
  });

  String get colorHex => _palette[yoloClassId % _palette.length];

  static const _palette = [
    '#2563eb',
    '#16a34a',
    '#dc2626',
    '#ca8a04',
    '#9333ea',
    '#0891b2',
    '#ea580c',
    '#4f46e5',
  ];

  factory AnnotatorLabelModel.fromJson(Map<String, dynamic> json) {
    return AnnotatorLabelModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      yoloClassId: json['yoloClassId'] as int? ?? 0,
    );
  }
}

class AnnotatorGuidelineModel {
  final String projectId;
  final String? guideline;

  AnnotatorGuidelineModel({
    required this.projectId,
    this.guideline,
  });

  factory AnnotatorGuidelineModel.fromJson(Map<String, dynamic> json) {
    return AnnotatorGuidelineModel(
      projectId: json['projectId']?.toString() ?? '',
      guideline: json['guideline']?.toString(),
    );
  }
}

class AnnotatorAnnotationModel {
  final String id;
  final String labelId;
  final dynamic geometryData;
  final bool isDraft;

  AnnotatorAnnotationModel({
    required this.id,
    required this.labelId,
    this.geometryData,
    this.isDraft = false,
  });

  factory AnnotatorAnnotationModel.fromJson(Map<String, dynamic> json) {
    return AnnotatorAnnotationModel(
      id: json['id']?.toString() ?? '',
      labelId: json['labelId']?.toString() ?? '',
      geometryData: json['geometryData'],
      isDraft: json['isDraft'] as bool? ?? false,
    );
  }
}
