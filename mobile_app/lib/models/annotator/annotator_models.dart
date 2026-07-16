import 'dart:convert';

import '../../core/constants/app_constants.dart';
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

  String get fileName => TaskDisplayUtils.fileNameFromObjectKey(objectKey);

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

  AnnotatorGuidelineModel({required this.projectId, this.guideline});

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

  BboxGeometry? get bbox => BboxGeometry.tryParse(geometryData);

  factory AnnotatorAnnotationModel.fromJson(Map<String, dynamic> json) {
    return AnnotatorAnnotationModel(
      id: json['id']?.toString() ?? '',
      labelId: json['labelId']?.toString() ?? '',
      geometryData: json['geometryData'],
      isDraft: json['isDraft'] as bool? ?? false,
    );
  }
}

class BboxGeometry {
  final double x;
  final double y;
  final double width;
  final double height;

  const BboxGeometry({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  Map<String, dynamic> toJson() => {
    'type': 'bbox',
    'x': x.round(),
    'y': y.round(),
    'width': width.round(),
    'height': height.round(),
  };

  static BboxGeometry? tryParse(dynamic data) {
    try {
      dynamic decoded = data;
      if (decoded is String) {
        decoded = jsonDecode(decoded);
        if (decoded is String) {
          decoded = jsonDecode(decoded);
        }
      }
      if (decoded is! Map) return null;
      final map = Map<String, dynamic>.from(decoded);
      final x = _toDouble(map['x']);
      final y = _toDouble(map['y']);
      final width = _toDouble(map['width']);
      final height = _toDouble(map['height']);
      if (x == null || y == null || width == null || height == null) {
        return null;
      }
      return BboxGeometry(x: x, y: y, width: width, height: height);
    } catch (_) {
      return null;
    }
  }

  static double? _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}

class LabelingBox {
  final String? id;
  final String labelId;
  final double x;
  final double y;
  final double width;
  final double height;

  const LabelingBox({
    this.id,
    required this.labelId,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  factory LabelingBox.fromAnnotation(AnnotatorAnnotationModel annotation) {
    final bbox = annotation.bbox;
    return LabelingBox(
      id: annotation.id,
      labelId: annotation.labelId,
      x: bbox?.x ?? 0,
      y: bbox?.y ?? 0,
      width: bbox?.width ?? 0,
      height: bbox?.height ?? 0,
    );
  }

  LabelingBox copyWith({
    String? id,
    String? labelId,
    double? x,
    double? y,
    double? width,
    double? height,
  }) {
    return LabelingBox(
      id: id ?? this.id,
      labelId: labelId ?? this.labelId,
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
    );
  }

  Map<String, dynamic> toUpsertJson() => {
    'labelId': labelId,
    'geometryData': BboxGeometry(
      x: x,
      y: y,
      width: width,
      height: height,
    ).toJson(),
  };
}

class AnnotatorReviewFeedbackModel {
  final String reviewId;
  final String annotationSetId;
  final String result;
  final int score;
  final String? comment;
  final DateTime? reviewedAt;
  final List<AnnotatorReviewErrorModel> errorCategories;

  AnnotatorReviewFeedbackModel({
    required this.reviewId,
    required this.annotationSetId,
    required this.result,
    required this.score,
    this.comment,
    this.reviewedAt,
    this.errorCategories = const [],
  });

  factory AnnotatorReviewFeedbackModel.fromJson(Map<String, dynamic> json) {
    return AnnotatorReviewFeedbackModel(
      reviewId: json['reviewId']?.toString() ?? '',
      annotationSetId: json['annotationSetId']?.toString() ?? '',
      result: json['result']?.toString() ?? '',
      score: json['score'] as int? ?? 0,
      comment: json['comment']?.toString(),
      reviewedAt: DateTime.tryParse(json['reviewedAt']?.toString() ?? ''),
      errorCategories: (json['errorCategories'] as List<dynamic>? ?? [])
          .map(
            (e) =>
                AnnotatorReviewErrorModel.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}

class AnnotatorReviewErrorModel {
  final String errorTypeId;
  final String errorName;
  final String? description;

  AnnotatorReviewErrorModel({
    required this.errorTypeId,
    required this.errorName,
    this.description,
  });

  factory AnnotatorReviewErrorModel.fromJson(Map<String, dynamic> json) {
    return AnnotatorReviewErrorModel(
      errorTypeId: json['errorTypeId']?.toString() ?? '',
      errorName: json['errorName']?.toString() ?? '',
      description: json['description']?.toString(),
    );
  }
}

double annotatorTaskProgress(String status, int annotationCount) {
  switch (status) {
    case AppConstants.taskStatusSubmitted:
    case AppConstants.taskStatusApproved:
    case AppConstants.taskStatusCompleted:
      return 1.0;
    case AppConstants.taskStatusInProgress:
      if (annotationCount > 0) {
        return (0.4 + annotationCount * 0.15).clamp(0.0, 0.95);
      }
      return 0.3;
    case AppConstants.taskStatusReturned:
    case AppConstants.taskStatusRejected:
    case AppConstants.taskStatusRework:
      return annotationCount > 0 ? 0.5 : 0.2;
    case AppConstants.taskStatusAssigned:
    default:
      return 0.1;
  }
}

bool annotatorTaskNeedsReviewFeedback(String status) {
  return const {
    AppConstants.taskStatusReturned,
    AppConstants.taskStatusRejected,
    AppConstants.taskStatusRework,
    AppConstants.taskStatusCompleted,
    AppConstants.taskStatusSubmitted,
  }.contains(status);
}

bool annotatorTaskCanLabel(String status) {
  return const {
    AppConstants.taskStatusAssigned,
    AppConstants.taskStatusInProgress,
    AppConstants.taskStatusReturned,
    AppConstants.taskStatusRejected,
    AppConstants.taskStatusRework,
  }.contains(status);
}

String annotatorLabelingButtonLabel(String status) {
  if (status == AppConstants.taskStatusReturned ||
      status == AppConstants.taskStatusRejected ||
      status == AppConstants.taskStatusRework) {
    return 'Revise Labeling';
  }
  return 'Continue Labeling';
}
