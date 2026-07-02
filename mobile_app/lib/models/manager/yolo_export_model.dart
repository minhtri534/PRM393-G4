import 'package:mobile_app/models/manager/yolo_label_file_model.dart';

class YoloExportModel {
  final List<String> classes;
  final List<YoloLabelFileModel> files;

  YoloExportModel({required this.classes, required this.files});

  factory YoloExportModel.fromJson(Map<String, dynamic> json) =>
      YoloExportModel(
        classes: (json['classes'] as List<dynamic>? ?? [])
            .map((e) => e.toString())
            .toList(),
        files: (json['files'] as List<dynamic>? ?? [])
            .map((e) => YoloLabelFileModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
