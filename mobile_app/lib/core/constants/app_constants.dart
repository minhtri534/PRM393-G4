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
}
