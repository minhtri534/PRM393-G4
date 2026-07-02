import 'review_statistics.dart';
import 'labeling_progress_overview_model.dart';

class QualityReportModel {
  final LabelingProgressOverviewModel progress;
  final ReviewStatisticsModel reviewStats;
  final int inconsistentLabelsCount;

  QualityReportModel({
    required this.progress,
    required this.reviewStats,
    required this.inconsistentLabelsCount,
  });

  factory QualityReportModel.fromJson(Map<String, dynamic> json) =>
      QualityReportModel(
        progress: LabelingProgressOverviewModel.fromJson(
          json['progress'] as Map<String, dynamic>? ?? {},
        ),
        reviewStats: ReviewStatisticsModel.fromJson(
          json['reviewStats'] as Map<String, dynamic>? ?? {},
        ),
        inconsistentLabelsCount: json['inconsistentLabelsCount'] as int? ?? 0,
      );
}
