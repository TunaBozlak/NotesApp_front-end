import 'package:flutter/material.dart';
import 'package:notlar/pages/homepage/folders/foldernotespage.dart';
import 'package:notlar/components/themenotifier.dart';
import 'package:provider/provider.dart';

import '../../../models/note.dart';

class ChooseFolderPage extends StatelessWidget {
  final List<Note> notes;
  final List<Note> deletedNotes;
  final List<Note> archivedNotes;
  final List<String> folders = [
    'Kişisel Notlarım',
    'Görev Listesi',
    'Rüya Günlüğü',
    'Projeler',
    'Okuma Listesi',
    'Çizimler'
  ];

  ChooseFolderPage({
    Key? key,
    required this.notes,
    required this.deletedNotes,
    required this.archivedNotes,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return GridView.count(
      crossAxisCount: 2,
      children: folders.map((folderName) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FolderNotesPage(
                  folderName: folderName,
                  folderNotes: notes.where((note) => note.folderName == folderName).toList(),
                  archivedNotes: archivedNotes,
                  deletedNotes: deletedNotes,
                ),
              ),
            );
          },
          child: Container(
            margin: EdgeInsets.all(8),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: themeNotifier.isDarkMode ? Colors.white12 : Colors.grey[400],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                folderName,
                style: TextStyle(
                  color: themeNotifier.isDarkMode ? Colors.white : Colors.black87,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
