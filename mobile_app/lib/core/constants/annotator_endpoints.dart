/// Annotator API endpoint paths (base URL already includes /api).
class AnnotatorEndpoints {
  static const String tasks = '/annotator/tasks';
  static String taskItems(String taskId) => '/annotator/tasks/$taskId/items';
  static String taskLabels(String taskId) => '/annotator/tasks/$taskId/labels';
  static String taskGuideline(String taskId) =>
      '/annotator/tasks/$taskId/guideline';
  static String taskDataItemContent(String taskId) =>
      '/annotator/tasks/$taskId/data-item/content';
  static String taskAccept(String taskId) => '/annotator/tasks/$taskId/accept';
  static String taskStart(String taskId) => '/annotator/tasks/$taskId/start';
  static String taskAnnotations(String taskId) =>
      '/annotator/tasks/$taskId/annotations';
  static String taskAnnotationsSubmit(String taskId) =>
      '/annotator/tasks/$taskId/annotations/submit';
}
