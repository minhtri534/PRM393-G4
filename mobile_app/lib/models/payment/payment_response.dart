class PaymentResponse {
  final bool success;

  final String message;

  final String transactionId;

  PaymentResponse({
    required this.success,
    required this.message,
    required this.transactionId,
  });

  factory PaymentResponse.fromJson(Map<String, dynamic> json) {
    return PaymentResponse(
      success: json['success'],
      message: json['message'],
      transactionId: json['transactionId'],
    );
  }
}
