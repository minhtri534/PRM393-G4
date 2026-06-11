import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/manager_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/dataset_card.dart';
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

        final datasets = provider.allDatasets
            .where((d) =>
                d.name.toLowerCase().contains(_search.toLowerCase()) ||
                (d.projectName ?? '')
                    .toLowerCase()
                    .contains(_search.toLowerCase()))
            .toList();

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Search datasets...',
                  border: OutlineInputBorder(),
                ),
                onChanged: (v) => setState(() => _search = v),
              ),
            ),
            Expanded(
              child: datasets.isEmpty
                  ? const Center(child: Text('No datasets found'))
                  : RefreshIndicator(
                      onRefresh: provider.fetchAllDatasets,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: datasets.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 8),
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
                    ),
            ),
          ],
        );
      },
    );
  }
}
