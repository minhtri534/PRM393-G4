import 'package:flutter/material.dart';

import '../models/payment/payment.dart';
import 'dlss_card.dart';
import 'payment_status_chip.dart';

class PaymentCard extends StatelessWidget {
  final Payment payment;
  final VoidCallback? onTap;

  const PaymentCard({
    super.key,
    required this.payment,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return DlssCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            children: [

              CircleAvatar(
                radius: 24,
                child: Text(
                  payment.userName[0],
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [

                    Text(
                      payment.userName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),

                    Text(
                      payment.role,
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              PaymentStatusChip(
                status: payment.status,
              ),
            ],
          ),

          const SizedBox(height: 18),

          Row(
            children: [

              Expanded(
                child: _info(
                  "Tasks",
                  payment.completedTasks.toString(),
                ),
              ),

              Expanded(
                child: _info(
                  "Labels",
                  payment.completedLabels.toString(),
                ),
              ),

              Expanded(
                child: _info(
                  "Salary",
                  "\$${payment.amount.toStringAsFixed(0)}",
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onTap,
              icon: const Icon(Icons.payments),
              label: const Text("Pay Salary"),
            ),
          )
        ],
      ),
    );
  }

  Widget _info(
      String title,
      String value,
      ) {
    return Column(
      children: [

        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          title,
          style: const TextStyle(
            color: Colors.grey,
          ),
        )
      ],
    );
  }
}