class ServiceResponse<T> {
  final bool isSuccess;
  final T? data;
  final String message;
  final List<String>? errors;

  ServiceResponse({
    required this.isSuccess,
    this.data,
    required this.message,
    this.errors,
  });

  factory ServiceResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? dataDecoder,
  ) {
    return ServiceResponse(
      isSuccess: json['isSuccess'] ?? false,
      data: json['data'] != null ? dataDecoder?.call(json['data']) : null,
      message: json['message'] ?? '',
      errors: json['errors'] != null ? List<String>.from(json['errors']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'isSuccess': isSuccess,
        'data': data,
        'message': message,
        'errors': errors,
      };
}
