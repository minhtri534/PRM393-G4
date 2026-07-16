/// Application-wide constants
class AppConstants {
  // Timeouts
  static const Duration httpTimeout = Duration(seconds: 30);
  static const Duration retryDelay = Duration(seconds: 2);
  static const int maxRetries = 3;

  // Storage keys
  static const String tokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userProfileKey = 'user_profile';

  // Task statuses
  static const String taskStatusAssigned = 'Assigned';
  static const String taskStatusInProgress = 'InProgress';
  static const String taskStatusSubmitted = 'Submitted';
  static const String taskStatusApproved = 'Approved';
  static const String taskStatusRejected = 'Rejected';
  static const String taskStatusReturned = 'Returned';
  static const String taskStatusRework = 'Rework';
  static const String taskStatusCompleted = 'Completed';
  static const String taskStatusCancelled = 'Cancelled';
  
  // Error messages
  static const String errorNetworkConnection = 'Network connection error';
  static const String errorUnauthorized = 'Unauthorized access';
  static const String errorServerError = 'Server error occurred';
  static const String errorInvalidInput = 'Invalid input provided';
  static const String errorTaskNotFound = 'Task not found';
  static const String errorGeneric = 'An error occurred. Please try again.';

  // UI Constants
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;
  static const double borderRadiusXL = 14.0;

  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;

  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;

