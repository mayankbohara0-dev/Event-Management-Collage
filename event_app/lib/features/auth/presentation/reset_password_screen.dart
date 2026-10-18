import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/zest_button.dart';
import '../../../core/widgets/zest_logo.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _updatePassword() async {
    final password = _passwordController.text.trim();
    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password must be at least 6 characters', style: AppTextStyles.body14.copyWith(color: AppColors.paper)),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.circularMd),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: password),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Password updated successfully! 🎉', style: AppTextStyles.body14.copyWith(color: AppColors.ink)),
            backgroundColor: AppColors.lime,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: AppRadius.circularMd),
          ),
        );
        context.go('/');
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
                  'Set New Password',
                  style: AppTextStyles.title36.copyWith(
                    color: AppColors.paper,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose a strong password to protect your Zest account and passes.',
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
                        'NEW PASSWORD',
                        style: AppTextStyles.overline.copyWith(
                          color: AppColors.grey400,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: AppTextStyles.body15.copyWith(color: AppColors.paper),
                        decoration: InputDecoration(
                          hintText: '••••••••',
                          prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.lime, size: 20),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: AppColors.grey400,
                              size: 20,
                            ),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ZestButton(
                        label: 'Save Password & Continue 🚀',
                        variant: ZestButtonVariant.primary,
                        isLoading: _isLoading,
                        onPressed: _updatePassword,
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
