import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_text_styles.dart';
import 'zest_logo.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ZestCard — the primary bento card component for the ZEST design system.
// Variants: standard, featured (lime accent), dark, and glass.
// ─────────────────────────────────────────────────────────────────────────────

enum ZestCardVariant { standard, featured, dark, glass }

class ZestCard extends StatelessWidget {
  const ZestCard({
    super.key,
    required this.child,
    this.variant = ZestCardVariant.standard,
    this.padding,
    this.margin,
    this.borderRadius,
    this.withWatermark = false,
    this.onTap,
    this.height,
    this.width,
  });

  final Widget child;
  final ZestCardVariant variant;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final bool withWatermark;
  final VoidCallback? onTap;
  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color border;
    Gradient? gradient;

    switch (variant) {
      case ZestCardVariant.standard:
        bg = AppColors.surfaceCard;
        border = AppColors.borderDark;
      case ZestCardVariant.featured:
        bg = AppColors.lime;
        border = AppColors.lime;
      case ZestCardVariant.dark:
        bg = AppColors.surfaceDark;
        border = AppColors.borderDark;
      case ZestCardVariant.glass:
        bg = AppColors.surfaceCard.withValues(alpha: 0.65);
        border = AppColors.borderDark.withValues(alpha: 0.5);
        gradient = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surfaceCard.withValues(alpha: 0.75),
            AppColors.surfaceDark.withValues(alpha: 0.55),
          ],
        );
    }

    final radius = borderRadius ?? AppRadius.circularCard;

    Widget content = Container(
      height: height,
      width: width,
      margin: margin,
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: gradient == null ? bg : null,
        gradient: gradient,
        borderRadius: radius,
        border: Border.all(color: border, width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: withWatermark
          ? Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  right: -32,
                  bottom: -32,
                  child: ZestLogo.watermark(
                    size: 160,
                    color: variant == ZestCardVariant.featured
                        ? AppColors.ink.withValues(alpha: 0.06)
                        : AppColors.grey400.withValues(alpha: 0.06),
                  ),
                ),
                child,
              ],
            )
          : child,
    );

    if (onTap != null) {
      content = GestureDetector(
        onTap: onTap,
        child: AnimatedScale(
          scale: 1.0,
          duration: const Duration(milliseconds: 150),
          child: content,
        ),
      );
    }

    return content;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SparkleBadge — the tiny 4-point sparkle + label combo from the brand mark.
// ─────────────────────────────────────────────────────────────────────────────

class SparkleBadge extends StatelessWidget {
  const SparkleBadge({
    super.key,
    required this.label,
    this.color = AppColors.lime,
    this.textColor = AppColors.ink,
    this.showSparkle = true,
  });

  final String label;
  final Color color;
  final Color textColor;
  final bool showSparkle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: AppRadius.circularPill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showSparkle) ...[
            _SparkleIcon(color: textColor, size: 12),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Bricolage Grotesque',
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: textColor,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _SparkleIcon extends StatelessWidget {
  const _SparkleIcon({required this.color, required this.size});
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _SparklePainter(color: color),
    );
  }
}

class _SparklePainter extends CustomPainter {
  const _SparklePainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final cx = size.width / 2;
    final cy = size.height / 2;
    const arms = 4;
    const pi = 3.14159265358979;

    final path = Path();
    for (int i = 0; i < arms * 2; i++) {
      final angle = (i * pi / arms) - pi / 2;
      final r = i.isEven ? size.width * 0.5 : size.width * 0.18;
      final px = cx + r * _cos(angle);
      final py = cy + r * _sin(angle);
      if (i == 0) {
        path.moveTo(px, py);
      } else {
        path.lineTo(px, py);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  double _cos(double rad) => rad == 0
      ? 1
      : (rad < 1.571
          ? 1 - rad * rad / 2
          : (rad < 3.142
              ? -(rad - 3.142) * (rad - 3.142) / 2 + 1
              : (rad < 4.712
                  ? -(rad - 3.142) * (rad - 3.142) / 2 + 1
                  : 1)));

  double _sin(double rad) => _cos(rad - 1.5708);

  @override
  bool shouldRepaint(_SparklePainter old) => old.color != color;
}

// ─────────────────────────────────────────────────────────────────────────────
// TicketCard — punched ticket with notch cutouts on the sides.
// Used for event passes and registered events.
// ─────────────────────────────────────────────────────────────────────────────

class TicketCard extends StatelessWidget {
  const TicketCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.venue,
    this.status = 'Registered',
    this.statusColor = AppColors.lime,
    this.onTap,
    this.qrWidget,
  });

