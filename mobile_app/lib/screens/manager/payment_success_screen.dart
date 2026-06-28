import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../widgets/action_button.dart';
import '../../widgets/dlss_card.dart';

class PaymentSuccessScreen extends StatelessWidget {
  final String transactionId;
  final double amount;
  final String name;

  const PaymentSuccessScreen({
    super.key,
    required this.transactionId,
    required this.amount,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment Success"),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),

            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 90,
            ),

            const SizedBox(height: 16),

            Text(
              "Payment Successful!",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),

            const SizedBox(height: 8),

            Text(
              "Salary has been sent to $name",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 24),

            DlssCard(
              child: Column(
                children: [
                  _row("Transaction ID", transactionId),
                  const Divider(),
                  _row("Amount", "\$${amount.toStringAsFixed(2)}"),
                  const Divider(),
                  _row("Status", "Completed"),
                ],
              ),
            ),

            const Spacer(),

            ActionButton(
              label: "Back to Payments",
              icon: Icons.arrow_back,
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
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
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}