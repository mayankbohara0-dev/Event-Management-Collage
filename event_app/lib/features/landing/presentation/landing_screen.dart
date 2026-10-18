import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/zest_button.dart';
import '../../../core/widgets/zest_logo.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // Keep brief splash visibility for smooth transition
    final start = DateTime.now();
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) {
      final elapsed = DateTime.now().difference(start);
      if (elapsed < const Duration(milliseconds: 700)) {
        await Future.delayed(const Duration(milliseconds: 700) - elapsed);
      }
      if (mounted) setState(() => _isChecking = false);
      return;
    }

    final user = session.user;

    try {
      // Check if student
      final studentRes = await Supabase.instance.client
          .from('student_profiles')
          .select('id, name')
          .eq('id', user.id)
          .maybeSingle();

      // Check if admin
      final adminRes = await Supabase.instance.client
          .from('admin_profiles')
          .select('id')
          .eq('id', user.id)
          .maybeSingle();

      // ── Setup FCM Token ──
      try {
        final fcm = FirebaseMessaging.instance;
        final settings = await fcm.requestPermission();
        if (settings.authorizationStatus == AuthorizationStatus.authorized) {
          final token = await fcm.getToken();
          final tableName = studentRes != null
              ? 'student_profiles'
              : (adminRes != null ? 'admin_profiles' : null);
          if (token != null && tableName != null) {
            await Supabase.instance.client
                .from(tableName)
                .update({'fcm_token': token}).eq('id', user.id);
          }
          if (tableName != null) {
            fcm.onTokenRefresh.listen((newToken) async {
              try {
                final current = Supabase.instance.client.auth.currentUser;
                if (current != null) {
                  await Supabase.instance.client
                      .from(tableName)
                      .update({'fcm_token': newToken}).eq('id', current.id);
                }
              } catch (_) {}
            });
          }
        }
      } catch (e) {
        debugPrint('FCM setup error: $e');
      }

      if (studentRes != null) {
        if (mounted) {
          if ((studentRes['name'] ?? '').toString().isNotEmpty) {
            context.go('/student/home');
          } else {
            context.go('/student/onboarding');
          }
        }
        return;
      }

      if (adminRes != null) {
        if (mounted) context.go('/admin/dashboard');
        return;
      }

      // If user is authenticated but not found in either table (e.g. just signed up),
      // route them to onboarding.
      if (mounted) {
        context.go('/student/onboarding');
        return;
      }
    } catch (e) {
      debugPrint('Auth check error: $e');
    }

    if (mounted) setState(() => _isChecking = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return _buildSplashScreen();
    }

    return _buildLandingScreen();
  }

  // ── Animated Splash Screen ─────────────────────────────────────────────────
  Widget _buildSplashScreen() {
    return Scaffold(
      backgroundColor: AppColors.ink,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background ambient radial lime glow
          Positioned(
            top: -100,
            left: -100,
            right: -100,
            child: Center(
              child: Container(
                width: 450,
                height: 450,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.lime.withValues(alpha: 0.12),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Giant watermark Z in bottom-right corner sliding in
          Positioned(
            right: -60,
            bottom: -60,
            child: ZestLogo.watermark(
              size: 380,
              color: AppColors.surfaceCard.withValues(alpha: 0.6),
            )
                .animate()
                .slide(
                  begin: const Offset(0.25, 0.25),
                  end: Offset.zero,
                  duration: 800.ms,
                  curve: Curves.easeOutCubic,
                )
                .fadeIn(duration: 600.ms),
          ),

          // Centered branding & animated logo
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Brand logo with elastic entrance
                const ZestLogo.icon(size: 110)
                    .animate()
                    .scale(
                      begin: const Offset(0.65, 0.65),
                      end: const Offset(1.0, 1.0),
                      duration: 750.ms,
                      curve: Curves.elasticOut,
                    )
                    .fadeIn(duration: 400.ms),
                const SizedBox(height: 28),

                // Lowercase wordmark
                const ZestLogo.wordmark(
                  height: 34,
                  color: AppColors.lime,
                )
                    .animate()
                    .fadeIn(delay: 200.ms, duration: 500.ms)
                    .slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic),
                const SizedBox(height: 12),

                // Punchy brand tagline
                Text(
                  'Add some zest to your campus life.',
                  style: AppTextStyles.body15.copyWith(
                    color: AppColors.grey400,
                    fontWeight: FontWeight.w500,
                  ),
                )
                    .animate()
                    .fadeIn(delay: 350.ms, duration: 600.ms)
                    .slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic),
                const SizedBox(height: 44),

                // Neo-bold lime loading indicator bar
                Container(
                  width: 140,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCard,
                    borderRadius: AppRadius.circularPill,
                  ),
                  child: ClipRRect(
                    borderRadius: AppRadius.circularPill,
                    child: LinearProgressIndicator(
                      backgroundColor: Colors.transparent,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.lime),
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(delay: 450.ms, duration: 500.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── High-Energy Neo-Bold Landing Screen ─────────────────────────────────────
  Widget _buildLandingScreen() {
    return Scaffold(
      backgroundColor: AppColors.ink,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight - 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Header Bar ───────────────────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const ZestLogo.lockup(height: 36, isDarkBg: true),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceCard,
                            borderRadius: AppRadius.circularPill,
                            border: Border.all(color: AppColors.borderDark, width: 1),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.lime,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'CAMPUS LIVE',
                                style: AppTextStyles.overline.copyWith(
                                  color: AppColors.lime,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // ── Hero Section with Giant Display Typography ───────────
                    Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceDark,
                        borderRadius: AppRadius.circularCardLarge,
                        border: Border.all(color: AppColors.borderDark, width: 1.5),
                      ),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // Background giant watermark Z
                          Positioned(
                            right: -40,
                            bottom: -40,
                            child: ZestLogo.watermark(
                              size: 260,
                              color: AppColors.surfaceCard.withValues(alpha: 0.35),
                            ),
                          ),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Overline chip
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.lime.withValues(alpha: 0.15),
                                  borderRadius: AppRadius.circularPill,
                                  border: Border.all(color: AppColors.lime.withValues(alpha: 0.3)),
                                ),
                                child: Text(
                                  'THE EVENT PLATFORM',
                                  style: AppTextStyles.overline.copyWith(
                                    color: AppColors.lime,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Display headline
                              RichText(
                                text: TextSpan(
                                  style: AppTextStyles.title40.copyWith(
                                    color: AppColors.paper,
                                    height: 1.05,
                                  ),
                                  children: [
                                    const TextSpan(text: 'DISCOVER.\nREGISTER.\n'),
                                    TextSpan(
                                      text: 'DOMINATE.',
                                      style: TextStyle(
                                        color: AppColors.lime,
                                        fontWeight: FontWeight.w900,
                                        shadows: [
                                          Shadow(
                                            color: AppColors.lime.withValues(alpha: 0.3),
                                            blurRadius: 16,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Subtitle
                              Text(
                                'Instant tickets, offline QR scanning, club management, and live college leaderboards in one pocket app.',
                                style: AppTextStyles.body15.copyWith(
                                  color: AppColors.grey400,
                                  height: 1.45,
                                ),
                              ),

                              const SizedBox(height: 24),

                              // Feature pills row
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  _buildFeaturePill('🎟️ Instant Passes'),
                                  _buildFeaturePill('⚡ Fast Gate Scan'),
                                  _buildFeaturePill('🏆 Student XP'),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Bottom Action Card ───────────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceCard,
                        borderRadius: AppRadius.circularCardLarge,
                        border: Border.all(color: AppColors.borderDark, width: 1.5),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Primary: Student Sign In
                          ZestButton(
                            label: 'Enter as Student ⚡',
                            variant: ZestButtonVariant.primary,
                            onPressed: () => context.go('/student/login'),
                          ),
                          const SizedBox(height: 12),

                          // Secondary: Admin Access
                          ZestButton(
                            label: 'Admin & Gate Access 🛡️',
                            variant: ZestButtonVariant.secondary,
                            onPressed: () => context.go('/admin/login'),
                          ),
                          const SizedBox(height: 18),

                          // Legal disclaimer
                          Text(
                            'By continuing, you agree to the Zest Terms of Service and Privacy Policy.',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.caption11.copyWith(
                              color: AppColors.grey400,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFeaturePill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: AppRadius.circularPill,
        border: Border.all(color: AppColors.borderDark, width: 1),
      ),
      child: Text(
        text,
        style: AppTextStyles.label13.copyWith(
          color: AppColors.paper,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
