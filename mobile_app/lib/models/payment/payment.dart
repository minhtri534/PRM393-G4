
class Payment {
  final int paymentId;
  final int userId;
  final String userName;
  final String role;

  final int completedTasks;
  final int completedLabels;

  final double amount;

  final String status;

  final String paymentMethod;

  final String? transactionId;

  final String? reference;

  final DateTime? paidAt;

  Payment({
    required this.paymentId,
    required this.userId,
    required this.userName,
    required this.role,
    required this.completedTasks,
    required this.completedLabels,
    required this.amount,
    required this.status,
    required this.paymentMethod,
    this.transactionId,
    this.reference,
    this.paidAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      paymentId: json['paymentId'],
      userId: json['userId'],
      userName: json['userName'],
      role: json['role'],
      completedTasks: json['completedTasks'],
      completedLabels: json['completedLabels'],
      amount: (json['amount'] as num).toDouble(),
      status: json['status'],
      paymentMethod: json['paymentMethod'],
      transactionId: json['transactionId'],
      reference: json['reference'],
      paidAt: json['paidAt'] == null
          ? null
          : DateTime.parse(json['paidAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'paymentId': paymentId,
      'userId': userId,
      'userName': userName,
      'role': role,
      'completedTasks': completedTasks,
      'completedLabels': completedLabels,
      'amount': amount,
      'status': status,
      'paymentMethod': paymentMethod,
      'transactionId': transactionId,
      'reference': reference,
      'paidAt': paidAt?.toIso8601String(),
    };
  }
}