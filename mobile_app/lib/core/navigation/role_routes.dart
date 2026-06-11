import '../../routes/app_routes.dart';

/// Resolve the home route after login/splash based on user role.
String homeRouteForRole(String? roleName) {
  final role = (roleName ?? 'annotator').toLowerCase();
  switch (role) {
    case 'manager':
    case 'admin':
      return AppRoutes.managerHome;
    case 'reviewer':
      return AppRoutes.annotatorHome; // reviewer module not built yet
    default:
      return AppRoutes.annotatorHome;
  }
}

bool isManagerRole(String? roleName) {
  final role = (roleName ?? '').toLowerCase();
  return role == 'manager' || role == 'admin';
}
