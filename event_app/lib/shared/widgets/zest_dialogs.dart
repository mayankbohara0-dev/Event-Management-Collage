import 'package:flutter/material.dart';
import '../../core/theme/zest_tokens.dart';
import 'zest_mascot.dart';
import 'zest_button.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// ZEST DIALOGS & BOTTOM SHEETS
/// Clean rounded modal dialogs (radius 28) and sheets with optional mascot header.
/// ─────────────────────────────────────────────────────────────────────────────

class ZestDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String? cancelText;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final bool isDestructive;
  final MascotMood? mascotMood;
  final MascotTint mascotTint;

  const ZestDialog({
    super.key,
    required this.title,
    required this.message,
    required this.confirmText,
    required this.onConfirm,
    this.cancelText,
    this.onCancel,
    this.isDestructive = false,
    this.mascotMood,
    this.mascotTint = MascotTint.blue,
  });

  static Future<T?> show<T>(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmText,
    String? cancelText,
    bool isDestructive = false,
    MascotMood? mascotMood,
    MascotTint mascotTint = MascotTint.blue,
  }) {
    return showDialog<T>(
      context: context,
      barrierColor: ZestTokens.ink.withValues(alpha: 0.4),
      builder: (context) => ZestDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText ?? 'Cancel',
        isDestructive: isDestructive,
        mascotMood: mascotMood,
        mascotTint: mascotTint,
        onConfirm: () => Navigator.of(context).pop(true as T?),
        onCancel: () => Navigator.of(context).pop(false as T?),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ZestTokens.radiusCard),
        side: const BorderSide(color: ZestTokens.line, width: 1.0),
      ),
      backgroundColor: Colors.white,
      elevation: 16,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (mascotMood != null) ...[
              ZestMascot(
                size: 70,
                mood: mascotMood!,
                tint: mascotTint,
              ),
              const SizedBox(height: 16),
            ],
            Text(
              title,
              textAlign: TextAlign.center,
              style: ZestTokens.section.copyWith(fontSize: 20),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: ZestTokens.body.copyWith(
                color: ZestTokens.ink2,
                fontSize: 14.5,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                if (cancelText != null) ...[
                  Expanded(
                    child: ZestButton(
                      text: cancelText!,
                      onPressed: onCancel ?? () => Navigator.of(context).pop(),
                      variant: ZestButtonVariant.secondary,
                      height: 48,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: ZestButton(
                    text: confirmText,
                    onPressed: onConfirm,
                    variant: isDestructive
                        ? ZestButtonVariant.danger
                        : ZestButtonVariant.primary,
                    height: 48,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ZestBottomSheet {
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    String? accentWord,
    bool isDismissible = true,
  }) {

    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      barrierColor: ZestTokens.ink.withValues(alpha: 0.45),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Pill handle
                const SizedBox(height: 12),
                Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: ZestTokens.line,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                if (title != null) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(title, style: ZestTokens.title.copyWith(fontSize: 20)),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, size: 20),
                          onPressed: () => Navigator.of(context).pop(),
                          color: ZestTokens.ink3,
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: ZestTokens.line, height: 1),
                ],
                Flexible(child: child),
              ],
            ),
          ),
        );
      },
    );
  }
}
