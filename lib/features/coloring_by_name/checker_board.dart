import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CheckerboardSvg extends StatelessWidget {
  final String svgAssetPath;
  final ui.Image? checkerboardImage;

  const CheckerboardSvg({super.key, required this.svgAssetPath, this.checkerboardImage});

  @override
  Widget build(BuildContext context) {
    // Show a loader until the checkerboard image is generated
    if (checkerboardImage == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (Rect bounds) {
        return ImageShader(
          checkerboardImage!,
          TileMode.repeated,
          TileMode.repeated,
          // You can tweak the matrix to scale or move the pattern
          Matrix4.identity().storage,
        );
      },
      child: SvgPicture.asset(
        svgAssetPath,
        fit: BoxFit.contain,
      ),
    );
  }
}
