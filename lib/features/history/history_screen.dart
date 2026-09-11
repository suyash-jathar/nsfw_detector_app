import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/scan_result.dart';
import '../../core/utils/haptics.dart';
import '../../core/widgets/safety_badge.dart';
import '../../presentation/routes/app_router.dart';
import 'history_controller.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late HistoryController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.put(HistoryController());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _ctrl.loadResults();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            _buildFilters(),
            Expanded(child: _buildList(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Scan History',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              Obx(
                () => Text(
                  '${_ctrl.results.length} total scans',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          Obx(() {
            if (_ctrl.results.isEmpty) return const SizedBox.shrink();
            return GestureDetector(
              onTap: () => _showClearDialog(context),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.unsafe.withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.unsafe.withAlpha(60),
                  ),
                ),
                child: Text(
                  'Clear All',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.unsafe,
                  ),
                ),
              ),
            );
          }),
        ],
      ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1),
    );
  }

  Widget _buildFilters() {
    return Obx(
      () {
        final currentFilter = _ctrl.filter.value; // read synchronously so GetX tracks it
        return SizedBox(
          height: 48,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            scrollDirection: Axis.horizontal,
            itemCount: _ctrl.filters.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final f = _ctrl.filters[i];
              final isSelected = currentFilter == f;
              final color = _filterColor(f);

            return GestureDetector(
              onTap: () {
                Haptics.select();
                _ctrl.filter.value = f;
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18, vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? color.withAlpha(40)
                      : AppColors.glassFill,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: isSelected
                        ? color.withAlpha(120)
                        : AppColors.glassBorder,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Text(
                  f,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? color : AppColors.textSecondary,
                  ),
                ),
              ),
            );
          },
        ),
      );
    },
    );
  }

  Color _filterColor(String f) {
    return switch (f) {
      'Safe' => AppColors.safe,
      'Risky' => AppColors.risky,
      'Unsafe' => AppColors.unsafe,
      _ => AppColors.brandStart,
    };
  }

  Widget _buildList(BuildContext context) {
    return Obx(() {
      final items = _ctrl.filteredResults;
      if (items.isEmpty) return _EmptyHistory();

      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
        physics: const BouncingScrollPhysics(),
        itemCount: items.length,
        itemBuilder: (context, i) {
          final scan = items[i];
          return Dismissible(
            key: Key(scan.id),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 24),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppColors.unsafe.withAlpha(30),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                color: AppColors.unsafe,
                size: 26,
              ),
            ),
            onDismissed: (_) {
              Haptics.medium();
              _ctrl.deleteResult(scan.id);
            },
            child: _HistoryItem(
              scan: scan,
              index: i,
              onTap: () {
                Haptics.light();
                context.push(AppRouter.result, extra: scan);
              },
            ),
          );
        },
      );
    });
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
          'This will permanently delete all scan history.',
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
              _ctrl.clearAll();
              Haptics.medium();
            },
            child: Text(
              'Clear All',
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
}

class _HistoryItem extends StatelessWidget {
  const _HistoryItem({
    required this.scan,
    required this.index,
    required this.onTap,
  });

  final ScanResult scan;
  final int index;
  final VoidCallback onTap;

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.glassBorder, width: 1),
        ),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 64,
                height: 64,
                child: File(scan.imagePath).existsSync()
                    ? Image.file(
                        File(scan.imagePath),
                        fit: BoxFit.cover,
                      )
                    : Container(
                        color: AppColors.bgSurface,
                        child: const Icon(
                          Icons.image_rounded,
                          color: AppColors.textTertiary,
                          size: 28,
                        ),
                      ),
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SafetyBadge(level: scan.safetyLevel),
                      const Spacer(),
                      Text(
                        _timeAgo(scan.scannedAt),
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _ScorePill(
                        label: 'Neutral',
                        value: scan.neutral,
                        color: AppColors.chipNeutral,
                      ),
                      const SizedBox(width: 6),
                      if (scan.porn > 0.05 || scan.hentai > 0.05)
                        _ScorePill(
                          label: 'Risk',
                          value: scan.porn + scan.hentai,
                          color: AppColors.chipPorn,
                        ),
                      if (scan.sexy > 0.1)
                        Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: _ScorePill(
                            label: 'Sexy',
                            value: scan.sexy,
                            color: AppColors.chipSexy,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textTertiary,
              size: 20,
            ),
          ],
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: index * 40))
        .fadeIn(duration: 350.ms)
        .slideX(begin: -0.05, end: 0);
  }
}

class _ScorePill extends StatelessWidget {
  const _ScorePill({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Text(
        '$label ${(value * 100).toStringAsFixed(0)}%',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('📋', style: const TextStyle(fontSize: 64))
              .animate()
              .scale(begin: const Offset(0.5, 0.5), curve: Curves.elasticOut),
          const SizedBox(height: 20),
          Text(
            'No history yet',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your scan history will appear here',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ).animate(delay: 200.ms).fadeIn(duration: 500.ms),
    );
  }
}
