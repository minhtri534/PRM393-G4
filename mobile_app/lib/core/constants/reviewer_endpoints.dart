/// Reviewer API endpoint paths (base URL already includes /api).
class ReviewerEndpoints {
  static const String projects = '/reviewer/projects';
  static const String submittedTasks = '/reviewer/tasks/submitted';
  static const String errorTypes = '/reviewer/error-types';

  static String labeledData(String taskId) =>
      '/reviewer/tasks/$taskId/labeled-data';
  static String taskContent(String taskId) => '/reviewer/tasks/$taskId/content';
  static String guidelineComparison(String taskId) =>
      '/reviewer/tasks/$taskId/guideline-comparison';
  static String consistencyValidation(String taskId) =>
      '/reviewer/tasks/$taskId/consistency-validation';
  static String approveTask(String taskId) => '/reviewer/tasks/$taskId/approve';
  static String returnTask(String taskId) => '/reviewer/tasks/$taskId/return';
}
