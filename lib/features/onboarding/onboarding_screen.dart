import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/storage_service.dart';
import '../../core/utils/haptics.dart';
import 'package:get/get.dart';
import '../../presentation/routes/app_router.dart';

class _OnboardPage {
  const _OnboardPage({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.body,
    required this.gradient,
    required this.highlightColor,
  });
  final String emoji;
  final String title;
  final String subtitle;
  final String body;
  final Gradient gradient;
  final Color highlightColor;
}

const _pages = [
  _OnboardPage(
    emoji: '🛡️',
    title: 'Protect Your\nReputation',
    subtitle: 'One wrong image can destroy everything',
    body:
        'Platforms like Instagram, TikTok, YouTube, LinkedIn and X use AI to scan every image you upload — NSFW content triggers instant shadowbans, demonetization, or permanent suspension.',
    gradient: LinearGradient(
      colors: [Color(0xFF1E0533), Color(0xFF0D0D1E)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    highlightColor: Color(0xFF7C3AED),
  ),
  _OnboardPage(
    emoji: '⚠️',
    title: 'One Post Away\nFrom a Ban',
    subtitle: 'Platforms have zero tolerance',
    body:
        'Even mildly suggestive content, certain poses, or artistic nudity can trigger content filters. What\'s allowed in one app can permanently ban you on another. The rules are strict and unpredictable.',
    gradient: LinearGradient(
      colors: [Color(0xFF2D1500), Color(0xFF0D0D1E)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    highlightColor: Color(0xFFF59E0B),
  ),
  _OnboardPage(
    emoji: '🤖',
    title: '100% Offline\nAI Detection',
    subtitle: 'Your images never leave your device',
    body:
        'SafeGuard uses a state-of-the-art MobileNetV2 AI model completely on-device. No cloud, no upload, no privacy risk. Get instant results in under a second — offline, always.',
    gradient: LinearGradient(
      colors: [Color(0xFF001A2D), Color(0xFF0D0D1E)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    highlightColor: Color(0xFF0EA5E9),
  ),
  _OnboardPage(
    emoji: '🚀',
    title: 'Stay Safe,\nGrow Fast',
    subtitle: 'Check before you post',
    body:
        'Scan any photo before posting — profile pictures, thumbnails, reels, stories, dating app photos, and more. Build your audience confidently with zero risk of content violations.',
    gradient: LinearGradient(
      colors: [Color(0xFF002210), Color(0xFF0D0D1E)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    highlightColor: Color(0xFF10B981),
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await Haptics.success();
    final storage = Get.find<StorageService>();
    await storage.markOnboardingDone();
    if (mounted) context.go(AppRouter.home);
  }

  Future<void> _next() async {
    await Haptics.light();
    if (_currentPage < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
      );
    } else {
      await _finish();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _currentPage == _pages.length - 1;

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Stack(
        children: [
          // Animated gradient background
          PageView.builder(
            controller: _controller,
            itemCount: _pages.length,
            physics: const BouncingScrollPhysics(),
            onPageChanged: (i) {
              setState(() => _currentPage = i);
              Haptics.select();
            },
            itemBuilder: (_, i) => _PageContent(page: _pages[i]),
          ),

          // Bottom controls overlay
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                child: Column(
                  children: [
                    SmoothPageIndicator(
                      controller: _controller,
                      count: _pages.length,
                      effect: ExpandingDotsEffect(
                        activeDotColor: _pages[_currentPage].highlightColor,
                        dotColor: AppColors.textTertiary.withAlpha(80),
                        dotHeight: 8,
                        dotWidth: 8,
                        expansionFactor: 3.5,
                        spacing: 6,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        if (_currentPage > 0)
                          TextButton(
                            onPressed: () {
                              Haptics.light();
                              _controller.previousPage(
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeOutCubic,
                              );
                            },
                            child: Text(
                              'Back',
                              style: GoogleFonts.plusJakartaSans(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                        else
                          TextButton(
                            onPressed: _finish,
                            child: Text(
                              'Skip',
                              style: GoogleFonts.plusJakartaSans(
                                color: AppColors.textTertiary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        const Spacer(),
                        _NextButton(
                          isLast: isLast,
                          color: _pages[_currentPage].highlightColor,
                          onTap: _next,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PageContent extends StatelessWidget {
  const _PageContent({required this.page});
  final _OnboardPage page;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: page.gradient),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 60, 28, 160),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Emoji icon
              Text(
                page.emoji,
                style: const TextStyle(fontSize: 72),
              )
                  .animate()
                  .scale(
                    begin: const Offset(0.5, 0.5),
                    curve: Curves.elasticOut,
                    duration: 700.ms,
                  )
                  .fadeIn(duration: 500.ms),

              const SizedBox(height: 32),

              // Title
              Text(
                page.title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 38,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  height: 1.1,
                  letterSpacing: -1.0,
                ),
              )
                  .animate(delay: 100.ms)
                  .fadeIn(duration: 500.ms)
                  .slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic),

              const SizedBox(height: 10),

              Text(
                page.subtitle,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: page.highlightColor,
                ),
              )
                  .animate(delay: 200.ms)
                  .fadeIn(duration: 500.ms),

              const SizedBox(height: 24),

              Text(
                page.body,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                  height: 1.7,
                ),
              )
                  .animate(delay: 300.ms)
                  .fadeIn(duration: 600.ms)
                  .slideY(begin: 0.1, end: 0),
            ],
          ),
        ),
      ),
    );
  }
}

class _NextButton extends StatelessWidget {
  const _NextButton({
    required this.isLast,
    required this.color,
    required this.onTap,
  });
  final bool isLast;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isLast ? 32 : 24,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(100),
          boxShadow: [
            BoxShadow(
              color: color.withAlpha(100),
              blurRadius: 20,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isLast ? 'Get Started' : 'Next',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              isLast ? Icons.rocket_launch_rounded : Icons.arrow_forward_rounded,
              color: Colors.white,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
