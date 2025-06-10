import 'dart:io';
import 'package:flutter/material.dart';

class PreviewPhotoScreen extends StatelessWidget {
  final File imageFile;
  final Function() onRetake;
  final Function() onSend;

  const PreviewPhotoScreen({
    super.key,
    required this.imageFile,
    required this.onRetake,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: () => Navigator.pop(context),
      onVerticalDragEnd: (details) {
        if (details.primaryVelocity != null &&
            details.primaryVelocity!.abs() > 200) {
          Navigator.pop(context);
        }
      },
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(0),
        child: Center(
          child: Container(
            width: screenWidth * 0.9,
            height: screenHeight * 0.8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.black,
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      imageFile,
                      fit: BoxFit.contain,
                      width: double.infinity,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: onRetake,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                      ),
                      icon: const Icon(Icons.replay),
                      label: const Text("Retake"),
                    ),
                    ElevatedButton.icon(
                      onPressed: onSend,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      icon: const Icon(Icons.send),
                      label: const Text("Send"),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
