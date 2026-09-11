import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

/// Animated horizontal progress bar for displaying NSFW category scores.
class AnimatedProgressBar extends StatelessWidget {
  const AnimatedProgressBar({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    this.delay = Duration.zero,
    this.showPercent = true,
  });

  final String label;
  final double value; // 0.0 – 1.0
  final Color color;
  final Duration delay;
  final bool showPercent;

  @override
  Widget build(BuildContext context) {
    final pct = (value * 100).toStringAsFixed(1);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              if (showPercent)
                Text(
                  '$pct%',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  // Track
                  Container(
                    height: 8,
                    width: constraints.maxWidth,
                    decoration: BoxDecoration(
                      color: color.withAlpha(30),
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  // Fill
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: value.clamp(0.0, 1.0)),
                    duration: const Duration(milliseconds: 900),
                    curve: Curves.easeOutCubic,
                    builder: (_, animVal, __) {
                      return Container(
                        height: 8,
                        width: constraints.maxWidth * animVal,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [color.withAlpha(180), color],
                          ),
                          borderRadius: BorderRadius.circular(100),
                          boxShadow: [
                            BoxShadow(
                              color: color.withAlpha(100),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
    ).animate(delay: delay).fadeIn(duration: 400.ms).slideX(
          begin: -0.1,
          end: 0,
          curve: Curves.easeOutCubic,
          duration: 400.ms,
        );
  }
}
