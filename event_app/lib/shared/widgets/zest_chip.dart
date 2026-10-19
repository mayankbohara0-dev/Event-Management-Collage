import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/zest_tokens.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// ZEST CHIP
/// Category and filter chip with blue tint style on selection (#E6F4FE + blue).
/// ─────────────────────────────────────────────────────────────────────────────

class ZestChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Widget? icon;
  final String? badge;

  const ZestChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    const selectedBg = Color(0xFFE6F4FE);
    const selectedBorder = ZestTokens.blue;
    const selectedText = ZestTokens.blue;

    final unselectedBg = ZestTokens.fill;
    final unselectedBorder = ZestTokens.line;
    final unselectedText = ZestTokens.ink2;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          borderRadius: ZestTokens.borderPill,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            decoration: BoxDecoration(
              color: isSelected ? selectedBg : unselectedBg,
              borderRadius: ZestTokens.borderPill,
              border: Border.all(
                color: isSelected ? selectedBorder : unselectedBorder,
                width: 1.0,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  icon!,
                  const SizedBox(width: 6),
                ],
                Text(
                  label,
                  style: ZestTokens.caption.copyWith(
                    color: isSelected ? selectedText : unselectedText,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
                if (badge != null) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isSelected ? ZestTokens.blue : ZestTokens.line,
                      borderRadius: ZestTokens.borderPill,
                    ),
                    child: Text(
                      badge!,
                      style: TextStyle(
                        color: isSelected ? Colors.white : ZestTokens.ink3,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
