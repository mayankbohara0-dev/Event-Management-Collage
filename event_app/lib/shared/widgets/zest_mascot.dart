import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/zest_tokens.dart';

enum MascotTint { blue, lemon, coral, lavender, mint, aqua }
enum MascotMood { idle, happy, sleepy, celebrate }

typedef ZestMascotMood = MascotMood;
typedef ZestMascotTint = MascotTint;

/// ─────────────────────────────────────────────────────────────────────────────
/// ZEST MASCOT
/// Playful living character (the lemon blob without the squircle).
/// Supports random eye blinks, subtle idle bobbing, color tints, and moods.
/// ─────────────────────────────────────────────────────────────────────────────

class ZestMascot extends StatefulWidget {
  final double size;
  final MascotTint tint;
  final MascotMood mood;
  final VoidCallback? onTap;

  const ZestMascot({
    super.key,
    this.size = 80.0,
    this.tint = MascotTint.blue,
    this.mood = MascotMood.idle,
    this.onTap,
  });

  @override
  State<ZestMascot> createState() => _ZestMascotState();
}

class _ZestMascotState extends State<ZestMascot>
    with TickerProviderStateMixin {
  late final AnimationController _bobController;
  late final Animation<double> _bobAnimation;

  late final AnimationController _blinkController;
  Timer? _blinkTimer;

  bool _isSquished = false;

  @override
  void initState() {
    super.initState();

    // Idle vertical breathing / bobbing
    _bobController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _bobAnimation = Tween<double>(begin: 0.0, end: -6.0).animate(
      CurvedAnimation(parent: _bobController, curve: Curves.easeInOut),
    );

    // Eye blinking controller (120ms blink)
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
    );

    _scheduleNextBlink();
  }

  void _scheduleNextBlink() {
    _blinkTimer?.cancel();
    if (!mounted) return;

    final int nextBlinkMs = 2800 + math.Random().nextInt(2400); // 2.8 - 5.2s
    _blinkTimer = Timer(Duration(milliseconds: nextBlinkMs), () {
      if (!mounted) return;
      if (widget.mood == MascotMood.idle) {
        _blinkController.forward().then((_) {
          if (mounted) {
            _blinkController.reverse().then((_) {
              _scheduleNextBlink();
            });
          }
        });
      } else {
        _scheduleNextBlink();
      }
    });
  }

  @override
  void dispose() {
    _bobController.dispose();
    _blinkController.dispose();
    _blinkTimer?.cancel();
    super.dispose();
  }

  Color _getTintFill(MascotTint tint) {
    switch (tint) {
      case MascotTint.blue:
        return ZestTokens.core;
      case MascotTint.lemon:
        return ZestTokens.lemon;
      case MascotTint.coral:
        return ZestTokens.coral;
      case MascotTint.lavender:
        return ZestTokens.lavender;
      case MascotTint.mint:
        return ZestTokens.mint;
      case MascotTint.aqua:
        return ZestTokens.aqua;
    }
  }

  Color _getTintGlow(MascotTint tint) {
    switch (tint) {
      case MascotTint.blue:
        return ZestTokens.sky;
      case MascotTint.lemon:
        return const Color(0xFFFDE047);
      case MascotTint.coral:
        return const Color(0xFFFDA4AF);
      case MascotTint.lavender:
        return const Color(0xFFC7D2FE);
      case MascotTint.mint:
        return const Color(0xFF6EE7B7);
      case MascotTint.aqua:
        return const Color(0xFFBAE6FD);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fillColor = _getTintFill(widget.tint);
    final glowColor = _getTintGlow(widget.tint);

    final mascotWidget = AnimatedBuilder(
      animation: Listenable.merge([_bobController, _blinkController]),
      builder: (context, child) {
        final double bobY = (widget.mood == MascotMood.celebrate)
            ? math.sin(_bobController.value * math.pi * 2) * -12.0
            : _bobAnimation.value;

        return Transform.translate(
          offset: Offset(0, bobY),
          child: Transform.scale(
            scale: _isSquished ? 0.92 : 1.0,
            child: SizedBox(
              width: widget.size,
              height: widget.size,
              child: CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _ZestMascotPainter(
                  fillColor: fillColor,
                  glowColor: glowColor,
                  mood: widget.mood,
                  blinkProgress: _blinkController.value,
                ),
              ),
            ),
          ),
        );
      },
    );

    if (widget.onTap != null) {
      return GestureDetector(
        onTapDown: (_) => setState(() => _isSquished = true),
        onTapUp: (_) {
          setState(() => _isSquished = false);
          widget.onTap?.call();
        },
        onTapCancel: () => setState(() => _isSquished = false),
        child: mascotWidget,
      );
    }

    return mascotWidget;
  }
}

class _ZestMascotPainter extends CustomPainter {
  final Color fillColor;
  final Color glowColor;
  final MascotMood mood;
  final double blinkProgress;

