class Annotation {
  final String id;
  final String labelId;
  final dynamic geometryData;

  Annotation({
    required this.id,
    required this.labelId,
    this.geometryData,
  });

  factory Annotation.fromJson(Map<String, dynamic> json) {
    return Annotation(
      id: json['id'] ?? '',
      labelId: json['labelId'] ?? '',
      geometryData: json['geometryData'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'labelId': labelId,
        'geometryData': geometryData,
      };
}
