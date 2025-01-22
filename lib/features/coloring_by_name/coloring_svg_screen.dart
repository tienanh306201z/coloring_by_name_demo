import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'checker_board.dart';
import 'models.dart';
import 'svg_painter.dart';
import 'utils.dart';

class ColoringSvgScreen extends StatefulWidget {
  const ColoringSvgScreen({super.key});

  @override
  State<ColoringSvgScreen> createState() => _ColoringSvgScreenState();
}

class _ColoringSvgScreenState extends State<ColoringSvgScreen> {
  static const _svgImage = 'assets/test4.svg';

  //Svg data
  Size? _originalSvgSize;
  List<PathSvgItem>? _paths;

  // For checkerboard background
  ui.Image? _checkerboardImage;

  ui.Image? _pencilBoardImage;

  // Currently selected color, and list of available “target” colors from the paths
  final _selectedColorNotifier = ValueNotifier<Color?>(null);
  final _availableColors = ValueNotifier<List<Color>>([]);

  // Image to show when interacting
  final _interactionNotifier = ValueNotifier<({bool isInteracting, ui.Image? image})>((isInteracting: false, image: null));

  // List of path items to color
  final _pathItemsNotifier = <ValueNotifier<PathSvgItem>>[];

  // Key to capture the image
  final _paintKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _loadSvg();
  }

  @override
  void dispose() {
    super.dispose();
    _interactionNotifier.value.image?.dispose();
  }

  Future<void> _loadSvg() async {
    final vectorImage = await getVectorImage(_svgImage);
    final checkerboard = await generateCheckerboardImage();
    final textureImage = await loadTextureImage();

    setState(() {
      _originalSvgSize = vectorImage.size;
      _paths = vectorImage.items;
      _checkerboardImage = checkerboard;
      _pencilBoardImage = textureImage;

      final nonBlackColors = _paths?.where((p) => p.targetColor != null && !isBlack(p.targetColor!)).map((p) => p.targetColor!).toSet().toList() ?? [];

      _availableColors.value = nonBlackColors;
      _pathItemsNotifier.addAll(_paths?.map((item) => ValueNotifier(item)).toList() ?? []);
    });
  }

  void _onTap(int index) {
    final notifier = _pathItemsNotifier[index];
    if (_interactionNotifier.value.isInteracting || notifier.value.targetColor != _selectedColorNotifier.value || notifier.value.isColored) return;

    notifier.value = notifier.value.copyWith(currentColor: notifier.value.targetColor, isColored: true);
    if (_pathItemsNotifier.where((item) => item.value.targetColor == notifier.value.targetColor).every((item) => item.value.isColored)) {
      _availableColors.value = _availableColors.value.where((color) => color != notifier.value.targetColor).toList();
    }
  }

  void _onSelectColor(Color color) {
    _selectedColorNotifier.value = color;

    for (final notifier in _pathItemsNotifier) {
      final currentColor = notifier.value.currentColor;
      final targetColor = notifier.value.targetColor;

      if (currentColor != Colors.transparent && targetColor == color && !notifier.value.isColored) {
        notifier.value = notifier.value.copyWith(currentColor: notifier.value.targetColor, isColored: true);
      } else if (currentColor == Colors.transparent) {
        notifier.value = notifier.value.copyWith(currentColor: Colors.white);
      }
    }
  }

  void _onInteractionStart(BuildContext context) {
    if (_interactionNotifier.value.isInteracting) return;
    _interactionNotifier.value = _interactionNotifier.value.copyWith(isInteracting: true);
  }

  void _onInteractionEnd() {
    if (!_interactionNotifier.value.isInteracting) return;
    _interactionNotifier.value = _interactionNotifier.value.copyWith(isInteracting: false);
  }

  @override
  Widget build(BuildContext context) {
    if (_paths == null || _originalSvgSize == null || _pathItemsNotifier.isEmpty || _checkerboardImage == null || _pencilBoardImage == null) {
      return const Scaffold(body: SafeArea(child: Center(child: CircularProgressIndicator())));
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: InteractiveViewer(
                boundaryMargin: const EdgeInsets.all(100),
                minScale: 0.7,
                maxScale: 4.0,
                constrained: true,
                clipBehavior: Clip.none,
                onInteractionStart: (_) => _onInteractionStart(context),
                onInteractionEnd: (_) => _onInteractionEnd(),
                child: Center(
                  child: FittedBox(
                    child: Stack(
                      children: [
                        RepaintBoundary(
                          child: SizedBox(
                            height: _originalSvgSize!.height,
                            width: _originalSvgSize!.width,
                            child: CheckerboardSvg(svgAssetPath: _svgImage, checkerboardImage: _checkerboardImage),
                          ),
                        ),
                        // RepaintBoundary(
                        //   child: SizedBox(
                        //     height: _originalSvgSize!.height,
                        //     width: _originalSvgSize!.width,
                        //     child: PencilBoard(svgAssetPath: _svgImage, pencilImage: _pencilBoardImage),
                        //   ),
                        // ),
                        RepaintBoundary(
                          key: _paintKey,
                          child: SizedBox(
                            width: _originalSvgSize!.width,
                            height: _originalSvgSize!.height,
                            child: Stack(
                              children: _pathItemsNotifier
                                  .asMap()
                                  .entries
                                  .map(
                                    (entry) => ValueListenableBuilder(
                                      valueListenable: entry.value,
                                      builder: (context, value, __) => _buildSvgPathImageItem(
                                        context: context,
                                        item: entry.value.value,
                                        size: _originalSvgSize!,
                                        onTap: () => _onTap(entry.key),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            _buildSelectColorList(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSvgPathImageItem({
    required BuildContext context,
    required PathSvgItem item,
    required Size size,
    required VoidCallback onTap,
  }) {
    return RepaintBoundary(
      // This prevents repainting of siblings
      child: CustomPaint(
        size: size,
        isComplex: true, // Add this to hint expensive painting
        willChange: false, // Add this since the path doesn't change frequently
        foregroundPainter: SvgPainter(
          context: context,
          pathSvgItem: item,
          onTap: onTap,
        ),
      ),
    );
  }

  Widget _buildSelectColorList() {
    return Container(
      height: 100,
      color: Theme.of(context).colorScheme.surface,
      child: ValueListenableBuilder(
        valueListenable: _availableColors,
        builder: (context, value, __) => ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: value.length,
          itemBuilder: (context, index) {
            final color = value[index];
            return GestureDetector(
              onTap: () => _onSelectColor(color),
              child: ValueListenableBuilder(
                valueListenable: _selectedColorNotifier,
                builder: (context, value, __) => Container(
                  margin: const EdgeInsets.all(8),
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(color: value == color ? Colors.black : Colors.transparent, width: 2),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
