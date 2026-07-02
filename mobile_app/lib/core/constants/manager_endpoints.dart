/// Manager API endpoint paths (base URL already includes /api).
class ManagerEndpoints {
  // Projects
  static const String projects = '/manager/projects';
  static String project(String id) => '/manager/projects/$id';
  static String projectStatus(String id) => '/manager/projects/$id/status';
  static String projectArchive(String id) => '/manager/projects/$id/archive';
  static String projectGuideline(String id) =>
      '/manager/projects/$id/guideline';
  static String projectRoles(String id) =>
      '/manager/projects/$id/project-roles';
  static const String projectRolesAssign = '/manager/project-roles';

  // Datasets
  static const String datasets = '/manager/datasets';
  static String dataset(String id) => '/manager/datasets/$id';
  static String projectDatasets(String projectId) =>
      '/manager/projects/$projectId/datasets';
  static const String datasetsUpload = '/manager/datasets/upload';
  static const String datasetsUploadFiles = '/manager/datasets/upload-files';
  static const String datasetsImportExternal =
      '/manager/datasets/import-external';
  static String datasetVersions(String datasetId) =>
      '/manager/datasets/$datasetId/versions';

  // Dataset versions
  static const String datasetVersionsCreate = '/manager/dataset-versions';
  static String datasetVersionRestore(String versionId) =>
      '/manager/dataset-versions/$versionId/restore';

  // Labels
  static const String labels = '/manager/labels';
  static String projectLabels(String projectId) =>
      '/manager/projects/$projectId/labels';
  static String label(String id) => '/manager/labels/$id';

  // Label categories
  static const String labelCategories = '/manager/label-categories';
  static String projectLabelCategories(String projectId) =>
      '/manager/projects/$projectId/label-categories';
  static String labelCategory(String id) => '/manager/label-categories/$id';

  // Annotation types
  static const String annotationTypes = '/manager/annotation-types';
  static String projectAnnotationTypes(String projectId) =>
      '/manager/projects/$projectId/annotation-types';
  static String annotationType(String id) => '/manager/annotation-types/$id';

  // Tasks
  static const String tasks = '/manager/tasks';
  static const String tasksBulkCreateByDataset =
      '/manager/tasks/bulk-create-by-dataset';
  static const String tasksBulkAssign = '/manager/tasks/bulk-assign';
  static String task(String id) => '/manager/tasks/$id';
  static String taskAssign(String id) => '/manager/tasks/$id/assign';
  static String taskReassign(String id) => '/manager/tasks/$id/reassign';
  static String taskPause(String id) => '/manager/tasks/$id/pause';
  static String taskResume(String id) => '/manager/tasks/$id/resume';
  static String taskCancel(String id) => '/manager/tasks/$id/cancel';
  static String taskRelabel(String id) => '/manager/tasks/$id/relabel';
  static String taskHistory(String id) => '/manager/tasks/$id/history';
  static String projectTasks(String projectId) =>
      '/manager/projects/$projectId/tasks';
  static String projectTaskProgress(String projectId) =>
      '/manager/projects/$projectId/tasks/progress';

  // Monitoring
  static String monitoringOverview(String projectId) =>
      '/manager/projects/$projectId/monitoring/overview';
  static String monitoringAnnotatorPerformance(String projectId) =>
      '/manager/projects/$projectId/monitoring/annotator-performance';
  static String monitoringReviewStats(String projectId) =>
      '/manager/projects/$projectId/monitoring/review-stats';
  static String monitoringInconsistentLabels(String projectId) =>
      '/manager/projects/$projectId/monitoring/inconsistent-labels';
  static String monitoringQualityReport(String projectId) =>
      '/manager/projects/$projectId/monitoring/quality-report';

  // Exports
  static const String exports = '/manager/exports';
  static String exportDownload(String exportId) =>
      '/manager/exports/$exportId/download';
  static String projectExports(String projectId) =>
      '/manager/projects/$projectId/exports';
  static String projectExportsValidate(String projectId) =>
      '/manager/projects/$projectId/exports/validate';

  // Activity logs
  static const String activityLogs = '/manager/activity-logs';

  // Users (Manager CRUD — use ManagerController; same auth as /manager/projects)
  static const String usersSearch = '/users/search';
  static const String users = '/manager/users';
  static String user(String id) => '/manager/users/$id';

  // Roles
  static const String roles = '/roles';

  // YOLO export (exports controller)
  static String yoloExportTask(String taskId) => '/exports/yolo/tasks/$taskId';
}

/// Default system role IDs used when assigning project members.
class ManagerRoleIds {
  static const String annotator = '000000000000000000000003';
  static const String reviewer = '000000000000000000000004';
}
