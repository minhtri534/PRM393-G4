class LabelCategoryModel {
  final String id;
  final String projectId;
  final String name;
  final String? description;

  LabelCategoryModel({
    required this.id,
    required this.projectId,
    required this.name,
    this.description,
  });

  factory LabelCategoryModel.fromJson(Map<String, dynamic> json) =>
      LabelCategoryModel(
        id: json['id']?.toString() ?? '',
        projectId: json['projectId']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        description: json['description']?.toString(),
      );
}