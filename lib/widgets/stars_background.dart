import 'dart:math';
import 'package:flutter/material.dart';

class AnimatedStarField extends StatefulWidget {
  final int starCount; // Кол-во звёзд

  const AnimatedStarField({super.key, this.starCount = 100}); // −135 чтобы на 35% меньше

  @override
  State<AnimatedStarField> createState() => _AnimatedStarFieldState();
}

class _AnimatedStarFieldState extends State<AnimatedStarField> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Star> _stars;
  final List<FallingStar> _fallingStars = [];
  int _lastFallingStarTimestamp = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    )
      ..addListener(_updateFallingStars)
      ..repeat();

    _stars = List.generate(widget.starCount, (_) => Star.random());
    _lastFallingStarTimestamp = DateTime.now().millisecondsSinceEpoch;
  }

  void _updateFallingStars() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final delta = now - _lastFallingStarTimestamp;

    if (delta > 15000) {
      _fallingStars.add(FallingStar.random());
      _lastFallingStarTimestamp = now;
    }

    for (var fs in _fallingStars) {
      fs.progress += 0.005;
    }

    _fallingStars.removeWhere((fs) => fs.progress >= 1.2);

    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: StarPainter(_stars, _fallingStars, _controller.value),
        size: Size.infinite,
      ),
    );
  }
}

class Star {
  Offset position;
  double radius;
  double twinkleSpeed;
  double baseOpacity;
  Color color;

  Star({
    required this.position,
    required this.radius,
    required this.twinkleSpeed,
    required this.baseOpacity,
    required this.color,
  });

  factory Star.random() {
    final random = Random();
    final List<Color> colors = [
      Colors.white,
      const Color(0xFFE0FFFF),
      const Color(0xFFE6E6FA),
      const Color(0xFFFFFFFF),
    ];

    return Star(
      position: Offset(random.nextDouble(), random.nextDouble()),
      radius: random.nextDouble() * 1.4 + 0.7,
      twinkleSpeed: random.nextDouble() * 1.5 + 0.5,
      baseOpacity: random.nextDouble() * 0.4 + 0.6,
      color: colors[random.nextInt(colors.length)],
    );
  }
}

class FallingStar {
  Offset start;
  Offset end;
  double progress;
  Color color;

  FallingStar({required this.start, required this.end, this.progress = 0.0, required this.color});

  factory FallingStar.random() {
    final random = Random();
    final startX = random.nextDouble() * 0.8;
    final startY = random.nextDouble() * 0.3;
    final endX = startX + 1.0;
    final endY = startY + 1.0;

    return FallingStar(
      start: Offset(startX, startY),
      end: Offset(endX, endY),
      color: Colors.white,
    );
  }
}

class StarPainter extends CustomPainter {
  final List<Star> stars;
  final List<FallingStar> fallingStars;
  final double animationValue;

  StarPainter(this.stars, this.fallingStars, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final starPaint = Paint();
    final glowPaint = Paint()..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    for (final star in stars) {
      final dx = star.position.dx * size.width;
      final dy = star.position.dy * size.height;

      final twinkle = star.baseOpacity + 0.4 * sin(animationValue * 2 * pi * star.twinkleSpeed);
      final opacity = twinkle.clamp(0.0, 1.0);

      glowPaint.color = star.color.withAlpha((opacity * 0.5 * 255).toInt());
      canvas.drawCircle(Offset(dx, dy), star.radius * 2, glowPaint);

      starPaint.color = star.color.withAlpha((opacity * 255).toInt());
      canvas.drawCircle(Offset(dx, dy), star.radius, starPaint);
    }

    final fallingPaint = Paint()
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    for (final fs in fallingStars) {
      final head = Offset.lerp(fs.start, fs.end, fs.progress)!;
      final tail = Offset.lerp(fs.start, fs.end, fs.progress - 0.07) ?? fs.start;

      fallingPaint.shader = LinearGradient(
        colors: [fs.color.withAlpha((0.8 * 255).toInt()), Colors.transparent],
      ).createShader(Rect.fromPoints(
        head.scale(size.width, size.height),
        tail.scale(size.width, size.height),
      ));

      canvas.drawLine(
        head.scale(size.width, size.height),
        tail.scale(size.width, size.height),
        fallingPaint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}