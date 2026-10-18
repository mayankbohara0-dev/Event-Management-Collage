import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';

/// ZestPointsBadge - citrus-styled points / level indicator.
class ZestPointsBadge extends StatelessWidget {
  const ZestPointsBadge({
    super.key,
    required this.points,
    this.level,
    this.compact = false,
  });

  final int points;
  final int? level;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 14,
        vertical: compact ? 4 : 8,
      ),
      decoration: BoxDecoration(
        gradient: AppColors.zestGradient,
        borderRadius: AppRadius.circularPill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('🍋', style: TextStyle(fontSize: compact ? 14 : 18)),
          const SizedBox(width: 6),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$points pts',
                style: GoogleFonts.poppins(
                  color: AppColors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: compact ? 13 : 16,
                  height: 1.0,
                ),
              ),
              if (level != null && !compact)
                Text(
                  'Zest Level $level',
                  style: GoogleFonts.poppins(
                    color: AppColors.white.withValues(alpha: 0.85),
                    fontWeight: FontWeight.w500,
                    fontSize: 11,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
