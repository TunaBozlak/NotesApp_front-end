import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notlar/components/themenotifier.dart';
import 'package:notlar/models/User.dart';
import 'package:notlar/models/file.dart';
import 'package:notlar/pages/homepage/addnote/drawingpage.dart';
import 'package:notlar/pages/homepage/addnote/selectfolderpage.dart';
import 'package:notlar/pages/homepage/homepage.dart';
import 'package:provider/provider.dart';
import 'package:signature/signature.dart';

import '../../../models/note.dart';

class AddNoteHomePage extends StatefulWidget {
  final User user;

  const AddNoteHomePage({Key? key, required this.user}) : super(key: key);

  @override
  _AddNoteHomePageState createState() => _AddNoteHomePageState();
}

class _AddNoteHomePageState extends State<AddNoteHomePage> {
  final TextEditingController notecontroller = TextEditingController();
  final SignatureController signaturecontroller = SignatureController(
    penStrokeWidth: 5,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );
  final ImagePicker picker = ImagePicker();
  List<XFile> images = [];

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    User user = widget.user;
    return Scaffold(
      backgroundColor:
      themeNotifier.isDarkMode ? Colors.grey[800] : Colors.grey[300],
      appBar: AppBar(
        backgroundColor:
        themeNotifier.isDarkMode ? Colors.grey[800] : Colors.grey[300],
        title: Text('Yeni Not Ekle'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () async {
              // Notu kaydetme işlevselliği

              if (notecontroller.text == "" || notecontroller.text.isEmpty) {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Hata'),
                      content: Text('Not içeriği boş olamaz.'),
                      actions: <Widget>[
                        TextButton(
                          child: Text('Tamam'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              } else {
                String noteText = notecontroller.text;
                // Notun ismini al
                String? noteTitle = await getNoteName(context);
                if (noteTitle == null || noteTitle.isEmpty) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Hata'),
                        content: Text('Beklenmedik bir hata oluştu.'),
                        actions: <Widget>[
                          TextButton(
                            child: Text('Tamam'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  // Klasör seçimi için dialog göster
                  String? selectedFolder = await showDialog<String>(
                    context: context,
                    builder: (BuildContext context) {
                      return SelectFolderPage();
                    },
                  );

                  if (selectedFolder != null) {
                    List<FileModel> files = []; // çizim ve fotolar
                    if (signaturecontroller.isNotEmpty) {
                      // çizim dosyasını ekle
                      Uint8List? signatureData =
                      await signaturecontroller.toPngBytes();
                      String base64String = base64Encode(signatureData!);
                      FileModel drawFile =
                      FileModel(fileType: "png", fileData: base64String);
                      files.add(drawFile);
                    }
                    for (XFile image in images) {
                      // fotoları ekle
                      Uint8List imageBytes = await image.readAsBytes();
                      String fileString = base64Encode(imageBytes);
                      FileModel newFile =
                      FileModel(fileType: "png", fileData: fileString);
                      files.add(newFile);
                    }

                    Note newNote = Note(
                        folderName: selectedFolder,
                        noteTitle: noteTitle,
                        noteText: noteText,
                        files: files);
                    user.notes.add(newNote);
                    String url = 'http://10.0.2.2:8080/api/users/${user.email}';
                    //10 sn time limit
                    final response = await http.put(
                      Uri.parse(url),
                      body: json.encode(user),
                      headers: {
                        'Content-Type': 'application/json',
                      },
                    ).timeout(const Duration(seconds: 15));
                    if (response.statusCode == 200) {
                      String decodedData = utf8.decode(response.bodyBytes);
                      user = User.fromJson(jsonDecode(decodedData));
                      //print('İşlem başarılı');
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => HomePage(user: user)),
                      );
                    } else {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Hata'),
                            content: Text(
                                'Not kaydedilemedi.Sistemsel bir hata oluştu'),
                            actions: <Widget>[
                              TextButton(
                                child: Text('Tamam'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    }
                  }
                }
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: notecontroller,
                      decoration: InputDecoration(
                        hintText: 'Notunuzu buraya yazın',
                        border: InputBorder.none,
                      ),
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                    ),
                    SizedBox(height: 16),
                    buildImageGallery(),
                  ],
                ),
              ),
            ),
            buildBottomBar(context),
          ],
        ),
      ),
    );
  }

  Widget buildImageGallery() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: images.map((image) {
        return Image.file(
          File(image.path),
          width: 100,
          height: 100,
          fit: BoxFit.cover,
        );
      }).toList(),
    );
  }

  Widget buildBottomBar(BuildContext context) {
    return Container(
      color: Colors.grey[300],
      padding: EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: Icon(Icons.brush),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      DrawingPage(controller: signaturecontroller),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.photo),
            onPressed: () {
              pickImage();
            },
          ),
        ],
      ),
    );
  }

  Future<void> pickImage() async {
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        images.add(image);
      });
    }
  }

  // Notun ismini almak için bir metot
  Future<String?> getNoteName(BuildContext context) {
    TextEditingController nameController = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Notun Başlığını Girin'),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(
              hintText: '...',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                String? noteName = nameController.text.trim();
                if (noteName == "" || noteName == null || noteName.isEmpty) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Hata'),
                        content: Text('Not başlığı boş olamaz.'),
                        actions: <Widget>[
                          TextButton(
                            child: Text('Tamam'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  Navigator.pop(context, noteName);
                }
              },
              child: Text('Tamam'),
            ),
          ],
        );
      },
    );
  }
}
