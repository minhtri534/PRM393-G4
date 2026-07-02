class ExportConfigModel {
  final String labelFormat;
  final dynamic includeFields;
  final dynamic filters;

  ExportConfigModel({
    required this.labelFormat,
    this.includeFields,
    this.filters,
  });

  factory ExportConfigModel.fromJson(Map<String, dynamic> json) =>
      ExportConfigModel(
        labelFormat: json['labelFormat']?.toString() ?? '',
        includeFields: json['includeFields'],
        filters: json['filters'],
      );
}
