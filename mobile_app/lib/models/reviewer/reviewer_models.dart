import '../annotator/annotator_models.dart';

class ReviewerSubmittedTaskModel {
  final String id;
  final String projectId;
  final String projectName;
  final String annotatorId;
  final String annotatorName;
  final String annotationSetId;
  final DateTime submittedAt;
  final int annotationCount;
  final String status;

  ReviewerSubmittedTaskModel({
    required this.id,
    required this.projectId,
    required this.projectName,
    required this.annotatorId,
    required this.annotatorName,
    required this.annotationSetId,
    required this.submittedAt,
    required this.annotationCount,
    required this.status,
  });

  String get displayTitle => 'Task ${id.length > 8 ? id.substring(id.length - 8) : id}';

  String get displaySubtitle =>
      'By $annotatorName · $annotationCount annotation${annotationCount == 1 ? '' : 's'}';

  factory ReviewerSubmittedTaskModel.fromJson(Map<String, dynamic> json) {
    return ReviewerSubmittedTaskModel(
      id: json['id']?.toString() ?? '',
      projectId: json['projectId']?.toString() ?? '',
      projectName: json['projectName']?.toString() ?? '',
      annotatorId: json['annotatorId']?.toString() ?? '',
      annotatorName: json['annotatorName']?.toString() ?? 'Unknown',
      annotationSetId: json['annotationSetId']?.toString() ?? '',
      submittedAt:
          DateTime.tryParse(json['submittedAt']?.toString() ?? '') ?? DateTime.now(),
      annotationCount: json['annotationCount'] as int? ?? 0,
      status: json['status']?.toString() ?? 'Submitted',
    );
  }
}

class ReviewerAnnotationItemModel {
  final String annotationId;
  final String labelId;
  final String labelName;
  final String annotationType;
  final dynamic geometryData;

  ReviewerAnnotationItemModel({
    required this.annotationId,
    required this.labelId,
    required this.labelName,
    required this.annotationType,
    required this.geometryData,
  });

  LabelingBox toLabelingBox() {
    final bbox = BboxGeometry.tryParse(geometryData);
    return LabelingBox(
      id: annotationId,
      labelId: labelId,
      x: bbox?.x ?? 0,
      y: bbox?.y ?? 0,
      width: bbox?.width ?? 0,
      height: bbox?.height ?? 0,
    );
  }

  AnnotatorLabelModel toLabelModel(int index) {
    return AnnotatorLabelModel(
      id: labelId,
      name: labelName,
      yoloClassId: index,
    );
  }

  factory ReviewerAnnotationItemModel.fromJson(Map<String, dynamic> json) {
    return ReviewerAnnotationItemModel(
      annotationId: json['annotationId']?.toString() ?? '',
      labelId: json['labelId']?.toString() ?? '',
      labelName: json['labelName']?.toString() ?? '',
      annotationType: json['annotationType']?.toString() ?? 'bbox',
      geometryData: json['geometryData'],
    );
  }
}

class ReviewerLabeledDataModel {
  final String taskId;
  final String annotationSetId;
  final String? guideline;
  final String storageProvider;
  final String objectKey;
  final List<ReviewerAnnotationItemModel> annotations;

  ReviewerLabeledDataModel({
    required this.taskId,
    required this.annotationSetId,
    this.guideline,
    required this.storageProvider,
    required this.objectKey,
    required this.annotations,
  });

  factory ReviewerLabeledDataModel.fromJson(Map<String, dynamic> json) {
    final raw = json['annotations'];
    return ReviewerLabeledDataModel(
      taskId: json['taskId']?.toString() ?? '',
      annotationSetId: json['annotationSetId']?.toString() ?? '',
      guideline: json['guideline']?.toString(),
      storageProvider: json['storageProvider']?.toString() ?? '',
      objectKey: json['objectKey']?.toString() ?? '',
      annotations: raw is List
          ? raw
              .map((item) => ReviewerAnnotationItemModel.fromJson(
                    item as Map<String, dynamic>,
                  ))
              .toList()
          : [],
    );
  }
}

class GuidelineComparisonModel {
  final String taskId;
  final String annotationSetId;
  final bool hasGuideline;
  final bool isAligned;
  final List<String> notes;

  GuidelineComparisonModel({
    required this.taskId,
    required this.annotationSetId,
    required this.hasGuideline,
    required this.isAligned,
    required this.notes,
  });

  factory GuidelineComparisonModel.fromJson(Map<String, dynamic> json) {
    final raw = json['notes'];
    return GuidelineComparisonModel(
      taskId: json['taskId']?.toString() ?? '',
      annotationSetId: json['annotationSetId']?.toString() ?? '',
      hasGuideline: json['hasGuideline'] as bool? ?? false,
      isAligned: json['isAligned'] as bool? ?? false,
      notes: raw is List ? raw.map((e) => e.toString()).toList() : [],
    );
  }
}

class LabelConsistencyModel {
  final String taskId;
  final String annotationSetId;
  final int totalAnnotations;
  final bool isConsistent;
  final List<String> issues;

  LabelConsistencyModel({
    required this.taskId,
    required this.annotationSetId,
    required this.totalAnnotations,
    required this.isConsistent,
    required this.issues,
  });

  factory LabelConsistencyModel.fromJson(Map<String, dynamic> json) {
    final raw = json['issues'];
    return LabelConsistencyModel(
      taskId: json['taskId']?.toString() ?? '',
      annotationSetId: json['annotationSetId']?.toString() ?? '',
      totalAnnotations: json['totalAnnotations'] as int? ?? 0,
      isConsistent: json['isConsistent'] as bool? ?? false,
      issues: raw is List ? raw.map((e) => e.toString()).toList() : [],
    );
  }
}

class ReviewerErrorTypeModel {
  final String id;
  final String name;
  final String? description;

  ReviewerErrorTypeModel({
    required this.id,
    required this.name,
    this.description,
  });

  factory ReviewerErrorTypeModel.fromJson(Map<String, dynamic> json) {
    return ReviewerErrorTypeModel(
      id: json['errorTypeId']?.toString() ?? json['id']?.toString() ?? '',
      name: json['errorName']?.toString() ?? json['name']?.toString() ?? '',
      description: json['description']?.toString(),
    );
  }
}
