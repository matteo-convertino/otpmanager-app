import 'package:arrow_path/arrow_path.dart';
import 'package:flutter/material.dart';

class ArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 3.0;

    Path path = Path();

    path.moveTo(-130, -115);
    path.relativeCubicTo(0, 0, 0, 30, 50, 55);
    path = ArrowPath.addTip(path);

    canvas.drawPath(path, paint..color = Colors.blue);
  }

  @override
  bool shouldRepaint(ArrowPainter oldDelegate) => false;
}
