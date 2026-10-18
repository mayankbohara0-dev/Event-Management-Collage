import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_shadows.dart';
import '../theme/app_spacing.dart';

/// StatTile - a chunky rounded card showing:
/// an icon in a tinted circle, a big animated number, and a label.
class StatTile extends StatefulWidget {
  const StatTile({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    this.iconColor,
    this.iconBg,
    this.valueColor,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color? iconColor;
  final Color? iconBg;
  final Color? valueColor;

  @override
  State<StatTile> createState() => _StatTileState();
}

class _StatTileState extends State<StatTile> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _scaleAnim = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final iconBg = widget.iconBg ?? AppColors.coral.withValues(alpha: 0.12);
    final iconColor = widget.iconColor ?? AppColors.coral;
    final valueColor = widget.valueColor ?? AppColors.charcoal;

    return ScaleTransition(
      scale: _scaleAnim,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.base),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.circularXl2,
          boxShadow: AppShadows.card,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: AppRadius.circularMd,
              ),
              child: Icon(widget.icon, color: iconColor, size: 20),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              widget.value,
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: valueColor,
                height: 1.0,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              widget.label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.grey400,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
