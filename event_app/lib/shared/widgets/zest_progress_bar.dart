import 'package:flutter/material.dart';
import '../../core/theme/zest_tokens.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// ZEST PROGRESS BAR
/// 8px pill progress bar with brandGradient that animates 0 -> value in 700ms.
/// ─────────────────────────────────────────────────────────────────────────────

class ZestProgressBar extends StatefulWidget {
  final double value; // 0.0 to 1.0
  final double height;
  final Gradient? gradient;
  final Gradient? progressGradient;
  final Color? trackColor;
  final Duration duration;

  const ZestProgressBar({
    super.key,
    required this.value,
    this.height = 8.0,
    this.gradient,
    this.progressGradient,
    this.trackColor,
    this.duration = const Duration(milliseconds: 700),
  });


  @override
  State<ZestProgressBar> createState() => _ZestProgressBarState();
}

class _ZestProgressBarState extends State<ZestProgressBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _animation = Tween<double>(
      begin: 0.0,
      end: widget.value.clamp(0.0, 1.0),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant ZestProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _controller.animateTo(
        widget.value.clamp(0.0, 1.0),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: widget.trackColor ?? ZestTokens.line,
        borderRadius: BorderRadius.circular(widget.height / 2),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              final double fillWidth =
                  constraints.maxWidth * _animation.value.clamp(0.0, 1.0);

              if (fillWidth <= 0) return const SizedBox.shrink();

              return Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: fillWidth,
                  height: widget.height,
                  decoration: BoxDecoration(
                    gradient: widget.progressGradient ??
                        widget.gradient ??
                        ZestTokens.brandGradient,
                    borderRadius: BorderRadius.circular(widget.height / 2),
                  ),

                ),
              );
            },
          );
        },
      ),
    );
  }
}
