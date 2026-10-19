import 'package:flutter/material.dart';
import '../../core/theme/zest_tokens.dart';
import 'zest_mascot.dart';
import 'zest_button.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// ZEST EMPTY STATE
/// Friendly screen state pairing the animated ZestMascot with a message and CTA.
/// ─────────────────────────────────────────────────────────────────────────────

class ZestEmptyState extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? message;
  final MascotMood mood;
  final MascotMood? mascotMood;
  final MascotTint tint;
  final double mascotSize;
  final String? ctaText;
  final String? actionLabel;
  final VoidCallback? onCta;
  final VoidCallback? onAction;

  const ZestEmptyState({
    super.key,
    required this.title,
    this.subtitle,
    this.message,
    this.mood = MascotMood.idle,
    this.mascotMood,
    this.tint = MascotTint.blue,
    this.mascotSize = 90.0,
    this.ctaText,
    this.actionLabel,
    this.onCta,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveSubtitle = subtitle ?? message;
    final effectiveMood = mascotMood ?? mood;
    final effectiveCta = actionLabel ?? ctaText;
    final effectiveOnCta = onAction ?? onCta;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ZestMascot(
              size: mascotSize,
              tint: tint,
              mood: effectiveMood,
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: ZestTokens.section.copyWith(fontSize: 19),
            ),
            if (effectiveSubtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                effectiveSubtitle,
                textAlign: TextAlign.center,
                style: ZestTokens.body.copyWith(
                  color: ZestTokens.ink2,
                  fontSize: 14,
                ),
              ),
            ],
            if (effectiveCta != null && effectiveOnCta != null) ...[
              const SizedBox(height: 24),
              ZestButton(
                text: effectiveCta,
                onPressed: effectiveOnCta,
                variant: ZestButtonVariant.secondary,
                height: 46,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

