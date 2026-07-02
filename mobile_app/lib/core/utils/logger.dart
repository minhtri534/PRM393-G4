/// Simple logger utility
class Logger {
  static const String _tag = '[DLSS Mobile]';

  static void debug(String message) {
    print('$_tag [DEBUG] $message');
  }

  static void info(String message) {
    print('$_tag [INFO] $message');
  }

  static void warning(String message) {
    print('$_tag [WARNING] $message');
  }

  static void error(
    String message, [
    dynamic exception,
    StackTrace? stackTrace,
  ]) {
    print('$_tag [ERROR] $message');
    if (exception != null) {
      print('$_tag Exception: $exception');
    }
    if (stackTrace != null) {
      print('$_tag StackTrace: $stackTrace');
    }
  }
}
