import 'package:flutter/material.dart';

class ThemeNotifier extends ChangeNotifier {
  bool _isDarkMode = false;
  double _fontSize = 20.0; // Varsayılan yazı tipi boyutu

  bool get isDarkMode => _isDarkMode;

  double get fontSize => _fontSize;

  ThemeData get currentTheme => _isDarkMode ? ThemeData.dark() : ThemeData.light();

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void setFontSize(double size) {
    _fontSize = size;
    notifyListeners();
  }
}
