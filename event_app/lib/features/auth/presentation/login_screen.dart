import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/zest_button.dart';
import '../../../core/widgets/zest_logo.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isSignUp = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please fill in both email and password.',
            style: AppTextStyles.body14.copyWith(color: AppColors.paper),
          ),
          backgroundColor: AppColors.surfaceDark,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.circularMd),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      if (_isSignUp) {
        final res = await Supabase.instance.client.auth.signUp(
          email: email,
          password: password,
        );
        if (mounted) {
          if (res.session != null) {
            context.go('/student/onboarding');
          } else {
            context.go(
              '/auth/verify-email',
              extra: email,
            );
          }
        }
      } else {
        final res = await Supabase.instance.client.auth.signInWithPassword(
          email: email,
          password: password,
        );
        if (mounted && res.user != null) {
          final profile = await Supabase.instance.client
              .from('student_profiles')
              .select('id, name')
              .eq('id', res.user!.id)
              .maybeSingle();
          if (mounted) {
            if (profile != null &&
                (profile['name'] ?? '').toString().isNotEmpty) {
              context.go('/student/home');
            } else {
              context.go('/student/onboarding');
            }
          }
        }
      }
    } on AuthException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error.message,
              style: AppTextStyles.body14.copyWith(color: AppColors.paper),
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: AppRadius.circularMd),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error.toString(),
              style: AppTextStyles.body14.copyWith(color: AppColors.paper),
            ),
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

  void _toggleMode(bool signUp) {
    if (_isSignUp != signUp) {
      setState(() => _isSignUp = signUp);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink,
      body: SafeArea(
        child: Stack(
          children: [
            // Watermark Z top right
            Positioned(
              top: -40,
              right: -50,
              child: ZestLogo.watermark(
                size: 260,
                color: AppColors.surfaceCard.withValues(alpha: 0.45),
              ),
            ),

            Column(
              children: [
                // ── Top Navigation Bar ─────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => context.go('/'),
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
                      const SizedBox(width: 44), // Balances the back button
                    ],
                  ),
                ),

                // ── Scrollable Form Area ───────────────────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 12),

                        // Animated Headline
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Column(
                            key: ValueKey<bool>(_isSignUp),
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _isSignUp ? 'Join the squad 🎉' : 'Welcome back! 👋',
                                style: AppTextStyles.title36.copyWith(
                                  color: AppColors.paper,
                                  height: 1.1,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _isSignUp
                                    ? 'Fresh campus events, squeezed daily. ⚡'
                                    : 'Sign in to access tickets, passes & leaderboard.',
                                style: AppTextStyles.body15.copyWith(
                                  color: AppColors.grey400,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Mode Selector Pills
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceDark,
                            borderRadius: AppRadius.circularPill,
                            border: Border.all(color: AppColors.borderDark, width: 1),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => _toggleMode(false),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      color: !_isSignUp ? AppColors.lime : Colors.transparent,
                                      borderRadius: AppRadius.circularPill,
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Sign In',
                                        style: AppTextStyles.buttonSmall.copyWith(
                                          color: !_isSignUp ? AppColors.ink : AppColors.grey400,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => _toggleMode(true),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      color: _isSignUp ? AppColors.lime : Colors.transparent,
                                      borderRadius: AppRadius.circularPill,
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Create Account',
                                        style: AppTextStyles.buttonSmall.copyWith(
                                          color: _isSignUp ? AppColors.ink : AppColors.grey400,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Form Bento Card
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
                              // Email Input
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
                                textInputAction: TextInputAction.next,
                                style: AppTextStyles.body15.copyWith(color: AppColors.paper),
                                decoration: InputDecoration(
                                  hintText: 'student@college.edu',
                                  prefixIcon: const Icon(Icons.alternate_email_rounded, color: AppColors.lime, size: 20),
                                ),
                              ),

                              const SizedBox(height: 20),

                              // Password Input
                              Text(
                                'PASSWORD',
                                style: AppTextStyles.overline.copyWith(
                                  color: AppColors.grey400,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                textInputAction: TextInputAction.done,
                                onSubmitted: (_) => _submit(),
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

                              // Forgot password link (Sign in only)
                              if (!_isSignUp) ...[
                                const SizedBox(height: 12),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: GestureDetector(
                                    onTap: () => context.push('/auth/forgot-password'),
                                    child: Text(
                                      'Forgot password?',
                                      style: AppTextStyles.label13.copyWith(
                                        color: AppColors.lime,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ],

                              const SizedBox(height: 28),

                              // Primary Submit Button
                              ZestButton(
                                label: _isSignUp ? 'Create Student Account 🚀' : 'Sign In ⚡',
                                variant: ZestButtonVariant.primary,
                                isLoading: _isLoading,
                                onPressed: _submit,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Switch mode footer
                        Center(
                          child: GestureDetector(
                            onTap: () => _toggleMode(!_isSignUp),
                            child: RichText(
                              text: TextSpan(
                                style: AppTextStyles.body14.copyWith(color: AppColors.grey400),
                                children: [
                                  TextSpan(
                                    text: _isSignUp ? 'Already registered? ' : "New student? ",
                                  ),
                                  TextSpan(
                                    text: _isSignUp ? 'Sign In' : 'Create an account',
                                    style: TextStyle(
                                      color: AppColors.lime,
                                      fontWeight: FontWeight.w800,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
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
