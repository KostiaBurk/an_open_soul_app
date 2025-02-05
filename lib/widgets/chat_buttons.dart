import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AnimatedRoundButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;

  const AnimatedRoundButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

 @override
AnimatedRoundButtonState createState() => AnimatedRoundButtonState();
}


class AnimatedRoundButtonState extends State<AnimatedRoundButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _glowAnimation = Tween<double>(begin: 5.0, end: 15.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onPressed();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 1, 235, 252),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.black,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(255, 240, 136, 222),
                    blurRadius: _glowAnimation.value,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  widget.text,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.irishGrover(
  fontSize: 24,
  fontWeight: FontWeight.w400,
  color: Colors.black,
  height: 1.2, // Здесь можно регулировать межстрочный интервал
),

                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
