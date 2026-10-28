import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AkeaColors {
  static const sidebar = Color(0xFF3A1638);
  static const sidebarSelected = Color(0xFF6B3A62);
  static const purple = Color(0xFF6B2D5C);
  static const purpleDeep = Color(0xFF2C1428);
  static const gold = Color(0xFFC4A04A);
  static const goldSoft = Color(0xFFE8D5A3);
  static const bg = Color(0xFFF6F0E8);
  static const cream = Color(0xFFF3EBE0);
  static const card = Color(0xFFFFFFFF);
  static const ink = Color(0xFF2C1428);
  static const muted = Color(0xFF8A7A80);
  static const border = Color(0xFFE6DCD0);
  static const banner = Color(0xFFFFF3D6);
  static const bannerInk = Color(0xFF8A5A12);
  static const statusNew = Color(0xFFD9E8F8);
  static const statusNewInk = Color(0xFF3D6FA8);
  static const statusWarn = Color(0xFFF8E3C4);
  static const statusWarnInk = Color(0xFFB06A16);
  static const statusOk = Color(0xFFD8F0DC);
  static const statusOkInk = Color(0xFF2F8A4A);
  static const statusDanger = Color(0xFFF8D5D4);
  static const statusDangerInk = Color(0xFFC04545);
  static const whiteButton = Color(0xFFFFFFFF);
}

class AkeaTheme {
  static ThemeData light() {
    final textTheme = GoogleFonts.sourceSans3TextTheme().copyWith(
      displayLarge: GoogleFonts.playfairDisplay(
        fontSize: 40,
        fontWeight: FontWeight.w600,
        color: AkeaColors.ink,
      ),
      headlineLarge: GoogleFonts.playfairDisplay(
        fontSize: 34,
        fontWeight: FontWeight.w600,
        color: AkeaColors.ink,
      ),
      headlineMedium: GoogleFonts.playfairDisplay(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: AkeaColors.ink,
      ),
      titleLarge: GoogleFonts.playfairDisplay(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: AkeaColors.ink,
      ),
      bodyLarge: GoogleFonts.sourceSans3(fontSize: 16, color: AkeaColors.ink),
      bodyMedium: GoogleFonts.sourceSans3(fontSize: 14, color: AkeaColors.ink),
      labelLarge: GoogleFonts.sourceSans3(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AkeaColors.ink,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AkeaColors.bg,
      colorScheme: ColorScheme.light(
        primary: AkeaColors.purple,
        secondary: AkeaColors.gold,
        surface: AkeaColors.card,
        onPrimary: Colors.white,
        onSurface: AkeaColors.ink,
      ),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AkeaColors.bg,
        foregroundColor: AkeaColors.ink,
        elevation: 0,
        titleTextStyle: GoogleFonts.playfairDisplay(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AkeaColors.ink,
        ),
      ),
      dividerColor: AkeaColors.border,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AkeaColors.card,
        hintStyle: const TextStyle(color: AkeaColors.muted),
        labelStyle: const TextStyle(color: AkeaColors.muted, fontSize: 13),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AkeaColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AkeaColors.purple, width: 1.4),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AkeaColors.border),
        ),
      ),
    );
  }
}

String akeaMoney(num value) {
  final n = value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 2);
  final parts = n.split('.');
  final chars = parts[0].replaceAll('-', '').split('').reversed.toList();
  final buf = StringBuffer();
  for (var i = 0; i < chars.length; i++) {
    if (i > 0 && i % 3 == 0) buf.write(',');
    buf.write(chars[i]);
  }
  final whole = buf.toString().split('').reversed.join();
  final sign = value < 0 ? '-' : '';
  if (parts.length > 1) return 'R $sign$whole.${parts[1]}';
  return 'R $sign$whole';
}

String akeaDate(DateTime date) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

String akeaShortDate(DateTime date) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${date.day} ${months[date.month - 1]}';
}

String akeaWeekdayDate(DateTime date) {
  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return '${days[date.weekday - 1]}, ${akeaShortDate(date)}';
}
