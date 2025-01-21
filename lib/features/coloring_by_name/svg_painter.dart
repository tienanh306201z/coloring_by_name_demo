import 'dart:ui' as ui;

import 'package:base_flutter/features/coloring_by_name/models.dart';
import 'package:base_flutter/features/coloring_by_name/utils.dart';
import 'package:flutter/material.dart';

class SvgPainter extends CustomPainter {
  final BuildContext context;
  final PathSvgItem pathSvgItem;
  final VoidCallback onTap;

  SvgPainter({required this.context, required this.pathSvgItem, required this.onTap});

  @override
  void paint(Canvas canvas, Size size) {
    // Draw the SVG path
    final path = pathSvgItem.path;
    final paint = Paint()
      ..color = pathSvgItem.currentColor ?? Colors.black
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, paint);
  }

  @override
  bool? hitTest(Offset position) {
    final path = pathSvgItem.path;
    if (path.contains(position)) {
      onTap();
      return true;
    }
    return super.hitTest(position);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => pathSvgItem != (oldDelegate as SvgPainter).pathSvgItem;
}

class MockImagePainter extends CustomPainter {
  final BuildContext context;
  final ui.Image image;

  const MockImagePainter({required this.context, required this.image});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    canvas.scale(1 / (context.devicePixelRatio * 2), 1 / (context.devicePixelRatio * 2));
    canvas.drawImage(image, Offset.zero, paint);
  }

  @override
  bool shouldRepaint(MockImagePainter oldDelegate) => false;
}
