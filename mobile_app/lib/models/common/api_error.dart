class ApiError implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  ApiError({required this.message, this.code, this.originalError});

  @override
  String toString() => 'ApiError: $message (Code: $code)';
}
