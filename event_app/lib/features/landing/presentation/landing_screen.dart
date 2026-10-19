import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/zest_button.dart';
import '../../../core/widgets/zest_logo.dart';

// ─────────────────────────────────────────────────────────────────────────────
// LandingScreen — handles auth check and shows either:
//   • _AnimatedSplash  (while checking, shown for 2.5s with lime gradient)
//   • _AuthLanding     (if unauthenticated after check)
// ─────────────────────────────────────────────────────────────────────────────

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
    // Keep splash visible for at least 2.5s while auth check runs
    final start = DateTime.now();
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) {
      final elapsed = DateTime.now().difference(start);
      const minSplash = Duration(milliseconds: 2500);
      if (elapsed < minSplash) {
        await Future.delayed(minSplash - elapsed);
      }
      if (mounted) setState(() => _isChecking = false);
      return;
    }

    final user = session.user;

    try {
      // Run auth check and FCM setup in parallel
      final results = await Future.wait<dynamic>([
        Supabase.instance.client
            .from('student_profiles')
            .select('id, name')
            .eq('id', user.id)
            .maybeSingle(),
        Supabase.instance.client
            .from('admin_profiles')
            .select('id')
            .eq('id', user.id)
            .maybeSingle(),
      ]);

      final studentRes = results[0] as Map<String, dynamic>?;
      final adminRes   = results[1] as Map<String, dynamic>?;

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

      // Ensure minimum splash duration
      final elapsed = DateTime.now().difference(start);
      const minSplash = Duration(milliseconds: 2500);
      if (elapsed < minSplash) {
        await Future.delayed(minSplash - elapsed);
      }

      if (!mounted) return;

      if (studentRes != null) {
        if ((studentRes['name'] ?? '').toString().isNotEmpty) {
          context.go('/student/home');
        } else {
          context.go('/student/onboarding');
        }
        return;
      }

      if (adminRes != null) {
        context.go('/admin/dashboard');
        return;
      }

      context.go('/student/onboarding');
      return;
    } catch (e) {
      debugPrint('Auth check error: $e');
    }

    if (mounted) setState(() => _isChecking = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return const _AnimatedSplash();
    }
    return const _AuthLanding();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _AnimatedSplash
// Spec: full-screen lime gradient, 168px logo icon (radius 42, soft shadow)
//   pops in with springy scale from 0.3 + slight rotation, two sparkles twinkle,
//   "zest" wordmark 78sp rises at ~550ms, tagline 15sp bold fades at ~800ms.
// ─────────────────────────────────────────────────────────────────────────────
class _AnimatedSplash extends StatelessWidget {
  const _AnimatedSplash();

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark, // dark icons on lime bg
      child: Scaffold(
        backgroundColor: AppColors.lime1,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.lime1, AppColors.lime2],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Stack(
              fit: StackFit.expand,
              children: [
                // ── Cropped Z watermark (ink, bottom-right corner) ──────────
                Positioned(
                  right: -60,
                  bottom: -40,
                  child: ZestLogo.watermark(
                    size: 340,
                    color: AppColors.ink.withValues(alpha: 0.08),
                  )
                      .animate()
                      .fadeIn(duration: 600.ms, delay: 300.ms)
                      .slide(
                        begin: const Offset(0.15, 0.15),
                        end: Offset.zero,
                        duration: 900.ms,
                        curve: Curves.easeOutCubic,
                      ),
                ),

                // ── Main branding column ────────────────────────────────────
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ── Logo icon: 168px, radius 42, springy scale from 0.3 ──
                      _SparkleWrapper(
                        child: Container(
                          width: 168,
                          height: 168,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(AppRadius.appIconTile),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.ink.withValues(alpha: 0.18),
                                blurRadius: 40,
                                offset: const Offset(0, 16),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(AppRadius.appIconTile),
                            ),
                            child: const ZestLogo.icon(size: 168),
                          ),
                        )
                            .animate()
                            .scale(
                              begin: const Offset(0.3, 0.3),
                              end: const Offset(1.0, 1.0),
                              duration: 700.ms,
                              curve: Curves.elasticOut,
                            )
                            .rotate(
                              begin: -0.05,
                              end: 0,
                              duration: 700.ms,
                              curve: Curves.elasticOut,
                            )
                            .fadeIn(duration: 300.ms),
                      ),

                      const SizedBox(height: 32),

                      // ── "zest" wordmark — 78sp, ink, rises at 550ms ────────
                      Text(
                        'zest',
                        style: AppTextStyles.display78.copyWith(
                          color: AppColors.ink,
                          height: 1.0,
                        ),
                      )
                          .animate()
                          .fadeIn(delay: 550.ms, duration: 500.ms)
                          .slideY(
                            begin: 0.25,
                            end: 0,
                            delay: 550.ms,
                            duration: 500.ms,
                            curve: Curves.easeOutCubic,
                          ),

                      const SizedBox(height: 12),

