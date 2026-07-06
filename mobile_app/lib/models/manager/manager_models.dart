/// User account status values from backend.
class UserAccountStatus {
  static const int active = 0;
  static const int pendingEmailVerification = 1;
}

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
        status: _parseInt(json['status']) ?? 0,
        createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
        updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? ''),
      );

  bool get isArchived => status == 9;
}

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

class LabelModel {
  final String id;
  final String projectId;
  final String name;
  final int yoloClassId;
  final String? categoryId;
  final String? annotationTypeId;

  LabelModel({
    required this.id,
    required this.projectId,
    required this.name,
    required this.yoloClassId,
    this.categoryId,
    this.annotationTypeId,
  });

  factory LabelModel.fromJson(Map<String, dynamic> json) => LabelModel(
        id: json['id']?.toString() ?? '',
        projectId: json['projectId']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        yoloClassId: json['yoloClassId'] as int? ?? 0,
        categoryId: json['categoryId']?.toString(),
        annotationTypeId: json['annotationTypeId']?.toString(),
      );
}

class LabelCategoryModel {
  final String id;
  final String projectId;
  final String name;
  final String? description;

  LabelCategoryModel({
    required this.id,
    required this.projectId,
    required this.name,
    this.description,
  });

  factory LabelCategoryModel.fromJson(Map<String, dynamic> json) =>
      LabelCategoryModel(
        id: json['id']?.toString() ?? '',
        projectId: json['projectId']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        description: json['description']?.toString(),
      );
}

class AnnotationTypeModel {
  final String id;
  final String projectId;
  final String name;
  final String? description;

  AnnotationTypeModel({
    required this.id,
    required this.projectId,
    required this.name,
    this.description,
  });

  factory AnnotationTypeModel.fromJson(Map<String, dynamic> json) =>
      AnnotationTypeModel(
        id: json['id']?.toString() ?? '',
        projectId: json['projectId']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        description: json['description']?.toString(),
      );
}

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

class TaskProgressModel {
  final String projectId;
  final int total;
  final int assigned;
  final int inProgress;
  final int submitted;
  final int completed;
  final int paused;
  final int cancelled;
  final int rework;

  TaskProgressModel({
    required this.projectId,
    required this.total,
    required this.assigned,
    required this.inProgress,
    required this.submitted,
    required this.completed,
    required this.paused,
    required this.cancelled,
    required this.rework,
  });

  factory TaskProgressModel.fromJson(Map<String, dynamic> json) =>
      TaskProgressModel(
        projectId: json['projectId']?.toString() ?? '',
        total: json['total'] as int? ?? 0,
        assigned: json['assigned'] as int? ?? 0,
        inProgress: json['inProgress'] as int? ?? 0,
        submitted: json['submitted'] as int? ?? 0,
        completed: json['completed'] as int? ?? 0,
        paused: json['paused'] as int? ?? 0,
        cancelled: json['cancelled'] as int? ?? 0,
        rework: json['rework'] as int? ?? 0,
      );
}

class TaskHistoryModel {
  final String id;
  final String taskId;
  final String? oldStatus;
  final String? newStatus;
  final String changedByUserId;
  final DateTime? changedAt;

  TaskHistoryModel({
    required this.id,
    required this.taskId,
    this.oldStatus,
    this.newStatus,
    required this.changedByUserId,
    this.changedAt,
  });

  factory TaskHistoryModel.fromJson(Map<String, dynamic> json) =>
      TaskHistoryModel(
        id: json['id']?.toString() ?? '',
        taskId: json['taskId']?.toString() ?? '',
        oldStatus: json['oldStatus']?.toString(),
        newStatus: json['newStatus']?.toString(),
        changedByUserId: json['changedByUserId']?.toString() ?? '',
        changedAt: DateTime.tryParse(json['changedAt']?.toString() ?? ''),
      );
}

class LabelingProgressOverviewModel {
  final String projectId;
  final int totalTasks;
  final int completedTasks;
  final int submittedTasks;
  final int activeTasks;

  LabelingProgressOverviewModel({
    required this.projectId,
    required this.totalTasks,
    required this.completedTasks,
    required this.submittedTasks,
    required this.activeTasks,
  });

