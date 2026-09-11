import 'dart:io';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/scan_result.dart';
import '../../core/utils/haptics.dart';
import '../../core/widgets/animated_progress_bar.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/safety_badge.dart';
import '../../presentation/routes/app_router.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key, required this.result});
  final ScanResult result;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late ConfettiController _confetti;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(
      duration: const Duration(seconds: 3),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.result.safetyLevel == SafetyLevel.safe) {
        _confetti.play();
        Haptics.success();
      } else if (widget.result.safetyLevel == SafetyLevel.unsafe) {
        Haptics.error();
      } else {
        Haptics.medium();
      }
    });
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  Future<void> _share() async {
    await Haptics.light();
    final r = widget.result;
    final level = r.safetyLevel.label.toUpperCase();
    const subject = 'SafeGuard Image Analysis Result';
    final body = '''🛡️ SafeGuard — Image Analysis Result
━━━━━━━━━━━━━━━━━━━━━
Verdict : $level
━━━━━━━━━━━━━━━━━━━━━
Neutral  : ${(r.neutral * 100).toStringAsFixed(1)}%
Drawings : ${(r.drawings * 100).toStringAsFixed(1)}%
Sexy     : ${(r.sexy * 100).toStringAsFixed(1)}%
Hentai   : ${(r.hentai * 100).toStringAsFixed(1)}%
Porn     : ${(r.porn * 100).toStringAsFixed(1)}%
━━━━━━━━━━━━━━━━━━━━━
Scanned with SafeGuard — 100% on-device. Your images never leave your phone.''';

    if (File(r.imagePath).existsSync()) {
      await Share.shareXFiles(
        [XFile(r.imagePath)],
        subject: subject,
        text: body,
      );
    } else {
      await Share.share(body, subject: subject);
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.result;
    final level = r.safetyLevel;
    final color = level.color;

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Stack(
        children: [
          // Ambient glow based on safety level
          Positioned(
            top: -80,
            right: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [color.withAlpha(40), Colors.transparent],
                ),
              ),
            ),
          ),

          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // App Bar with image
              SliverAppBar(
                backgroundColor: Colors.transparent,
                expandedHeight: 320,
                pinned: true,
                leading: GestureDetector(
                  onTap: () {
                    Haptics.light();
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go(AppRouter.home);
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.bgCard.withAlpha(200),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: AppColors.textPrimary,
                      size: 18,
                    ),
                  ),
                ),
                actions: [
                  GestureDetector(
                    onTap: _share,
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.bgCard.withAlpha(200),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.share_rounded,
                        color: AppColors.textPrimary,
                        size: 20,
                      ),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: _ImagePreview(result: r, level: level),
                ),
              ),

              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Verdict Card
                      VerdictCard(level: level),

                      const SizedBox(height: 24),

                      // Score breakdown
                      GlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.analytics_rounded,
                                  color: AppColors.brandStart,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Score Breakdown',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            ...r.orderedScores.asMap().entries.map((entry) {
                              final idx = entry.key;
                              final score = entry.value;
                              return AnimatedProgressBar(
                                label: score.$1,
                                value: score.$2,
                                color: r.categoryColor(score.$1),
                                delay: Duration(milliseconds: idx * 80),
                              );
                            }),
                          ],
                        ),
                      ).animate(delay: 200.ms).fadeIn(duration: 400.ms),

                      const SizedBox(height: 20),

                      // Tips card
                      _TipsCard(level: level),

                      const SizedBox(height: 20),

                      // Platform impact card
                      _PlatformCard(level: level),

                      const SizedBox(height: 24),

                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: _ActionButton(
                              label: 'Scan Another',
                              icon: Icons.document_scanner_rounded,
                              gradient: AppColors.brandGradient,
                              onTap: () {
                                Haptics.medium();
                                context.pop();
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _ActionButton(
                              label: 'Share Result',
                              icon: Icons.share_rounded,
                              gradient: const LinearGradient(
                                colors: [Color(0xFF0EA5E9), Color(0xFF2563EB)],
                              ),
                              onTap: _share,
                            ),
                          ),
                        ],
                      ).animate(delay: 600.ms).fadeIn(duration: 400.ms),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirectionality: BlastDirectionality.explosive,
              numberOfParticles: 30,
              maxBlastForce: 40,
              minBlastForce: 10,
              emissionFrequency: 0.05,
              colors: const [
                AppColors.safe,
                AppColors.safeGlow,
                Colors.white,
                AppColors.brandStart,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ImagePreview extends StatelessWidget {
  const _ImagePreview({required this.result, required this.level});
  final ScanResult result;
  final SafetyLevel level;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Image
        if (File(result.imagePath).existsSync())
          Image.file(
            File(result.imagePath),
            fit: BoxFit.cover,
          )
        else
          Container(
            color: AppColors.bgCard,
            child: const Center(
              child: Icon(
                Icons.image_not_supported_outlined,
                color: AppColors.textTertiary,
                size: 48,
              ),
            ),
          ),

        // Gradient overlay
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withAlpha(60),
                Colors.transparent,
                Colors.transparent,
                AppColors.bgDark,
              ],
              stops: const [0.0, 0.3, 0.6, 1.0],
            ),
          ),
        ),

        // Safety badge
        Positioned(
          bottom: 20,
          left: 20,
          child: SafetyBadge(level: level, large: true),
        ),
      ],
    );
  }
}

