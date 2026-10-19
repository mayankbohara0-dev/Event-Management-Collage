import 'package:flutter/material.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// COUNT UP TEXT
/// Animated integer counter counting from startValue to endValue with easing.
/// ─────────────────────────────────────────────────────────────────────────────

class CountUpText extends StatefulWidget {
  final int value;
  final TextStyle? style;
  final TextStyle? textStyle;
  final Duration duration;
  final String prefix;
  final String suffix;
  final bool formatCommas;

  const CountUpText({
    super.key,
    required this.value,
    this.style,
    this.textStyle,
    this.duration = const Duration(milliseconds: 900),
    this.prefix = '',
    this.suffix = '',
    this.formatCommas = true,
  });


  @override
  State<CountUpText> createState() => _CountUpTextState();
}

class _CountUpTextState extends State<CountUpText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<int> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _animation = IntTween(begin: 0, end: widget.value).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant CountUpText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _animation = IntTween(
        begin: _animation.value,
        end: widget.value,
      ).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatNumber(int number) {
    if (!widget.formatCommas) return '$number';
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return Text(
          '${widget.prefix}${_formatNumber(_animation.value)}${widget.suffix}',
          style: widget.textStyle ?? widget.style,
        );

      },
    );
  }
}