  _ZestMascotPainter({
    required this.fillColor,
    required this.glowColor,
    required this.mood,
    required this.blinkProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double s = size.width;
    // Map coordinate system based on 160 width
    final double scale = s / 140.0;

    // Shift lemon to center of canvas
    canvas.save();
    canvas.translate(size.width * 0.08, size.height * 0.05);

    // 1. Soft atmospheric glow layer
    final Paint glowPaint = Paint()
      ..color = glowColor.withValues(alpha: 0.35)
      ..style = PaintingStyle.fill
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 6.0 * scale);

    _drawLemon(canvas, scale, glowPaint);

    // 2. White outline edge for crisp pop
    final Paint edgePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5 * scale
      ..strokeJoin = StrokeJoin.round;
    _drawLemon(canvas, scale, edgePaint);

    // 3. Crisp Body
    final Paint bodyPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    _drawLemon(canvas, scale, bodyPaint);

    // 4. Leaf
    canvas.save();
    final Offset leafCenter = Offset(84.0 * scale, 38.0 * scale);
    canvas.translate(leafCenter.dx, leafCenter.dy);
    canvas.rotate(-30.0 * math.pi / 180.0);
    final Paint leafPaint = Paint()..color = Colors.white;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset.zero,
        width: 24.0 * scale,
        height: 11.0 * scale,
      ),
      leafPaint,
    );
    canvas.restore();

    // 5. Mascot Eyes based on Mood
    _drawEyes(canvas, scale);

    canvas.restore();
  }

  void _drawLemon(Canvas canvas, double scale, Paint paint) {
    canvas.save();
    final Offset center = Offset(72.0 * scale, 75.0 * scale);
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-18.0 * math.pi / 180.0);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset.zero,
        width: 80.0 * scale,
        height: 58.0 * scale,
      ),
      paint,
    );
    canvas.restore();

    canvas.drawCircle(Offset(108.0 * scale, 63.0 * scale), 8.0 * scale, paint);
    canvas.drawCircle(Offset(36.0 * scale, 87.0 * scale), 8.0 * scale, paint);
  }

  void _drawEyes(Canvas canvas, double scale) {
    final Offset leftEye = Offset(62.0 * scale, 76.0 * scale);
    final Offset rightEye = Offset(86.0 * scale, 70.0 * scale);

    switch (mood) {
      case MascotMood.happy:
      case MascotMood.celebrate:
        // Squint happy arcs (curved smiling eyes)
        final Paint arcPaint = Paint()
          ..color = const Color(0xFF0B1220)
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 2.8 * scale;

        _drawHappyArc(canvas, leftEye, scale, arcPaint);
        _drawHappyArc(canvas, rightEye, scale, arcPaint);

        if (mood == MascotMood.celebrate) {
          _drawSparkles(canvas, scale);
        }
        break;

      case MascotMood.sleepy:
        // Closed flat horizontal lines
        final Paint sleepPaint = Paint()
          ..color = const Color(0xFF0B1220)
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 2.5 * scale;

        canvas.drawLine(
          leftEye - Offset(6 * scale, 0),
          leftEye + Offset(6 * scale, 0),
          sleepPaint,
        );
        canvas.drawLine(
          rightEye - Offset(6 * scale, 0),
          rightEye + Offset(6 * scale, 0),
          sleepPaint,
        );
        break;

      case MascotMood.idle:
        // Normal tilted gradient eyes with blink
        final double blinkScale = 1.0 - (0.88 * blinkProgress);
        _drawNormalEye(canvas, leftEye, scale, blinkScale);
        _drawNormalEye(canvas, rightEye, scale, blinkScale);
        break;
    }
  }

  void _drawHappyArc(Canvas canvas, Offset center, double scale, Paint paint) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-6.0 * math.pi / 180.0);
    final Path path = Path()
      ..moveTo(-6.0 * scale, 2.0 * scale)
      ..quadraticBezierTo(0, -6.0 * scale, 6.0 * scale, 2.0 * scale);
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  void _drawNormalEye(Canvas canvas, Offset center, double scale, double blink) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-8.0 * math.pi / 180.0);

    final double w = 12.0 * scale;
    final double h = 18.0 * scale * blink;
    final Rect rect = Rect.fromCenter(center: Offset.zero, width: w, height: h);

    final Paint eyePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.white, Color(0xFFA9DBFF)],
      ).createShader(rect);

    canvas.drawOval(rect, eyePaint);

    // Eye outline
    final Paint outlinePaint = Paint()
      ..color = const Color(0xFF0B1220)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0 * scale;
    canvas.drawOval(rect, outlinePaint);

    // Pupil
    if (blink > 0.5) {
      final Paint pupilPaint = Paint()..color = const Color(0xFF0B1220);
      canvas.drawCircle(Offset(1.0 * scale, 0.5 * scale), 2.2 * scale, pupilPaint);
    }

    canvas.restore();
  }

  void _drawSparkles(Canvas canvas, double scale) {
    final Paint starPaint = Paint()..color = const Color(0xFFFFD84D);
    canvas.drawCircle(Offset(106.0 * scale, 30.0 * scale), 2.5 * scale, starPaint);
    canvas.drawCircle(Offset(24.0 * scale, 50.0 * scale), 2.0 * scale, starPaint);
  }

  @override
  bool shouldRepaint(covariant _ZestMascotPainter oldDelegate) {
    return oldDelegate.fillColor != fillColor ||
        oldDelegate.mood != mood ||
        oldDelegate.blinkProgress != blinkProgress;
  }
}
