import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/zest_tokens.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// ZEST BLOB LOGO
/// Pure CustomPainter vector rendering matching the exact brand geometry:
/// Sky-to-blue gradient squircle, white glow edge, core #0AA5F0 lemon,
/// white leaf, and tilted eyes with white-to-blue gradient.
/// ─────────────────────────────────────────────────────────────────────────────

class ZestBlobLogo extends StatefulWidget {
  final double size;
  final bool animateOnLoad;

  const ZestBlobLogo({
    super.key,
    this.size = 40.0,
    this.animateOnLoad = false,
  });

  @override
  State<ZestBlobLogo> createState() => _ZestBlobLogoState();
}

class _ZestBlobLogoState extends State<ZestBlobLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _blinkAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.6, end: 1.05)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.05, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 40,
      ),
    ]).animate(_controller);

    _blinkAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween<double>(1.0), weight: 80),
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 0.1), weight: 10),
      TweenSequenceItem(tween: Tween<double>(begin: 0.1, end: 1.0), weight: 10),
    ]).animate(_controller);

    if (widget.animateOnLoad) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.animateOnLoad) {
      return SizedBox(
        width: widget.size,
        height: widget.size,
        child: CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _ZestBlobLogoPainter(blinkScale: 1.0),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: CustomPaint(
              size: Size(widget.size, widget.size),
              painter: _ZestBlobLogoPainter(blinkScale: _blinkAnimation.value),
            ),
          ),
        );
      },
    );
  }
}

class _ZestBlobLogoPainter extends CustomPainter {
  final double blinkScale;

  _ZestBlobLogoPainter({required this.blinkScale});

  @override
  void paint(Canvas canvas, Size size) {
    final double s = size.width;
    final double scale = s / 160.0;

    // 1. Squircle background (radius .24 * size = 38.4 / 160)
    final RRect squircle = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, s, s),
      Radius.circular(38.0 * scale),
    );

    final Paint bgPaint = Paint()
      ..shader = ZestTokens.brandGradient.createShader(
        Rect.fromLTWH(0, 0, s, s),
      );
    canvas.drawRRect(squircle, bgPaint);

    // 2. Layer 1: White Glow Edge (stroke .15 * s, blur 1.2)
    final Paint glowEdgePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 24.0 * scale
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 1.2 * scale);

    final Paint glowEdgeFill = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 1.2 * scale);

    _drawLemonGroup(canvas, scale, glowEdgeFill);
    _drawLemonGroup(canvas, scale, glowEdgePaint);

    // 3. Layer 2: Core Glow (#0AA5F0, stroke width 8, blur 5.5)
    final Paint coreGlowPaint = Paint()
      ..color = ZestTokens.core
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0 * scale
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 5.5 * scale);

    final Paint coreGlowFill = Paint()
      ..color = ZestTokens.core
      ..style = PaintingStyle.fill
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 5.5 * scale);

    _drawLemonGroup(canvas, scale, coreGlowFill);
    _drawLemonGroup(canvas, scale, coreGlowPaint);

    // 4. Solid Crisp Lemon Body
    final Paint solidLemonPaint = Paint()
      ..color = ZestTokens.core
      ..style = PaintingStyle.fill;
    _drawLemonGroup(canvas, scale, solidLemonPaint);

    // 5. White Leaf (cx 90, cy 45, rx 13, ry 6, rotate -30)
    canvas.save();
    final Offset leafCenter = Offset(90.0 * scale, 45.0 * scale);
    canvas.translate(leafCenter.dx, leafCenter.dy);
    canvas.rotate(-30.0 * math.pi / 180.0);
    final Paint leafPaint = Paint()..color = Colors.white;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset.zero,
        width: 26.0 * scale,
        height: 12.0 * scale,
      ),
      leafPaint,
    );
    canvas.restore();

    // 6. Eyes: Left (68, 85), Right (93, 79), rx 6.5, ry 10, rotate -8
    _drawEye(canvas, Offset(68.0 * scale, 85.0 * scale), scale, blinkScale);
    _drawEye(canvas, Offset(93.0 * scale, 79.0 * scale), scale, blinkScale);
  }

  void _drawLemonGroup(Canvas canvas, double scale, Paint paint) {
    // Rotated ellipse: cx 80, cy 84, rx 42, ry 31, rotate -18
    canvas.save();
    final Offset center = Offset(80.0 * scale, 84.0 * scale);
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-18.0 * math.pi / 180.0);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset.zero,
        width: 84.0 * scale,
        height: 62.0 * scale,
      ),
      paint,
    );
    canvas.restore();

    // End nubs: circles at (118, 71) r=8.5 and (42, 97) r=8.5
    canvas.drawCircle(Offset(118.0 * scale, 71.0 * scale), 8.5 * scale, paint);
    canvas.drawCircle(Offset(42.0 * scale, 97.0 * scale), 8.5 * scale, paint);
  }

  void _drawEye(Canvas canvas, Offset center, double scale, double blink) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-8.0 * math.pi / 180.0);

    final double eyeWidth = 13.0 * scale;
    final double eyeHeight = 20.0 * scale * blink;

    final Rect eyeRect = Rect.fromCenter(
      center: Offset.zero,
      width: eyeWidth,
      height: eyeHeight,
    );

    // Eye gradient: white -> #A9DBFF
    final Paint eyePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.white, Color(0xFFA9DBFF)],
      ).createShader(eyeRect);

    canvas.drawOval(eyeRect, eyePaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ZestBlobLogoPainter oldDelegate) {
    return oldDelegate.blinkScale != blinkScale;
  }
}