class _TipsCard extends StatefulWidget {
  const _TipsCard({required this.level});
  final SafetyLevel level;

  @override
  State<_TipsCard> createState() => _TipsCardState();
}

class _TipsCardState extends State<_TipsCard> {
  bool _expanded = false;

  List<String> get _tips {
    switch (widget.level) {
      case SafetyLevel.safe:
        return [
          'Great job! This image looks safe.',
          'Always double-check thumbnails before YouTube uploads.',
          'Consider adding a clear watermark for branding.',
        ];
      case SafetyLevel.risky:
        return [
          'Consider cropping out suggestive elements.',
          'Use brighter lighting to reduce ambiguity.',
          'Add clothing coverage to reduce "sexy" score.',
          'Test with a different camera angle.',
        ];
      case SafetyLevel.unsafe:
        return [
          'Do NOT post this image on public platforms.',
          'High risk of account suspension on Instagram, TikTok, YouTube.',
          'Artistic nudity still triggers AI filters.',
          'Consider a completely different image for your goal.',
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.level.color;

    return GlassCard(
      onTap: () {
        setState(() => _expanded = !_expanded);
        Haptics.select();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withAlpha(30),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.tips_and_updates_rounded, color: color, size: 18),
              ),
              const SizedBox(width: 12),
              Text(
                'Tips to Improve',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              AnimatedRotation(
                turns: _expanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 300),
                child: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            child: _expanded
                ? Column(
                    children: [
                      const SizedBox(height: 16),
                      ..._tips.asMap().entries.map((e) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 3),
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  e.value,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    ).animate(delay: 400.ms).fadeIn(duration: 400.ms);
  }
}

class _PlatformCard extends StatelessWidget {
  const _PlatformCard({required this.level});
  final SafetyLevel level;

  @override
  Widget build(BuildContext context) {
    final platforms = [
      ('Instagram', Icons.camera_alt_rounded, level == SafetyLevel.safe),
      ('TikTok', Icons.music_video_rounded, level == SafetyLevel.safe),
      ('YouTube', Icons.play_circle_rounded, level != SafetyLevel.unsafe),
      ('LinkedIn', Icons.work_rounded, level == SafetyLevel.safe),
      ('X / Twitter', Icons.tag_rounded, level != SafetyLevel.unsafe),
      ('Facebook', Icons.facebook_rounded, level != SafetyLevel.unsafe),
    ];

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.public_rounded,
                color: AppColors.brandStart,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Platform Compatibility',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: platforms.map((p) {
              final ok = p.$3;
              final color = ok ? AppColors.safe : AppColors.unsafe;
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: color.withAlpha(20),
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: color.withAlpha(60)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(p.$2, color: color, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      p.$1,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      ok ? Icons.check_circle_rounded : Icons.cancel_rounded,
                      color: color,
                      size: 12,
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    ).animate(delay: 500.ms).fadeIn(duration: 400.ms);
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Gradient gradient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.brandStart.withAlpha(60),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
