import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_shadows.dart';
import '../theme/app_text_styles.dart';

// ─────────────────────────────────────────────────────────────────────────────
// HeroEventCard — Featured Carousel Card
// Spec: 250×290, radius 34, solid event color bg (coral/lavender/mustard/aqua),
//       ink pill tag top-left with lime text, large emoji 64sp, title 27sp
//       Bricolage 800 (ink text), date 13sp at 70% opacity, 48px ink circle
//       with lime arrow bottom-right.
// ─────────────────────────────────────────────────────────────────────────────

class HeroEventCard extends StatelessWidget {
  const HeroEventCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.tag,
    this.emoji,
    this.date,
    this.venue,
    this.onTap,
    this.colorIndex = 0,
    this.heroTag,
  });

  final String title;
  final String subtitle;
  final String? tag;
  final String? emoji;
  final String? date;
  final String? venue;
  final VoidCallback? onTap;
  final int colorIndex;
  final String? heroTag;

  static const List<Color> _palette = [
    AppColors.coral,
    AppColors.lavender,
    AppColors.mustard,
    AppColors.aqua,
    AppColors.teal,
    AppColors.orange,
  ];

  String _resolveEmoji() {
    if (emoji != null && emoji!.isNotEmpty) return emoji!;
    final lower = '$title $subtitle $tag'.toLowerCase();
    if (lower.contains('hack') || lower.contains('code') || lower.contains('tech')) return '💻';
    if (lower.contains('music') || lower.contains('concert') || lower.contains('fest')) return '🎵';
    if (lower.contains('dance') || lower.contains('cultural')) return '💃';
    if (lower.contains('design') || lower.contains('art')) return '🎨';
    if (lower.contains('sport') || lower.contains('cricket') || lower.contains('football')) return '⚡';
    if (lower.contains('ai') || lower.contains('robot')) return '🤖';
    if (lower.contains('quiz') || lower.contains('brain')) return '🧠';
    if (lower.contains('drama') || lower.contains('theatre')) return '🎭';
    return '✨';
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = _palette[colorIndex % _palette.length];
    final displayEmoji = _resolveEmoji();

    Widget card = GestureDetector(
      onTap: onTap,
      child: Container(
        width: 250,
        height: 290,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppRadius.carouselCard),
          boxShadow: AppShadows.hero,
        ),
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: Tag Pill + Big Emoji
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (tag != null && tag!.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.ink,
                      borderRadius: AppRadius.circularPill,
                    ),
                    child: Text(
                      tag!.toUpperCase(),
                      style: AppTextStyles.pillTag.copyWith(
                        color: AppColors.lime,
                        fontSize: 11,
                        letterSpacing: 0.5,
                      ),
                    ),
                  )
                else
                  const SizedBox.shrink(),
                Text(
                  displayEmoji,
                  style: const TextStyle(fontSize: 48, height: 1.0),
                ),
              ],
            ),

            const Spacer(),

            // Title: 27sp Bricolage 800 with ink text
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.title27.copyWith(
                color: AppColors.ink,
                height: 1.15,
              ),
            ),
            const SizedBox(height: 6),

            // Date / Venue: 13sp at 70% ink opacity
            if (date != null || venue != null)
              Text(
                [if (date != null) date, if (venue != null) venue].join(' • '),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption13.copyWith(
                  color: AppColors.ink.withValues(alpha: 0.72),
                  fontWeight: FontWeight.w600,
                ),
              )
            else
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption13.copyWith(
                  color: AppColors.ink.withValues(alpha: 0.72),
                  fontWeight: FontWeight.w600,
                ),
              ),

            const SizedBox(height: 16),

            // Bottom Row: Action pill or indicator + 48px ink circle with lime arrow
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Info label
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.ink.withValues(alpha: 0.12),
                    borderRadius: AppRadius.circularPill,
                  ),
                  child: Text(
                    'FEATURED',
                    style: AppTextStyles.overline.copyWith(
                      color: AppColors.ink,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),

                // 48px ink circle with lime arrow
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: AppColors.ink,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      color: AppColors.lime,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (heroTag != null) {
      return Hero(tag: heroTag!, child: card);
    }
    return card;
  }
}
