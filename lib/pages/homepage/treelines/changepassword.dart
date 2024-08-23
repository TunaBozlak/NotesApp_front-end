import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:notlar/components/themenotifier.dart';
import 'package:provider/provider.dart';
import '../../../models/User.dart';
import 'package:http/http.dart' as http;
import '../homepage.dart';

class ChangePasswordPage extends StatelessWidget {
  final User user;

  const ChangePasswordPage({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    TextEditingController oldPasswordController = TextEditingController();
    TextEditingController newPasswordController = TextEditingController();
    TextEditingController newPasswordController2 = TextEditingController();

    return Scaffold(
      backgroundColor: themeNotifier.isDarkMode ? Colors.grey[800] : Colors.grey[300],
      appBar: AppBar(
        backgroundColor: themeNotifier.isDarkMode ? Colors.grey[800] : Colors.grey[300],
        title: Text('Şifre Değiştir'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mevcut Şifre',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            TextFormField(
              controller: oldPasswordController,
              obscureText: true, // Şifrenin görünmesini engeller
              decoration: InputDecoration(
                hintText: 'Mevcut şifrenizi girin',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              'Yeni Şifre',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            TextFormField(
              controller: newPasswordController,
              obscureText: true, // Şifrenin görünmesini engeller
              decoration: InputDecoration(
                hintText: 'Yeni şifrenizi girin',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              'Yeni Şifre Tekrar',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            TextFormField(
              controller: newPasswordController2,
              obscureText: true, // Şifrenin görünmesini engeller
              decoration: InputDecoration(
                hintText: 'Yeni şifrenizi tekrar girin',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: () {
                // Yeni şifreleri kontrol ederek değiştirme işlemini gerçekleştir
                changePassword(
                    context,
                    oldPasswordController.text,
                    newPasswordController.text,
                    newPasswordController2.text,
                    user);
              },
              child: Text('Şifreyi Değiştir'),
            ),
          ],
        ),
      ),
    );
  }

  void changePassword(BuildContext context, String oldPassword,
      String newPassword1, String newPassword2, User user) {
    // Yeni şifreleri kontrol ederek değiştirme işlemini gerçekleştir
    // Burada gerekli işlemleri yapabilirsiniz
    // Örneğin:
    // - Kullanıcının mevcut şifresini kontrol etme
    // - Yeni şifrelerin eşleşip eşleşmediğini kontrol etme
    // - Şifreyi değiştirme işlemini gerçekleştirme
    // - Kullanıcıyı bilgilendirme mesajı gösterme
    if (newPassword1.length > 4 && newPassword2.length > 4) {
      if (newPassword1 == newPassword2) {
        if (oldPassword == user.password) {
          return changePasswordWithAPI(context, newPassword1, user);
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Hata'),
                content: Text('Eski parolanız yanlış.'),
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
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Hata'),
              content: Text('Yeni şifreler eşleşmiyor.'),
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
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Hata'),
            content: Text('Yeni şifre 4 karakterden uzun olmalıdır.'),
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

  void changePasswordWithAPI(
      BuildContext context, String newPassword, User user) async {
    String url = 'http://10.0.2.2:8080/api/users/${user.email}';
    //10 sn time limit
    user.password = newPassword;
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
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('İşlem Başarılı'),
            content: Text('Şifre başarıyla değiştirildi.'),
            actions: <Widget>[
              TextButton(
                child: Text('Tamam'),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage(user: user)),
                  );
                },
              ),
            ],
          );
        },
      );

    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Hata'),
            content: Text('Şifre değiştirilirken sistemde bir hata oldu.'),
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
