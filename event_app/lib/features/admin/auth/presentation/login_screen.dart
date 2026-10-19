import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/zest_tokens.dart';
import '../../../../shared/widgets/shared_widgets.dart';

class AdminLoginScreen extends ConsumerStatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  ConsumerState<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends ConsumerState<AdminLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLoading = false;
  bool _isSignUp = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ZestSnack.show(
        context,
        message: 'Please fill in both email and password.',
        type: ZestSnackType.warning,
      );
      return;
    }

    if (_isSignUp && password.length < 6) {
      ZestSnack.show(
        context,
        message: 'Password must be at least 6 characters long.',
        type: ZestSnackType.warning,
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
        final user = res.user;
        if (user != null) {
          final adminName = _nameController.text.trim().isNotEmpty
              ? _nameController.text.trim()
              : 'Admin User';
          try {
            await Supabase.instance.client.from('admin_profiles').upsert({
              'id': user.id,
              'name': adminName,
              'role': 'admin',
            });
          } catch (e) {
            debugPrint('Failed to upsert admin profile: $e');
          }

          if (mounted) {
            if (res.session != null) {
              ZestSnack.show(
                context,
                message: 'Admin account created successfully! 🛡️',
                type: ZestSnackType.success,
              );
              context.go('/admin/dashboard');
            } else {
              context.go('/auth/verify-email', extra: email);
            }
          }
        }
      } else {
        await Supabase.instance.client.auth.signInWithPassword(
          email: email,
          password: password,
        );
        final user = Supabase.instance.client.auth.currentUser;
        if (user != null) {
          final results = await Future.wait<dynamic>([
            Supabase.instance.client
                .from('admin_profiles')
                .select('id, role')
                .eq('id', user.id)
                .maybeSingle(),
            Supabase.instance.client
                .from('student_profiles')
                .select('id, name')
                .eq('id', user.id)
                .maybeSingle(),
          ]);

          final adminProfile = results[0] as Map<String, dynamic>?;
          final studentProfile = results[1] as Map<String, dynamic>?;

          if (adminProfile != null) {
            if (mounted) context.go('/admin/dashboard');
          } else if (studentProfile != null &&
              (studentProfile['name'] ?? '').toString().isNotEmpty) {
            // Student account trying to log into admin portal
            await Supabase.instance.client.auth.signOut();
            if (mounted) {
              ZestSnack.show(
                context,
                message:
                    'This account is registered as a Student. Please use the Student Portal to sign in.',
                type: ZestSnackType.warning,
              );
            }
          } else {
            // Auto-initialize admin profile for new admin user
            try {
              await Supabase.instance.client.from('admin_profiles').upsert({
                'id': user.id,
                'name': 'Admin User',
                'role': 'admin',
              });
              if (mounted) context.go('/admin/dashboard');
            } catch (e) {
              if (mounted) context.go('/admin/dashboard');
            }
          }
        }
      }
    } on AuthException catch (error) {
      if (mounted) {
        String msg = error.message;
        if (msg.toLowerCase().contains('invalid login credentials')) {
          msg = 'Invalid credentials. If you haven\'t created an admin account yet, switch to "Create Admin Account" above!';
        }
        ZestSnack.show(
          context,
          message: msg,
          type: ZestSnackType.error,
        );
      }
    } catch (error) {
      if (mounted) {
        ZestSnack.show(
          context,
          message: 'Error: ${error.toString()}',
          type: ZestSnackType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZestTokens.page,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: ZestTokens.horizontalPadding,
            vertical: 16,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top Navigation Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => context.go('/'),
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: ZestTokens.line),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x0A0B1220),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            LucideIcons.arrowLeft,
                            color: ZestTokens.ink,
                            size: 18,
                          ),
                        ),
                      ),
                      const ZestBlobLogo(size: 40),
                      const SizedBox(width: 42),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // Organizer Badge Pill
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F6FE),
                        borderRadius: ZestTokens.borderPill,
                        border: Border.all(
                          color: ZestTokens.sky.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: ZestTokens.blue,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'ADMIN & ORGANIZER PORTAL',
                            style: ZestTokens.labelCaps.copyWith(
                              color: ZestTokens.blue,
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Headline
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: _isSignUp ? 'Join as ' : 'Admin ',
                          style: ZestTokens.display.copyWith(fontSize: 32),
                        ),
                        TextSpan(
                          text: _isSignUp ? 'organizer' : 'command',
                          style: ZestTokens.accentItalic.copyWith(
                            fontSize: 36,
                            color: ZestTokens.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _isSignUp
                        ? 'Create an authorized organizer account to create campus events and manage registrations.'
                        : 'Sign in to manage campus events, scan attendee tickets, and view registration analytics.',
                    style: ZestTokens.body.copyWith(
                      color: ZestTokens.ink2,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Toggle Sign In / Create Admin Account
                  ZestSegmentedToggle(
                    options: const ['Sign In', 'Create Admin Account'],
                    selectedIndex: _isSignUp ? 1 : 0,
                    onChanged: (idx) {
                      setState(() {
                        _isSignUp = idx == 1;
                      });
                    },
                  ),

                  const SizedBox(height: 20),

                  // Form Bento Card
                  ZestCard(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_isSignUp) ...[
                          Text(
                            'FULL NAME / ORGANIZER TITLE',
                            style: ZestTokens.labelCaps.copyWith(
                              color: ZestTokens.ink3,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ZestTextField(
                            controller: _nameController,
                            hintText: 'e.g. Prof. Sharma / Tech Club Head',
                            keyboardType: TextInputType.name,
                            prefixIcon: LucideIcons.user,
                          ),
                          const SizedBox(height: 18),
                        ],

                        // Email Input
                        Text(
                          'OFFICIAL ADMIN EMAIL',
                          style: ZestTokens.labelCaps.copyWith(
                            color: ZestTokens.ink3,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ZestTextField(
                          controller: _emailController,
                          hintText: 'admin@college.edu',
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: LucideIcons.mail,
                        ),

                        const SizedBox(height: 18),

                        // Password Input
                        Text(
                          'PASSWORD',
                          style: ZestTokens.labelCaps.copyWith(
                            color: ZestTokens.ink3,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ZestTextField(
                          controller: _passwordController,
                          hintText: '••••••••',
                          isPassword: true,
                          prefixIcon: LucideIcons.lock,
                          onSubmitted: (_) => _submit(),
                        ),

                        const SizedBox(height: 24),

                        // Primary Submit Button
                        ZestButton(
                          text: _isSignUp
                              ? 'Create Admin Account 🛡️'
                              : 'Sign In to Admin Portal',
                          variant: ZestButtonVariant.primary,
                          prefixIcon: _isSignUp
                              ? LucideIcons.userPlus
                              : LucideIcons.shieldCheck,
                          isLoading: _isLoading,
                          fullWidth: true,
                          onPressed: _submit,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Switch to Student mode link
                  Center(
                    child: GestureDetector(
                      onTap: () => context.go('/student/login'),
                      child: RichText(
                        text: TextSpan(
                          style: ZestTokens.body.copyWith(
                            color: ZestTokens.ink3,
                            fontSize: 13.5,
                          ),
                          children: [
                            const TextSpan(text: 'Looking for student passes? '),
                            TextSpan(
                              text: 'Enter as Student',
                              style: TextStyle(
                                color: ZestTokens.blue,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Disclaimer
                  Center(
                    child: Text(
                      'Access restricted to authorized club leaders and administrators.',
                      textAlign: TextAlign.center,
                      style: ZestTokens.caption.copyWith(
                        color: ZestTokens.ink3,
                        fontSize: 11.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
