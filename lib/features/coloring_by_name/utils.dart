import 'dart:ui' as ui;

import 'package:base_flutter/features/coloring_by_name/models.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_drawing/path_drawing.dart';
import 'package:xml/xml.dart';

Future<String> _fetchSvgData(String source) async {
  if (source.startsWith('http')) {
    final response = await http.get(Uri.parse(source));
    return response.body;
  } else {
    return await rootBundle.loadString(source);
  }
}

Future<VectorImage> getVectorImage(String svgImage) async {
  final svgData = await _fetchSvgData(svgImage);
  return getVectorImageFromStringXml(svgData);
}

VectorImage getVectorImageFromStringXml(String svgData) {
  final items = <PathSvgItem>[];
  // Parse the SVG data
  final xmlDocument = XmlDocument.parse(svgData);

  // Get the size element
  final svgElement = xmlDocument.findAllElements('svg').firstOrNull;
  Size? size;
  if (svgElement != null) {
    final width = svgElement.getAttribute('width')?.replaceAll(RegExp(r'[^0-9.]'), ''); // Remove all non-numeric characters
    final height = svgElement.getAttribute('height')?.replaceAll(RegExp(r'[^0-9.]'), '');
    final viewBox = svgElement.getAttribute('viewBox')?.split(' ');

    if (width != null && height != null) {
      size = Size(double.parse(width), double.parse(height));
    } else if (viewBox != null && viewBox.length == 4) {
      size = Size(double.parse(viewBox[2]), double.parse(viewBox[3]));
    }
  }

  // Get the path elements
  for (final element in xmlDocument.findAllElements('path')) {
    // Get the path data
    final pathData = element.getAttribute('d');
    if (pathData == null) continue;
    var path = parseSvgPathData(pathData);

    // Get the fill color
    final fillColor = element.getAttribute('fill') ?? _getFillColor(element.getAttribute('style') ?? '');
    final colorFromString = _getColorFromString(fillColor);

    // Get the transform attribute
    final transformAttribute = element.getAttribute('transform');
    final matrix4 = Matrix4.identity();
    if (transformAttribute != null) {
      final scale = _getScale(transformAttribute);
      final translate = _getTranslate(transformAttribute);
      if (translate != null) matrix4.translate(translate.x, translate.y);
      if (scale != null) matrix4.scale(scale.x, scale.y);
    }
    path = path.transform(matrix4.storage);

    items.add(PathSvgItem(path: path, targetColor: colorFromString, currentColor: isBlack(colorFromString ?? Colors.black) ? Colors.black : Colors.white));
  }
  return VectorImage(size: size, items: items);
}

/// Generate a small tileable checkerboard image in memory
Future<ui.Image> generateCheckerboardImage() async {
  const double tileSize = 7; // Size of each square

  // We will create a 2x2 grid of squares, so the canvas
  // dimension is tileSize * 2
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);

  // White background
  final paintWhite = Paint()..color = const Color(0xFFDDDDDD);
  // Black squares
  final paintBlack = Paint()..color = const Color(0xFFAAAAAA);

  // Draw the 4 squares
  // Top-left
  canvas.drawRect(const Rect.fromLTWH(0, 0, tileSize, tileSize), paintWhite);
  // Top-right
  canvas.drawRect(const Rect.fromLTWH(tileSize, 0, tileSize, tileSize), paintBlack);
  // Bottom-left
  canvas.drawRect(const Rect.fromLTWH(0, tileSize, tileSize, tileSize), paintBlack);
  // Bottom-right
  canvas.drawRect(const Rect.fromLTWH(tileSize, tileSize, tileSize, tileSize), paintWhite);

  // End the recording and convert to an image
  final picture = recorder.endRecording();
  final image = await picture.toImage((tileSize * 2).toInt(), (tileSize * 2).toInt());

  return image;
}

bool isBlackColor(Color color) {
  return color.r == 0 && color.g == 0 && color.b == 0;
}

bool isBlack(Color color) {
  final hsv = HSVColor.fromColor(color);
  return hsv.value < 0.5;
}

String? _getFillColor(String data) {
  RegExp regExp = RegExp(r'fill:\s*(#[a-fA-F0-9]{6})'); // Match the fill color in the style attribute
  RegExpMatch? match = regExp.firstMatch(data);

  return match?.group(1);
}

Color _hexToColor(String hex) {
  final buffer = StringBuffer();
  if (hex.length == 6 || hex.length == 7) buffer.write('ff');
  buffer.write(hex.replaceFirst('#', ''));

  return Color(int.parse(buffer.toString(), radix: 16));
}

Color? _getColorFromString(String? colorString) {
  if (colorString == null) return null;
  if (colorString.startsWith('#')) return _hexToColor(colorString);

  switch (colorString) {
    case 'red':
      return Colors.red;
    case 'green':
      return Colors.green;
    case 'blue':
      return Colors.blue;
    case 'yellow':
      return Colors.yellow;
    case 'white':
      return Colors.white;
    case 'black':
      return Colors.black;
    default:
      return Colors.transparent;
  }
}

// Get the scale value from the transform attribute
({double x, double y})? _getScale(String data) {
  RegExp regExp = RegExp(r'scale\(([^,]+),([^)]+)\)'); // Match the scale attribute
  var match = regExp.firstMatch(data);

  if (match != null) {
    double scaleX = double.parse(match.group(1)!);
    double scaleY = double.parse(match.group(2)!);
    return (x: scaleX, y: scaleY);
  }
  return null;
}

// Get the translate value from the transform attribute
({double x, double y})? _getTranslate(String data) {
  RegExp regExp = RegExp(r'translate\(([^,]+),([^)]+)\)'); // Match the translate attribute
  var match = regExp.firstMatch(data);

  if (match != null) {
    double translateX = double.parse(match.group(1)!);
    double translateY = double.parse(match.group(2)!);
    return (x: translateX, y: translateY);
  }
  return null;
}

extension BuildContextExtension on BuildContext {
  double get devicePixelRatio => MediaQuery.of(this).devicePixelRatio;
}

class ValuesNotifier implements ValueListenable<bool> {
  final List<ValueListenable> valueListenableList;
  late final Listenable listenable;
  bool val = false;

  ValuesNotifier(this.valueListenableList) {
    listenable = Listenable.merge(valueListenableList);
    listenable.addListener(onNotified);
  }

  @override
  void addListener(VoidCallback listener) {
    listenable.addListener(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    listenable.removeListener(listener);
  }

  @override
  bool get value => val;

  void onNotified() {
    val = !val;
  }
}

extension InteractingMapCopyWith on ({bool isInteracting, ui.Image? image}) {
  ({bool isInteracting, ui.Image? image}) copyWith({bool? isInteracting, ui.Image? image}) {
    return (isInteracting: isInteracting ?? this.isInteracting, image: image ?? this.image);
  }
}
