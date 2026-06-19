import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// ALTYN типографикасы — Modern / high-tech.
/// Headlines: Space Grotesk (геометриялық, заманауи).
/// UI: Outfit (sans-serif).
/// Цифры/цены: IBM Plex Mono.
/// Өлшемдер заманауи әрі оқуға ыңғайлы (ірілеу) болатындай таңдалған.
class AppTypography {
  AppTypography._();

  static TextStyle display({Color color = AppColors.textPrimary}) =>
      GoogleFonts.spaceGrotesk(fontSize: 36, fontWeight: FontWeight.w700, color: color, height: 1.1, letterSpacing: -0.5);

  static TextStyle h1({Color color = AppColors.textPrimary}) =>
      GoogleFonts.spaceGrotesk(fontSize: 27, fontWeight: FontWeight.w700, color: color, height: 1.15, letterSpacing: -0.4);

  static TextStyle h2({Color color = AppColors.textPrimary}) =>
      GoogleFonts.spaceGrotesk(fontSize: 22, fontWeight: FontWeight.w600, color: color, height: 1.2, letterSpacing: -0.2);

  static TextStyle bodyLarge({Color color = AppColors.textPrimary}) =>
      GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.w400, color: color, height: 1.45);

  static TextStyle bodyMedium({Color color = AppColors.textPrimary}) =>
      GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w400, color: color, height: 1.45);

  static TextStyle bodySmall({Color color = AppColors.textSecondary}) =>
      GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w400, color: color, height: 1.4);

  static TextStyle label({Color color = AppColors.textSecondary}) =>
      GoogleFonts.outfit(fontSize: 12.5, fontWeight: FontWeight.w600, color: color, letterSpacing: 0.4);

  static TextStyle button({Color color = Colors.white}) =>
      GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600, color: color, letterSpacing: 0.2);

  static TextStyle price({double size = 19, FontWeight weight = FontWeight.w600, Color color = AppColors.textPrimary}) =>
      GoogleFonts.ibmPlexMono(fontSize: size, fontWeight: weight, color: color);

  static TextStyle ticker({Color color = Colors.white}) =>
      GoogleFonts.ibmPlexMono(fontSize: 14, fontWeight: FontWeight.w600, color: color, letterSpacing: 0.2);
}
