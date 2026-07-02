import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../providers/payment_provider.dart';
import '../../widgets/action_button.dart';
import '../../widgets/dlss_card.dart';
import '../../widgets/payment_status_chip.dart';
import 'payment_success_screen.dart';

class PaymentDetailScreen extends StatefulWidget {
  const PaymentDetailScreen({super.key});

  @override
  State<PaymentDetailScreen> createState() => _PaymentDetailScreenState();
}

class _PaymentDetailScreenState extends State<PaymentDetailScreen> {
  bool _isPaying = false;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PaymentProvider>();
    final payment = provider.selectedPayment;

    if (payment == null) {
      return const Scaffold(
        body: Center(
          child: Text("No payment selected"),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment Detail"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DlssCard(
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    child: Text(payment.userName[0]),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          payment.userName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(payment.role),
                      ],
                    ),
                  ),
                  PaymentStatusChip(status: payment.status),
                ],
              ),
            ),

            const SizedBox(height: 16),

            DlssCard(
              child: Column(
                children: [
                  _row("Completed Tasks",
                      payment.completedTasks.toString()),
                  const Divider(),
                  _row("Completed Labels",
                      payment.completedLabels.toString()),
                  const Divider(),
                  _row("Amount", "\$${payment.amount}"),
                  const Divider(),
                  _row("Payment Method", payment.paymentMethod),
                  const Divider(),
                  _row("Reference",
                      payment.reference ?? "Monthly Salary"),
                ],
              ),
            ),

            const Spacer(),

            ActionButton(
              label: _isPaying ? "Processing..." : "Send Payment",
              isLoading: _isPaying,
              icon: Icons.send,
              onPressed: payment.status == "Paid"
                  ? null
                  : () async {
                      setState(() => _isPaying = true);

                      await Future.delayed(
                          const Duration(seconds: 2));

                      final result =
                          await provider.paySalary(
                        paymentRequestFrom(payment),
                      );

                      setState(() => _isPaying = false);

                      if (!mounted) return;

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              PaymentSuccessScreen(
                            transactionId:
                                result.transactionId,
                            amount: payment.amount,
                            name: payment.userName,
                          ),
                        ),
                      );
                    },
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // convert model -> request (mock)
  dynamic paymentRequestFrom(payment) {
    return {
      "userId": payment.userId,
      "amount": payment.amount,
      "paymentMethod": payment.paymentMethod,
      "reference": payment.reference ?? "Monthly Salary",
    };
  }
}