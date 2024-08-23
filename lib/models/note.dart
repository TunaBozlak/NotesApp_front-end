import 'file.dart';

class Note {
  int? id;
  String folderName;
  String noteText;
  String noteTitle;
  List<FileModel> files;

  Note({this.id, required this.folderName, required this.noteText,required this.noteTitle,required this.files});

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'],
      folderName: json['folderName'],
      noteText: json['noteText'],
      noteTitle: json['noteTitle'],
      files: List<FileModel>.from(json['files'].map((x) => FileModel.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'folderName': folderName,
      'noteText': noteText,
      'noteTitle': noteTitle,
      'files': files.map((x) => x.toJson()).toList(),
    };
  }
}
