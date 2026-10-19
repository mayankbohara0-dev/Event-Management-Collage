import 'package:flutter/material.dart';
import '../../core/theme/zest_tokens.dart';

enum ZestStatusType { verified, pending, rejected, attended, custom }

/// ─────────────────────────────────────────────────────────────────────────────
/// STATUS PILL
/// Rounded badge showing entry/registration state with harmonious tints.
/// ─────────────────────────────────────────────────────────────────────────────

class StatusPill extends StatelessWidget {
  final String label;
  final ZestStatusType type;
  final bool isGlass;
  final Widget? icon;

  const StatusPill({
    super.key,
    required this.label,
    this.type = ZestStatusType.verified,
    this.isGlass = false,
    this.icon,
  });

  factory StatusPill.fromStatus(String status, {bool isGlass = false}) {
    final lower = status.toLowerCase();
    if (lower.contains('attend') || lower.contains('checked')) {
      return StatusPill(
        label: 'Attended ✓',
        type: ZestStatusType.attended,
        isGlass: isGlass,
      );
    } else if (lower.contains('approv') || lower.contains('verif')) {
      return StatusPill(
        label: 'Verified ✓',
        type: ZestStatusType.verified,
        isGlass: isGlass,
      );
    } else if (lower.contains('reject')) {
      return StatusPill(
        label: 'Rejected ✕',
        type: ZestStatusType.rejected,
        isGlass: isGlass,
      );
    } else {
      return StatusPill(
        label: 'Pending...',
        type: ZestStatusType.pending,
        isGlass: isGlass,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isGlass) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.22),
          borderRadius: ZestTokens.borderPill,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.4),
            width: 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              icon!,
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      );
    }

    Color bg;
    Color border;
    Color text;

    switch (type) {
      case ZestStatusType.verified:
        bg = const Color(0xFFECFDF5);
        border = const Color(0xFFA7F3D0);
        text = ZestTokens.success;
        break;

      case ZestStatusType.pending:
        bg = const Color(0xFFFEF3C7);
        border = const Color(0xFFFDE68A);
        text = const Color(0xFFD97706);
        break;

      case ZestStatusType.rejected:
        bg = const Color(0xFFFEF2F2);
        border = const Color(0xFFFECDD3);
        text = ZestTokens.danger;
        break;

      case ZestStatusType.attended:
      case ZestStatusType.custom:
        bg = const Color(0xFFE6F4FE);
        border = const Color(0xFFBAE6FD);
        text = ZestTokens.blue;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: ZestTokens.borderPill,
        border: Border.all(color: border, width: 1.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            icon!,
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: text,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
