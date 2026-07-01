class ReviewStatisticsModel {
  final String projectId;
  final int totalReviews;
  final int approvedReviews;
  final int rejectedReviews;
  final double averageScore;

  ReviewStatisticsModel({
    required this.projectId,
    required this.totalReviews,
    required this.approvedReviews,
    required this.rejectedReviews,
    required this.averageScore,
  });

  factory ReviewStatisticsModel.fromJson(Map<String, dynamic> json) =>
      ReviewStatisticsModel(
        projectId: json['projectId']?.toString() ?? '',
        totalReviews: json['totalReviews'] as int? ?? 0,
        approvedReviews: json['approvedReviews'] as int? ?? 0,
        rejectedReviews: json['rejectedReviews'] as int? ?? 0,
        averageScore: (json['averageScore'] as num?)?.toDouble() ?? 0,
      );
}