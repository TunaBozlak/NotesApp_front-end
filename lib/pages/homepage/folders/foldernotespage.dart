import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:notlar/pages/homepage/folders/notecontentpage.dart';
import 'package:http/http.dart' as http;
import 'package:notlar/components/themenotifier.dart';
import 'package:notlar/models/note.dart';
import 'package:provider/provider.dart';

class FolderNotesPage extends StatefulWidget {
  final String folderName;
  final List<Note> folderNotes;
  final List<Note> deletedNotes;
  final List<Note> archivedNotes;

  const FolderNotesPage({
    Key? key,
    required this.folderName,
    required this.folderNotes,
    required this.archivedNotes,
    required this.deletedNotes,
  }) : super(key: key);

  @override
  _FolderNotesPageState createState() => _FolderNotesPageState();
}

class _FolderNotesPageState extends State<FolderNotesPage> {
  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return Scaffold(
      backgroundColor: themeNotifier.isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
      appBar: AppBar(
        backgroundColor: themeNotifier.isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
        title: Text('${widget.folderName}'),
      ),
      body: _buildNotesList(),
    );
  }

  Widget _buildNotesList() {
    return widget.folderNotes.isEmpty
        ? Center(child: Text('Henüz bu kategori için not yok.'))
        : ListView.builder(
      itemCount: widget.folderNotes.length,
      itemBuilder: (context, index) {
        return _buildNoteItem(index);
      },
    );
  }

  Widget _buildNoteItem(int index) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return ListTile(
      title: Text(
        widget.folderNotes[index].noteTitle,
        style: TextStyle(
          color: themeNotifier.isDarkMode ? Colors.white : Colors.black,
        ),
      ),
      onTap: () {
        _editNote(context, index);
      },
      onLongPress: () {
        _showBottomSheetMenu(context, index);
      },
    );
  }

  void _editNote(BuildContext context, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteContentPage(note: widget.folderNotes[index]),
      ),
    ).then((editedNote) {
      if (editedNote != null) {
        _updateNoteAtIndex(index, editedNote);
      }
    });
  }

  void _updateNoteAtIndex(int index, Note editedNote) async {
    if (await _updateNoteWithAPI(editedNote)) {
      setState(() {
        widget.folderNotes[index] = editedNote;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Not Düzenlendi: ${editedNote.noteTitle}'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<bool> _updateNoteWithAPI(Note note) async {
    try {
      String url = 'http://10.0.2.2:8080/api/notes/${note.id}';
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
    } catch (e) {
      print('HTTP Hatası: $e');
      return false;
    }
  }

  void _showBottomSheetMenu(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20.0),
        ),
      ),
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _buildBottomSheetContent(context, index);
      },
    );
  }

  Widget _buildBottomSheetContent(BuildContext context, int index) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return Container(
      decoration: BoxDecoration(
        color: themeNotifier.isDarkMode ? Colors.grey[800]! : Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20.0),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _buildBottomSheetListItem(
            Icons.edit,
            'İçeriği Düzenle',
                () {
              Navigator.pop(context);
              _editNote(context, index);
            },
          ),
          _buildBottomSheetListItem(
            Icons.delete,
            'Sil',
                () {
              Navigator.pop(context);
              _showDeleteConfirmationDialog(context, index);
            },
          ),
          _buildBottomSheetListItem(
            Icons.archive,
            'Arşivle',
                () {
              Navigator.pop(context);
              _showArchiveConfirmationDialog(context, index);
            },
          ),
          _buildBottomSheetListItem(
            Icons.edit,
            'Başlığı Yeniden Adlandır',
                () {
              Navigator.pop(context);
              _showRenameNoteDialog(context, index);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSheetListItem(IconData icon, String title, Function() onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap,
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Notu Sil"),
          content: Text("Bu notu silmek istiyor musun?"),
          actions: <Widget>[
            TextButton(
              child: Text("Evet"),
              onPressed: () {
                Navigator.pop(context);
                _deleteNoteAtIndex(index);
              },
            ),
            TextButton(
              child: Text("Hayır"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteNoteAtIndex(int index) async {
    String oldFolder = widget.folderNotes[index].folderName;

    if (await _deleteNoteWithAPI(widget.folderNotes[index])) {
      setState(() {
        widget.deletedNotes.add(widget.folderNotes[index]);
        widget.folderNotes.removeAt(index);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.folderNotes[index].noteTitle} Silindi'),
          duration: Duration(seconds: 2),
          action: SnackBarAction(
            label: 'Geri Al',
            onPressed: () async {
              Note newNote = widget.deletedNotes.last;
              if (await _updateFolderWithAPI(newNote, oldFolder)) {
                setState(() {
                  widget.deletedNotes.removeLast();
                  widget.folderNotes.add(newNote);
                });
              }
            },
          ),
        ),
      );
    }
  }

  Future<bool> _deleteNoteWithAPI(Note note) async {
    return _updateFolderWithAPI(note, "Çöp Kutusu");
  }

  void _showArchiveConfirmationDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Notu Arşivle"),
          content: Text("Bu notu arşivlemek istiyor musun?"),
          actions: <Widget>[
            TextButton(
              child: Text("Evet"),
              onPressed: () {
                Navigator.pop(context);
                _archiveNoteAtIndex(index);
              },
            ),
            TextButton(
              child: Text("Hayır"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _archiveNoteAtIndex(int index) async {
    String oldFolder = widget.folderNotes[index].folderName;

    if (await _archiveNoteWithAPI(widget.folderNotes[index])) {
      setState(() {
        widget.archivedNotes.add(widget.folderNotes[index]);
        widget.folderNotes.removeAt(index);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.folderNotes[index].noteTitle} Arşivlendi'),
          duration: Duration(seconds: 2),
          action: SnackBarAction(
            label: 'Geri Al',
            onPressed: () async {
              Note newNote = widget.archivedNotes.last;
              if (await _updateFolderWithAPI(newNote, oldFolder)) {
                setState(() {
                  widget.archivedNotes.removeLast();
                  widget.folderNotes.add(newNote);
                });
              }
            },
          ),
        ),
      );
    }
  }

  Future<bool> _archiveNoteWithAPI(Note note) async {
    return _updateFolderWithAPI(note, "Arşiv");
  }

  void _showRenameNoteDialog(BuildContext context, int index) {
    TextEditingController controller = TextEditingController(text: widget.folderNotes[index].noteTitle);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Yeniden Adlandır"),
          content: TextFormField(
            autofocus: true,
            controller: controller,
            decoration: InputDecoration(hintText: "Yeni Not Adı"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text("İptal"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Kaydet"),
              onPressed: () async {
                String newName = controller.text;
                widget.folderNotes[index].noteTitle = newName;

                if (await _updateNoteWithAPI(widget.folderNotes[index])) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Not başlığı güncellendi: $newName'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                  Navigator.of(context).pop();
                  setState(() {});
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Not başlığı güncellenemedi.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<bool> _updateFolderWithAPI(Note note, String folderName) async {
    try {
      note.folderName = folderName;
      return await _updateNoteWithAPI(note);
    } catch (e) {
      print('Hata: $e');
      return false;
    }
  }
}
