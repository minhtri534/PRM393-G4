class YoloLabelFileModel {
  final String fileName;
  final String content;

  YoloLabelFileModel({required this.fileName, required this.content});

  factory YoloLabelFileModel.fromJson(Map<String, dynamic> json) =>
      YoloLabelFileModel(
        fileName: json['fileName']?.toString() ?? '',
        content: json['content']?.toString() ?? '',
      );
}
