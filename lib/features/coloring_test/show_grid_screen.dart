import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ShowGridScreen extends StatefulWidget {
  const ShowGridScreen({super.key});

  @override
  State<ShowGridScreen> createState() => _ShowGridScreenState();
}

class _ShowGridScreenState extends State<ShowGridScreen> {
  late final _cachedSvg = SvgPicture.asset('assets/test5.svg', fit: BoxFit.contain);
  late final _cachedPng = Image.asset(
    'assets/test6.png',
    errorBuilder: (context, error, stackTrace) {
      print('Error loading image: $error');
      return const ColoredBox(
        color: Colors.red,
        child: Center(
          child: Text(
            '!',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    },
    frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
      if (frame == null) {
        return const Center(child: CircularProgressIndicator());
      }
      return child;
    },
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SVG Grid'),
      ),
      body: InteractiveViewer(
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 10,
            crossAxisSpacing: 1,
            mainAxisSpacing: 1,
            childAspectRatio: 1,
          ),
          cacheExtent: 500, // Cache more items
          padding: const EdgeInsets.all(8),
          itemCount: 1000,
          addAutomaticKeepAlives: true,
          itemBuilder: (context, index) {
            return RepaintBoundary(child: _cachedPng);
          },
        ),
      ),
    );
  }
}
