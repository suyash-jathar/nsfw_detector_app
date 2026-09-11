import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/haptics.dart';
import '../../core/widgets/glass_card.dart';
import 'scan_controller.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  late ScanController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.put(ScanController());
    // Check permissions upfront so the user can grant access before tapping a button
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _ctrl.proactivePermissionCheck(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Stack(
        children: [
          // Background glow
          Positioned(
            top: 100,
            left: MediaQuery.of(context).size.width / 2 - 150,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.brandStart.withAlpha(40),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      // Header
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Scan Image',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              Text(
                                'Choose a source to analyze',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                          .animate()
                          .fadeIn(duration: 400.ms)
                          .slideY(begin: -0.1),

                      const SizedBox(height: 40),

                      // Animated scanner icon
                      _ScannerIcon()
                          .animate()
                          .fadeIn(duration: 600.ms, delay: 100.ms)
                          .scale(
                            begin: const Offset(0.8, 0.8),
                            curve: Curves.elasticOut,
                          ),

                      const SizedBox(height: 48),

                      // Source buttons
                      _SourceButton(
                        icon: Icons.camera_alt_rounded,
                        gradient: AppColors.brandGradient,
                        label: 'Camera',
                        subtitle: 'Take a new photo',
                        delay: 200.ms,
                        onTap: () => _ctrl.pickAndScan(
                          context, ImageSource.camera,
                        ),
                      ),
                      const SizedBox(height: 14),
                      _SourceButton(
                        icon: Icons.photo_library_rounded,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0EA5E9), Color(0xFF2563EB)],
                        ),
                        label: 'Photo Gallery',
                        subtitle: 'Choose from your library',
                        delay: 300.ms,
                        onTap: () => _ctrl.pickAndScan(
                          context, ImageSource.gallery,
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Privacy note
                      GlassCard(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12,
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.lock_outline_rounded,
                              color: AppColors.safe,
                              size: 18,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                '100% on-device. Your images never leave your phone.',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ).animate(delay: 400.ms).fadeIn(duration: 400.ms),
                    ],
                  ),
                ),

                const Spacer(),
              ],
            ),
          ),

          // Processing overlay
          Obx(() {
            if (_ctrl.state.value == ScanState.processing) {
              return _ProcessingOverlay();
            }
            if (_ctrl.state.value == ScanState.error) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _showErrorDialog(context);
              });
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  void _showErrorDialog(BuildContext context) {
    final msg = _ctrl.errorMessage.value;
    if (msg.isEmpty) return;
    _ctrl.clearError();
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Error',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          msg,
          style: GoogleFonts.inter(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () { Navigator.pop(context); Haptics.light(); },
            child: Text(
              'OK',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                color: AppColors.brandStart,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScannerIcon extends StatefulWidget {
  @override
  State<_ScannerIcon> createState() => _ScannerIconState();
}

class _ScannerIconState extends State<_ScannerIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scan;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _scan = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      height: 180,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer ring
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.brandStart.withAlpha(40),
                width: 1,
              ),
            ),
          ),
          // Middle ring
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.brandStart.withAlpha(60),
                width: 1,
              ),
            ),
          ),
          // Inner shield
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: AppColors.brandGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.brandStart.withAlpha(80),
                  blurRadius: 24,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: const Icon(
              Icons.security_rounded,
              color: Colors.white,
              size: 48,
            ),
          ),
          // Scanning line
          AnimatedBuilder(
            animation: _scan,
            builder: (_, __) {
              return Positioned(
                top: 90 - 80 + _scan.value * 160,
                child: Container(
                  width: 130,
                  height: 2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        AppColors.brandStart.withAlpha(200),
                        Colors.transparent,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SourceButton extends StatelessWidget {
  const _SourceButton({
    required this.icon,
    required this.gradient,
    required this.label,
    required this.subtitle,
    required this.delay,
    required this.onTap,
  });

  final IconData icon;
  final Gradient gradient;
  final String label;
  final String subtitle;
  final Duration delay;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () { Haptics.medium(); onTap(); },
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: Colors.white, size: 26),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textTertiary,
              size: 22,
            ),
          ],
        ),
      ),
    )
        .animate(delay: delay)
        .fadeIn(duration: 400.ms)
        .slideX(begin: 0.08, end: 0, curve: Curves.easeOutCubic);
  }
}

class _ProcessingOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withAlpha(180),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Center(
          child: GlassCard(
            padding: const EdgeInsets.all(36),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 52,
                  height: 52,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: const AlwaysStoppedAnimation(
                      AppColors.brandStart,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Analyzing Image…',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Running AI model on-device',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
