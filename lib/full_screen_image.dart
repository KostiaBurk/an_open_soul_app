import 'package:flutter/material.dart';
import 'dart:io';

class FullScreenImages extends StatefulWidget {
  final List<dynamic> images; // File или String
  final int initialIndex;

  const FullScreenImages({
    super.key,
    required this.images,
    this.initialIndex = 0,
  });

  @override
  FullScreenImagesState createState() => FullScreenImagesState();
}

class FullScreenImagesState extends State<FullScreenImages> {
  late PageController _pageController;
  double _scale = 1.0;
  double _previousScale = 1.0;
  double _dragOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onScaleStart(ScaleStartDetails details) {
    _previousScale = _scale;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    setState(() {
      _scale = (_previousScale * details.scale).clamp(1.0, 3.0);
    });
  }

 Widget _buildImage(dynamic image) {
  if (image is String && image.startsWith("http")) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox.expand(
        child: Image.network(
          image,
          fit: BoxFit.cover,
        ),
      ),
    );
  } else if (image is File) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox.expand(
        child: Image.file(
          image,
          fit: BoxFit.cover,
        ),
      ),
    );
  } else {
    return const Center(
      child: Text("Invalid image", style: TextStyle(color: Colors.white)),
    );
  }
}



  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final dialogHeight = screenHeight * 0.82;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.only(top: 70, bottom: 20, left: 0, right: 0),

      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        onVerticalDragUpdate: (details) {
          setState(() {
            _dragOffset += details.primaryDelta!;
          });
        },
        onVerticalDragEnd: (_) {
          if (_dragOffset.abs() > 100) {
            Navigator.pop(context);
          } else {
            setState(() {
              _dragOffset = 0.0;
            });
          }
        },
        onScaleStart: _onScaleStart,
        onScaleUpdate: _onScaleUpdate,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.translationValues(0, _dragOffset, 0),
          height: dialogHeight,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.images.length,
            itemBuilder: (context, index) {
              return Center(
               child: ClipRRect(
  borderRadius: BorderRadius.circular(16),
  child: SizedBox(
    width: double.infinity, // 💥 тянем на всю ширину
    child: Transform.scale(
      scale: _scale,
      child: _buildImage(widget.images[index]),
    ),
  ),
),

              );
            },
          ),
        ),
      ),
    );
  }
}
