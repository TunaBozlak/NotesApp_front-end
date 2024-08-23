import 'dart:convert';

import 'package:flutter/material.dart';
import '../../../models/note.dart';
import 'package:http/http.dart' as http;
import '../../../components/themenotifier.dart';
import 'package:provider/provider.dart';

class ArchivePage extends StatefulWidget {
  final List<Note> archivedNotes;
  const ArchivePage({Key? key, required this.archivedNotes}) :  super(key: key);

  @override
  State <ArchivePage>  createState() => _ArchivePageState();
}

class _ArchivePageState extends State<ArchivePage> {

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return Scaffold(
      backgroundColor: themeNotifier.isDarkMode ? Colors.grey[800] : Colors.grey[300],
      appBar: AppBar(
        backgroundColor: themeNotifier.isDarkMode ? Colors.grey[800] : Colors.grey[300],
        title: Text('Arşiv'),
      ),
      body: widget.archivedNotes.isEmpty ?Center(child: Text("Arşiv boş.")): ListView.builder(
        itemCount: widget.archivedNotes.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onLongPress: () {
              showDeleteConfirmationDialog(context, index);
            },
            child: ListTile(
              title: Text(widget.archivedNotes[index].noteTitle),
            ),
          );
        },
      ),
    );
  }

  void showDeleteConfirmationDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final themeNotifier = Provider.of<ThemeNotifier>(context);

        return AlertDialog(
          title: Text('Emin misiniz?'),
          content: Text('Bu notu arşivden kaldırmak istediğinizden emin misiniz?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Hayır'),
            ),
            TextButton(
              onPressed: () async {
                if (await updateFolderWithAPI(widget.archivedNotes[index], "Kategorisiz")){
                  widget.archivedNotes.removeAt(index);
                }
                setState(() {
                  // Arşivden notu kaldırma işlemi

                  // Kaldırılan notu burada işleyebilirsiniz.
                  //print("Removed Note: $removedNote");

                });
                Navigator.of(context).pop();
              },
              child: Text('Evet'),
            ),
          ],
        );
      },
    );
  }
  Future<bool> updateWithAPI(Note note) async {
    String url = 'http://10.0.2.2:8080/api/notes/${note.id}';
    //10 sn time limit

    final response = await http.put(
      Uri.parse(url),
      body: json.encode(note),
      headers: {
        'Content-Type': 'application/json',
      },
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> updateFolderWithAPI(Note note, String folderName) {
    note.folderName = folderName;
    return updateWithAPI(note);
  }
}