  final String title;
  final String subtitle;
  final String date;
  final String venue;
  final String status;
  final Color statusColor;
  final VoidCallback? onTap;
  final Widget? qrWidget;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        painter: _TicketPainter(
          color: AppColors.surfaceCard,
          borderColor: AppColors.borderDark,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status pill
              SparkleBadge(
                label: status.toUpperCase(),
                color: statusColor,
                textColor: statusColor == AppColors.lime
                    ? AppColors.ink
                    : AppColors.paper,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: AppTextStyles.title24.copyWith(color: AppColors.paper),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: AppTextStyles.body14.copyWith(color: AppColors.grey400),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              // Dashed divider line
              Row(
                children: List.generate(
                  20,
                  (i) => Expanded(
                    child: Container(
                      height: 1,
                      color:
                          i.isEven ? AppColors.borderDark : Colors.transparent,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _TicketDetail(icon: Icons.calendar_today_outlined, text: date),
                        const SizedBox(height: 6),
                        _TicketDetail(icon: Icons.location_on_outlined, text: venue),
                      ],
                    ),
                  ),
                  if (qrWidget != null) ...[
                    const SizedBox(width: 12),
                    qrWidget!,
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TicketDetail extends StatelessWidget {
  const _TicketDetail({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.grey400),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            style: AppTextStyles.caption12.copyWith(color: AppColors.grey400),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// Custom painter for the punched ticket shape with side notches.
class _TicketPainter extends CustomPainter {
  const _TicketPainter({required this.color, required this.borderColor});
  final Color color;
  final Color borderColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    const r = 20.0; // corner radius
    const notchR = 10.0; // notch semicircle radius
    final notchY = size.height * 0.72; // where the dashed line is

    final path = Path()
      ..moveTo(r, 0)
      ..lineTo(size.width - r, 0)
      ..arcToPoint(Offset(size.width, r), radius: const Radius.circular(r))
      ..lineTo(size.width, notchY - notchR)
      ..arcToPoint(Offset(size.width, notchY + notchR),
          radius: const Radius.circular(notchR), clockwise: false)
      ..lineTo(size.width, size.height - r)
      ..arcToPoint(Offset(size.width - r, size.height),
          radius: const Radius.circular(r))
      ..lineTo(r, size.height)
      ..arcToPoint(Offset(0, size.height - r), radius: const Radius.circular(r))
      ..lineTo(0, notchY + notchR)
      ..arcToPoint(Offset(0, notchY - notchR),
          radius: const Radius.circular(notchR), clockwise: false)
      ..lineTo(0, r)
      ..arcToPoint(const Offset(r, 0), radius: const Radius.circular(r))
      ..close();

    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(_TicketPainter old) =>
      old.color != color || old.borderColor != borderColor;
}

// ─────────────────────────────────────────────────────────────────────────────
// ZestProgressBar — thin lime progress bar for XP / points display
// ─────────────────────────────────────────────────────────────────────────────

class ZestProgressBar extends StatelessWidget {
  const ZestProgressBar({
    super.key,
    required this.value,
    this.height = 6.0,
    this.backgroundColor,
    this.foregroundColor = AppColors.lime,
    this.label,
  });

  final double value; // 0.0 to 1.0
  final double height;
  final Color? backgroundColor;
  final Color foregroundColor;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: AppTextStyles.caption11.copyWith(color: AppColors.grey400),
          ),
          const SizedBox(height: 4),
        ],
        ClipRRect(
          borderRadius: AppRadius.circularPill,
          child: LinearProgressIndicator(
            value: value.clamp(0.0, 1.0),
            backgroundColor:
                backgroundColor ?? AppColors.surfaceDark,
            valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
            minHeight: height,
          ),
        ),
      ],
    );
  }
}
