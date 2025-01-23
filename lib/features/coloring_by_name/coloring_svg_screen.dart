import 'dart:ui' as ui;

import 'package:base_flutter/features/coloring_by_name/checker_board.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/svg.dart';

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

    setState(() {
      _originalSvgSize = vectorImage.size;
      _paths = vectorImage.items;
      _checkerboardImage = checkerboard;

      final nonBlackColors = _paths?.where((p) => p.targetColor != null && !isBlack(p.targetColor!)).map((p) => p.targetColor!).toSet().toList() ?? [];

      _availableColors.value = nonBlackColors;
      _pathItemsNotifier.addAll(_paths?.map((item) => ValueNotifier(item)).toList() ?? []);
    });

    _capturePainting();
  }

  void _capturePainting() {
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   final capturedPicture = (_paintKey.currentContext!.findRenderObject()! as RenderRepaintBoundary).toImageSync(pixelRatio: context.devicePixelRatio * 2);
    //   _interactionNotifier.value.image?.dispose();
    //   _interactionNotifier.value = _interactionNotifier.value.copyWith(image: capturedPicture);
    // });
  }

  void _onTap(int index) {
    // final notifier = _pathItemsNotifier[index];
    // if (_interactionNotifier.value.isInteracting || notifier.value.targetColor != _selectedColorNotifier.value || notifier.value.isColored) return;

    // notifier.value = notifier.value.copyWith(currentColor: notifier.value.targetColor, isColored: true);
    // if (_pathItemsNotifier.where((item) => item.value.targetColor == notifier.value.targetColor).every((item) => item.value.isColored)) {
    //   _availableColors.value = _availableColors.value.where((color) => color != notifier.value.targetColor).toList();
    // }
    // _capturePainting();
  }

  void _onSelectColor(Color color) {
    _selectedColorNotifier.value = color;

    for (final notifier in _pathItemsNotifier) {
      final currentColor = notifier.value.currentColor;
      final targetColor = notifier.value.targetColor;

      if (currentColor != Colors.transparent && targetColor == color && !notifier.value.isColored) {
        notifier.value = notifier.value.copyWith(currentColor: Colors.transparent);
      } /* else if (currentColor == Colors.transparent) {
        notifier.value = notifier.value.copyWith(currentColor: Colors.white);
      } */
    }
    _capturePainting();
  }

  void _onInteractionStart(BuildContext context) {
    if (_interactionNotifier.value.isInteracting) return;
    _interactionNotifier.value = _interactionNotifier.value.copyWith(isInteracting: true);
    _capturePainting();
  }

  void _onInteractionEnd() {
    if (!_interactionNotifier.value.isInteracting) return;
    _interactionNotifier.value = _interactionNotifier.value.copyWith(isInteracting: false);
  }

  @override
  Widget build(BuildContext context) {
    if (_paths == null || _originalSvgSize == null || _pathItemsNotifier.isEmpty || _checkerboardImage == null) {
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
                  child: Stack(
                    children: [
                      FittedBox(
                        child: RepaintBoundary(
                          child: SizedBox(
                            height: _originalSvgSize!.height,
                            width: _originalSvgSize!.width,
                            child: SvgPicture.asset(
                              _svgImage,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      // ValueListenableBuilder(
                      //   valueListenable: _interactionNotifier,
                      //   builder: (context, value, __) => Visibility(
                      //     visible: value.isInteracting && value.image != null,
                      //     child: FittedBox(
                      //       child: value.image != null ? MockSvgImage(image: value.image!, size: _originalSvgSize!) : Container(),
                      //     ),
                      //   ),
                      // ),
                      // ValueListenableBuilder(
                      //   valueListenable: _interactionNotifier,
                      //   builder: (context, value, __) => Visibility.maintain(
                      //     visible: !value.isInteracting,
                      //     child:
                      FittedBox(
                        child: RepaintBoundary(
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
                                      builder: (context, value, __) => value.currentColor == Colors.transparent
                                          ? Container()
                                          : _buildSvgPathImageItem(
                                              context: context,
                                              item: value,
                                              size: _originalSvgSize!,
                                              onTap: () => _onTap(entry.key),
                                            ),
                                    ),
                                  )
                                  .toList(),
                            ),
                            //   ),
                            // ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            _buildSelectColorList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSvgPathImageItem({required BuildContext context, required PathSvgItem item, required Size size, required VoidCallback onTap}) {
    return RepaintBoundary(
      child: CustomPaint(
        size: size,
        foregroundPainter: SvgPainter(
          context: context,
          pathSvgItem: item,
          onTap: onTap,
        ),
      ),
    );
  }

  Widget _buildSelectColorList() {
    return SizedBox(
      height: 150,
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

class MockSvgImage extends StatelessWidget {
  final ui.Image image;
  final Size size;

  const MockSvgImage({super.key, required this.image, required this.size});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        size: size,
        painter: MockImagePainter(context: context, image: image),
      ),
    );
  }
}
