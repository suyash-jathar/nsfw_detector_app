import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/scan_result.dart';

/// Pill badge that shows the safety level with color + icon.
class SafetyBadge extends StatelessWidget {
  const SafetyBadge({
    super.key,
    required this.level,
    this.large = false,
  });

  final SafetyLevel level;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final color = level.color;
    final iconSize = large ? 22.0 : 14.0;
    final fontSize = large ? 16.0 : 12.0;
    final padding = large
        ? const EdgeInsets.symmetric(horizontal: 20, vertical: 12)
        : const EdgeInsets.symmetric(horizontal: 12, vertical: 6);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withAlpha(80), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(level.icon, color: color, size: iconSize),
          SizedBox(width: large ? 8 : 5),
          Text(
            level.label.toUpperCase(),
            style: GoogleFonts.plusJakartaSans(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    )
        .animate()
        .scale(begin: const Offset(0.8, 0.8), curve: Curves.elasticOut)
        .fadeIn(duration: 400.ms);
  }
}

/// Large verdict card shown on the result screen.
class VerdictCard extends StatelessWidget {
  const VerdictCard({super.key, required this.level});

  final SafetyLevel level;

  @override
  Widget build(BuildContext context) {
    final color = level.color;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(60), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withAlpha(40),
                  shape: BoxShape.circle,
                ),
                child: Icon(level.icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Verdict: ${level.label}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                    Text(
                      level.description,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: color.withAlpha(180),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: color.withAlpha(15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.public_rounded,
                  color: color.withAlpha(180),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    level.platformWarning,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: color.withAlpha(200),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(
          begin: 0.1,
          end: 0,
          curve: Curves.easeOutCubic,
          duration: 500.ms,
        );
  }
}
