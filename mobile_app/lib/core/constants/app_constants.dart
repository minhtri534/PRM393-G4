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
  static const String managerProjectListSubtitle =
      'View and manage data labeling projects';
  static const String managerProjectListProjectLoadError =
      'Failed to load projects';
  static const String managerProjectListNoProjects = 'No projects yet';
  static const String managerProjectListAlertProjectArchived =
      'Project archived';
  //// Project Detail Screen
  static const String managerProjectDetailTabOverview = 'Overview';
  static const String managerProjectDetailTabData = 'Data';
  static const String managerProjectDetailTabTasks = 'Tasks';
  static const String managerProjectDetailTabMonitor = 'Monitor';
  static const String managerProjectDetailTabExports = 'Exports';
  static const String managerProjectDetailTabSettings = 'Settings';
  static const String managerProjectDetailErrorProjectNotFound =
      'Project not found';
  static const String managerProjectDetailProjectChat = 'Project chat';
  ////// Overview Tab
  static const String managerProjectDetailOverviewGuidelines = 'Guideline';
  static const String managerProjectDetailOverviewProjectGuidelines =
      'Project Guideline';
  static const String managerProjectDetailOverviewGuidelinesHint =
      'Instructions for annotators';
  static const String managerProjectDetailOverviewSaveGuideline =
      'Save Guideline';
  static const String managerProjectDetailOverviewTeamMembers = 'Team Members';
  static const String managerProjectDetailOverviewRemove = 'Remove';
  static const String managerProjectDetailOverviewSearch =
      'Search user to assign';
  static const String managerProjectDetailOverviewSearchHint =
      'Type name or email';
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
  static const String managerProjectDetailTasksRequestRelabel =
      'Request Relabel';
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
  static const String managerProjectDetailMonitorTasksCompleted =
      'tasks completed';
  static const String managerProjectDetailMonitorReviewStats = 'Review Stats';
  static const String managerProjectDetailMonitorApproved = 'Approved';
  static const String managerProjectDetailMonitorRejected = 'Rejected';
  static const String managerProjectDetailMonitorAnnotatorPerformance =
      'Annotator Performance';
  static const String managerProjectDetailMonitorAssigned = 'Assigned';
  static const String managerProjectDetailMonitorSubmitted = 'Submitted';
  static const String managerProjectDetailMonitorDone = 'Done';
  ////// Export Tab
  static const String managerProjectDetailExportWebDownloadWarning =
      'Download is not supported on web.';
  static String managerProjectDetailExport(String id, String extension) =>
      'dlss-export-$id$extension';
  static String managerProjectDetailExportOpenedExport(String fileType) =>
      'Opened $fileType export';
  static const String managerProjectDetailExportOpenError =
      'Cannot open export';
  static const String managerProjectDetailExportReady = 'Ready to export';
  static const String managerProjectDetailExportNotReady = 'Not ready';
  static const String managerProjectDetailExportAllReviewed =
      'All submitted annotation sets have been reviewed.';
  static String managerProjectDetailExportSubmittedReviewedCount(
    int submitted,
    int reviewed,
  ) => 'Submitted: $submitted • Reviewed: $reviewed. ';
  static const String managerProjectDetailExportExportWarning =
      'Export still works, but annotations/reviews may be empty until tasks are reviewed.';
  static const String managerProjectDetailExportInfo =
      'Export project labeling data as a JSON file (labels, tasks, approved annotations, reviews).';
  static const String managerProjectDetailExportCreateExport =
      'Create JSON Export';
  static const String managerProjectDetailExportExportCreated =
      'Export created. Tap download to open the JSON file.';
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
  static const String managerProjectDetailSettingsDeleteProject =
      'Delete Project';
  static const String managerProjectDetailSettingsDeleteConfirm =
      'Delete Project?';
  static const String managerProjectDetailSettingsDeleteWarning =
      'This action cannot be undone.';
  static const String managerProjectDetailSettingsDeleteCancel = 'Cancel';
  static const String managerProjectDetailSettingsDelete = 'Delete';
  //// Project Create Screen
  static const String managerProjectCreateCreateProjectBar = 'Create Project';
  static const String managerProjectCreateNewProjectTitle = 'New Project';
  static const String managerProjectCreateNewProjectSubtitle =
      'Set up a data labeling project for your team';
  static const String managerProjectCreateProjectName = 'Project Name';
  static const String managerProjectCreateProjectNameHint =
      'Enter project name';
  static const String managerProjectCreateProjectNameMissing =
      'Name is required';
  static const String managerProjectCreateGuideline = 'Guideline (optional)';
  static const String managerProjectCreateGuidelineHint =
      'Labeling instructions for annotators';
  static const String managerProjectCreateCreateProject = 'Create Project';
  //// Dataset List Screen
  static const String managerDatasetListDatasetsTitle = 'Datasets';
  static const String managerDatasetListDatasetsSubtitle =
      'Browse and manage uploaded datasets';
  static const String managerDatasetListSearch = 'Search datasets...';
  static const String managerDatasetListLoadError = 'Failed to load datasets';
  static const String managerDatasetListNoDatasets = 'No datasets found';
  //// Dataset Detail Screen
  static const String managerDatasetDetailDatasetNotFound = 'Dataset not found';
  static const String managerDatasetDetailDatasetDetailsSubtitle =
      'Dataset details';
  static const String managerDatasetDetailDatasetProject = 'Project';
  static String managerDatasetDetailItem(int numberOfItems) =>
      '$numberOfItems items';
  static const String managerDatasetDetailActive = 'Active';
  static const String managerDatasetDetailSettings = 'Dataset settings';
  static const String managerDatasetDetailName = 'Dataset Name';
  static const String managerDatasetDetailRename = 'Rename dataset';
  static const String managerDatasetDetailSave = 'Save Name';
  static const String managerDatasetDetailAddFiles = 'Add More Files';
  static const String managerDatasetDetailDelete = 'Delete Dataset';
  //// Dataset Upload Screen
  static const String managerDatasetUploadMissingInputError =
      'Select project, name, and files';
  static const String managerDatasetUploadFileReadError =
      'Could not read selected files';
  static const String managerDatasetUploadUploadSuccess =
      'Dataset uploaded successfully';
  static const String managerDatasetUploadUploadDataset = 'Upload Dataset';
  static const String managerDatasetUploadUploadDatasetSubtitle =
      'Add image files to a project dataset';
  static const String managerDatasetUploadProject = 'Project';
  static const String managerDatasetUploadName = 'Dataset Name';
  static const String managerDatasetUploadNameHint =
      'e.g. Street Images Batch 1';
  static const String managerDatasetUploadNoFilesSelected = 'No files selected';
  static String managerDatasetUploadFilesSelected(int numberOfFiles) =>
      '$numberOfFiles files(s) selected';
  static const String managerDatasetUploadSelectFiles = 'Select image files';
  static const String managerDatasetUploadChangeSelection = 'Change selection';
  static const String managerDatasetUploadUpload = 'Upload';
  //// Task Create Screen
  static const String managerTaskCreateCreateTask = 'Create Tasks';
  static const String managerTaskCreateAssignTasks = 'Assign Tasks';
  static const String managerTaskCreateAssignTasksSubtitle =
      'Create labeling tasks for annotators';
  static const String managerTaskCreateAssignBulk = 'Bulk by Dataset';
  static const String managerTaskCreateAssignSingle = 'Single Task';
  static const String managerTaskCreateProject = 'Project';
  static const String managerTaskCreateDataset = 'Dataset';
  static String managerTaskCreateItems(String id, int total) =>
      '$id ($total items)';
  static const String managerTaskCreateIDLabel = 'Data Item ID';
  static const String managerTaskCreateIDHint = 'UUID of data item';
  static const String managerTaskCreateAnnotator = 'Annotator';
  static const String managerTaskCreateSingleCreateTask = 'Create Task';
  static const String managerTaskCreateBulkCreateTask = 'Bulk Create Tasks';
  static const String managerTaskCreateAssignMissingDataError =
      'Select project and annotator';
  static const String managerTaskCreateAssignMissingIDError =
      'Enter data item ID';
  static const String managerTaskCreateSelectDataset = 'Select dataset';
  static const String managerTaskCreateTaskCreateSuccess = 'Tasks created';
  //// User List Screen
  static const String managerUserListDeleteUser = 'Delete user';
  static String managerUserListDeleteWarning(String fullName, String email) =>
      'Delete $fullName ($email)? This cannot be undone.';
  static const String managerUserListCancel = 'Cancel';
  static const String managerUserListDelete = 'Delete';
  static String managerUserListDeleteConfirm(String email) => 'Deleted $email';
  static const String managerUserListUserManagement = 'User Management';
  static const String managerUserListUserManagementSubtitle =
      'Create and remove team accounts';
  static const String managerUserListSearchHint =
      'Search by name, email, or role';
  static const String managerUserListLoadUsersError = 'Failed to load users';
  static const String managerUserListNoExistingUsers = 'No users yet';
  static const String managerUserListNoUsersFound =
      'No users match your search';
  static const String managerUserListUnknownRole = 'Unknown role';
  static const String managerUserListMissingName = '?';
  //// User Form Screen
  static const String managerUserFormStatus = 'Status';
  static const String managerUserFormStatusActive = 'Active';
  static const String managerUserFormNoPhone = '';
  static const String managerUserFormUnknownRole = 'Unknown role';
  static const String managerUserFormMissingRoleAlert = 'Please select a role';
  static const String managerUserFormUserDetails = 'User Details';
  static const String managerUserFormCreateUser = 'Create User';
  static const String managerUserFormUpdateUser = 'Update User';
  static const String managerUserFormUserNotFound = 'User not found';
  static const String managerUserFormViewAccount =
      'View account information (read-only)';
  static const String managerUserFormCreateAccount =
      'Create an Annotator or Reviewer account';
  static const String managerUserFormName = 'Full Name';
  static const String managerUserFormNameHint = 'Enter full name';
  static const String managerUserFormMissingName = 'Name is required';
  static const String managerUserFormEmail = 'Email';
  static const String managerUserFormEmailHint = 'user@example.com';
  static const String managerUserFormPassword = 'Password';
  static const String managerUserFormPasswordHint = 'At least 8 characters';
  static const String managerUserFormMissingPassword = 'Password is required';
  static const String managerUserFormInvalidPassword =
      'Password must be at least 8 characters';
  static const String managerUserFormPhone = 'Phone (optional)';
  static const String managerUserFormPhoneHint = '+84 ...';
  static const String managerUserFormRole = 'Role';
  static const String managerUserFormRoleHint = 'Role';
  static const String managerUserFormMissingRole = 'Role is required';

  //// Profile Screen
  static const String profileTitle = 'My Profile';
  static const String profileSubtitle = 'View and manage your account';
  static const String profileEdit = 'Edit profile';
  static const String profileCancel = 'Cancel';
  static const String profileSave = 'Save changes';
  static const String profileSaved = 'Profile updated';
  static const String profileDelete = 'Delete account';
  static const String profileDeleteTitle = 'Delete account?';
  static const String profileDeleteWarning =
      'This permanently deletes your account. This action cannot be undone.';
  static const String profileDeleteConfirm = 'Delete';
  static const String profileDeleted = 'Account deleted';
  static const String profileFullName = 'Full name';
  static const String profileEmail = 'Email';
  static const String profilePhone = 'Phone number';
  static const String profileAddress = 'Address';
  static const String profileGender = 'Gender';
  static const String profileDateOfBirth = 'Date of birth';
  static const String profileRole = 'Role';
  static const String profileStatus = 'Status';
  static const String profileMissingName = 'Name is required';
  static const String profileNavLabel = 'Profile';
}
