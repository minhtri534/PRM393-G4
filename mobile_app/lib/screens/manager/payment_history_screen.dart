import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/payment_provider.dart';
import '../../widgets/dlss_card.dart';
import '../../widgets/dlss_page_header.dart';
import '../../widgets/error_widget.dart' as error_widget;
import '../../widgets/loading_skeleton.dart';

class PaymentHistoryScreen extends StatefulWidget {
  const PaymentHistoryScreen({super.key});

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  String _filter = "All";

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PaymentProvider>().loadHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PaymentProvider>(
      builder: (context, provider, _) {
        final history = provider.history.where((item) {
          if (_filter == "All") return true;
          return item.status == _filter;
        }).toList();

        return Padding(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const DlssPageHeader(
                title: "Payment History",
                subtitle: "All salary transactions",
              ),

              const SizedBox(height: 16),

              SizedBox(
                height: 42,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [_chip("All"), _chip("Paid"), _chip("Failed")],
                ),
              ),

              const SizedBox(height: 16),

              Expanded(child: _buildBody(provider, history)),
            ],
          ),
        );
      },
    );
  }

  Widget _chip(String value) {
    final selected = _filter == value;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(value),
        selected: selected,
        onSelected: (_) {
          setState(() {
            _filter = value;
          });
        },
      ),
    );
  }

  Widget _buildBody(PaymentProvider provider, List history) {
    if (provider.isLoading && provider.history.isEmpty) {
      return const LoadingSkeleton(itemCount: 4);
    }

    if (provider.error != null && provider.history.isEmpty) {
      return error_widget.ErrorWidget(
        message: provider.error!,
        onRetry: provider.loadHistory,
      );
    }

    if (history.isEmpty) {
      return const Center(child: Text("No payment history"));
    }

    return RefreshIndicator(
      onRefresh: provider.loadHistory,
      child: ListView.separated(
        itemCount: history.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final item = history[index];

          return DlssCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(child: Text(item.workerName[0])),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.workerName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            item.role,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    _status(item.status),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Amount"),
                    Text(
                      "\$${item.amount}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Transaction"),
                    Text(
                      item.transactionId,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Date"),
                    Text(item.paymentDate.toString().split(" ").first),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _status(String status) {
    Color color;

    switch (status.toLowerCase()) {
      case "paid":
        color = Colors.green;
        break;
      case "failed":
        color = Colors.red;
        break;
      default:
        color = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}
