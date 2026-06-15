import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/manager_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/dataset_card.dart';
import '../../widgets/dlss_page_header.dart';
import '../../widgets/error_widget.dart' as error_widget;
import '../../widgets/loading_skeleton.dart';

class DatasetListScreen extends StatefulWidget {
  const DatasetListScreen({super.key});

  @override
  State<DatasetListScreen> createState() => _DatasetListScreenState();
}

class _DatasetListScreenState extends State<DatasetListScreen> {
  String _search = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ManagerProvider>().fetchAllDatasets();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ManagerProvider>(
      builder: (context, provider, _) {
        final datasets = provider.allDatasets
            .where(
              (d) =>
                  d.name.toLowerCase().contains(_search.toLowerCase()) ||
                  (d.projectName ?? '')
                      .toLowerCase()
                      .contains(_search.toLowerCase()),
            )
            .toList();

        return Padding(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const DlssPageHeader(
                title: 'Datasets',
                subtitle: 'Browse and manage uploaded datasets',
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: 'Search datasets...',
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.borderColor),
                  ),
                ),
                onChanged: (v) => setState(() => _search = v),
              ),
              const SizedBox(height: 16),
              Expanded(child: _buildBody(provider, datasets)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(ManagerProvider provider, List datasets) {
    if (provider.isLoading && provider.allDatasets.isEmpty) {
      return const LoadingSkeleton(itemCount: 4);
    }

    if (provider.state == ManagerLoadState.error &&
        provider.allDatasets.isEmpty) {
      return error_widget.ErrorWidget(
        message: provider.errorMessage ?? 'Failed to load datasets',
        onRetry: provider.fetchAllDatasets,
      );
    }

    if (datasets.isEmpty) {
      return Center(
        child: Text(
          'No datasets found',
          style: TextStyle(color: AppTheme.textSecondaryColor),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: provider.fetchAllDatasets,
      child: ListView.separated(
        itemCount: datasets.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final dataset = datasets[index];
          return DatasetCard(
            dataset: dataset,
            onTap: () => Navigator.pushNamed(
              context,
              AppRoutes.managerDatasetDetail,
              arguments: dataset.id,
            ),
          );
        },
      ),
    );
  }
}
