import 'dart:typed_data';

class FileModel {
  int? id;
  String fileType;
  final String fileData;

  FileModel({this.id, required this.fileType,required this.fileData});

  factory FileModel.fromJson(Map<String, dynamic> json) {
    return FileModel(
      id: json['id'],
      fileType: json['fileType'],
      fileData: json['fileData'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fileType': fileType,
      'fileData': fileData,
    };
  }
}