  // Manager Constants
  //// Shell Screen
  static const String managerShellRoleTitle = 'Manager';
  static const String managerShellTabProjects = 'Projects';
  static const String managerShellTabDatasets = 'Datasets';
  static const String managerShellTabUsers = 'Users';
  static const String managerShellTabProjectsNewProject = 'New Project';
  static const String managerShellTabDatasetUploadDataset = 'Upload Dataset';
  static const String managerShellTabUsersNewUser = 'New User';
  //// Project List Screen
  static const String managerProjectListTitle = 'Project Management';
  static const String managerProjectListSubtitle = 'View and manage data labeling projects';
  static const String managerProjectListProjectLoadError = 'Failed to load projects';
  static const String managerProjectListNoProjects = 'No projects yet';
  static const String managerProjectListAlertProjectArchived = 'Project archived';
  //// Project Detail Screen
  static const String managerProjectDetailTabOverview = 'Overview';
  static const String managerProjectDetailTabData = 'Data';
  static const String managerProjectDetailTabTasks = 'Tasks';
  static const String managerProjectDetailTabMonitor = 'Monitor';
  static const String managerProjectDetailTabExports = 'Exports';
  static const String managerProjectDetailTabSettings = 'Settings';
  static const String managerProjectDetailErrorProjectNotFound = 'Project not found';
  static const String managerProjectDetailProjectChat = 'Project chat';
  ////// Overview Tab
  static const String managerProjectDetailOverviewGuidelines = 'Guideline';
  static const String managerProjectDetailOverviewProjectGuidelines = 'Project Guideline';
  static const String managerProjectDetailOverviewGuidelinesHint = 'Instructions for annotators';
  static const String managerProjectDetailOverviewSaveGuideline = 'Save Guideline';
  static const String managerProjectDetailOverviewTeamMembers = 'Team Members';
  static const String managerProjectDetailOverviewRemove = 'Remove';
  static const String managerProjectDetailOverviewSearch = 'Search user to assign';
  static const String managerProjectDetailOverviewSearchHint = 'Type name or email';
  static const String managerProjectDetailOverviewAssign = 'Assign';
  ////// Data Tab
  static const String managerProjectDetailDataDataSet = 'Datasets';
  static const String managerProjectDetailDataNewDataSet = 'New dataset name';
  static const String managerProjectDetailDataDataSetName = 'Dataset name';
  static const String managerProjectDetailDataLabels = 'Labels';
  static const String managerProjectDetailDataLabelName = 'Label name';
  static const String managerProjectDetailDataLabelNameHint = 'e.g. Car';
  static const String managerProjectDetailDataID = 'ID';
  static const String managerProjectDetailDataEditLabel = 'Edit Label';
  static const String managerProjectDetailDataEditLabelName = 'Name';
  static const String managerProjectDetailDataEditLabelCancel = 'Cancel';
  static const String managerProjectDetailDataEditLabelSave = 'Save';
  ////// Tasks Tab
  static const String managerProjectDetailTasksCreateTasks = 'Create Tasks';
  static const String managerProjectDetailTasksTotal = 'Total';
  static const String managerProjectDetailTasksAssigned = 'Assigned';
  static const String managerProjectDetailTasksInProgress = 'In Progress';
  static const String managerProjectDetailTasksSubmitted = 'Submitted';
  static const String managerProjectDetailTasksCompleted = 'Completed';
  static const String managerProjectDetailTasksRework = 'Rework';
  static const String managerProjectDetailTasksTaskHistory = 'Task History';
  static const String managerProjectDetailTasksNoHistory = 'No history';
  static const String managerProjectDetailTasksRequestRelabel = 'Request Relabel';
  static const String managerProjectDetailTasksRelabelReason = 'Reason';
  static const String managerProjectDetailTasksRelabelCancel = 'Cancel';
  static const String managerProjectDetailTasksRelabelSubmit = 'Submit';
  static const String managerProjectDetailTasksActionPause = 'Pause';
  static const String managerProjectDetailTasksActionResume = 'Resume';
  static const String managerProjectDetailTasksActionCancel = 'Cancel';
  static const String managerProjectDetailTasksActionHistory = 'History';
  static const String managerProjectDetailTasksActionRelabel = 'Relabel';
  static const String managerProjectDetailTasksActionAssign = 'Assign';
  static const String managerProjectDetailTasksActionReassign = 'Reassign';
  ////// Monitoring Tab
  static const String managerProjectDetailMonitorCompletion = 'Completion';
  static const String managerProjectDetailMonitorTasksCompleted = 'tasks completed';
  static const String managerProjectDetailMonitorReviewStats = 'Review Stats';
  static const String managerProjectDetailMonitorApproved = 'Approved';
  static const String managerProjectDetailMonitorRejected = 'Rejected';
  static const String managerProjectDetailMonitorAnnotatorPerformance = 'Annotator Performance';
  static const String managerProjectDetailMonitorAssigned = 'Assigned';
  static const String managerProjectDetailMonitorSubmitted = 'Submitted';
  static const String managerProjectDetailMonitorDone = 'Done';
  ////// Export Tab
  static const String managerProjectDetailExportWebDownloadWarning = 'Download is not supported on web.';
  static String managerProjectDetailExportOpenedExport(String fileType) => 'Opened $fileType export';
  static const String managerProjectDetailExportOpenError = 'Cannot open export';
  static const String managerProjectDetailExportReady = 'Ready to export';
  static const String managerProjectDetailExportNotReady = 'Not ready';
  static const String managerProjectDetailExportAllReviewed = 'All submitted annotation sets have been reviewed.';
  static String managerProjectDetailExportSubmittedReviewedCount(int submitted, int reviewed) => 'Submitted: $submitted • Reviewed: $reviewed. ';
  static const String managerProjectDetailExportExportWarning = 'Export still works, but annotations/reviews may be empty until tasks are reviewed.';
  static const String managerProjectDetailExportInfo = 'Export project labeling data as a JSON file (labels, tasks, approved annotations, reviews).';
  static const String managerProjectDetailExportCreateExport = 'Create JSON Export';
  static const String managerProjectDetailExportExportCreated = 'Export created. Tap download to open the JSON file.';
  static const String managerProjectDetailExportHistory = 'Export History';
  static const String managerProjectDetailExportNoExports = 'No exports yet';
  static const String managerProjectDetailExportDownload = 'Download JSON';
  static const String managerProjectDetailExportActivityLog = 'Activity Log';
  ///// Settings Tab
  static const String managerProjectDetailSettingsProjectName = 'Project Name';
  static const String managerProjectDetailSettingsStatus = 'Status';
  static const String managerProjectDetailSettingsStatusActive = 'Active';
  static const String managerProjectDetailSettingsStatusPaused = 'Paused';
  static const String managerProjectDetailSettingsStatusArchived = 'Archived';
  static const String managerProjectDetailSettingsSave = 'Save Project';
  static const String managerProjectDetailSettingsDeleteProject = 'Delete Project';
  static const String managerProjectDetailSettingsDeleteConfirm = 'Delete Project?';
  static const String managerProjectDetailSettingsDeleteWarning = 'This action cannot be undone.';
  static const String managerProjectDetailSettingsDeleteCancel = 'Cancel';
  static const String managerProjectDetailSettingsDelete = 'Delete';
}
