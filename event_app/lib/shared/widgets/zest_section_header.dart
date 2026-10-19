import 'package:flutter/material.dart';
import '../../core/theme/zest_tokens.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// ZEST SECTION HEADER
/// Section title with optional action text button (e.g. "See all").
/// ─────────────────────────────────────────────────────────────────────────────

class ZestSectionHeader extends StatelessWidget {
  final String title;
  final String? accentWord;
  final String? actionText;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback? onActionTap;
  final String? badgeText;

  const ZestSectionHeader({
    super.key,
    required this.title,
    this.accentWord,
    this.actionText,
    this.actionLabel,
    this.onAction,
    this.onActionTap,
    this.badgeText,
  });


  @override
  Widget build(BuildContext context) {
    Widget titleWidget;
    if (accentWord != null && accentWord!.isNotEmpty) {
      final parts = title.split(accentWord!);
      titleWidget = RichText(
        text: TextSpan(
          style: ZestTokens.section,
          children: [
            if (parts.isNotEmpty) TextSpan(text: parts[0]),
            TextSpan(
              text: accentWord,
              style: ZestTokens.accentItalic.copyWith(fontSize: 20),
            ),
            if (parts.length > 1) TextSpan(text: parts[1]),
          ],
        ),
      );
    } else {
      titleWidget = Text(title, style: ZestTokens.section);
    }

    final effectiveActionText = actionLabel ?? actionText;
    final effectiveOnAction = onActionTap ?? onAction;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              titleWidget,
              if (badgeText != null && badgeText!.isNotEmpty) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: ZestTokens.fill,
                    borderRadius: ZestTokens.borderPill,
                    border: Border.all(color: ZestTokens.line, width: 1),
                  ),
                  child: Text(
                    badgeText!,
                    style: ZestTokens.caption.copyWith(
                      color: ZestTokens.ink2,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (effectiveActionText != null && effectiveOnAction != null)
            GestureDetector(
              onTap: effectiveOnAction,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text(
                  effectiveActionText,
                  style: ZestTokens.caption.copyWith(
                    color: ZestTokens.blue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

