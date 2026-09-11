import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/haptics.dart';
import '../routes/app_router.dart';

class _NavItem {
  const _NavItem({
    required this.path,
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
  final String path;
  final IconData icon;
  final IconData activeIcon;
  final String label;
}

const _navItems = [
  _NavItem(
    path: AppRouter.home,
    icon: Icons.home_outlined,
    activeIcon: Icons.home_rounded,
    label: 'Home',
  ),
  _NavItem(
    path: AppRouter.history,
    icon: Icons.history_outlined,
    activeIcon: Icons.history_rounded,
    label: 'History',
  ),
  _NavItem(
    path: AppRouter.scan,
    icon: Icons.camera_alt_outlined,
    activeIcon: Icons.camera_alt_rounded,
    label: 'Scan',
  ),
  _NavItem(
    path: AppRouter.tips,
    icon: Icons.lightbulb_outline_rounded,
    activeIcon: Icons.lightbulb_rounded,
    label: 'Tips',
  ),
  _NavItem(
    path: AppRouter.settings,
    icon: Icons.settings_outlined,
    activeIcon: Icons.settings_rounded,
    label: 'Settings',
  ),
];

class MainNavigation extends StatelessWidget {
  const MainNavigation({
    super.key,
    required this.child,
    required this.location,
  });

  final Widget child;
  final String location;

  int _indexFromLocation() {
    for (int i = 0; i < _navItems.length; i++) {
      if (location.startsWith(_navItems[i].path)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _indexFromLocation();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBody: true,
      body: child,
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.bgSurface.withAlpha(230)
                  : AppColors.lightSurface.withAlpha(230),
              border: const Border(
                top: BorderSide(color: AppColors.glassBorder, width: 1),
              ),
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                height: 68,
                child: Row(
                  children: List.generate(_navItems.length, (i) {
                    final item = _navItems[i];
                    final isActive = i == currentIndex;
                    final isScan = item.path == AppRouter.scan;

                    return Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () async {
                          if (!isActive) {
                            await Haptics.select();
                            if (context.mounted) context.go(item.path);
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOutCubic,
                          child: isScan
                              ? _ScanFab(isActive: isActive)
                              : _NavButton(
                                  item: item,
                                  isActive: isActive,
                                ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({required this.item, required this.isActive});

  final _NavItem item;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.brandStart : AppColors.textTertiary;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, anim) =>
              ScaleTransition(scale: anim, child: child),
          child: Icon(
            isActive ? item.activeIcon : item.icon,
            key: ValueKey(isActive),
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 4),
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: TextStyle(
            fontSize: 11,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            color: color,
          ),
          child: Text(item.label),
        ),
        const SizedBox(height: 2),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          height: 3,
          width: isActive ? 18 : 0,
          decoration: BoxDecoration(
            gradient: AppColors.brandGradient,
            borderRadius: BorderRadius.circular(100),
          ),
        ),
      ],
    );
  }
}

class _ScanFab extends StatelessWidget {
  const _ScanFab({required this.isActive});
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.elasticOut,
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          gradient: AppColors.brandGradient,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.brandStart.withAlpha(isActive ? 120 : 60),
              blurRadius: 16,
              spreadRadius: isActive ? 2 : 0,
            ),
          ],
        ),
        child: const Icon(
          Icons.document_scanner_rounded,
          color: Colors.white,
          size: 26,
        ),
      ),
    );
  }
}
