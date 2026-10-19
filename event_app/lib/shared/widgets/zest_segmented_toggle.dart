import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/zest_tokens.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// ZEST SEGMENTED TOGGLE
/// Sliding white thumb on fill (#EEF2F8) track with smooth 300ms animation.
/// ─────────────────────────────────────────────────────────────────────────────

class ZestSegmentedToggle extends StatelessWidget {
  final List<String>? options;
  final List<String>? segments;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final double height;

  const ZestSegmentedToggle({
    super.key,
    this.options,
    this.segments,
    required this.selectedIndex,
    required this.onChanged,
    this.height = 46.0,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveOptions = options ?? segments ?? const [];

    return Container(
      height: height,
      padding: const EdgeInsets.all(3.0),
      decoration: BoxDecoration(
        color: ZestTokens.fill,
        borderRadius: ZestTokens.borderPill,
        border: Border.all(color: ZestTokens.line, width: 1.0),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final int count = effectiveOptions.isEmpty ? 1 : effectiveOptions.length;
          final double segmentWidth = (constraints.maxWidth - 2.0) / count;


          return Stack(
            children: [
              // Sliding white thumb
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                left: selectedIndex * segmentWidth,
                top: 0,
                bottom: 0,
                width: segmentWidth,
                child: Container(
                  decoration: BoxDecoration(
                    color: ZestTokens.card,
                    borderRadius: ZestTokens.borderPill,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0B1220).withValues(alpha: 0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),

              // Labels row
              Row(
                children: List.generate(effectiveOptions.length, (index) {
                  final bool isSelected = index == selectedIndex;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (index != selectedIndex) {
                          HapticFeedback.selectionClick();
                          onChanged(index);
                        }
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: ZestTokens.caption.copyWith(
                            color: isSelected
                                ? ZestTokens.ink
                                : ZestTokens.ink2,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w500,
                            fontSize: 13.5,
                          ),
                          child: Text(effectiveOptions[index]),
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
    );
  }
}
