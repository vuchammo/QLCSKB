import 'package:flutter/material.dart';

class AppTheme {
  // Bảng màu Dragon Ball Cyber Gaming
  static const Color primaryOrange = Color(0xFFFF7A00); // Màu cam ngọc rồng
  static const Color primaryGold = Color(0xFFFFB800);   // Màu vàng ngọc rồng / thỏi vàng
  static const Color kiCyan = Color(0xFF00E5FF);        // Màu xanh ki aura
  static const Color successGreen = Color(0xFF10B981);  // Màu xanh lá (lợi nhuận / đã thu)
  static const Color dangerRed = Color(0xFFEF4444);     // Màu đỏ (chi phí / lỗ)
  static const Color cardDark = Color(0xFF1E293B);      // Nền card tối
  static const Color bgDark = Color(0xFF0F172A);        // Nền ứng dụng tối
  static const Color borderDark = Color(0xFF334155);    // Viền card

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgDark,
      colorScheme: const ColorScheme.dark(
        primary: primaryGold,
        secondary: kiCyan,
        surface: cardDark,
        error: dangerRed,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF141E33),
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardDark,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: borderDark, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF0F172A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: borderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: primaryGold, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGold,
          foregroundColor: Colors.black,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
