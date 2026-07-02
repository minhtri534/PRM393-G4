import 'package:flutter/material.dart';

import '../models/payment/payment.dart';
import '../models/payment/payment_history.dart';
import '../models/payment/payment_request.dart';
import '../models/payment/payment_response.dart';
import '../repositories/payment_repository.dart';

class PaymentProvider extends ChangeNotifier {
  final PaymentRepository _repository = PaymentRepository();

  List<Payment> payments = [];

  List<PaymentHistory> history = [];

  Payment? selectedPayment;

  bool isLoading = false;

  String? error;

  Future<void> loadPayments() async {
    try {
      isLoading = true;

      notifyListeners();

      payments = await _repository.getPayments();

      error = null;
    } catch (e) {
      error = e.toString();
    }

    isLoading = false;

    notifyListeners();
  }

  Future<void> loadPaymentDetail(int paymentId) async {
    isLoading = true;

    notifyListeners();

    selectedPayment = await _repository.getPaymentDetail(paymentId);

    isLoading = false;

    notifyListeners();
  }

  Future<PaymentResponse> paySalary(PaymentRequest request) async {
    isLoading = true;

    notifyListeners();

    final response = await _repository.paySalary(request);

    if (response.success) {
      await loadPayments();
    }

    isLoading = false;

    notifyListeners();

    return response;
  }

  Future<void> loadHistory() async {
    isLoading = true;

    notifyListeners();

    history = await _repository.getPaymentHistory();

    isLoading = false;

    notifyListeners();
  }
}