  factory LabelingProgressOverviewModel.fromJson(Map<String, dynamic> json) =>
      LabelingProgressOverviewModel(
        projectId: json['projectId']?.toString() ?? '',
        totalTasks: json['totalTasks'] as int? ?? 0,
        completedTasks: json['completedTasks'] as int? ?? 0,
        submittedTasks: json['submittedTasks'] as int? ?? 0,
        activeTasks: json['activeTasks'] as int? ?? 0,
      );
}

class AnnotatorPerformanceModel {
  final String annotatorId;
  final String annotatorEmail;
  final int assignedTasks;
  final int submittedTasks;
  final int completedTasks;

  AnnotatorPerformanceModel({
    required this.annotatorId,
    required this.annotatorEmail,
    required this.assignedTasks,
    required this.submittedTasks,
    required this.completedTasks,
  });

  factory AnnotatorPerformanceModel.fromJson(Map<String, dynamic> json) =>
      AnnotatorPerformanceModel(
        annotatorId: json['annotatorId']?.toString() ?? '',
        annotatorEmail: json['annotatorEmail']?.toString() ?? '',
        assignedTasks: json['assignedTasks'] as int? ?? 0,
        submittedTasks: json['submittedTasks'] as int? ?? 0,
        completedTasks: json['completedTasks'] as int? ?? 0,
      );
}

class ReviewStatisticsModel {
  final String projectId;
  final int totalReviews;
  final int approvedReviews;
  final int rejectedReviews;
  final double averageScore;

  ReviewStatisticsModel({
    required this.projectId,
    required this.totalReviews,
    required this.approvedReviews,
    required this.rejectedReviews,
    required this.averageScore,
  });

  factory ReviewStatisticsModel.fromJson(Map<String, dynamic> json) =>
      ReviewStatisticsModel(
        projectId: json['projectId']?.toString() ?? '',
        totalReviews: json['totalReviews'] as int? ?? 0,
        approvedReviews: json['approvedReviews'] as int? ?? 0,
        rejectedReviews: json['rejectedReviews'] as int? ?? 0,
        averageScore: (json['averageScore'] as num?)?.toDouble() ?? 0,
      );
}

class InconsistentLabelModel {
  final String annotationId;
  final String taskId;
  final String labelId;
  final String issue;

  InconsistentLabelModel({
    required this.annotationId,
    required this.taskId,
    required this.labelId,
    required this.issue,
  });

  factory InconsistentLabelModel.fromJson(Map<String, dynamic> json) =>
      InconsistentLabelModel(
        annotationId: json['annotationId']?.toString() ?? '',
        taskId: json['taskId']?.toString() ?? '',
        labelId: json['labelId']?.toString() ?? '',
        issue: json['issue']?.toString() ?? '',
      );
}

class QualityReportModel {
  final LabelingProgressOverviewModel progress;
  final ReviewStatisticsModel reviewStats;
  final int inconsistentLabelsCount;

  QualityReportModel({
    required this.progress,
    required this.reviewStats,
    required this.inconsistentLabelsCount,
  });

  factory QualityReportModel.fromJson(Map<String, dynamic> json) =>
      QualityReportModel(
        progress: LabelingProgressOverviewModel.fromJson(
          json['progress'] as Map<String, dynamic>? ?? {},
        ),
        reviewStats: ReviewStatisticsModel.fromJson(
          json['reviewStats'] as Map<String, dynamic>? ?? {},
        ),
        inconsistentLabelsCount:
            json['inconsistentLabelsCount'] as int? ?? 0,
      );
}

class ExportConfigModel {
  final String labelFormat;
  final dynamic includeFields;
  final dynamic filters;

  ExportConfigModel({
    required this.labelFormat,
    this.includeFields,
    this.filters,
  });

  factory ExportConfigModel.fromJson(Map<String, dynamic> json) =>
      ExportConfigModel(
        labelFormat: json['labelFormat']?.toString() ?? '',
        includeFields: json['includeFields'],
        filters: json['filters'],
      );
}

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
            ? ExportConfigModel.fromJson(
                json['config'] as Map<String, dynamic>,
              )
            : null,
      );
}

