import 'package:flutter/material.dart';
import 'package:notlar/components/themenotifier.dart';
import 'package:provider/provider.dart';

class SelectFolderPage extends StatelessWidget {
  final List<String> folders = [
    'Kişisel Notlarım',
    'Görev Listesi',
    'Rüya Günlüğü',
    'Projeler',
    'Okuma Listesi',
    'Çizimler'
  ];

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return AlertDialog(
      title: Text('Klasör Seçin'),
      backgroundColor: themeNotifier.isDarkMode ? Colors.grey[800] : Colors.grey[300],
      content: SingleChildScrollView(
        child: ListBody(
          children: folders.map((folder) {
            return ListTile(
              title: Text(
                folder,
                style: TextStyle(
                  color: themeNotifier.isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              onTap: () {
                Navigator.of(context).pop(folder); // Seçilen klasörü geri döndür
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
