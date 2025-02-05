// main.dart – точка входа приложения. Здесь вызывается runApp() для запуска корневого виджета и инициализации глобальных настроек.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:an_open_soul_app/screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WelcomeScreen(),
    );
  }
}

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  WelcomeScreenState createState() => WelcomeScreenState();
}

class WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          // ✅ Градиентный фон
          Container(
            width: screenWidth,
            height: screenHeight,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF8E24AA), // Фиолетовый сверху
                  Color(0xFFF3D9FF), // Светло-розовый в центре
                  Color(0xFF80DEEA), // Голубой снизу
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // ✅ Основное содержимое
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: screenHeight * 0.06),

              // ✅ Логотип
              Image.asset(
                'assets/images/logo.png',
                width: 230,
                height: 230,
              ),

              const SizedBox(height: 5),

              // ✅ Заголовок "Welcome!"
              Text(
                "Welcome!",
                style: GoogleFonts.fingerPaint(
                  fontSize: 32,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 5),

              // ✅ Подзаголовок
              Text(
                "This is the place where you can be yourself. Ready to get started?",
                textAlign: TextAlign.center,
                style: GoogleFonts.fingerPaint(
                  fontSize: 20,
                  color: Colors.black87,
                ),
              ),

              SizedBox(height: screenHeight * 0.14),

              // ✅ Анимированная кнопка "Get Started"
              GestureDetector(
                onTapDown: (_) {
                  setState(() {
                    _scale = 0.95;
                  });
                },
                onTapUp: (_) {
                  setState(() {
                    _scale = 1.0;
                  });
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                  );
                },
                child: Transform.scale(
                  scale: _scale,
                  child: Container(
                    width: 250,
                    height: 70,
                    decoration: BoxDecoration(
                      color: const Color(0xFF79F0FF), // Светло-голубая кнопка
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromARGB(66, 0, 0, 0), // Лёгкая тень с 26% прозрачности
                          blurRadius: 3,
                          spreadRadius: 0,
                          offset: Offset(0, 2), // Чуть ниже
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Stack(
                      children: [
                        // Чёрная обводка (чуть толще, чем сам текст)
                        Text(
                          "Get Started",
                          style: GoogleFonts.racingSansOne(
                            fontSize: 36,
                            foreground: Paint()
                              ..style = PaintingStyle.stroke
                              ..strokeWidth = 1.2 // Чуть более заметная обводка
                              ..color = Colors.black54, // Тёмно-серый, но не слишком резкий
                          ),
                        ),
                        // Белый основной текст
                        Text(
                          "Get Started",
                          style: GoogleFonts.racingSansOne(
                            fontSize: 36,
                            color: Colors.white, // Чисто белый цвет
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
