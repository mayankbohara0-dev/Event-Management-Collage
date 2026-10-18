import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';

class ZestNavItem {
  const ZestNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
  final IconData icon;
  final IconData activeIcon;
  final String label;
}

/// FloatingPillNavBar — neo-bold lime & ink floating bottom bar.
/// Active tab gets a neon lime pill indicator that morphs in.
/// Auto-hides on scroll down, reveals on scroll up via [scrollController].
class FloatingPillNavBar extends StatelessWidget {
  const FloatingPillNavBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onTap,
    this.isVisible = true,
  });

  final List<ZestNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final bool isVisible;

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
      offset: isVisible ? Offset.zero : const Offset(0, 1.5),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 250),
        opacity: isVisible ? 1.0 : 0.0,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Container(
              height: 68,
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: AppRadius.circularPill,
                border: Border.all(color: AppColors.borderDark, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 28,
                    offset: const Offset(0, 12),
                  ),
                  BoxShadow(
                    color: AppColors.lime.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(items.length, (i) {
                  final item = items[i];
                  final isActive = i == selectedIndex;
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      onTap(i);
                    },
                    child: SizedBox(
                      width: 60,
                      height: 68,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Lime pill indicator + icon
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 280),
                              curve: Curves.easeOutBack,
                              width: isActive ? 48 : 36,
                              height: isActive ? 32 : 36,
                              decoration: BoxDecoration(
                                color: isActive
                                    ? AppColors.lime
                                    : Colors.transparent,
                                borderRadius: isActive
                                    ? AppRadius.circularPill
                                    : BorderRadius.zero,
                              ),
                              child: Center(
                                child: Icon(
                                  isActive ? item.activeIcon : item.icon,
                                  color: isActive
                                      ? AppColors.ink
                                      : AppColors.grey400,
                                  size: isActive ? 20 : 22,
                                ),
                              ),
                            ),
                            if (isActive) ...[
                              const SizedBox(height: 3),
                              AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 200),
                                style: TextStyle(
                                  fontFamily: 'Bricolage Grotesque',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.lime,
                                  letterSpacing: 0.2,
                                ),
                                child: Text(item.label),
                              ),
                            ],
                          ],
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
    );
  }
}
