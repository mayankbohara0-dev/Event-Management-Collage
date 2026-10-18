import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_shadows.dart';
import '../theme/app_spacing.dart';

/// HeroEventCard - big colored gradient card with title, short text,
/// category tag, and a circular dark arrow button.
/// Palette rotates through AppColors.heroCardGradients based on [colorIndex].
class HeroEventCard extends StatelessWidget {
  const HeroEventCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.tag,
    this.date,
    this.venue,
    this.onTap,
    this.colorIndex = 0,
    this.heroTag,
  });

  final String title;
  final String subtitle;
  final String? tag;
  final String? date;
  final String? venue;
  final VoidCallback? onTap;
  final int colorIndex;
  final String? heroTag;

  @override
  Widget build(BuildContext context) {
    final gradient = AppColors.heroCardGradients[colorIndex % AppColors.heroCardGradients.length];

    Widget card = GestureDetector(
      onTap: onTap,
      child: Container(
        width: 280,
        height: 180,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: AppRadius.circularXl3,
          boxShadow: AppShadows.hero,
        ),
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (tag != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  borderRadius: AppRadius.circularPill,
                ),
                child: Text(
                  tag!,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            const Spacer(),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
            if (date != null || venue != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  if (date != null)
                    _chip(Icons.calendar_today_outlined, date!),
                  if (date != null && venue != null)
                    const SizedBox(width: AppSpacing.xs),
                  if (venue != null)
                    Expanded(child: _chip(Icons.location_on_outlined, venue!)),
                  const Spacer(),
                  // Dark arrow button
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.charcoal,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );

    if (heroTag != null) {
      return Hero(tag: heroTag!, child: card);
    }
    return card;
  }

  Widget _chip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white70, size: 11),
        const SizedBox(width: 3),
        Text(
          text,
          style: GoogleFonts.poppins(
            color: Colors.white70,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
