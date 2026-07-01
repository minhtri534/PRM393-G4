class RoleModel {
  final String id;
  final String name;

  RoleModel({required this.id, required this.name});

  factory RoleModel.fromJson(Map<String, dynamic> json) => RoleModel(
    id: json['id']?.toString() ?? '',
    name: json['name']?.toString() ?? '',
  );

  bool get isAssignableByManager {
    final normalized = name.toLowerCase();
    return normalized == 'annotator' || normalized == 'reviewer';
  }
}