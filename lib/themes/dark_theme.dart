import 'package:flutter/material.dart';

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color(0xFF121212),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color.fromARGB(255, 79, 27, 105), // ✅ Цвет как у кнопок
    foregroundColor: Colors.white,
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.white),
    bodyMedium: TextStyle(color: Colors.white70),
  ),
  colorScheme: const ColorScheme.dark().copyWith(
    primary: Color(0xFF9C27B0),
    secondary: Color(0xFF7B1FA2),
  ),
  cardColor: const Color(0xFF1E1E1E),
  iconTheme: const IconThemeData(color: Colors.white),
  buttonTheme: const ButtonThemeData(buttonColor: Colors.deepPurple),
);
