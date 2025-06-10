import 'dart:math';
import 'package:flutter/material.dart';

class AudioWaveVisualizer extends StatefulWidget {
  const AudioWaveVisualizer({super.key});

  @override
  State<AudioWaveVisualizer> createState() => _AudioWaveVisualizerState();
}

class _AudioWaveVisualizerState extends State<AudioWaveVisualizer>
    with TickerProviderStateMixin {
  final int _barCount = 5;
  final List<AnimationController> _controllers = [];
  final List<Animation<double>> _animations = [];

  @override
  void initState() {
    super.initState();
    final random = Random();

    for (int i = 0; i < _barCount; i++) {
      final controller = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 300 + random.nextInt(500)),
      )..repeat(reverse: true);

      final animation = Tween<double>(
        begin: 10 + random.nextInt(10).toDouble(),
        end: 30 + random.nextInt(20).toDouble(),
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ));

      _controllers.add(controller);
      _animations.add(animation);
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_barCount, (index) {
          return AnimatedBuilder(
            animation: _animations[index],
            builder: (context, child) {
              return Container(
                width: 6,
                height: _animations[index].value,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: Colors.deepPurple,
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
