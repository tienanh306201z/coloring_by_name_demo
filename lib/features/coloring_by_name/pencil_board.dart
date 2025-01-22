import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PencilBoard extends StatelessWidget {
  final String svgAssetPath;
  final ui.Image? pencilImage;

  const PencilBoard({super.key, required this.svgAssetPath, this.pencilImage});

  @override
  Widget build(BuildContext context) {
    // Show a loader until the checkerboard image is generated
    if (pencilImage == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (Rect bounds) {
        return ImageShader(
          pencilImage!,
          TileMode.repeated,
          TileMode.repeated,
          // You can tweak the matrix to scale or move the pattern
          Matrix4.identity().scaled(0.05, 0.05).storage,
        );
      },
      child: SvgPicture.asset(
        svgAssetPath,
        fit: BoxFit.contain,
      ),
    );
  }
}