class ExportValidationModel {
  final String projectId;
  final int submittedAnnotationSets;
  final int reviewedAnnotationSets;
  final bool isValid;

  ExportValidationModel({
    required this.projectId,
    required this.submittedAnnotationSets,
    required this.reviewedAnnotationSets,
    required this.isValid,
  });

  factory ExportValidationModel.fromJson(Map<String, dynamic> json) =>
      ExportValidationModel(
        projectId: json['projectId']?.toString() ?? '',
        submittedAnnotationSets: json['submittedAnnotationSets'] as int? ?? 0,
        reviewedAnnotationSets: json['reviewedAnnotationSets'] as int? ?? 0,
        isValid: json['isValid'] as bool? ?? false,
      );
}

class UserProjectRoleModel {
  final String userId;
  final String userEmail;
  final String projectId;
  final String? projectName;
  final String roleId;
  final String roleName;

  UserProjectRoleModel({
    required this.userId,
    required this.userEmail,
    required this.projectId,
    this.projectName,
    required this.roleId,
    required this.roleName,
  });

  factory UserProjectRoleModel.fromJson(Map<String, dynamic> json) =>
      UserProjectRoleModel(
        userId: json['userId']?.toString() ?? '',
        userEmail: json['userEmail']?.toString() ?? '',
        projectId: json['projectId']?.toString() ?? '',
        projectName: json['projectName']?.toString(),
        roleId: json['roleId']?.toString() ?? '',
        roleName: json['roleName']?.toString() ?? '',
      );
}

class ActivityLogModel {
  final String id;
  final String userId;
  final String? userEmail;
  final String action;
  final String? targetType;
  final String? targetId;
  final DateTime? createdAt;

  ActivityLogModel({
    required this.id,
    required this.userId,
    this.userEmail,
    required this.action,
    this.targetType,
    this.targetId,
    this.createdAt,
  });

  factory ActivityLogModel.fromJson(Map<String, dynamic> json) =>
      ActivityLogModel(
        id: json['id']?.toString() ?? '',
        userId: json['userId']?.toString() ?? '',
        userEmail: json['userEmail']?.toString(),
        action: json['action']?.toString() ?? '',
        targetType: json['targetType']?.toString(),
        targetId: json['targetId']?.toString(),
        createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      );
}

class UserSummaryModel {
  final String id;
  final String fullName;
  final String email;
  final String? roleName;

  UserSummaryModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.roleName,
  });

  factory UserSummaryModel.fromJson(Map<String, dynamic> json) =>
      UserSummaryModel(
        id: json['id']?.toString() ?? '',
        fullName: json['fullName']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        roleName: json['roleName']?.toString(),
      );
}

class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String? identifyNumber;
  final String? gender;
  final String? address;
  final DateTime? dateOfBirth;
  final String roleId;
  final String? roleName;
  final int status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    this.identifyNumber,
    this.gender,
    this.address,
    this.dateOfBirth,
    required this.roleId,
    this.roleName,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id']?.toString() ?? '',
        fullName: json['fullName']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        phoneNumber: json['phoneNumber']?.toString(),
        identifyNumber: json['identifyNumber']?.toString(),
        gender: json['gender']?.toString(),
        address: json['address']?.toString(),
        dateOfBirth: _parseDateOnly(json['dateOfBirth']),
        roleId: json['roleId']?.toString() ?? '',
        roleName: json['roleName']?.toString(),
        status: _parseInt(json['status']) ?? UserAccountStatus.active,
        createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
        updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? ''),
      );

  String get statusLabel => 'Active';
}

class RoleModel {
  final String id;
  final String name;

  RoleModel({required this.id, required this.name});

  factory RoleModel.fromJson(Map<String, dynamic> json) => RoleModel(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
      );

  bool get isAssignableByManager {
    final normalized = name.toLowerCase();
    return normalized == 'annotator' || normalized == 'reviewer';
  }
}

DateTime? _parseDateOnly(dynamic value) {
  if (value == null) return null;
  final raw = value.toString();
  if (raw.isEmpty) return null;
  return DateTime.tryParse(raw);
}

int? _parseInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}
