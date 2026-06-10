class Label {
  final String id;
  final String name;
  final String color;
  final String projectId;
  final int yoloClassId;

  Label({
    required this.id,
    required this.name,
    required this.color,
    required this.projectId,
    required this.yoloClassId,
  });

  factory Label.fromJson(Map<String, dynamic> json) {
    return Label(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      color: json['color'] ?? '#2563eb',
      projectId: json['projectId'] ?? '',
      yoloClassId: json['yoloClassId'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'color': color,
        'projectId': projectId,
        'yoloClassId': yoloClassId,
      };
}
