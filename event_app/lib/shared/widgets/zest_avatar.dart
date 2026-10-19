import 'package:flutter/material.dart';
import '../../core/theme/zest_tokens.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// ZEST AVATAR
/// Clean circular avatar with optional brand gradient ring, camera badge, and initials fallback.
/// ─────────────────────────────────────────────────────────────────────────────

class ZestAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final double radius;
  final double? size;
  final bool hasGradientRing;
  final bool isEditable;
  final VoidCallback? onTap;
  final VoidCallback? onCameraTap;

  const ZestAvatar({
    super.key,
    this.imageUrl,
    this.name,
    this.radius = 24.0,
    this.size,
    this.hasGradientRing = false,
    this.isEditable = false,
    this.onTap,
    this.onCameraTap,
  });

  String _getInitials(String? text) {
    if (text == null || text.trim().isEmpty) return '?';
    final parts = text.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final double effectiveRadius = size != null ? size! / 2 : radius;
    final double diameter = effectiveRadius * 2;

    final initials = _getInitials(name);

    Widget avatarContent;
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      avatarContent = ClipOval(
        child: Image.network(
          imageUrl!,
          width: diameter,
          height: diameter,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _buildInitials(diameter, initials),
        ),
      );
    } else {
      avatarContent = _buildInitials(diameter, initials);
    }

    Widget content = avatarContent;

    if (hasGradientRing) {
      content = Container(
        padding: const EdgeInsets.all(3.0),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: ZestTokens.brandGradient,
        ),
        child: Container(
          padding: const EdgeInsets.all(2.0),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          child: avatarContent,
        ),
      );
    }

    if (isEditable) {
      content = Stack(
        clipBehavior: Clip.none,
        children: [
          content,
          Positioned(
            right: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: onCameraTap ?? onTap,
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.all(6.0),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: ZestTokens.brandGradient,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x330063F0),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),

        ],
      );
    }

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: content,
      );
    }

    return content;
  }

  Widget _buildInitials(double size, String initials) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFE6F4FE),
      ),
      child: Center(
        child: Text(
          initials,
          style: ZestTokens.title.copyWith(
            color: ZestTokens.blue,
            fontSize: size * 0.38,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
