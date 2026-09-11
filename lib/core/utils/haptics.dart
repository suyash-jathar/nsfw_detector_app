import 'package:flutter/services.dart';

/// Provides a centralized haptic feedback API across the app.
class Haptics {
  Haptics._();

  static Future<void> light() =>
      HapticFeedback.lightImpact();

  static Future<void> medium() =>
      HapticFeedback.mediumImpact();

  static Future<void> heavy() =>
      HapticFeedback.heavyImpact();

  static Future<void> select() =>
      HapticFeedback.selectionClick();

  static Future<void> success() async {
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 80));
    await HapticFeedback.lightImpact();
  }

  static Future<void> error() async {
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.heavyImpact();
  }
}
