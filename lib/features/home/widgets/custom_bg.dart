import 'package:flutter/material.dart';

class TodayBgCustom extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint();
    Path path = Path();

    // Path number 1

    paint.color = Color(0xffC84523);
    path = Path();
    path.lineTo(size.width, size.height * 0.93);
    path.cubicTo(size.width, size.height * 0.97, size.width * 0.98, size.height,
        size.width * 0.97, size.height);
    path.cubicTo(size.width * 0.97, size.height, size.width * 0.87, size.height,
        size.width * 0.87, size.height);
    path.cubicTo(size.width * 0.85, size.height, size.width * 0.84,
        size.height * 0.97, size.width * 0.83, size.height * 0.93);
    path.cubicTo(size.width * 0.82, size.height * 0.89, size.width * 0.79,
        size.height * 0.86, size.width * 0.77, size.height * 0.86);
    path.cubicTo(size.width * 0.77, size.height * 0.86, size.width * 0.47,
        size.height * 0.86, size.width * 0.47, size.height * 0.86);
    path.cubicTo(size.width * 0.44, size.height * 0.86, size.width * 0.42,
        size.height * 0.89, size.width * 0.41, size.height * 0.93);
    path.cubicTo(size.width * 0.4, size.height * 0.97, size.width * 0.39,
        size.height, size.width * 0.37, size.height);
    path.cubicTo(size.width * 0.37, size.height, size.width * 0.03, size.height,
        size.width * 0.03, size.height);
    path.cubicTo(size.width * 0.02, size.height, 0, size.height * 0.97, 0,
        size.height * 0.93);
    path.cubicTo(
        0, size.height * 0.93, 0, size.height * 0.07, 0, size.height * 0.07);
    path.cubicTo(
        0, size.height * 0.03, size.width * 0.02, 0, size.width * 0.03, 0);
    path.cubicTo(
        size.width * 0.03, 0, size.width * 0.26, 0, size.width * 0.26, 0);
    path.cubicTo(size.width * 0.28, 0, size.width * 0.29, size.height * 0.03,
        size.width * 0.3, size.height * 0.06);
    path.cubicTo(size.width * 0.31, size.height * 0.09, size.width / 3,
        size.height * 0.12, size.width * 0.36, size.height * 0.12);
    path.cubicTo(size.width * 0.36, size.height * 0.12, size.width * 0.45,
        size.height * 0.12, size.width * 0.45, size.height * 0.12);
    path.cubicTo(size.width * 0.47, size.height * 0.12, size.width * 0.49,
        size.height * 0.09, size.width * 0.51, size.height * 0.06);
    path.cubicTo(size.width * 0.52, size.height * 0.03, size.width * 0.53, 0,
        size.width * 0.55, 0);
    path.cubicTo(
        size.width * 0.55, 0, size.width * 0.97, 0, size.width * 0.97, 0);
    path.cubicTo(size.width * 0.98, 0, size.width, size.height * 0.03,
        size.width, size.height * 0.07);
    path.cubicTo(size.width, size.height * 0.07, size.width, size.height * 0.93,
        size.width, size.height * 0.93);
    path.cubicTo(size.width, size.height * 0.93, size.width, size.height * 0.93,
        size.width, size.height * 0.93);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class MyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));
    Paint paint = Paint();
    Path path = Path();

    // Path number 1

    paint.color = Color(0xff777777);
    path = Path();
    path.lineTo(0, size.height * 0.12);
    path.cubicTo(
        0, size.height * 0.05, size.width * 0.03, 0, size.width * 0.06, 0);
    path.cubicTo(
        size.width * 0.06, 0, size.width * 0.59, 0, size.width * 0.59, 0);
    path.cubicTo(size.width * 0.61, 0, size.width * 0.62, size.height * 0.01,
        size.width * 0.64, size.height * 0.04);
    path.cubicTo(size.width * 0.64, size.height * 0.04, size.width * 0.98,
        size.height * 0.8, size.width * 0.98, size.height * 0.8);
    path.cubicTo(size.width * 1.02, size.height * 0.87, size.width, size.height,
        size.width * 0.94, size.height);
    path.cubicTo(size.width * 0.94, size.height, size.width * 0.06, size.height,
        size.width * 0.06, size.height);
    path.cubicTo(size.width * 0.03, size.height, 0, size.height * 0.95, 0,
        size.height * 0.88);
    path.cubicTo(
        0, size.height * 0.88, 0, size.height * 0.12, 0, size.height * 0.12);
    path.cubicTo(
        0, size.height * 0.12, 0, size.height * 0.12, 0, size.height * 0.12);
    canvas.drawPath(path, paint);

    // Path number 2

    paint.color = Color(0xff777777);
    path = Path();
    path.lineTo(size.width * 1.69, 0);
    path.cubicTo(size.width * 1.72, 0, size.width * 1.75, size.height * 0.05,
        size.width * 1.75, size.height * 0.12);
    path.cubicTo(size.width * 1.75, size.height * 0.12, size.width * 1.75,
        size.height * 0.53, size.width * 1.75, size.height * 0.53);
    path.cubicTo(size.width * 1.75, size.height * 0.58, size.width * 1.72,
        size.height * 0.62, size.width * 1.69, size.height * 0.62);
    path.cubicTo(size.width * 1.62, size.height * 0.62, size.width * 1.57,
        size.height * 0.73, size.width * 1.57, size.height * 0.88);
    path.cubicTo(size.width * 1.57, size.height * 0.93, size.width * 1.55,
        size.height, size.width * 1.52, size.height);
    path.cubicTo(size.width * 1.52, size.height, size.width * 1.16, size.height,
        size.width * 1.16, size.height);
    path.cubicTo(size.width * 1.14, size.height, size.width * 1.12, size.height,
        size.width * 1.11, size.height * 0.96);
    path.cubicTo(size.width * 1.11, size.height * 0.96, size.width * 0.76,
        size.height / 5, size.width * 0.76, size.height / 5);
    path.cubicTo(size.width * 0.73, size.height * 0.13, size.width * 0.76, 0,
        size.width * 0.81, 0);
    path.cubicTo(
        size.width * 0.81, 0, size.width * 1.69, 0, size.width * 1.69, 0);
    path.cubicTo(
        size.width * 1.69, 0, size.width * 1.69, 0, size.width * 1.69, 0);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class Card1Painter extends CustomPainter {
  final Color color;
  const Card1Painter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    // Clip biar tidak tembus
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final paint = Paint()..color = color;
    final path = Path();

    path.lineTo(0, size.height * 0.12);
    path.cubicTo(
        0, size.height * 0.05, size.width * 0.03, 0, size.width * 0.06, 0);
    path.cubicTo(
        size.width * 0.06, 0, size.width * 0.59, 0, size.width * 0.59, 0);
    path.cubicTo(size.width * 0.61, 0, size.width * 0.62, size.height * 0.01,
        size.width * 0.64, size.height * 0.04);
    path.cubicTo(size.width * 0.64, size.height * 0.04, size.width * 0.98,
        size.height * 0.8, size.width * 0.98, size.height * 0.8);
    path.cubicTo(size.width * 1.02, size.height * 0.87, size.width, size.height,
        size.width * 0.94, size.height);
    path.cubicTo(size.width * 0.94, size.height, size.width * 0.06, size.height,
        size.width * 0.06, size.height);
    path.cubicTo(size.width * 0.03, size.height, 0, size.height * 0.95, 0,
        size.height * 0.88);
    path.cubicTo(
        0, size.height * 0.88, 0, size.height * 0.12, 0, size.height * 0.12);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(Card1Painter old) => old.color != color;
}

