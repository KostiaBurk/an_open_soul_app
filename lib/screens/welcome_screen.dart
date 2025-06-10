import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: screenWidth,
            height: screenHeight,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF8E24AA),
                  Color(0xFFF3D9FF),
                  Color(0xFF80DEEA),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const SizedBox(height: 30),

                  // Лого сверху
                  FadeInDown(
                    duration: const Duration(milliseconds: 800),
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 230,
                      height: 230,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Welcome! слева
                  FadeInLeft(
                    duration: const Duration(milliseconds: 900),
                    child: Text(
                      "Welcome!",
                      style: GoogleFonts.fingerPaint(
                        fontSize: 32,
                        color: Colors.black,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Текст справа
                  FadeInRight(
                    delay: const Duration(milliseconds: 300),
                    child: Text(
                      "This is the place where you can be yourself. Ready to get started?",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.fingerPaint(
                        fontSize: 20,
                        color: Colors.black87,
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Кнопка снизу
                  FadeInUp(
                    delay: const Duration(milliseconds: 600),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/auth');
                      },
                      child: Container(
                        width: 250,
                        height: 70,
                        margin: const EdgeInsets.only(bottom: 30),
                        decoration: BoxDecoration(
                          color: const Color(0xFF79F0FF),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: const [
                            BoxShadow(
                              color: Color.fromARGB(66, 0, 0, 0),
                              blurRadius: 3,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Stack(
                          children: [
                            Text(
                              "Get Started",
                              style: GoogleFonts.racingSansOne(
                                fontSize: 36,
                                foreground: Paint()
                                  ..style = PaintingStyle.stroke
                                  ..strokeWidth = 3
                                  ..color = Colors.black54,
                              ),
                            ),
                            Text(
                              "Get Started",
                              style: GoogleFonts.racingSansOne(
                                fontSize: 36,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
