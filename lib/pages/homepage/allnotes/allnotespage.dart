import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:notlar/components/fish_shape_clipper.dart';
import 'package:notlar/components/themenotifier.dart';
import 'package:notlar/models/note.dart';
import 'package:http/http.dart' as http;
import 'package:notlar/pages/homepage/folders/notecontentpage.dart';
import 'package:provider/provider.dart';

class AllNotesPage extends StatefulWidget {
  final List<Note> notes;
  final List<Note> deletedNotes;
  final List<Note> archivedNotes;

  const AllNotesPage({
    Key? key,
    required this.notes,
    required this.deletedNotes,
    required this.archivedNotes,
  }) : super(key: key);

  @override
  _AllNotesPageState createState() => _AllNotesPageState();
}

class _AllNotesPageState extends State<AllNotesPage> with SingleTickerProviderStateMixin {
  final Random _random = Random();
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )
      ..repeat(reverse: true);

    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return Scaffold(
      body: Stack(
        children: [
          // Akvaryum arka planı
          Positioned.fill(
            child: Image.asset(
              'lib/images/aquarium_background.jpg', // Akvaryum arka planı resmi
              fit: BoxFit.cover,
            ),
          ),
          // Not kartları
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Stack(
                children: widget.notes.map((note) {
                  final double offsetX = _random.nextDouble() * MediaQuery
                      .of(context)
                      .size
                      .width;
                  final double offsetY = _random.nextDouble() * MediaQuery
                      .of(context)
                      .size
                      .height;
                  return AnimatedPositioned(
                    left: offsetX,
                    top: offsetY,
                    duration: const Duration(seconds: 5),
                    child: GestureDetector(
                      onTap: () {
                        editNote(context, widget.notes.indexOf(note));
                      },
                      onLongPress: () {
                        showModalBottomSheet(
                          context: context,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20.0),
                            ),
                          ),
                          backgroundColor: Colors.transparent,
                          builder: (context) {
                            return Container(
                              decoration: BoxDecoration(
                                color: themeNotifier.isDarkMode
                                    ? Colors.grey[800]
                                    : Colors.white,
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(20.0),
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  ListTile(
                                    leading: Icon(Icons.edit),
                                    title: Text('İçeriği Düzenle'),
                                    onTap: () {
                                      Navigator.pop(context);
                                      editNote(
                                          context, widget.notes.indexOf(note));
                                    },
                                  ),
                                  ListTile(
                                    leading: Icon(Icons.delete),
                                    title: Text('Sil'),
                                    onTap: () {
                                      Navigator.pop(context);
                                      deleteNoteConfirmation(
                                          context, widget.notes.indexOf(note));
                                    },
                                  ),
                                  ListTile(
                                    leading: Icon(Icons.archive),
                                    title: Text('Arşivle'),
                                    onTap: () {
                                      Navigator.pop(context);
                                      archiveNoteConfirmation(
                                          context, widget.notes.indexOf(note));
                                    },
                                  ),
                                  ListTile(
                                    leading: Icon(Icons.edit),
                                    title: Text('Başlığı Yeniden Adlandır'),
                                    onTap: () {
                                      Navigator.pop(context);
                                      renameNote(
                                          context, widget.notes.indexOf(note));
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      child: ClipPath(
                        clipper: FishShapeClipper(),
                        // Balık şeklinde klipleyici
                        child: Container(
                          padding: EdgeInsets.all(10),
                          margin: EdgeInsets.symmetric(
                              vertical: 5, horizontal: 10),
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('lib/images/fish.jpg'), // Balık arka plan resmi
                              fit: BoxFit.cover,
                            ),
                            color: themeNotifier.isDarkMode
                                ? Colors.grey[700]
                                : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                spreadRadius: 2,
                                blurRadius: 5,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              note.noteTitle,
                              style: TextStyle(
                                fontSize: 18,
                                color: themeNotifier.isDarkMode
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void editNote(BuildContext context, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteContentPage(note: widget.notes[index]),
      ),
    ).then((editedNote) {
      if (editedNote != null) {
        updateNoteWithAPI(editedNote).then((success) {
          if (success) {
            setState(() {
              widget.notes[index] = editedNote;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Not Düzenlendi: ${editedNote.noteTitle}'),
                duration: Duration(seconds: 2),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Not düzenlenirken bir hata oluştu.'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        });
      }
    });
  }

  void deleteNoteConfirmation(BuildContext context, int index) {
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
                Navigator.of(context).pop();
                deleteNote(context, index);
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

  void deleteNote(BuildContext context, int index) {
    Note noteToDelete = widget.notes[index];
    String oldFolder = noteToDelete.folderName;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${noteToDelete.noteTitle} Silindi'),
        duration: Duration(seconds: 2),
        action: SnackBarAction(
          label: 'Geri Al',
          onPressed: () async {
            if (await updateFolderWithAPI(noteToDelete, oldFolder)) {
              setState(() {
                widget.deletedNotes.remove(noteToDelete);
                widget.notes.add(noteToDelete);
              });
            }
          },
        ),
      ),
    );

    deleteWithAPI(noteToDelete).then((success) {
      if (success) {
        setState(() {
          widget.deletedNotes.add(noteToDelete);
          widget.notes.removeAt(index);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Not silinirken bir hata oluştu.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
  }

  void archiveNoteConfirmation(BuildContext context, int index) {
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
                Navigator.of(context).pop();
                archiveNote(context, index);
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

  void archiveNote(BuildContext context, int index) {
    String oldFolder = widget.notes[index].folderName;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.notes[index].noteTitle} Arşivlendi'),
        duration: Duration(seconds: 2),
        action: SnackBarAction(
          label: 'Geri Al',
          onPressed: () async {
            Note newNote = widget.deletedNotes.last;
            if (await updateFolderWithAPI(newNote, oldFolder)) {
              setState(() {
                widget.archivedNotes.removeLast();
                widget.notes.add(newNote);
              });
            }
          },
        ),
      ),
    );

    archiveWithAPI(widget.notes[index]).then((success) {
      if (success) {
        setState(() {
          widget.archivedNotes.add(widget.notes[index]);
          widget.notes.removeAt(index);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Not arşivlenirken bir hata oluştu.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
  }

  void renameNote(BuildContext context, int index) {
    TextEditingController controller =
    TextEditingController(text: widget.notes[index].noteTitle);

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
                widget.notes[index].noteTitle = newName;

                updateWithAPI(widget.notes[index]).then((success) {
                  if (success) {
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
                });
              },
            ),
          ],
        );
      },
    );
  }

  Future<bool> deleteWithAPI(Note note) async {
    return updateFolderWithAPI(note, "Çöp Kutusu");
  }

  Future<bool> archiveWithAPI(Note note) async {
    return updateFolderWithAPI(note, "Arşiv");
  }

  Future<bool> updateNoteWithAPI(Note note) async {
    String url = 'http://10.0.2.2:8080/api/notes/${note.id}';
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(note.toJson()),
      );
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateWithAPI(Note note) async {
    String url = 'http://10.0.2.2:8080/api/notes/${note.id}';
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(note.toJson()),
      );
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateFolderWithAPI(Note note, String newFolder) async {
    String url = 'http://10.0.2.2:8080/api/notes/${note.id}';
    note.folderName = newFolder;
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(note.toJson()),
      );
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
