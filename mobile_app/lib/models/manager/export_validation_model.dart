class ExportValidationModel {
  final String projectId;
  final int submittedAnnotationSets;
  final int reviewedAnnotationSets;
  final bool isValid;

  ExportValidationModel({
    required this.projectId,
    required this.submittedAnnotationSets,
    required this.reviewedAnnotationSets,
    required this.isValid,
  });

  factory ExportValidationModel.fromJson(Map<String, dynamic> json) =>
      ExportValidationModel(
        projectId: json['projectId']?.toString() ?? '',
        submittedAnnotationSets: json['submittedAnnotationSets'] as int? ?? 0,
        reviewedAnnotationSets: json['reviewedAnnotationSets'] as int? ?? 0,
        isValid: json['isValid'] as bool? ?? false,
      );
}
