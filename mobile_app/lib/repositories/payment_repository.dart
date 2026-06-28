import 'dart:async';

import '../models/payment/payment.dart';
import '../models/payment/payment_history.dart';
import '../models/payment/payment_request.dart';
import '../models/payment/payment_response.dart';

class PaymentRepository {
  Future<List<Payment>> getPayments() async {
    await Future.delayed(const Duration(milliseconds: 700));

    return [
      Payment(
        paymentId: 1,
        userId: 1001,
        userName: "John Smith",
        role: "Annotator",
        completedTasks: 34,
        completedLabels: 5260,
        amount: 245,
        status: "Pending",
        paymentMethod: "Bank",
      ),
      Payment(
        paymentId: 2,
        userId: 1002,
        userName: "Anna Lee",
        role: "Reviewer",
        completedTasks: 27,
        completedLabels: 3812,
        amount: 190,
        status: "Pending",
        paymentMethod: "Wallet",
      ),
      Payment(
        paymentId: 3,
        userId: 1003,
        userName: "Lucas",
        role: "Annotator",
        completedTasks: 51,
        completedLabels: 8210,
        amount: 430,
        status: "Paid",
        paymentMethod: "Bank",
        transactionId: "TX982341",
        paidAt: DateTime.now(),
      ),
    ];
  }

  Future<Payment> getPaymentDetail(int paymentId) async {
    await Future.delayed(const Duration(milliseconds: 500));

    return Payment(
      paymentId: paymentId,
      userId: 1001,
      userName: "John Smith",
      role: "Annotator",
      completedTasks: 34,
      completedLabels: 5260,
      amount: 245,
      status: "Pending",
      paymentMethod: "Bank",
      reference: "Monthly Salary",
    );
  }

  Future<PaymentResponse> paySalary(
      PaymentRequest request) async {
    await Future.delayed(const Duration(seconds: 2));

    return PaymentResponse(
      success: true,
      message: "Payment Successful",
      transactionId:
          "TX${DateTime.now().millisecondsSinceEpoch}",
    );
  }

  Future<List<PaymentHistory>> getPaymentHistory() async {
    await Future.delayed(const Duration(milliseconds: 600));

    return [
      PaymentHistory(
        paymentId: 1,
        workerName: "John Smith",
        role: "Annotator",
        amount: 245,
        status: "Paid",
        transactionId: "TX123456",
        paymentDate: DateTime.now(),
      ),
      PaymentHistory(
        paymentId: 2,
        workerName: "Anna Lee",
        role: "Reviewer",
        amount: 190,
        status: "Paid",
        transactionId: "TX123457",
        paymentDate: DateTime.now(),
      ),
      PaymentHistory(
        paymentId: 3,
        workerName: "Lucas",
        role: "Annotator",
        amount: 430,
        status: "Failed",
        transactionId: "TX123458",
        paymentDate: DateTime.now(),
      ),
    ];
  }
}