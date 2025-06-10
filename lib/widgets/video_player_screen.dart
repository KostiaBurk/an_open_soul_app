import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoPath;

  const VideoPlayerScreen({super.key, required this.videoPath});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  double _verticalDrag = 0.0;
  bool _showControls = true;

 @override
void initState() {
  super.initState();
  if (widget.videoPath.startsWith('http')) {
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoPath));
  } else {
    _controller = VideoPlayerController.file(File(widget.videoPath));
  }

  _controller.initialize().then((_) {
    setState(() {});
  });
}


  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        _showControls = true;
      } else {
        _controller.play();
        _showControls = false;
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _showControls = !_showControls;
          });
        },
        onVerticalDragUpdate: (details) {
          setState(() {
            _verticalDrag += details.primaryDelta!;
          });
        },
        onVerticalDragEnd: (details) {
          if (_verticalDrag.abs() > 100) {
            Navigator.of(context).pop();
          } else {
            setState(() {
              _verticalDrag = 0.0;
            });
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.translationValues(0, _verticalDrag, 0),
          child: Center(
            child: _controller.value.isInitialized
                ? Container(
                    width: screenWidth * 0.91,
                    height: screenHeight * 0.56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.black,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned.fill(
                            child: FittedBox(
                              fit: BoxFit.cover,
                              child: SizedBox(
                                width: _controller.value.size.width,
                                height: _controller.value.size.height,
                                child: VideoPlayer(_controller),
                              ),
                            ),
                          ),
                          if (_showControls)
                            Positioned(
                              child: IconButton(
                                icon: Icon(
                                  _controller.value.isPlaying
                                      ? Icons.pause_circle_filled
                                      : Icons.play_circle_fill,
                                  size: 70,
                                  color: Colors.white,
                                ),
                                onPressed: _togglePlayPause,
                              ),
                            ),
                        ],
                      ),
                    ),
                  )
                : const CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}
