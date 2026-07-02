
class PaymentHistory {
  final int paymentId;

  final String workerName;

  final String role;

  final double amount;

  final String status;

  final String transactionId;

  final DateTime paymentDate;

  PaymentHistory({
    required this.paymentId,
    required this.workerName,
    required this.role,
    required this.amount,
    required this.status,
    required this.transactionId,
    required this.paymentDate,
  });

  factory PaymentHistory.fromJson(Map<String, dynamic> json) {
    return PaymentHistory(
      paymentId: json['paymentId'],
      workerName: json['workerName'],
      role: json['role'],
      amount: (json['amount'] as num).toDouble(),
      status: json['status'],
      transactionId: json['transactionId'],
      paymentDate: DateTime.parse(json['paymentDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'paymentId': paymentId,
      'workerName': workerName,
      'role': role,
      'amount': amount,
      'status': status,
      'transactionId': transactionId,
      'paymentDate': paymentDate.toIso8601String(),
    };
  }
}