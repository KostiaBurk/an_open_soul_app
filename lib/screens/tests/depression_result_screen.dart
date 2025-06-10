import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DepressionResultScreen extends StatelessWidget {
  final int score;

  const DepressionResultScreen({super.key, required this.score});

  String getResultCategory(int score) {
    if (score <= 10) return 'Normal';
    if (score <= 16) return 'Mild Mood Disturbance';
    if (score <= 20) return 'Borderline Clinical Depression';
    if (score <= 30) return 'Moderate Depression';
    if (score <= 40) return 'Severe Depression';
    return 'Extreme Depression';
  }

  Color getColor(int score) {
    if (score <= 10) return Colors.greenAccent;
    if (score <= 16) return Colors.lightGreen;
    if (score <= 20) return Colors.amber;
    if (score <= 30) return Colors.orangeAccent;
    if (score <= 40) return Colors.deepOrange;
    return Colors.redAccent;
  }

  @override
  Widget build(BuildContext context) {
    final category = getResultCategory(score);
    final color = getColor(score);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E2C) : const Color(0xFFF2F2F2),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha((0.2 * 255).toInt()),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Your Result',
                    style: GoogleFonts.poppins(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Score: $score',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    category,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      // меняем цвет кнопки на более нейтральный тёмно-серый
                      backgroundColor: isDark ? Colors.grey[800] : Colors.grey[300],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                    ),
                    onPressed: () {
                      // полностью очищаем стек и возвращаемся к /home
                      Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
                    },
                    child: Text(
                      'Back to Home',
                      style: GoogleFonts.poppins(
                        // текст делает белым, чтобы чётко читался на тёмном фоне кнопки
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
