// Отвечает за название приложение (текст) - An Open Soul

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TitleWidget extends StatelessWidget {
  const TitleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Обводка текста (добавляет толщину и цвет границы)
        Text(
          "An Open Soul",
          textAlign: TextAlign.center,
          style: GoogleFonts.dancingScript(
            fontSize: 62,
            fontWeight: FontWeight.bold,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 3
              ..color = const Color.fromARGB(255, 2, 2, 2), // Цвет обводки
          ),
        ),
        // Основной текст с градиентом
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [
              Color.fromARGB(255, 243, 233, 243),
              Color.fromARGB(249, 248, 248, 248),
            ],
            begin: Alignment(-1.0, -1.0),
            end: Alignment(1.5, 1.5),
          ).createShader(bounds),
          child: Text(
            "An Open Soul",
            textAlign: TextAlign.center,
            style: GoogleFonts.dancingScript(
              fontSize: 62,
              fontWeight: FontWeight.bold,
              color: const Color.fromARGB(255, 1, 235, 252), // Установка основного текста прозрачным
            ),
          ),
        ),
      ],
    );
  }
}
