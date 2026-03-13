import 'package:flutter/material.dart';

enum TooltipArrowDirection { topCenter, bottomCenter }

class TooltipWithArrowShape extends ShapeBorder {
  final double radius;
  final double arrowWidth;
  final double arrowHeight;
  final TooltipArrowDirection direction;

  const TooltipWithArrowShape({
    this.radius = 8,
    this.arrowWidth = 14,
    this.arrowHeight = 8,
    required this.direction,
  });

  @override
  EdgeInsetsGeometry get dimensions {
    switch (direction) {
      case TooltipArrowDirection.topCenter:
        return EdgeInsets.only(top: arrowHeight);
      case TooltipArrowDirection.bottomCenter:
        return EdgeInsets.only(bottom: arrowHeight);
    }
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final path = Path();

    final left = rect.left;
    final top = rect.top;
    final right = rect.right;
    final bottom = rect.bottom;
    final centerX = rect.center.dx;

    if (direction == TooltipArrowDirection.topCenter) {
      // Corpo sotto, freccia sopra
      final bodyRect = Rect.fromLTWH(
        left,
        top + arrowHeight,
        rect.width,
        rect.height - arrowHeight,
      );
      final rrect = RRect.fromRectAndRadius(bodyRect, Radius.circular(radius));

      path.moveTo(centerX - arrowWidth / 2, top + arrowHeight);
      path.lineTo(centerX, top);
      path.lineTo(centerX + arrowWidth / 2, top + arrowHeight);
      path.addRRect(rrect);
    } else {
      // Corpo sopra, freccia sotto
      final bodyRect = Rect.fromLTWH(
        left,
        top,
        rect.width,
        rect.height - arrowHeight,
      );
      final rrect = RRect.fromRectAndRadius(bodyRect, Radius.circular(radius));

      path.addRRect(rrect);
      path.moveTo(centerX - arrowWidth / 2, bottom - arrowHeight);
      path.lineTo(centerX, bottom);
      path.lineTo(centerX + arrowWidth / 2, bottom - arrowHeight);
    }

    return path;
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return getOuterPath(rect, textDirection: textDirection);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    // Non serve: dipinge ShapeDecoration
  }

  @override
  ShapeBorder scale(double t) {
    return TooltipWithArrowShape(
      radius: radius * t,
      arrowWidth: arrowWidth * t,
      arrowHeight: arrowHeight * t,
      direction: direction,
    );
  }
}
