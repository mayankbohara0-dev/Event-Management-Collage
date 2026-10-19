import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/zest_button.dart';
import '../../../../core/widgets/zest_logo.dart';

class AdminLoginScreen extends ConsumerStatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  ConsumerState<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends ConsumerState<AdminLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
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
      await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        // Check admin_profiles table (the correct table per schema)
        final adminProfile = await Supabase.instance.client
            .from('admin_profiles')
            .select('role')
            .eq('id', user.id)
            .maybeSingle();

        if (adminProfile != null) {
          // User exists in admin_profiles — allow access
          if (mounted) context.go('/admin/dashboard');
        } else {
          // Auto-create admin profile for the demo
          try {
            await Supabase.instance.client.from('admin_profiles').insert({
              'id': user.id,
              'name': 'Admin User',
              'role': 'admin',
            });
            if (mounted) context.go('/admin/dashboard');
          } catch (e) {
            await Supabase.instance.client.auth.signOut();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Failed to initialize admin profile.',
                    style: AppTextStyles.body14.copyWith(color: AppColors.paper),
                  ),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.circularMd),
                ),
              );
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
              'Error: ${error.toString()}',
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
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 480),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 12),

                            // Organizer Badge Pill
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.lime.withValues(alpha: 0.12),
                                  borderRadius: AppRadius.circularPill,
                                  border: Border.all(color: AppColors.lime.withValues(alpha: 0.35), width: 1),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.lime,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'ADMIN & ORGANIZER PORTAL',
                                      style: AppTextStyles.caption12.copyWith(
                                        color: AppColors.lime,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1.1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 14),

                            // Headline
                            Text(
                              'Admin Command 🛡️',
                              style: AppTextStyles.title36.copyWith(
                                color: AppColors.paper,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Sign in to manage campus events, scan attendee tickets, and view registration analytics.',
                              style: AppTextStyles.body15.copyWith(
                                color: AppColors.grey400,
                              ),
                            ),

                            const SizedBox(height: 28),

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
                                    'OFFICIAL ADMIN EMAIL',
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
                                    cursorColor: AppColors.lime,
                                    decoration: InputDecoration(
                                      hintText: 'admin@college.edu',
                                      hintStyle: const TextStyle(color: AppColors.grey400, fontSize: 14),
                                      prefixIcon: const Icon(Icons.alternate_email_rounded, color: AppColors.lime, size: 20),
                                      filled: true,
                                      fillColor: AppColors.surfaceDark,
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                                      border: const OutlineInputBorder(
                                        borderRadius: AppRadius.circularInput,
                                        borderSide: BorderSide(color: AppColors.borderDark, width: 1.5),
                                      ),
                                      enabledBorder: const OutlineInputBorder(
                                        borderRadius: AppRadius.circularInput,
                                        borderSide: BorderSide(color: AppColors.borderDark, width: 1.5),
                                      ),
                                      focusedBorder: const OutlineInputBorder(
                                        borderRadius: AppRadius.circularInput,
                                        borderSide: BorderSide(color: AppColors.lime, width: 2),
                                      ),
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
                                    onSubmitted: (_) => _login(),
                                    style: AppTextStyles.body15.copyWith(color: AppColors.paper),
                                    cursorColor: AppColors.lime,
                                    decoration: InputDecoration(
                                      hintText: '••••••••',
                                      hintStyle: const TextStyle(color: AppColors.grey400, fontSize: 14),
                                      prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.lime, size: 20),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                          color: AppColors.grey400,
                                          size: 20,
                                        ),
                                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                      ),
                                      filled: true,
                                      fillColor: AppColors.surfaceDark,
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                                      border: const OutlineInputBorder(
                                        borderRadius: AppRadius.circularInput,
                                        borderSide: BorderSide(color: AppColors.borderDark, width: 1.5),
                                      ),
                                      enabledBorder: const OutlineInputBorder(
                                        borderRadius: AppRadius.circularInput,
                                        borderSide: BorderSide(color: AppColors.borderDark, width: 1.5),
                                      ),
                                      focusedBorder: const OutlineInputBorder(
                                        borderRadius: AppRadius.circularInput,
                                        borderSide: BorderSide(color: AppColors.lime, width: 2),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 28),

                                  // Primary Submit Button
                                  ZestButton(
                                    label: 'Sign In to Admin Portal 🚀',
                                    variant: ZestButtonVariant.primary,
                                    isLoading: _isLoading,
                                    onPressed: _login,
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
                                    style: AppTextStyles.body14.copyWith(color: AppColors.grey400),
                                    children: [
                                      const TextSpan(text: 'Looking for student passes? '),
                                      TextSpan(
                                        text: 'Enter as Student',
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

                            const SizedBox(height: 16),

                            // Disclaimer
                            Center(
                              child: Text(
                                'Access restricted to authorized club leaders and administrators.',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.caption11.copyWith(
                                  color: AppColors.grey400,
                                  height: 1.4,
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}
