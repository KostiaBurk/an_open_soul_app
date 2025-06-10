import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';

class ChatVideoPreview extends StatefulWidget {
  final String videoPath;

  const ChatVideoPreview({super.key, required this.videoPath});

  @override
  ChatVideoPreviewState createState() => ChatVideoPreviewState();
}

class ChatVideoPreviewState extends State<ChatVideoPreview> {
  late VideoPlayerController _controller;

  @override
void initState() {
  super.initState();

  if (widget.videoPath.startsWith("http")) {
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoPath));
  } else {
    _controller = VideoPlayerController.file(File(widget.videoPath));
  }

  _controller.initialize().then((_) {
    setState(() {});
  });
}


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width * 0.25;

    return Container(
      width: maxWidth,
      height: maxWidth * (16 / 9),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.black,
      ),
      clipBehavior: Clip.hardEdge,
      child: _controller.value.isInitialized
          ? Stack(
              alignment: Alignment.center,
              children: [
                SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _controller.value.size.width,
                      height: _controller.value.size.height,
                      child: VideoPlayer(_controller),
                    ),
                  ),
                ),
                const Icon(
                  Icons.play_circle_fill,
                  size: 50,
                  color: Colors.white,
                ),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