class Card2Painter extends CustomPainter {
  final Color color;
  const Card2Painter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    // Clip biar tidak tembus
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final paint = Paint()..color = color;
    final path = Path();

    path.lineTo(size.width * 1.69, 0);
    path.cubicTo(size.width * 1.72, 0, size.width * 1.75, size.height * 0.05,
        size.width * 1.75, size.height * 0.12);
    path.cubicTo(size.width * 1.75, size.height * 0.12, size.width * 1.75,
        size.height * 0.53, size.width * 1.75, size.height * 0.53);
    path.cubicTo(size.width * 1.75, size.height * 0.58, size.width * 1.72,
        size.height * 0.62, size.width * 1.69, size.height * 0.62);
    path.cubicTo(size.width * 1.62, size.height * 0.62, size.width * 1.57,
        size.height * 0.73, size.width * 1.57, size.height * 0.88);
    path.cubicTo(size.width * 1.57, size.height * 0.93, size.width * 1.55,
        size.height, size.width * 1.52, size.height);
    path.cubicTo(size.width * 1.52, size.height, size.width * 1.16, size.height,
        size.width * 1.16, size.height);
    path.cubicTo(size.width * 1.14, size.height, size.width * 1.12, size.height,
        size.width * 1.11, size.height * 0.96);
    path.cubicTo(size.width * 1.11, size.height * 0.96, size.width * 0.76,
        size.height / 5, size.width * 0.76, size.height / 5);
    path.cubicTo(size.width * 0.73, size.height * 0.13, size.width * 0.76, 0,
        size.width * 0.81, 0);
    path.cubicTo(
        size.width * 0.81, 0, size.width * 1.69, 0, size.width * 1.69, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(Card2Painter old) => old.color != color;
}
