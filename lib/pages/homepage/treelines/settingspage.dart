import 'package:flutter/material.dart';
import 'package:notlar/components/themenotifier.dart';
import 'package:provider/provider.dart';
import 'package:notlar/pages/homepage/treelines/changepassword.dart';
import '../../../models/User.dart';

class SettingsPage extends StatefulWidget {
  final User user;
  const SettingsPage({Key? key, required this.user}) : super(key: key);

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  double fontSize = 16.0; // Örnek bir yazı tipi boyutu

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return Scaffold(
      backgroundColor: themeNotifier.isDarkMode ? Colors.grey[800] : Colors
          .grey[300],
      appBar: AppBar(
        backgroundColor: themeNotifier.isDarkMode ? Colors.grey[800] : Colors
            .grey[300],
        title: Text('Ayarlar'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          Consumer<ThemeNotifier>(
            builder: (context, themeNotifier, child) {
              return ListTile(
                title: Text('Tema Seçimi'),
                subtitle: Text(themeNotifier.isDarkMode
                    ? 'Uygulamanın temasını karanlık moda geçirin'
                    : 'Uygulamanın temasını aydınlık moda geçirin'),
                trailing: IconButton(
                  icon: Icon(themeNotifier.isDarkMode ? Icons.dark_mode : Icons
                      .light_mode),
                  onPressed: () {
                    themeNotifier.toggleTheme();
                  },
                ),
              );
            },
          ),
          Divider(),
          ListTile(
            title: Text('Şifre Değiştir'),
            subtitle: Text('Şifrenizi değiştirmek için tıklayın'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>
                    ChangePasswordPage(user: widget.user)),
              );
            },
          ),
          Divider(),
          ListTile(
            title: Text('Yazı Tipi Boyutu'),
            subtitle: Text('Yazı tipi boyutunu ayarlamak için tıklayın'),
            onTap: () {
              showFontSizeDialog();
            },
          ),
        ],
      ),
    );
  }

  void showFontSizeDialog() {
    double selectedFontSize = fontSize; // Başlangıçta seçilen boyut, mevcut boyut

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Yazı Tipi Boyutu'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Yazı tipi boyutunu seçin:'),
              SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        selectedFontSize = 12.0; // Düşük boyut
                        Navigator.of(context).pop(selectedFontSize);
                        Provider.of<ThemeNotifier>(context, listen: false)
                            .setFontSize(selectedFontSize);
                      },
                      child: Text('Küçük'),
                    ),
                  ),
                  SizedBox(width: 8.0),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        selectedFontSize = 20.0; // Orta boyut
                        Navigator.of(context).pop(selectedFontSize);
                        Provider.of<ThemeNotifier>(context, listen: false)
                            .setFontSize(selectedFontSize);
                      },
                      child: Text('Orta'),
                    ),
                  ),
                  SizedBox(width: 8.0),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        selectedFontSize = 25.0; // Büyük boyut
                        Navigator.of(context).pop(selectedFontSize);
                        Provider.of<ThemeNotifier>(context, listen: false)
                            .setFontSize(selectedFontSize);
                      },
                      child: Text('Büyük'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
