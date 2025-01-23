import 'package:flutter/material.dart';

class PathSegment {
  final Path path;
  final int id;
  final Rect bounds;
  
  PathSegment({
    required this.path,
    required this.id,
    required this.bounds,
  });
}

class QuadTree {
  final Rect bounds;
  final int capacity;
  final List<PathSegment> segments;
  List<QuadTree>? children;
  
  QuadTree(this.bounds, [this.capacity = 4]) : segments = [];
  
  bool insert(PathSegment segment) {
    if (!bounds.overlaps(segment.bounds)) return false;
    
    if (segments.length < capacity) {
      segments.add(segment);
      return true;
    }
    
    children ??= _subdivide();
    
    return children!.any((child) => child.insert(segment));
  }
  
  List<QuadTree> _subdivide() {
    final x = bounds.left;
    final y = bounds.top;
    final w = bounds.width / 2;
    final h = bounds.height / 2;
    
    return [
      QuadTree(Rect.fromLTWH(x, y, w, h)),
      QuadTree(Rect.fromLTWH(x + w, y, w, h)),
      QuadTree(Rect.fromLTWH(x, y + h, w, h)),
      QuadTree(Rect.fromLTWH(x + w, y + h, w, h)),
    ];
  }
  
  List<PathSegment> query(Offset point) {
    if (!bounds.contains(point)) return [];
    
    final results = <PathSegment>[];
    
    results.addAll(segments.where((segment) => 
      segment.bounds.contains(point)));
      
    if (children != null) {
      for (final child in children!) {
        results.addAll(child.query(point));
      }
    }
    
    return results;
  }
}

class ColoringPainter extends CustomPainter {
  final List<PathSegment> paths;
  final Map<int, Color> coloredAreas;
  
  ColoringPainter({
    required this.paths,
    required this.coloredAreas,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    for (final segment in paths) {
      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = coloredAreas[segment.id] ?? Colors.white;
      
      canvas.drawPath(segment.path, paint);
    }
  }
  
  @override
  bool shouldRepaint(ColoringPainter oldDelegate) =>
      paths != oldDelegate.paths ||
      coloredAreas != oldDelegate.coloredAreas;
}

class ColoringPage extends StatefulWidget {
  const ColoringPage({super.key});

  @override
  State<ColoringPage> createState() => _ColoringPageState();
}

class _ColoringPageState extends State<ColoringPage> {
  final Map<int, Color> coloredAreas = {};
  final List<PathSegment> paths = [];
  late final QuadTree quadTree;
  Color currentColor = Colors.red;
  
  @override
  void initState() {
    super.initState();
    _initializePaths();
  }
  
  void _initializePaths() {
    // Load and process SVG/PNG paths here
    // Example:
    // paths = await loadSvgPaths();
    
    // Initialize QuadTree with canvas bounds
    quadTree = QuadTree(const Rect.fromLTWH(0, 0, 1000, 1000));
    for (final segment in paths) {
      quadTree.insert(segment);
    }
  }
  
  void _handleTap(Offset position) {
    final segments = quadTree.query(position);
    
    for (final segment in segments) {
      if (segment.path.contains(position)) {
        setState(() {
          coloredAreas[segment.id] = currentColor;
        });
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: GestureDetector(
        onTapDown: (details) => _handleTap(details.localPosition),
        child: CustomPaint(
          painter: ColoringPainter(
            paths: paths,
            coloredAreas: coloredAreas,
          ),
        ),
      ),
    );
  }
}