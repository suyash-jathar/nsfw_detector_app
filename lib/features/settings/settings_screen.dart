import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/haptics.dart';
import '../../core/widgets/glass_card.dart';
import 'settings_controller.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late SettingsController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.put(SettingsController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Settings',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 28),
                    _buildAppCard(context),
                    const SizedBox(height: 16),
                    _buildScanSection(context),
                    const SizedBox(height: 16),
                    _buildModelCard(),
                    const SizedBox(height: 16),
                    _buildAboutCard(context),
                    const SizedBox(height: 120),
                  ],
                ).animate().fadeIn(duration: 400.ms),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppCard(BuildContext context) {
    return GlassCard(
      child: Column(
        children: [
          // App icon & name
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: AppColors.brandGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.brandStart.withAlpha(80),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.security_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SafeGuard',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'The Universal Image Guardian',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    'Version 1.0.0',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScanSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: 'Scanning'),
        const SizedBox(height: 10),
        GlassCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              // Auto-save toggle
              Obx(
                () => _SettingsRow(
                  icon: Icons.save_rounded,
                  iconColor: AppColors.safe,
                  title: 'Auto-Save Scans',
                  subtitle: 'Automatically save results to history',
                  trailing: Switch.adaptive(
                    value: _ctrl.autoSave.value,
                    activeThumbColor: AppColors.brandStart,
                    activeTrackColor: AppColors.brandStart.withAlpha(80),
                    onChanged: (v) {
                      Haptics.select();
                      _ctrl.setAutoSave(v);
                    },
                  ),
                ),
              ),
              _Divider(),

              // Total scanned
              _SettingsRow(
                icon: Icons.analytics_rounded,
                iconColor: AppColors.chipDrawings,
                title: 'Total Images Scanned',
                subtitle: 'Lifetime count',
                trailing: Text(
                  '${_ctrl.totalScanned}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              _Divider(),

              // Clear history
              _SettingsRow(
                icon: Icons.delete_outline_rounded,
                iconColor: AppColors.unsafe,
                title: 'Clear History',
                subtitle: 'Delete all saved scan results',
                onTap: () => _showClearDialog(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildModelCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: 'AI Model'),
        const SizedBox(height: 10),
        GlassCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _SettingsRow(
                icon: Icons.memory_rounded,
                iconColor: AppColors.brandStart,
                title: 'Model',
                subtitle: _ctrl.modelVersion,
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: _ctrl.modelLoaded
                        ? AppColors.safe.withAlpha(30)
                        : AppColors.unsafe.withAlpha(30),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(
                      color: _ctrl.modelLoaded
                          ? AppColors.safe.withAlpha(80)
                          : AppColors.unsafe.withAlpha(80),
                    ),
                  ),
                  child: Text(
                    _ctrl.modelLoaded ? 'Loaded' : 'Error',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _ctrl.modelLoaded
                          ? AppColors.safe
                          : AppColors.unsafe,
                    ),
                  ),
                ),
              ),
              _Divider(),
              _SettingsRow(
                icon: Icons.category_rounded,
                iconColor: AppColors.chipNeutral,
                title: 'Detection Classes',
                subtitle: _ctrl.classLabels.isEmpty
                    ? 'drawings, hentai, neutral, porn, sexy'
                    : _ctrl.classLabels.join(', '),
              ),
              _Divider(),
              _SettingsRow(
                icon: Icons.speed_rounded,
                iconColor: AppColors.risky,
                title: 'Processing',
                subtitle: '100% on-device • under 800ms',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAboutCard(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: 'More'),
        const SizedBox(height: 10),
        GlassCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _SettingsRow(
                icon: Icons.share_rounded,
                iconColor: AppColors.brandEnd,
                title: 'Share App',
                subtitle: 'Recommend SafeGuard to your friends',
                onTap: () async {
                  await Haptics.light();
                  await Share.share(
                    'Check out SafeGuard — the best NSFW Image Guardian! 🛡️\nScan any image before posting online to protect your accounts.',
                  );
                },
              ),
              _Divider(),
              _SettingsRow(
                icon: Icons.privacy_tip_outlined,
                iconColor: AppColors.chipNeutral,
                title: 'Privacy Policy',
                subtitle: 'We never collect or upload your data',
                onTap: () => _showPrivacyDialog(context),
              ),
              _Divider(),
              _SettingsRow(
                icon: Icons.info_outline_rounded,
                iconColor: AppColors.textSecondary,
                title: 'About',
                subtitle:
                    'SafeGuard v1.0 — 100% offline, powered by GantMan NSFW model',
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showClearDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Clear History',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'This will permanently delete all saved scan results.',
          style: GoogleFonts.inter(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () { Navigator.of(ctx).pop(); Haptics.light(); },
            child: Text(
              'Cancel',
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _ctrl.clearHistory();
              Haptics.medium();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: AppColors.bgCard,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  content: Text(
                    'History cleared.',
                    style: GoogleFonts.inter(color: AppColors.textPrimary),
                  ),
                ),
              );
            },
            child: Text(
              'Clear',
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.unsafe,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Privacy Policy',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'SafeGuard runs entirely on-device. '
          'Your images are never uploaded to any server. '
          'No analytics data is collected. '
          'Scan history is stored locally on your device only and '
          'can be deleted at any time from Settings.',
          style: GoogleFonts.inter(
            color: AppColors.textSecondary,
            height: 1.6,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () { Navigator.pop(context); Haptics.light(); },
            child: Text(
              'Got It',
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.brandStart,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.textTertiary,
        letterSpacing: 1.5,
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconColor.withAlpha(25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 8),
              trailing!,
            ] else if (onTap != null)
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textTertiary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        height: 1,
        color: AppColors.divider,
      ),
    );
  }
}
