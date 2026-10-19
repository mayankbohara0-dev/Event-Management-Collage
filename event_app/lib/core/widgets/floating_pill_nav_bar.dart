import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Zest FloatingPillNavBar
// Spec:
//   • height 66, margin 16 from left/right/bottom (+ safe area)
//   • Ink (#141416) background, fully rounded, soft shadow
//   • 5 icon-only tabs (no labels)
//   • Inactive icons: white at 65% opacity, size 24
//   • Active icon: ink on a 48px LIME CIRCLE that SLIDES between tabs
//     with a springy spring curve (~450ms, overshoot)
//   • Hidden when isVisible=false
// ─────────────────────────────────────────────────────────────────────────────

class ZestNavItem {
  const ZestNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
  final IconData icon;
  final IconData activeIcon;
  final String label; // used for semantics only (not displayed)
}

class FloatingPillNavBar extends StatefulWidget {
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
  State<FloatingPillNavBar> createState() => _FloatingPillNavBarState();
}

class _FloatingPillNavBarState extends State<FloatingPillNavBar> {
  // Spring curve for the sliding indicator (overshoot ~450ms)
  static const _springCurve = Curves.easeOutBack;
  static const _springDuration = Duration(milliseconds: 420);

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final n = widget.items.length;

    return AnimatedSlide(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
      offset: widget.isVisible ? Offset.zero : const Offset(0, 1.5),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 250),
        opacity: widget.isVisible ? 1.0 : 0.0,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + bottomInset),
          child: Container(
            height: 66,
            decoration: BoxDecoration(
              color: AppColors.ink,   // #141416 per spec
              borderRadius: AppRadius.circularPill,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.45),
                  blurRadius: 32,
                  offset: const Offset(0, 14),
                ),
                BoxShadow(
                  color: AppColors.lime.withValues(alpha: 0.06),
                  blurRadius: 24,
                  offset: Offset.zero,
                ),
              ],
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final itemWidth = constraints.maxWidth / n;
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // ── Sliding lime circle indicator ─────────────────────
                    AnimatedPositioned(
                      duration: _springDuration,
                      curve: _springCurve,
                      left: itemWidth * widget.selectedIndex + (itemWidth - 48) / 2,
                      top: (66 - 48) / 2,
                      child: RepaintBoundary(
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(
                            color: AppColors.lime,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),

                    // ── Tab icons ─────────────────────────────────────────
                    Row(
                      children: List.generate(n, (i) {
                        final item = widget.items[i];
                        final isActive = i == widget.selectedIndex;
                        return Expanded(
                          child: Semantics(
                            label: item.label,
                            selected: isActive,
                            button: true,
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                HapticFeedback.lightImpact();
                                widget.onTap(i);
                              },
                              child: SizedBox(
                                height: 66,
                                child: Center(
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 200),
                                    child: Icon(
                                      isActive ? item.activeIcon : item.icon,
                                      key: ValueKey('${i}_$isActive'),
                                      color: isActive
                                          ? AppColors.ink
                                          : Colors.white.withValues(alpha: 0.65),
                                      size: 24,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
