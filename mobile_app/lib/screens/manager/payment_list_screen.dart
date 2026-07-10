import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/payment_provider.dart';
import '../../widgets/dlss_page_header.dart';
import '../../widgets/error_widget.dart' as error_widget;
import '../../widgets/loading_skeleton.dart';
import '../../widgets/payment_card.dart';
import '../../widgets/salary_summary_card.dart';
import 'payment_detail_screen.dart';

class PaymentListScreen extends StatefulWidget {
  const PaymentListScreen({super.key});

  @override
  State<PaymentListScreen> createState() => _PaymentListScreenState();
}

class _PaymentListScreenState extends State<PaymentListScreen> {
  String _search = '';

  String _filter = 'All';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PaymentProvider>().loadPayments();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PaymentProvider>(
      builder: (context, provider, _) {
        final payments = provider.payments.where((payment) {
          final keyword = _search.toLowerCase();

          final matchedKeyword =
              payment.userName.toLowerCase().contains(keyword) ||
              payment.role.toLowerCase().contains(keyword);

          final matchedFilter = _filter == 'All' || payment.status == _filter;

          return matchedKeyword && matchedFilter;
        }).toList();

        final totalPending = provider.payments
            .where((e) => e.status == "Pending")
            .fold<double>(0, (a, b) => a + b.amount);

        final totalPaid = provider.payments
            .where((e) => e.status == "Paid")
            .fold<double>(0, (a, b) => a + b.amount);

        return Padding(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const DlssPageHeader(
                title: "Salary Payment",
                subtitle: "Pay Annotators and Reviewers",
              ),

              const SizedBox(height: 16),

              SalarySummaryCard(
                totalPending: totalPending,
                totalPaid: totalPaid,
                workers: provider.payments.length,
              ),

              const SizedBox(height: 16),

              TextField(
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: "Search employee...",
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: .85),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.borderColor),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _search = value;
                  });
                },
              ),

              const SizedBox(height: 16),

              SizedBox(
                height: 42,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _filterChip("All"),
                    _filterChip("Pending"),
                    _filterChip("Paid"),
                    _filterChip("Failed"),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Expanded(child: _buildBody(provider, payments)),
            ],
          ),
        );
      },
    );
  }

  Widget _filterChip(String value) {
    final selected = value == _filter;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        selected: selected,
        label: Text(value),
        onSelected: (_) {
          setState(() {
            _filter = value;
          });
        },
      ),
    );
  }

  Widget _buildBody(PaymentProvider provider, List payments) {
    if (provider.isLoading && provider.payments.isEmpty) {
      return const LoadingSkeleton(itemCount: 5);
    }

    if (provider.error != null && provider.payments.isEmpty) {
      return error_widget.ErrorWidget(
        message: provider.error!,
        onRetry: provider.loadPayments,
      );
    }

    if (payments.isEmpty) {
      return const Center(child: Text("No employee found"));
    }

    return RefreshIndicator(
      onRefresh: provider.loadPayments,
      child: ListView.separated(
        itemCount: payments.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (_, index) {
          final payment = payments[index];

          return PaymentCard(
            payment: payment,
            onTap: () async {
              await provider.loadPaymentDetail(payment.paymentId);

              if (!mounted) return;

              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PaymentDetailScreen()),
              );
            },
          );
        },
      ),
    );
  }
}
