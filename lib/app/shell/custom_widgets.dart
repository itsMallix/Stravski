import 'package:flutter/material.dart';

class CustomRecordButton extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint();
    Path path = Path();

    // Path number 1

    paint.color = Color(0xffC84523);
    path = Path();
    path.lineTo(size.width, size.height * 0.23);
    path.cubicTo(size.width, size.height / 4, size.width, size.height * 0.27,
        size.width, size.height * 0.3);
    path.cubicTo(size.width, size.height * 0.3, size.width, size.height * 0.89,
        size.width, size.height * 0.89);
    path.cubicTo(size.width, size.height * 0.95, size.width * 0.98, size.height,
        size.width * 0.95, size.height);
    path.cubicTo(size.width * 0.95, size.height, size.width * 0.05, size.height,
        size.width * 0.05, size.height);
    path.cubicTo(size.width * 0.02, size.height, 0, size.height * 0.95, 0,
        size.height * 0.89);
    path.cubicTo(
        0, size.height * 0.89, 0, size.height * 0.82, 0, size.height * 0.82);
    path.cubicTo(0, size.height * 0.77, size.width * 0.02, size.height * 0.73,
        size.width * 0.03, size.height * 0.7);
    path.cubicTo(size.width * 0.04, size.height * 0.67, size.width * 0.05,
        size.height * 0.64, size.width * 0.05, size.height * 0.6);
    path.cubicTo(size.width * 0.05, size.height * 0.6, size.width * 0.05,
        size.height * 0.4, size.width * 0.05, size.height * 0.4);
    path.cubicTo(size.width * 0.05, size.height * 0.36, size.width * 0.04,
        size.height / 3, size.width * 0.03, size.height * 0.31);
    path.cubicTo(size.width * 0.02, size.height * 0.27, 0, size.height * 0.23,
        0, size.height * 0.18);
    path.cubicTo(
        0, size.height * 0.18, 0, size.height * 0.11, 0, size.height * 0.11);
    path.cubicTo(
        0, size.height * 0.05, size.width * 0.02, 0, size.width * 0.05, 0);
    path.cubicTo(
        size.width * 0.05, 0, size.width * 0.86, 0, size.width * 0.86, 0);
    path.cubicTo(size.width * 0.87, 0, size.width * 0.88, size.height * 0.01,
        size.width * 0.89, size.height * 0.03);
    path.cubicTo(size.width * 0.89, size.height * 0.03, size.width,
        size.height * 0.23, size.width, size.height * 0.23);
    path.cubicTo(size.width, size.height * 0.23, size.width, size.height * 0.23,
        size.width, size.height * 0.23);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
