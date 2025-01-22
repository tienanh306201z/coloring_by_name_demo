import 'dart:ui';

import 'package:copy_with_extension/copy_with_extension.dart';

part 'models.g.dart';

class VectorImage {
  final List<PathSvgItem> items;
  final Size? size;

  VectorImage({required this.items, this.size});
}

@CopyWith()
class PathSvgItem {
  final Path path;
  Color? currentColor;
  Color? targetColor;
  bool isColored;

  PathSvgItem({required this.path, this.currentColor, this.targetColor, this.isColored = false});
}
