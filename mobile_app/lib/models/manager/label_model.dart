class LabelModel {
  final String id;
  final String projectId;
  final String name;
  final int yoloClassId;
  final String? categoryId;
  final String? annotationTypeId;

  LabelModel({
    required this.id,
    required this.projectId,
    required this.name,
    required this.yoloClassId,
    this.categoryId,
    this.annotationTypeId,
  });

  factory LabelModel.fromJson(Map<String, dynamic> json) => LabelModel(
    id: json['id']?.toString() ?? '',
    projectId: json['projectId']?.toString() ?? '',
    name: json['name']?.toString() ?? '',
    yoloClassId: json['yoloClassId'] as int? ?? 0,
    categoryId: json['categoryId']?.toString(),
    annotationTypeId: json['annotationTypeId']?.toString(),
  );
}