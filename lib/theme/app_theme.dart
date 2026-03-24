import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TruckiColors {
  // Base
  static const Color black = Color(0xFF0A0A0A);
  static const Color blackDeep = Color(0xFF050505);
  static const Color blackCard = Color(0xFF111111);
  static const Color blackSurface = Color(0xFF1A1A1A);
  static const Color blackBorder = Color(0xFF2A2A2A);

  // Red
  static const Color red = Color(0xFFCC1A1A);
  static const Color redBright = Color(0xFFE82020);
  static const Color redDark = Color(0xFF8B0000);
  static const Color redGlow = Color(0x33CC1A1A);

  // Gold
  static const Color gold = Color(0xFFD4AF37);
  static const Color goldLight = Color(0xFFF0D060);
  static const Color goldDark = Color(0xFF9A7D1A);
  static const Color goldGlow = Color(0x44D4AF37);
  static const Color goldFaint = Color(0x1AD4AF37);

  // Text
  static const Color textPrimary = Color(0xFFF5F0E8);
  static const Color textSecondary = Color(0xFF9A9080);
  static const Color textMuted = Color(0xFF5A5550);

  // Suits
  static const Color suitRed = Color(0xFFCC1A1A);
  static const Color suitBlack = Color(0xFFE8E0D0);
}

class TruckiTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: TruckiColors.black,
      colorScheme: const ColorScheme.dark(
        primary: TruckiColors.gold,
        secondary: TruckiColors.red,
        surface: TruckiColors.blackCard,
        background: TruckiColors.black,
        onPrimary: TruckiColors.black,
        onSecondary: TruckiColors.textPrimary,
        onSurface: TruckiColors.textPrimary,
      ),
      textTheme: GoogleFonts.playfairDisplayTextTheme(
        ThemeData.dark().textTheme,
      ).copyWith(
        displayLarge: GoogleFonts.playfairDisplay(
          color: TruckiColors.gold,
          fontWeight: FontWeight.w700,
          letterSpacing: 2,
        ),
        titleLarge: GoogleFonts.playfairDisplay(
          color: TruckiColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        bodyMedium: GoogleFonts.lato(
          color: TruckiColors.textSecondary,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: GoogleFonts.playfairDisplay(
          color: TruckiColors.gold,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
        iconTheme: const IconThemeData(color: TruckiColors.gold),
      ),
    );
  }
}
