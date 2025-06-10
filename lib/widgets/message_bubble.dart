import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../chat_video_preview.dart';
import '../../full_screen_image.dart';
import '../../models/message_model.dart';
import '../widgets/video_player_screen.dart';

class MessageBubble extends StatefulWidget {
  final Message message;
  final int index;
  final bool isMe;
  final VoidCallback onLongPress;
  final VoidCallback onDoubleTap;
  final int? longPressIndex;
  final Function(String) onReaction;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onCopy;

  const MessageBubble({
    super.key,
    required this.message,
    required this.index,
    required this.isMe,
    required this.onLongPress,
    required this.onDoubleTap,
    required this.longPressIndex,
    required this.onReaction,
    required this.onEdit,
    required this.onDelete,
    required this.onCopy,
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(widget.isMe ? 0.3 : -0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  BorderRadius _bubbleRadius() {
    const radius = Radius.circular(18);
    return BorderRadius.only(
      topLeft: radius,
      topRight: radius,
      bottomLeft: widget.isMe ? radius : Radius.zero,
      bottomRight: widget.isMe ? Radius.zero : radius,
    );
  }

  Widget buildImage(String path) {
    if (path.startsWith('http')) {
      return Image.network(
        path,
        width: 200,
        height: 200,
        fit: BoxFit.cover,
      );
    } else {
      return Image.file(
        File(path),
        width: 200,
        height: 200,
        fit: BoxFit.cover,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final message = widget.message;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: widget.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: GestureDetector(
              onDoubleTap: widget.onDoubleTap,
              onLongPress: widget.onLongPress,
              child: Container(
                margin: EdgeInsets.fromLTRB(widget.isMe ? 60 : 10, 8, widget.isMe ? 10 : 60, 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (message.imagePath != null && message.imagePath!.isNotEmpty)
                      GestureDetector(
                        onTap: () => _openFullScreenImage(context, message.imagePath!, widget.index),

                        child: Hero(
                          tag: 'imageHero_${widget.index}',
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: buildImage(message.imagePath!),
                          ),
                        ),
                      ),
                   if (message.videoPath != null && message.videoPath!.isNotEmpty)

                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            barrierDismissible: true,
                            builder: (_) => VideoPlayerScreen(videoPath: message.videoPath!),
                          );
                        },
                        child: ChatVideoPreview(videoPath: message.videoPath!),
                      ),
                    if (message.text != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: widget.isMe ? const Color(0xFF007AFF) : const Color(0xFFE5E5EA),
                          borderRadius: _bubbleRadius(),
                        ),
                        child: Text(
                          message.text ?? '',
                          style: GoogleFonts.roboto(
                            fontSize: 16,
                            color: widget.isMe ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                      if (widget.isMe && message.isRead == true)
  Padding(
    padding: const EdgeInsets.only(top: 4),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const Icon(Icons.check, size: 14, color: Colors.green),
        const SizedBox(width: 4),
        Text(
          "Read",
          style: TextStyle(
            fontSize: 11,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white60
                : Colors.black54,
          ),
        ),
      ],
    ),
  ),


                    if (message.reaction != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: message.reaction!.contains("assets/images")
                            ? Image.asset(message.reaction!, width: 24, height: 24)
                            : Text(message.reaction!, style: const TextStyle(fontSize: 24)),
                      ),
                    if (message.edited == true)
                      Padding(
                        padding: const EdgeInsets.only(top: 2, left: 6),
                        child: Text(
                          "Edited",
                          style: TextStyle(
                            fontSize: 12,
                            color: const Color.fromARGB(255, 243, 242, 242),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (widget.longPressIndex == widget.index)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 50, vertical: 5),
            decoration: BoxDecoration(
              gradient: isDark
                  ? null
                  : const LinearGradient(
                      colors: [Color(0xFFCE93D8), Color(0xFFB2EBF2)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              color: isDark ? const Color(0xFF2C2C54) : null,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    "assets/images/like.png",
                    "assets/images/heart.png",
                    "assets/images/laugh.png",
                    "assets/images/angry.png",
                    "assets/images/sad.png",
                  ].map((reactionPath) {
                    return IconButton(
                      icon: Image.asset(reactionPath, width: 30, height: 30),
                      onPressed: () => widget.onReaction(reactionPath),
                    );
                  }).toList(),
                ),
                const Divider(),
                Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.edit, color: Colors.white),
                      title: const Text("Edit Text", style: TextStyle(color: Colors.white)),
                      onTap: widget.onEdit,
                    ),
                    ListTile(
                      leading: const Icon(Icons.delete, color: Colors.white),
                      title: const Text("Delete for Me", style: TextStyle(color: Colors.white)),
                      onTap: widget.onDelete,
                    ),
                    ListTile(
                      leading: const Icon(Icons.copy, color: Colors.white),
                      title: const Text("Copy", style: TextStyle(color: Colors.white)),
                      onTap: widget.onCopy,
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }

  void _openFullScreenImage(BuildContext context, String imagePath, int index) {
  Navigator.push(
    context,
    PageRouteBuilder(
      pageBuilder: (_, __, ___) => FullScreenImages(
        images: [imagePath],
        initialIndex: index,
      ),
      transitionsBuilder: (_, animation, __, child) {
        final tween = Tween(begin: const Offset(-1.0, 0.0), end: Offset.zero)
            .chain(CurveTween(curve: Curves.easeInOut));
        return SlideTransition(position: animation.drive(tween), child: child);
      },
      opaque: false,
      barrierDismissible: true,
    ),
  );
}


}