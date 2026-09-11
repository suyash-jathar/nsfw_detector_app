import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

class _Tip {
  const _Tip({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.body,
    required this.category,
  });
  final IconData icon;
  final Color iconColor;
  final String title;
  final String body;
  final String category;
}

const _tips = [
  _Tip(
    icon: Icons.crop_rotate_rounded,
    iconColor: AppColors.safe,
    title: 'Crop & Reframe',
    body:
        'Simple cropping can remove elements that trigger content filters. Even minor framing changes can shift a "Risky" score to "Safe".',
    category: 'Quick Fix',
  ),
  _Tip(
    icon: Icons.light_mode_rounded,
    iconColor: AppColors.chipSexy,
    title: 'Lighting Matters',
    body:
        'Dark, moody images with skin tones can trigger false positives. Use bright, even lighting to reduce ambiguity in AI analysis.',
    category: 'Quick Fix',
  ),
  _Tip(
    icon: Icons.checkroom_rounded,
    iconColor: AppColors.chipDrawings,
    title: 'Coverage',
    body:
        'More clothing coverage almost always lowers the "Sexy" and "Porn" scores significantly. This applies to both real photos and artwork.',
    category: 'Content',
  ),
  _Tip(
    icon: Icons.photo_filter_rounded,
    iconColor: AppColors.brandStart,
    title: 'Avoid Filters',
    body:
        'Heavy skin-smoothing or body-augmentation filters can paradoxically increase NSFW scores. Use natural-looking edits instead.',
    category: 'Content',
  ),
  _Tip(
    icon: Icons.aspect_ratio_rounded,
    iconColor: Color(0xFF60A5FA),
    title: 'Context is Key',
    body:
        'Family, team, or branded context in an image (text, logos, multiple people) signals safety to platform AI and reduces false flags.',
    category: 'Strategy',
  ),
  _Tip(
    icon: Icons.color_lens_rounded,
    iconColor: AppColors.chipHentai,
    title: 'Artistic Nudity',
    body:
        'Platform policies do NOT always align with artistic intent. A classic painting can still trigger filters — always scan art before posting.',
    category: 'Awareness',
  ),
  _Tip(
    icon: Icons.psychology_rounded,
    iconColor: AppColors.risky,
    title: 'Platform Differences',
    body:
        'LinkedIn is strictest. Reddit most lenient. Instagram/TikTok auto-remove flagged content. X/Twitter restricts reach. Know your platform.',
    category: 'Awareness',
  ),
  _Tip(
    icon: Icons.verified_rounded,
    iconColor: AppColors.safe,
    title: 'Profile Pictures',
    body:
        'Your profile picture is checked multiple times. Even a mildly flagged profile pic can shadow-restrict your entire account.',
    category: 'Strategy',
  ),
  _Tip(
    icon: Icons.video_library_rounded,
    iconColor: AppColors.chipNeutral,
    title: 'Thumbnails',
    body:
        'YouTube thumbnails can demonetize entire channels. Always scan before uploading — even if the thumbnail looks completely innocent.',
    category: 'Strategy',
  ),
  _Tip(
    icon: Icons.scanner_rounded,
    iconColor: AppColors.brandEnd,
    title: 'Scan Before Every Post',
    body:
        'Make SafeGuard part of your workflow. Scan every image before posting — it takes seconds and can save your entire account.',
    category: 'Best Practice',
  ),
];

const _categories = ['All', 'Quick Fix', 'Content', 'Strategy', 'Awareness', 'Best Practice'];

class TipsScreen extends StatefulWidget {
  const TipsScreen({super.key});

  @override
  State<TipsScreen> createState() => _TipsScreenState();
}

class _TipsScreenState extends State<TipsScreen> {
  String _selectedCategory = 'All';

  List<_Tip> get _filtered => _selectedCategory == 'All'
      ? _tips
      : _tips.where((t) => t.category == _selectedCategory).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tips & Tricks',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    'Keep your content platform-safe',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1),
            ),

            const SizedBox(height: 16),

            // Category filters
            SizedBox(
              height: 44,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final cat = _categories[i];
                  final isSelected = cat == _selectedCategory;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = cat),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.brandStart.withAlpha(40)
                            : AppColors.glassFill,
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.brandStart.withAlpha(120)
                              : AppColors.glassBorder,
                        ),
                      ),
                      child: Text(
                        cat,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isSelected
                              ? AppColors.brandStart
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            // Tips list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 120),
                physics: const BouncingScrollPhysics(),
                itemCount: _filtered.length,
                itemBuilder: (_, i) {
                  return _TipCard(
                    tip: _filtered[i],
                    index: i,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TipCard extends StatefulWidget {
  const _TipCard({required this.tip, required this.index});
  final _Tip tip;
  final int index;

  @override
  State<_TipCard> createState() => _TipCardState();
}

class _TipCardState extends State<_TipCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final tip = widget.tip;

    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.glassBorder, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: tip.iconColor.withAlpha(25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(tip.icon, color: tip.iconColor, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tip.title,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          tip.category,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: tip.iconColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                child: _expanded
                    ? Padding(
                        padding: const EdgeInsets.only(top: 14, left: 4),
                        child: Text(
                          tip.body,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            height: 1.6,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: widget.index * 50))
        .fadeIn(duration: 350.ms)
        .slideY(begin: 0.05, end: 0);
  }
}
