import 'package:flutter/material.dart';

import 'dlss_card.dart';

class SalarySummaryCard extends StatelessWidget {
  final double totalPending;
  final double totalPaid;
  final int workers;

  const SalarySummaryCard({
    super.key,
    required this.totalPending,
    required this.totalPaid,
    required this.workers,
  });

  Widget _item(
      String title,
      String value,
      IconData icon,
      Color color,
      ) {
    return Expanded(
      child: Column(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: color.withOpacity(.12),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DlssCard(
      child: Row(
        children: [
          _item(
            "Workers",
            workers.toString(),
            Icons.people,
            Colors.blue,
          ),
          _item(
            "Pending",
            "\$${totalPending.toStringAsFixed(0)}",
            Icons.schedule,
            Colors.orange,
          ),
          _item(
            "Paid",
            "\$${totalPaid.toStringAsFixed(0)}",
            Icons.check_circle,
            Colors.green,
          ),
        ],
      ),
    );
  }
}