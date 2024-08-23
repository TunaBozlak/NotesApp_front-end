import 'package:flutter/material.dart';
import 'package:notlar/components/mybutton.dart';
import 'package:notlar/components/mytextfield.dart';
import 'package:notlar/components/themenotifier.dart';
import 'package:notlar/models/User.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../models/User.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatelessWidget {
  final VoidCallback Girisyap;
  final Function(User) Kayitol;

  const RegisterPage({Key? key, required this.Girisyap, required this.Kayitol})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    final usernameController = TextEditingController();
    final passwordController = TextEditingController();
    final mailController = TextEditingController();

    return Scaffold(
      backgroundColor: themeNotifier.isDarkMode ? Colors.grey[800] : Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: 50),

                // Hesap Oluştur!
                Text(
                  'Hesap Oluştur!',
                  style: TextStyle(
                    color: themeNotifier.isDarkMode ? Colors.white : Colors.grey[700],
                    fontSize: themeNotifier.fontSize,
                  ),
                ),
                SizedBox(height: 25),

                // Kullanıcı adı metin alanı
                MyTextField(
                  controller: usernameController,
                  hintText: 'Kullanıcı Adı',
                  obscureText: false,
                ),
                SizedBox(height: 10),

                // E-posta metin alanı
                MyTextField(
                  controller: mailController,
                  hintText: 'E-posta',
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

                // Kayıt ol düğmesi
                MyButton(
                  onTap: () {
                    // Kullanıcı adı, e-posta ve şifre kontrolü yapılıyor
                    if (usernameController.text.isNotEmpty &&
                        mailController.text.isNotEmpty &&
                        passwordController.text.isNotEmpty) {
                      createUser(context, mailController.text, usernameController.text, passwordController.text);
                    } else {
                      // Kullanıcıya bir uyarı gösterilebilir
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text("Hata"),
                          content: Text(
                              "Kullanıcı adı, e-posta ve şifre boş olamaz."),
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
                  text: 'Kayıt Ol',
                ),
                SizedBox(height: 50),

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
                SizedBox(height: 50),

                // Zaten üye misin? Giriş yap
                GestureDetector(
                  onTap: Girisyap,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Zaten üye misin',
                        style: TextStyle(color: themeNotifier.isDarkMode ? Colors.white : Colors.grey[700]),
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Giriş Yap',
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
      ),
    );
  }

  void createUser(BuildContext context, String mail, String username,
      String password) async {
    User user = new User(
        email: mail, username: username, password: password, notes: []);
    String url = 'http://10.0.2.2:8080/api/users';
    print(json.encode(user));
    //10 sn time limit
    final response = await http.post(
      Uri.parse(url),
      body: json.encode(user),
      headers: {
        'Content-Type': 'application/json',
      },
    ).timeout(const Duration(seconds: 10));
    if (response.statusCode == 201) {
      //API'den 201 dönerse, kullanıcı oluşturuldu
      String decodedData = utf8.decode(response.bodyBytes);
      user = User.fromJson(jsonDecode(decodedData));
      Kayitol(user);
    }
    // Kullanıcı adı veya şifre yanlış olduğunu belirtmek için alert dialog

    else if (response.statusCode == 403) {
      //API'den 403 dönerse, email zaten alınmış
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Hata"),
          content: Text("Bu email adresi alınmış."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Tamam"),
            ),
          ],
        ),
      );
    } else if (response.statusCode == 409) {
      //API'den 409 dönerse, kullanıcı adı zaten alınmış.

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Hata"),
          content: Text("Bu kullanıcı adı daha önce alınmış."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Tamam"),
            ),
          ],
        ),
      );
    } else {
      //API'den 409 dönerse, kullanıcı adı zaten alınmış.

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Hata"),
          content: Text("Sistemde beklenmedik bir hata oluştu."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Tamam"),
            ),
          ],
        ),
      );
    }
  }
}
