import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:notlar/components/mybutton.dart';
import 'package:notlar/components/mytextfield.dart';
import 'package:notlar/components/squaretile.dart';
import 'package:notlar/components/themenotifier.dart';

import '../../models/User.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatelessWidget {
  final VoidCallback Uyeol;
  final Function(User) Oturumac;
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();

  LoginPage({Key? key, required this.Uyeol, required this.Oturumac}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return Scaffold(
      backgroundColor: themeNotifier.isDarkMode ? Colors.grey[800] : Colors.grey[300],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 40),

              // Logo
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.account_circle,
                    size: 125,
                  )
                ],
              ),

              SizedBox(height: 25),

              // Tekrar hoş geldin!
              Text(
                'Hoşgeldiniz!',
                style: TextStyle(
                  color: themeNotifier.isDarkMode ? Colors.white : Colors.grey[700],
                  fontSize: themeNotifier.fontSize, // Yazı tipi boyutunu dinamik olarak ayarla
                ),
              ),
              SizedBox(height: 25),

              // Kullanıcı adı metin alanı
              MyTextField(
                controller: usernameController,
                hintText: 'Kullanıcı Adı/e-posta',
                obscureText: false,
              ),
              SizedBox(height: 10),

              // Şifre metin alanı
              MyTextField(
                controller: passwordController,
                hintText: 'Şifre',
                obscureText: true,
              ),
              SizedBox(height: 10),

              // Şifreyi unuttum
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Şifremi unuttum',
                      style: TextStyle(color: themeNotifier.isDarkMode ? Colors.white : Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),

              // Oturum aç düğmesi
              MyButton(
                onTap: () async {
                  // Kullanıcı adı, e-posta ve şifre kontrolü yapılıyor
                  if (usernameController.text.isNotEmpty && passwordController.text.isNotEmpty) {
                    // Kayıt işlemi gerçekleştirilir
                    User? user = await login(context);
                    if (user != null) {
                      Oturumac(user);
                    };
                  } else {
                    // Kullanıcıya bir uyarı gösterilebilir
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text("Hata"),
                        content: Text("Kullanıcı adı ve şifre boş olamaz."),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text("Tamam"),
                          ),
                        ],
                      ),
                    );
                  }
                },
                text: 'Oturum Aç',
              ),

              SizedBox(height: 30),

              // Veya devam et
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Divider(
                        thickness: 0.5,
                        color: themeNotifier.isDarkMode ? Colors.white : Colors.grey[400],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text(
                        'veya devam et',
                        style: TextStyle(color: themeNotifier.isDarkMode ? Colors.white : Colors.grey[700]),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        thickness: 0.5,
                        color: themeNotifier.isDarkMode ? Colors.white : Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),

              // Google ve Apple ile oturum açma
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  SquareTile(imagePath: 'lib/images/google.png'),
                  SizedBox(width: 10), // İki buton arasında boşluk bırakmak için
                  SquareTile(imagePath: 'lib/images/apple.png'),
                ],
              ),
              SizedBox(height: 30),

              // Üye değil misin? Kayıt ol
              GestureDetector(
                onTap: Uyeol,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Üye değil misin',
                      style: TextStyle(color: themeNotifier.isDarkMode ? Colors.white : Colors.grey[700]),
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Üye ol',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<User?> login(BuildContext context) async {
    String username = usernameController.text;
    String password = passwordController.text;
    User? user;
    String url = 'http://10.0.2.2:8080/api/users/$username/$password';
    //10 sn time limit
    final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      String decodedData = utf8.decode(response.bodyBytes);
      user = User.fromJson(jsonDecode(decodedData));
      return user;
    }

    // Kullanıcı adı veya şifre yanlış olduğunu belirtmek için alert diaolg
    else if (response.statusCode == 401 || response.statusCode == 404) {
      //API'den 401 dönerse, username password ikilisi yanlış,
      //API'den 404 dönerse,böyle bir kullanıcı adı veya eposta yok.

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Giriş Hatası'),
            content: Text('Kullanıcı adı veya şifre yanlış.'),
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
      // Sistem hatası olduğunu belirtmek için alert dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Sistem Hatası'),
            content: Text('Beklenmeyen bir hata oluştu. Lütfen daha sonra tekrar deneyin.'),
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
    return null;
  }

}