import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:notlar/components/themenotifier.dart';
import 'package:notlar/models/User.dart';
import 'package:notlar/pages/homepage/addnote/addnotehomepage.dart';
import 'package:notlar/pages/homepage/allnotes/allnotespage.dart';
import 'package:notlar/pages/homepage/treelines/archivepage.dart';
import 'package:notlar/pages/homepage/treelines/settingspage.dart';
import 'package:notlar/pages/homepage/treelines/trashpage.dart';
import 'package:http/http.dart' as http;

import '../../models/note.dart';
import 'folders/choosefolderpage.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  final User user;

  const HomePage({Key? key, required this.user}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    List<Note> allNotes = widget.user.notes ?? [];
    List<Note> deletedNotes = allNotes.where((note) => note.folderName == "Çöp Kutusu").toList();
    List<Note> archivedNotes = allNotes.where((note) => note.folderName == "Arşiv").toList();

    // Çöp ve arşiv dışındaki kategorilerin olduğu liste
    List<Note> notes =
    allNotes.where((note) => note.folderName != "Çöp Kutusu" && note.folderName != "Arşiv").toList();
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: themeNotifier.isDarkMode ? Colors.grey[800] : Colors.grey[300],
        appBar: AppBar(
          backgroundColor: themeNotifier.isDarkMode ? Colors.grey[800] : Colors.grey[300],
          title: Text('Notlarım', style: TextStyle(color: themeNotifier.isDarkMode ? Colors.white : Colors.black)),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Klasörler'),
              Tab(text: 'Tüm Notlar'),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.search, color: themeNotifier.isDarkMode ? Colors.white : Colors.black),
              onPressed: () {
                // Arama işlevselliğini uygula
                showSearchDialog(context);
              },
            ),
            IconButton(
              icon: Icon(Icons.menu, color: themeNotifier.isDarkMode ? Colors.white : Colors.black),
              onPressed: () {
                // Özel menüyü göster
                showCustomMenu(context, notes, archivedNotes, deletedNotes);
              },
            ),
          ],
        ),
        body: TabBarView(
          children: [
            ChooseFolderPage(notes: notes, archivedNotes: archivedNotes, deletedNotes: deletedNotes),
            AllNotesPage(notes: notes, archivedNotes: archivedNotes, deletedNotes: deletedNotes),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddNoteHomePage(user: widget.user)),
            );
          },
          child: Icon(Icons.add),
        ),
      ),
    );
  }

  void showCustomMenu(BuildContext context, List<Note> notes, List<Note> archivedNotes, List<Note> deletedNotes) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.5,
          child: ListView(
            children: [
              ListTile(
                leading: Icon(Icons.archive),
                title: Text("Arşiv"),
                onTap: () {
                  Navigator.pop(context); // Menüyü kapat
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ArchivePage(archivedNotes: archivedNotes)),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.delete),
                title: Text("Çöp Kutusu"),
                onTap: () {
                  Navigator.pop(context); // Menüyü kapat
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TrashPage(deletedNotes: deletedNotes)),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.settings),
                title: Text("Ayarlar"),
                onTap: () {
                  Navigator.pop(context); // Menüyü kapat
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SettingsPage(user: widget.user)),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void showSearchDialog(BuildContext context) {
    TextEditingController searchController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Not Ara"),
          content: TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: "Aranacak not adını girin",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Diyalog kutusunu kapat
              },
              child: Text("İptal"),
            ),
            TextButton(
              onPressed: () {
                String searchText = searchController.text.trim();
                if (searchText.isNotEmpty) {
                  // Aranan notun sayfasına yönlendir
                  // Örneğin:
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(builder: (context) => NotSayfasi(searchText)),
                  // );
                }
                Navigator.pop(context); // Diyalog kutusunu kapat
              },
              child: Text("Ara"),
            ),
          ],
        );
      },
    );
  }

  fetchDataFromAPI() async {
    String url = 'http://10.0.2.2:8080/api/users/${widget.user.email}';
    //10 sn time limit
    final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      String decodedData = utf8.decode(response.bodyBytes);
      User updatedUser = User.fromJson(jsonDecode(decodedData));
      return updatedUser;
    }
  }
}
