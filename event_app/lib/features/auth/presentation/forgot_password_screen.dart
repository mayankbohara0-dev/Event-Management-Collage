import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/zest_button.dart';
import '../../../core/widgets/zest_logo.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a valid email address.', style: AppTextStyles.body14.copyWith(color: AppColors.paper)),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.circularMd),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(
        email,
        redirectTo: 'http://localhost:8080/#/auth/reset-password',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Check your email for the reset link!', style: AppTextStyles.body14.copyWith(color: AppColors.ink)),
            backgroundColor: AppColors.lime,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: AppRadius.circularMd),
          ),
        );
        context.go('/student/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed: $e', style: AppTextStyles.body14.copyWith(color: AppColors.paper)),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: AppRadius.circularMd),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.paper, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const ZestLogo.markSmall(size: 48),
                const SizedBox(height: 24),
                Text(
                  'Reset Password',
                  style: AppTextStyles.title36.copyWith(
                    color: AppColors.paper,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter your registered student email and we\'ll send you a secure link to reset your credentials.',
                  style: AppTextStyles.body15.copyWith(color: AppColors.grey400),
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCard,
                    borderRadius: AppRadius.circularCardLarge,
                    border: Border.all(color: AppColors.borderDark, width: 1.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'COLLEGE EMAIL',
                        style: AppTextStyles.overline.copyWith(
                          color: AppColors.grey400,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: AppTextStyles.body15.copyWith(color: AppColors.paper),
                        decoration: InputDecoration(
                          hintText: 'student@college.edu',
                          prefixIcon: const Icon(Icons.alternate_email_rounded, color: AppColors.lime, size: 20),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ZestButton(
                        label: 'Send Reset Link 📩',
                        variant: ZestButtonVariant.primary,
                        isLoading: _isLoading,
                        onPressed: _resetPassword,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
