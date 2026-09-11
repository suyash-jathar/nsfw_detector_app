import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Backgrounds ───────────────────────────────────────────
  static const Color bgDark = Color(0xFF05050F);
  static const Color bgSurface = Color(0xFF0D0D1E);
  static const Color bgCard = Color(0xFF141428);

  // ── Brand Gradient ────────────────────────────────────────
  static const Color brandStart = Color(0xFF7C3AED);
  static const Color brandEnd = Color(0xFF4361EE);
  static const Gradient brandGradient = LinearGradient(
    colors: [brandStart, brandEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Safety Colors ─────────────────────────────────────────
  static const Color safe = Color(0xFF10B981);
  static const Color safeGlow = Color(0xFF34D399);
  static const Gradient safeGradient = LinearGradient(
    colors: [Color(0xFF059669), Color(0xFF10B981)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Color risky = Color(0xFFF59E0B);
  static const Color riskyGlow = Color(0xFFFCD34D);
  static const Gradient riskyGradient = LinearGradient(
    colors: [Color(0xFFD97706), Color(0xFFF59E0B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Color unsafe = Color(0xFFEF4444);
  static const Color unsafeGlow = Color(0xFFF87171);
  static const Gradient unsafeGradient = LinearGradient(
    colors: [Color(0xFFDC2626), Color(0xFFEF4444)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Text ──────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFA1A1AA);
  static const Color textTertiary = Color(0xFF71717A);

  // ── Glass / Borders ───────────────────────────────────────
  static const Color glassBorder = Color(0x1AFFFFFF);
  static const Color glassFill = Color(0x0DFFFFFF);
  static const Color divider = Color(0x1AFFFFFF);

  // ── Category chip colors ──────────────────────────────────
  static const Color chipDrawings = Color(0xFF60A5FA);
  static const Color chipHentai = Color(0xFFF472B6);
  static const Color chipNeutral = Color(0xFF34D399);
  static const Color chipPorn = Color(0xFFF87171);
  static const Color chipSexy = Color(0xFFFBBF24);

  // ── Light Mode ────────────────────────────────────────────
  static const Color lightBg = Color(0xFFF2F2F7);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFF8F8FC);
  static const Color lightTextPrimary = Color(0xFF1D1D1F);
  static const Color lightTextSecondary = Color(0xFF6E6E73);
}
