import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/theme.dart';
import '../../../shared/widgets/shared_widgets.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String email;
  const EmailVerificationScreen({super.key, required this.email});

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool _isResending = false;
  int _countdown = 30;
  Timer? _countdownTimer;
  bool _canResend = false;
  final bool _isVerified = false;

  @override



  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    setState(() {
      _countdown = 30;
      _canResend = false;
    });
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 1) {
        if (mounted) setState(() => _countdown--);
      } else {
        timer.cancel();
        if (mounted) setState(() => _canResend = true);
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _resendEmail() async {
    if (!_canResend || _isResending) return;

    setState(() => _isResending = true);
    try {
      await Supabase.instance.client.auth.resend(
        type: OtpType.signup,
        email: widget.email,
      );
      if (mounted) {
        ZestSnack.success(context, 'Verification email resent! Check your inbox.');
        _startCountdown();
      }
    } on AuthException catch (e) {
      if (mounted) {
        ZestSnack.error(context, e.message);
      }
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZestTokens.page,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => context.go('/student/login'),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: ZestCard(
              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Centered mascot: sleepy -> happy when verified
                  ZestMascot(
                    size: 90,
                    tint: MascotTint.lemon,
                    mood: _isVerified ? MascotMood.happy : MascotMood.sleepy,
                  ),
                  const SizedBox(height: 22),

                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: ZestTokens.display.copyWith(fontSize: 28),
                      children: [
                        const TextSpan(text: 'Verify your '),
                        TextSpan(
                          text: 'email',
                          style: ZestTokens.accentItalic.copyWith(fontSize: 34),
                        ),
                        const TextSpan(text: '.'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  Text(
                    'We sent a verification link to:',
                    style: ZestTokens.body.copyWith(color: ZestTokens.ink2),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: ZestTokens.fill,
                      borderRadius: ZestTokens.borderPill,
                    ),
                    child: Text(
                      widget.email,
                      style: ZestTokens.bodyBold.copyWith(
                        color: ZestTokens.blue,
                        fontSize: 14,
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),
                  Text(
                    'Please click the link in your email to activate your account and start claiming event passes.',
                    textAlign: TextAlign.center,
                    style: ZestTokens.caption.copyWith(
                      color: ZestTokens.ink3,
                      height: 1.45,
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Resend Button with 30s countdown ring
                  ZestButton(
                    text: _isResending
                        ? 'Resending...'
                        : _canResend
                            ? 'Resend Verification Email'
                            : 'Resend in $_countdown s',
                    variant: ZestButtonVariant.primary,
                    fullWidth: true,
                    isLoading: _isResending,
                    onPressed: _canResend ? _resendEmail : null,
                  ),

                  const SizedBox(height: 14),

                  ZestButton(
                    text: 'Back to Sign In',
                    variant: ZestButtonVariant.ghost,
                    fullWidth: true,
                    onPressed: () => context.go('/student/login'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
