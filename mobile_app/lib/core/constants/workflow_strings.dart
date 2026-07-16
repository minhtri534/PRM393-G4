/// User-facing copy for annotator and reviewer workflows.
class WorkflowStrings {
  // Annotator — projects & tasks
  static const String annotatorProjectsTitle = 'My Projects';
  static const String annotatorProjectsSubtitle =
      'Choose a project to view your assigned labeling tasks.';
  static const String annotatorNoProjects = 'No projects yet.';
  static const String annotatorNoProjectsHint =
      'Ask your manager to add you to a project.';

  static const String annotatorWorkspaceTitle = 'Workspace';
  static const String annotatorWorkspaceSubtitle =
      'View assigned tasks and track annotation progress.';
  static const String annotatorTasksTitle = 'Tasks';
  static const String annotatorTasksSubtitleFallback =
      'Assigned labeling tasks in this project.';
  static const String annotatorNoTodoTasks = 'You have no tasks to do.';
  static const String annotatorNoDoneTasks =
      "You haven't completed any tasks yet.";
  static const String annotatorNoProjectTodoTasks =
      'No tasks to do in this project.';
  static const String annotatorNoProjectDoneTasks =
      'No completed tasks in this project yet.';

  static const String annotatorTaskDetails = 'Task Details';
  static const String annotatorTaskDescription = 'Task Description';
  static const String annotatorGuidelines = 'Guidelines';
  static const String annotatorNoGuideline =
      'No specific guideline for this project.';
  static const String annotatorLabels = 'Labels';
  static const String annotatorNoLabels = 'No labels configured';
  static const String annotatorStatus = 'Status';
  static const String annotatorReviewFeedback = 'Review Feedback';

  static const String annotatorAcceptTask = 'Accept Task';
  static const String annotatorStartLabeling = 'Start Labeling';
  static const String annotatorRejectTask = 'Reject Task';
  static const String annotatorContinueLabeling = 'Continue Labeling';
  static const String annotatorReviseLabeling = 'Revise Labeling';
  static const String annotatorViewLabeling = 'View Labeling';
  static const String annotatorChatWithTeam = 'Chat with project team';

  static const String annotatorRejectDialogTitle = 'Reject task?';
  static const String annotatorRejectReasonLabel = 'Reason (optional)';
  static const String annotatorRejectReasonHint =
      'Why are you rejecting this task?';
  static const String annotatorTaskAccepted = 'Task accepted';
  static const String annotatorTaskRejected = 'Task rejected';

  // Annotator — labeling
  static const String annotatorLabelingTitle = 'Labeling';
  static const String annotatorNoProjectLabels =
      'No labels configured for this project.';
  static const String annotatorDeleteSelectedBox = 'Delete selected box';
  static const String annotatorSaveDraft = 'Save Draft';
  static const String annotatorSubmit = 'Submit';
  static const String annotatorDraftSaved = 'Draft saved';
  static const String annotatorSubmitted = 'Task submitted successfully';

  // Reviewer — projects & tasks
  static const String reviewerProjectsTitle = 'My Projects';
  static const String reviewerProjectsSubtitle =
      'Choose a project to review submitted labeling tasks.';
  static const String reviewerNoProjects = 'No reviewer projects yet.';
  static const String reviewerNoProjectsHint =
      'Ask your manager to assign you as a reviewer on a project.';

  static const String reviewerPendingReview = 'Pending Review';
  static const String reviewerPendingReviewSubtitle =
      'Submitted tasks waiting for your review.';
  static const String reviewerNoPendingTasks = 'No tasks pending review.';
  static const String reviewerPendingBadge = 'Submitted';

  static const String reviewerProjectGuideline = 'Project Guideline';
  static const String reviewerAnnotations = 'Annotations';
  static const String reviewerErrorTypes = 'Error types (optional)';
  static const String reviewerCommentLabel = 'Comment / feedback';
  static const String reviewerCommentHint = 'Required when returning a task';
  static const String reviewerValidationInsights = 'Validation insights';
  static const String reviewerImageUnavailable = 'Image not available';
  static const String reviewerNoLabeledData = 'No labeled data available';

  static const String reviewerReturn = 'Return';
  static const String reviewerApprove = 'Approve';
  static const String reviewerApproved = 'Task approved successfully';
  static const String reviewerReturned = 'Task returned with feedback';
  static const String reviewerFeedbackRequired =
      'Please provide feedback before returning';

  // Shared tabs
  static String todoTabLabel(int count) => 'To Do ($count)';
  static String doneTabLabel(int count) => 'Done ($count)';
}
