import 'models.dart';
import 'package:flutter/material.dart';

class SvgPainter extends CustomPainter {
  final BuildContext context;
  final PathSvgItem pathSvgItem;
  final VoidCallback onTap;

  SvgPainter({
    required this.context,
    required this.pathSvgItem,
    required this.onTap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = pathSvgItem.path;

    // Draw the base color.
    final baseColorPaint = Paint()
      ..style = PaintingStyle.fill
      // ..blendMode = pathSvgItem.isColored ? BlendMode.hardLight : BlendMode.srcOver
      ..color = pathSvgItem.currentColor ?? Colors.black;

    canvas.drawPath(path, baseColorPaint);
  }

  @override
  bool? hitTest(Offset position) {
    final path = pathSvgItem.path;
    final hitTestArea = Rect.fromCenter(center: position, width: 20, height: 20);
    final pathBounds = path.getBounds();

    if (path.contains(position) || pathBounds.overlaps(hitTestArea)) {
      onTap();
      return true;
    }
    return super.hitTest(position);
  }

  @override
  bool shouldRepaint(covariant SvgPainter oldDelegate) {
    return pathSvgItem.currentColor != oldDelegate.pathSvgItem.currentColor || pathSvgItem.isColored != oldDelegate.pathSvgItem.isColored;
  }
}
