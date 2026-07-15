import '../constants/app_constants.dart';
import '../../models/annotator/annotator_models.dart';

/// Task list filtering helpers — keeps tab logic out of UI widgets.
class AnnotatorTaskFilters {
  static const Set<String> _todoStatuses = {
    AppConstants.taskStatusAssigned,
    AppConstants.taskStatusInProgress,
    AppConstants.taskStatusReturned,
    AppConstants.taskStatusRejected,
    AppConstants.taskStatusRework,
  };

  static const Set<String> _doneStatuses = {
    AppConstants.taskStatusSubmitted,
    AppConstants.taskStatusCompleted,
    AppConstants.taskStatusApproved,
  };

  static bool isTodo(String status) => _todoStatuses.contains(status);

  static bool isDone(String status) => _doneStatuses.contains(status);

  static List<AnnotatorTaskModel> filterByTab(
    List<AnnotatorTaskModel> tasks, {
    required bool showTodo,
  }) {
    return tasks
        .where((task) => showTodo ? isTodo(task.status) : isDone(task.status))
        .toList();
  }

  static int countTodo(List<AnnotatorTaskModel> tasks) =>
      tasks.where((task) => isTodo(task.status)).length;

  static int countDone(List<AnnotatorTaskModel> tasks) =>
      tasks.where((task) => isDone(task.status)).length;
}
