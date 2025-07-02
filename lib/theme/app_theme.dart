import 'package:flutter/material.dart';

class AppTheme {
  // Cores Principais
  static const Color primaryColor = Color(0xFF0A2E4E); // Azul escuro do fundo
  static const Color accentColor = Color(0xFF4A90E2); // Um tom de azul mais claro para detalhes
  static const Color darkTextColor = Color(0xFF333333);
  static const Color lightTextColor = Colors.white;
  static const Color backgroundColor = Colors.white;
  static const Color lightGrey = Color(0xFFF0F0F0);

  // Tema Geral do App
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      fontFamily: 'Poppins', // (Certifique-se de adicionar esta fonte no pubspec.yaml se quiser)

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: darkTextColor),
        titleTextStyle: TextStyle(color: darkTextColor, fontSize: 18, fontWeight: FontWeight.bold),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
        hintStyle: TextStyle(color: Colors.grey[400]),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: lightTextColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
