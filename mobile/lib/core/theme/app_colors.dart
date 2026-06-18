import 'package:flutter/material.dart';

/// ALTYN түс палитрасы — Modern light (sleek) бағыты, электрлік көк/индиго акцент.
/// Ескерту: `gold`/`goldBright` атаулары тарихи; қазір негізгі акцент = көк/индиго
/// (бүкіл аппта осы константалар арқылы қолданылады).
class AppColors {
  AppColors._();

  /// Қою фон (ticker/контраст беттер).
  static const Color midnight = Color(0xFF0B1020);

  /// Негізгі фон — салқын, таза «ақ» реңк.
  static const Color obsidian = Color(0xFFFAFBFC);

  /// Екінші фон реңкі (секциялар, chip жолақтары) — салқын ашық сұр.
  static const Color surfaceMuted = Color(0xFFEFF2F7);

  /// Негізгі акцент — электрлік көк.
  static const Color gold = Color(0xFF2563EB);

  /// Жарық акцент — индиго (градиент/белсенді күй).
  static const Color goldBright = Color(0xFF4F46E5);

  /// Жұмсақ көлеңке — карталарға тереңдік (салқын slate реңк).
  static const Color shadow = Color(0x14101828);

  static const Color dxyBlue = Color(0xFF3B82F6);
  static const Color silverGray = Color(0xFF64748B);
  static const Color oilRed = Color(0xFFE11D48);

  static const Color profitGreen = Color(0xFF059669);
  static const Color lossRed = Color(0xFFDC2626);
  static const Color purple = Color(0xFF7C3AED);

  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textMuted = Color(0xFF94A3B8);

  static const Color border = Color(0xFFE2E8F0);
  static const Color cardSurface = Color(0xFFFFFFFF);
}
