class PaymentRequest {
  final int userId;

  final double amount;

  final String paymentMethod;

  final String reference;

  PaymentRequest({
    required this.userId,
    required this.amount,
    required this.paymentMethod,
    required this.reference,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'amount': amount,
      'paymentMethod': paymentMethod,
      'reference': reference,
    };
  }
}
