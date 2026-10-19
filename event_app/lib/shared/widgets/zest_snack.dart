import 'package:flutter/material.dart';
import '../../core/theme/zest_tokens.dart';

enum ZestSnackType { info, success, warning, error }

/// ─────────────────────────────────────────────────────────────────────────────
/// ZEST SNACK
/// Floating top pill toast with icon and soft shadow (instead of heavy bottom bar).
/// ─────────────────────────────────────────────────────────────────────────────

class ZestSnack {
  static void show(
    BuildContext context, {
    required String message,
    ZestSnackType type = ZestSnackType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => _TopSnackWidget(
        message: message,
        type: type,
        onDismiss: () => entry.remove(),
        duration: duration,
      ),
    );

    overlay.insert(entry);
  }

  static void success(BuildContext context, String message) {
    show(context, message: message, type: ZestSnackType.success);
  }

  static void warning(BuildContext context, String message) {
    show(context, message: message, type: ZestSnackType.warning);
  }

  static void error(BuildContext context, String message) {
    show(context, message: message, type: ZestSnackType.error);
  }

  static void info(BuildContext context, String message) {
    show(context, message: message, type: ZestSnackType.info);
  }
}


class _TopSnackWidget extends StatefulWidget {
  final String message;
  final ZestSnackType type;
  final VoidCallback onDismiss;
  final Duration duration;

  const _TopSnackWidget({
    required this.message,
    required this.type,
    required this.onDismiss,
    required this.duration,
  });

  @override
  State<_TopSnackWidget> createState() => _TopSnackWidgetState();
}

class _TopSnackWidgetState extends State<_TopSnackWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _offsetAnimation;
  late final Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, -1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();

    Future.delayed(widget.duration, () {
      if (mounted) {
        _controller.reverse().then((_) {
          widget.onDismiss();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top + 12.0;

    Color iconBg;
    Color iconColor;
    IconData icon;

    switch (widget.type) {
      case ZestSnackType.success:
        iconBg = const Color(0xFFECFDF5);
        iconColor = ZestTokens.success;
        icon = Icons.check_circle_rounded;
        break;
      case ZestSnackType.warning:
        iconBg = const Color(0xFFFFFBEB);
        iconColor = const Color(0xFFF59E0B);
        icon = Icons.warning_amber_rounded;
        break;
      case ZestSnackType.error:
        iconBg = const Color(0xFFFEF2F2);
        iconColor = ZestTokens.danger;
        icon = Icons.error_rounded;
        break;
      case ZestSnackType.info:
        iconBg = const Color(0xFFE6F4FE);
        iconColor = ZestTokens.blue;
        icon = Icons.info_rounded;
        break;
    }


    return Positioned(
      top: topPadding,
      left: 20,
      right: 20,
      child: Material(
        color: Colors.transparent,
        child: SlideTransition(
          position: _offsetAnimation,
          child: FadeTransition(
            opacity: _opacityAnimation,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: ZestTokens.borderPill,
                  border: Border.all(color: ZestTokens.line, width: 1.0),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1F0B1220),
                      blurRadius: 24,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: iconBg,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: iconColor, size: 16),
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        widget.message,
                        style: ZestTokens.bodyBold.copyWith(
                          fontSize: 13.5,
                          color: ZestTokens.ink,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
