import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/zest_tokens.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// ZEST TEXT FIELD
/// Fill (#EEF2F8) background, radius 16, 1.5px core focus border with soft glow,
/// and error shake animation.
/// ─────────────────────────────────────────────────────────────────────────────

class ZestTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hintText;
  final dynamic prefixIcon;
  final dynamic suffixIcon;
  final bool isPassword;
  final bool autofocus;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FormFieldValidator<String>? validator;
  final String? errorText;
  final int maxLines;
  final bool enabled;


  const ZestTextField({
    super.key,
    this.controller,
    this.label,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.isPassword = false,
    this.autofocus = false,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.errorText,
    this.maxLines = 1,
    this.enabled = true,
  });

  @override
  State<ZestTextField> createState() => _ZestTextFieldState();
}

class _ZestTextFieldState extends State<ZestTextField>
    with SingleTickerProviderStateMixin {
  late final FocusNode _focusNode;
  bool _isFocused = false;
  bool _obscureText = true;

  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;

  Widget? _resolveIcon(dynamic icon, Color defaultColor) {
    if (icon == null) return null;
    if (icon is Widget) return icon;
    if (icon is IconData) return Icon(icon, size: 20, color: defaultColor);
    return null;
  }

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _shakeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut),
    );

    if (widget.errorText != null && widget.errorText!.isNotEmpty) {
      _shakeController.forward();
    }
  }

  @override
  void didUpdateWidget(covariant ZestTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.errorText != null &&
        widget.errorText!.isNotEmpty &&
        widget.errorText != oldWidget.errorText) {
      _shakeController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Padding(
            padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
            child: Text(
              widget.label!,
              style: ZestTokens.caption.copyWith(
                fontWeight: FontWeight.w600,
                color: ZestTokens.ink,
              ),
            ),
          ),
        ],

        // Input container with shake animation
        AnimatedBuilder(
          animation: _shakeAnimation,
          builder: (context, child) {
            final double offset = hasError
                ? math.sin(_shakeAnimation.value * math.pi * 4) * 6.0
                : 0.0;
            return Transform.translate(
              offset: Offset(offset, 0),
              child: child,
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: widget.enabled ? ZestTokens.fill : const Color(0xFFF1F5F9),
              borderRadius: ZestTokens.borderInput,
              border: Border.all(
                color: hasError
                    ? ZestTokens.danger
                    : _isFocused
                        ? ZestTokens.core
                        : ZestTokens.line,
                width: _isFocused ? 1.5 : 1.0,
              ),
              boxShadow: _isFocused && !hasError
                  ? [
                      BoxShadow(
                        color: ZestTokens.core.withValues(alpha: 0.16),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: TextFormField(
              controller: widget.controller,
              focusNode: _focusNode,
              autofocus: widget.autofocus,
              enabled: widget.enabled,
              obscureText: widget.isPassword && _obscureText,
              keyboardType: widget.keyboardType,
              textInputAction: widget.textInputAction,
              onChanged: widget.onChanged,
              onFieldSubmitted: widget.onSubmitted,
              validator: widget.validator,
              maxLines: widget.isPassword ? 1 : widget.maxLines,
              style: ZestTokens.body.copyWith(color: ZestTokens.ink),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: ZestTokens.body.copyWith(color: ZestTokens.ink3),
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 16,
                ),
                prefixIcon: _resolveIcon(
                  widget.prefixIcon,
                  _isFocused ? ZestTokens.blue : ZestTokens.ink3,
                ) != null
                    ? Padding(
                        padding: const EdgeInsets.only(left: 14, right: 10),
                        child: _resolveIcon(
                          widget.prefixIcon,
                          _isFocused ? ZestTokens.blue : ZestTokens.ink3,
                        ),
                      )
                    : null,
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 42,
                  minHeight: 24,
                ),
                suffixIcon: widget.isPassword
                    ? IconButton(
                        icon: AnimatedRotation(
                          turns: _obscureText ? 0 : 0.5,
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            _obscureText
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: ZestTokens.ink3,
                            size: 20,
                          ),
                        ),
                        onPressed: () =>
                            setState(() => _obscureText = !_obscureText),
                      )
                    : _resolveIcon(
                        widget.suffixIcon,
                        _isFocused ? ZestTokens.blue : ZestTokens.ink3,
                      ),
              ),
            ),
          ),
        ),


        if (hasError) ...[
          Padding(
            padding: const EdgeInsets.only(left: 6.0, top: 6.0),
            child: Text(
              widget.errorText!,
              style: ZestTokens.caption.copyWith(
                color: ZestTokens.danger,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
