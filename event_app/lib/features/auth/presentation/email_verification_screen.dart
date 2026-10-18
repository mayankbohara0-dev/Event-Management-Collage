import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/zest_button.dart';
import '../../../core/widgets/zest_logo.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String email;
  const EmailVerificationScreen({super.key, required this.email});

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool _isResending = false;
  bool _resentSuccess = false;

  Future<void> _resendEmail() async {
    setState(() {
      _isResending = true;
      _resentSuccess = false;
    });
    try {
      await Supabase.instance.client.auth.resend(
        type: OtpType.signup,
        email: widget.email,
      );
      if (mounted) setState(() => _resentSuccess = true);
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message, style: AppTextStyles.body14.copyWith(color: AppColors.paper)),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: AppRadius.circularMd),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink,
      body: SafeArea(
        child: Column(
          children: [
            // Top Nav
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => context.go('/student/login'),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceCard,
                        borderRadius: AppRadius.circularSm,
                        border: Border.all(color: AppColors.borderDark, width: 1),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: AppColors.paper,
                        size: 18,
                      ),
                    ),
                  ),
                  const ZestLogo.lockup(height: 32, isDarkBg: true),
                  const SizedBox(width: 44),
                ],
              ),
            ),

            // Content
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceCard,
                        borderRadius: AppRadius.circularCardLarge,
                        border: Border.all(color: AppColors.borderDark, width: 1.5),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Verification Badge Icon
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceDark,
                              borderRadius: AppRadius.circularHeroCard,
                              border: Border.all(color: AppColors.lime, width: 2),
                            ),
                            child: const Icon(
                              Icons.mark_email_unread_rounded,
                              size: 40,
                              color: AppColors.lime,
                            ),
                          ),
                          const SizedBox(height: 24),

                          Text(
                            'Check your inbox!',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.title32.copyWith(color: AppColors.paper),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'We sent an activation link to:',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.body14.copyWith(color: AppColors.grey400),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceDark,
                              borderRadius: AppRadius.circularPill,
                              border: Border.all(color: AppColors.borderDark),
                            ),
                            child: Text(
                              widget.email,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.label14Bold.copyWith(color: AppColors.lime),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Tap the verification link in your college mailbox to activate your student pass, then sign in below.',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.body14.copyWith(color: AppColors.grey400, height: 1.5),
                          ),

                          if (_resentSuccess) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.lime.withValues(alpha: 0.15),
                                borderRadius: AppRadius.circularPill,
                                border: Border.all(color: AppColors.lime.withValues(alpha: 0.3)),
                              ),
                              child: Text(
                                '✓ Fresh email sent!',
                                style: AppTextStyles.caption12.copyWith(color: AppColors.lime, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],

                          const SizedBox(height: 32),

                          // I've verified button
                          ZestButton(
                            label: "I've Verified — Sign In ⚡",
                            variant: ZestButtonVariant.primary,
                            onPressed: () => context.go('/student/login'),
                          ),
                          const SizedBox(height: 12),

                          // Resend button
                          ZestButton(
                            label: _isResending ? 'Sending...' : 'Resend Email 🔄',
                            variant: ZestButtonVariant.ghost,
                            isLoading: _isResending,
                            onPressed: _resendEmail,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
