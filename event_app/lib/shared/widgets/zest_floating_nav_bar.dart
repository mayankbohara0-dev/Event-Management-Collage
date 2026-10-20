import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/zest_tokens.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// ZEST FLOATING NAV BAR
/// Floating white pill with sliding 48px brandGradient circle indicator (easeOutBack),
/// 5 Lucide outline icons, scale 1.08 pop on active item, and light haptic feedback.
/// ─────────────────────────────────────────────────────────────────────────────

class ZestFloatingNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool isVisible;

  const ZestFloatingNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.isVisible = true,
  });

  static const List<IconData> _navIcons = [
    LucideIcons.home,
    LucideIcons.compass,
    LucideIcons.ticket,
    LucideIcons.trophy,
    LucideIcons.user,
  ];

  static const List<String> _navLabels = [
    'Home',
    'Explore',
    'Passes',
    'Ranks',
    'Profile',
  ];

  @override
  Widget build(BuildContext context) {
    final bottomSafe = MediaQuery.of(context).padding.bottom;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      left: 24,
      right: 24,
      bottom: isVisible ? (bottomSafe > 0 ? bottomSafe + 6 : 16) : -100,
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: ZestTokens.borderPill,
          border: Border.all(color: ZestTokens.line, width: 1.0),
          boxShadow: ZestTokens.navBarShadow,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double slotWidth = constraints.maxWidth / _navIcons.length;
            const double circleSize = 48.0;

            return Stack(
              alignment: Alignment.center,
              children: [
                // Sliding 48px brandGradient circle indicator
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 420),
                  curve: Curves.easeOutBack,
                  left: (currentIndex * slotWidth) +
                      (slotWidth - circleSize) / 2,
                  top: (64 - circleSize) / 2 - 1,
                  width: circleSize,
                  height: circleSize,
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: ZestTokens.brandGradient,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x330063F0),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                ),

                // 5 Nav icon buttons
                Row(
                  children: List.generate(_navIcons.length, (index) {
                    final bool isSelected = index == currentIndex;

                    return Expanded(
                      child: Semantics(
                        label: _navLabels[index],
                        selected: isSelected,
                        button: true,
                        child: GestureDetector(
                          onTap: () {
                            if (index != currentIndex) {
                              HapticFeedback.lightImpact();
                              onTap(index);
                            }
                          },
                          behavior: HitTestBehavior.opaque,
                          child: Center(
                            child: AnimatedScale(
                              scale: isSelected ? 1.08 : 1.0,
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOutBack,
                              child: Icon(
                                _navIcons[index],
                                size: 24,
                                color: isSelected ? Colors.white : ZestTokens.ink3,
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
    );
  }
}
