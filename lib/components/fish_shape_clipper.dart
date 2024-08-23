import 'package:flutter/material.dart';

class FishShapeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final Path path = Path();
    final double width = size.width;
    final double height = size.height;

    // Balığın gövdesi
    path.moveTo(width * 0.2, height * 0.5); // Balığın gövdesinin sol kısmı
    path.quadraticBezierTo(width * 0.1, height * 0.3, width * 0.3, height * 0.2); // Sol üst kuyruk
    path.quadraticBezierTo(width * 0.4, height * 0.1, width * 0.5, height * 0.2); // Balığın üst kısmı
    path.quadraticBezierTo(width * 0.6, height * 0.1, width * 0.7, height * 0.2); // Balığın alt kısmı
    path.quadraticBezierTo(width * 0.8, height * 0.3, width * 0.7, height * 0.5); // Sağ üst kuyruk

    // Balığın kuyruğu
    path.lineTo(width * 0.8, height * 0.5);
    path.lineTo(width * 0.7, height * 0.6);
    path.lineTo(width * 0.7, height * 0.8);
    path.lineTo(width * 0.5, height * 0.7);
    path.lineTo(width * 0.3, height * 0.8);
    path.lineTo(width * 0.3, height * 0.6);
    path.lineTo(width * 0.2, height * 0.5);

    path.close(); // Balığın şeklinin kapanması

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}


