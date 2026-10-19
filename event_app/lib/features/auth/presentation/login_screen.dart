import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/theme.dart';
import '../../../shared/widgets/shared_widgets.dart';

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
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Please enter both email and password.');
      ZestSnack.error(context, 'Please enter both email and password.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_isSignUp) {
        final res = await Supabase.instance.client.auth.signUp(
          email: email,
          password: password,
        );
        if (res.user != null) {
          final adminCheck = await Supabase.instance.client
              .from('admin_profiles')
              .select('id')
              .eq('id', res.user!.id)
              .maybeSingle();
          if (adminCheck != null) {
            if (mounted) {
              ZestSnack.show(
                context,
                message: 'Admin account detected. Redirecting to Admin Dashboard... 🛡️',
                type: ZestSnackType.info,
              );
              context.go('/admin/dashboard');
            }
            return;
          }
        }

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
          final adminCheck = await Supabase.instance.client
              .from('admin_profiles')
              .select('id, role')
              .eq('id', res.user!.id)
              .maybeSingle();

          if (adminCheck != null) {
            if (mounted) {
              ZestSnack.show(
                context,
                message: 'Admin account detected. Redirecting to Admin Dashboard... 🛡️',
                type: ZestSnackType.info,
              );
              context.go('/admin/dashboard');
            }
            return;
          }

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
        setState(() => _errorMessage = error.message);
        ZestSnack.error(context, error.message);
      }
    } catch (error) {
      if (mounted) {
        final msg = error.toString();
        setState(() => _errorMessage = msg);
        ZestSnack.error(context, msg);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZestTokens.page,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => context.go('/'),
        ),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top Logo 56px
                  const Center(child: ZestBlobLogo(size: 56, animateOnLoad: true)),
                  const SizedBox(height: 20),

                  // Animated Headline ("Welcome back" / "Join the fun")
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: RichText(
                      key: ValueKey<bool>(_isSignUp),
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: ZestTokens.display.copyWith(
                          fontSize: 32,
                          color: ZestTokens.ink,
                        ),
                        children: [
                          TextSpan(text: _isSignUp ? 'Join the ' : 'Welcome '),
                          TextSpan(
                            text: _isSignUp ? 'fun' : 'back',
                            style: ZestTokens.accentItalic.copyWith(fontSize: 38),
                          ),
                          const TextSpan(text: '.'),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),
                  Text(
                    _isSignUp
                        ? 'Create your student pass wallet and start earning XP.'
                        : 'Sign in to access tickets, event passes & leaderboards.',
                    textAlign: TextAlign.center,
                    style: ZestTokens.body.copyWith(color: ZestTokens.ink2),
                  ),

                  const SizedBox(height: 24),

                  // Toggle Sign In / Create Account
                  ZestSegmentedToggle(
                    options: const ['Sign In', 'Create Account'],
                    selectedIndex: _isSignUp ? 1 : 0,
                    onChanged: (idx) {
                      setState(() {
                        _isSignUp = idx == 1;
                        _errorMessage = null;
                      });
                    },
                  ),

                  const SizedBox(height: 24),

                  // Main White Form Card with staggered inputs
                  ZestCard(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Email input
                        ZestTextField(
                          controller: _emailController,
                          label: 'COLLEGE EMAIL',
                          hintText: 'student@college.edu',
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: const Icon(
                            Icons.alternate_email_rounded,
                            color: ZestTokens.ink3,
                            size: 19,
                          ),
                          errorText: _errorMessage,
                        )
                            .animate()
                            .fadeIn(duration: 400.ms)
                            .slideY(begin: 0.1, end: 0, duration: 300.ms),

                        const SizedBox(height: 18),

                        // Password input
                        ZestTextField(
                          controller: _passwordController,
                          label: 'PASSWORD',
                          hintText: '••••••••',
                          isPassword: true,
                          prefixIcon: const Icon(
                            Icons.lock_outline_rounded,
                            color: ZestTokens.ink3,
                            size: 19,
                          ),
                          onSubmitted: (_) => _submit(),
                        )
                            .animate()
                            .fadeIn(delay: 60.ms, duration: 400.ms)
                            .slideY(begin: 0.1, end: 0, duration: 300.ms),

                        if (!_isSignUp) ...[
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => context.push('/auth/forgot-password'),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                'Forgot password?',
                                style: ZestTokens.caption.copyWith(
                                  color: ZestTokens.blue,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 24),

                        // Primary Submit Button
                        ZestButton(
                          text: _isSignUp ? 'Create Student Account 🚀' : 'Sign In ⚡',
                          fullWidth: true,
                          isLoading: _isLoading,
                          onPressed: _submit,
                        )
                            .animate()
                            .fadeIn(delay: 120.ms, duration: 400.ms)
                            .slideY(begin: 0.1, end: 0, duration: 300.ms),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Bottom Organizer Portal Link
                  Center(
                    child: TextButton(
                      onPressed: () => context.go('/admin/login'),
                      child: Text(
                        'Club Organizer or Admin? Access Suite 🛡️',
                        style: ZestTokens.caption.copyWith(
                          color: ZestTokens.ink2,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),

          // Subtle Mascot peeking from bottom-right
          Positioned(
            right: 12,
            bottom: 8,
            child: const ZestMascot(
              size: 70,
              tint: MascotTint.lemon,
              mood: MascotMood.idle,
            )
                .animate()
                .fadeIn(delay: 400.ms, duration: 600.ms)
                .slideX(begin: 0.2, end: 0, duration: 500.ms),
          ),
        ],
      ),
    );
  }
}
