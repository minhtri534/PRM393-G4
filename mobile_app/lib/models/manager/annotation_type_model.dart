class AnnotationTypeModel {
  final String id;
  final String projectId;
  final String name;
  final String? description;

  AnnotationTypeModel({
    required this.id,
    required this.projectId,
    required this.name,
    this.description,
  });

  factory AnnotationTypeModel.fromJson(Map<String, dynamic> json) =>
      AnnotationTypeModel(
        id: json['id']?.toString() ?? '',
        projectId: json['projectId']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        description: json['description']?.toString(),
      );
}