                      // ── Tagline — 15sp, ink 80% opacity, fades at 800ms ───
                      Text(
                        'Add some zest to your campus life.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.body15.copyWith(
                          color: AppColors.ink.withValues(alpha: 0.80),
                          fontWeight: FontWeight.w700,
                        ),
                      )
                          .animate()
                          .fadeIn(delay: 800.ms, duration: 600.ms)
                          .slideY(
                            begin: 0.2,
                            end: 0,
                            delay: 800.ms,
                            duration: 500.ms,
                            curve: Curves.easeOutCubic,
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

// ── Twinkling sparkle wrapper — two ink sparkles beside the logo ────────────
class _SparkleWrapper extends StatelessWidget {
  const _SparkleWrapper({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        child,
        // Top-right sparkle
        Positioned(
          top: -8,
          right: -18,
          child: _Sparkle(size: 20, delay: 200.ms, color: AppColors.ink),
        ),
        // Bottom-left sparkle
        Positioned(
          bottom: 4,
          left: -22,
          child: _Sparkle(size: 14, delay: 600.ms, color: AppColors.ink.withValues(alpha: 0.6)),
        ),
      ],
    );
  }
}

class _Sparkle extends StatelessWidget {
  const _Sparkle({required this.size, required this.delay, required this.color});
  final double size;
  final Duration delay;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _SparklePainter(color: color),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scale(
          begin: const Offset(1.0, 1.0),
          end: const Offset(0.5, 0.5),
          delay: delay,
          duration: 1000.ms,
          curve: Curves.easeInOut,
        )
        .rotate(
          begin: 0,
          end: 0.11, // ~40 degrees
          delay: delay,
          duration: 1000.ms,
          curve: Curves.easeInOut,
        );
  }
}

class _SparklePainter extends CustomPainter {
  const _SparklePainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final cx = size.width / 2;
    final cy = size.height / 2;
    const arms = 4;
    const pi = 3.14159265358979;

    final path = Path();
    for (int i = 0; i < arms * 2; i++) {
      final angle = (i * pi / arms) - pi / 2;
      final r = i.isEven ? size.width * 0.5 : size.width * 0.18;
      final px = cx + r * _cos(angle);
      final py = cy + r * _sin(angle);
      if (i == 0) {
        path.moveTo(px, py);
      } else {
        path.lineTo(px, py);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  double _cos(double rad) {
    // Simplified cos approximation (good enough for small angles)
    final n = rad % (2 * 3.14159265358979);
    if (n < 1.5708) return 1 - n * n / 2 + n * n * n * n / 24;
    if (n < 3.1416) return -(n - 3.1416) * (n - 3.1416) / 2 + 1;
    if (n < 4.7124) return -(n - 3.1416) * (n - 3.1416) / 2 + 1;
    return 1 - (n - 6.2832) * (n - 6.2832) / 2;
  }

  double _sin(double rad) => _cos(rad - 1.5708);

  @override
  bool shouldRepaint(_SparklePainter old) => old.color != color;
}

// ─────────────────────────────────────────────────────────────────────────────
// _AuthLanding — shown after auth check if user is not signed in
// High-energy neo-bold design on ink background
// ─────────────────────────────────────────────────────────────────────────────
class _AuthLanding extends StatelessWidget {
  const _AuthLanding();

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light, // light icons on ink bg
      child: Scaffold(
        backgroundColor: AppColors.ink,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight - 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── Header Bar ─────────────────────────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const ZestLogo.lockup(height: 36, isDarkBg: true),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.ink2,
                              borderRadius: AppRadius.circularPill,
                              border: Border.all(
                                  color: AppColors.borderDark, width: 1),
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

                      // ── Hero Section ───────────────────────────────────────
                      Container(
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: AppColors.ink2,
                          borderRadius: AppRadius.circularCardLarge,
                          border: Border.all(
                              color: AppColors.borderDark, width: 1.5),
                        ),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // Background Z watermark
                            Positioned(
                              right: -40,
                              bottom: -40,
                              child: ZestLogo.watermark(
                                size: 260,
                                color: AppColors.ink3.withValues(alpha: 0.35),
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Overline chip
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.lime.withValues(alpha: 0.15),
                                    borderRadius: AppRadius.circularPill,
                                    border: Border.all(
                                        color: AppColors.lime.withValues(
                                            alpha: 0.3)),
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
                                      const TextSpan(
                                          text: 'DISCOVER.\nREGISTER.\n'),
                                      TextSpan(
                                        text: 'DOMINATE.',
                                        style: TextStyle(
                                          color: AppColors.lime,
                                          fontWeight: FontWeight.w800,
                                          shadows: [
                                            Shadow(
                                              color: AppColors.lime
                                                  .withValues(alpha: 0.3),
                                              blurRadius: 16,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Instant tickets, offline QR scanning, club management, and live college leaderboards in one pocket app.',
                                  style: AppTextStyles.body15.copyWith(
                                    color: AppColors.grey400,
                                    height: 1.45,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    _featurePill('🎟️ Instant Passes'),
                                    _featurePill('⚡ Fast Gate Scan'),
                                    _featurePill('🏆 Student XP'),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ── Bottom Action Card ─────────────────────────────────
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.ink2,
                          borderRadius: AppRadius.circularCardLarge,
                          border: Border.all(
                              color: AppColors.borderDark, width: 1.5),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ZestButton(
                              label: 'Enter as Student ⚡',
                              onPressed: () => context.go('/student/login'),
                            ),
                            const SizedBox(height: 12),
                            ZestButton(
                              label: 'Admin & Gate Access 🛡️',
                              variant: ZestButtonVariant.secondary,
                              onPressed: () => context.go('/admin/login'),
                            ),
                            const SizedBox(height: 18),
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
      ),
    );
  }

  static Widget _featurePill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.ink3,
        borderRadius: AppRadius.circularPill,
        border: Border.all(color: AppColors.borderDark, width: 1),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.paper,
        ),
      ),
    );
  }
}
