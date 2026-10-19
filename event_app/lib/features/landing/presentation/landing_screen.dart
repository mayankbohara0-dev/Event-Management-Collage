import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../../core/theme/theme.dart';
import '../../../shared/widgets/shared_widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// LandingScreen — handles auth check and shows either:
//   • _AnimatedSplash  (while checking, shown for 2.5s with white->#EAF6FF radial)
//   • _AuthLanding     (if unauthenticated after check, calm modern light UI)
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
// White→#EAF6FF radial background. Center: ZestBlobLogo 120px pops in
// (scale .6→1, easeOutBack, 500ms), eyes blink once; soft glow ring pulses;
// wordmark "zest" (Inter 600, 36) rises at 550ms; tagline fades at 800ms
// with "zest" in Instrument Serif Italic.
// ─────────────────────────────────────────────────────────────────────────────
class _AnimatedSplash extends StatelessWidget {
  const _AnimatedSplash();

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 0.9,
              colors: [Colors.white, Color(0xFFEAF6FF)],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Pulse glow ring behind logo
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: ZestTokens.core.withValues(alpha: 0.12),
                        ),
                      )
                          .animate(onPlay: (c) => c.repeat(reverse: true))
                          .scale(
                            begin: const Offset(0.9, 0.9),
                            end: const Offset(1.2, 1.2),
                            duration: 1800.ms,
                            curve: Curves.easeInOut,
                          )
                          .fadeIn(duration: 400.ms),

                      // 120px ZestBlobLogo pops in
                      const ZestBlobLogo(size: 120, animateOnLoad: true),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // "zest" wordmark (Inter 600, 36sp) rises + fades at 550ms
                  Text(
                    'zest',
                    style: ZestTokens.display.copyWith(
                      fontSize: 38,
                      fontWeight: FontWeight.w600,
                      color: ZestTokens.ink,
                      letterSpacing: -1.2,
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

                  // Tagline with "zest" in Instrument Serif Italic
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: ZestTokens.body.copyWith(
                        fontSize: 16,
                        color: ZestTokens.ink2,
                      ),
                      children: [
                        const TextSpan(text: 'Add some '),
                        TextSpan(
                          text: 'zest',
                          style: ZestTokens.accentItalic.copyWith(fontSize: 20),
                        ),
                        const TextSpan(text: ' to your campus life'),
                      ],
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
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _AuthLanding — shown after auth check if user is not signed in
// Designjoy-style calm light aesthetic on page background
// ─────────────────────────────────────────────────────────────────────────────
class _AuthLanding extends StatelessWidget {
  const _AuthLanding();

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: ZestTokens.page,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Top Header Bar ─────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const ZestBlobLogo(size: 34),
                        const SizedBox(width: 10),
                        Text(
                          'zest',
                          style: ZestTokens.title.copyWith(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: ZestTokens.borderPill,
                        border: Border.all(color: const Color(0xFFA7F3D0)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: Color(0xFF10B981),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'CAMPUS LIVE',
                            style: TextStyle(
                              color: Color(0xFF059669),
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // ── Main Hero Card ─────────────────────────────────────────
                ZestCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Eyebrow pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE6F4FE),
                          borderRadius: ZestTokens.borderPill,
                        ),
                        child: Text(
                          'CAMPUS EVENTS, SORTED',
                          style: ZestTokens.labelCaps.copyWith(
                            color: ZestTokens.blue,
                            fontSize: 10.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Heading with single italic serif accent word
                      RichText(
                        text: TextSpan(
                          style: ZestTokens.display.copyWith(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            height: 1.15,
                          ),
                          children: [
                            const TextSpan(text: 'Campus life, with a '),
                            TextSpan(
                              text: 'twist',
                              style: ZestTokens.accentItalic.copyWith(
                                fontSize: 38,
                              ),
                            ),
                            const TextSpan(text: '.'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      Text(
                        'Find events, grab an animated QR pass, and earn real XP for showing up. One app instead of forms and paper lists.',
                        style: ZestTokens.body.copyWith(
                          color: ZestTokens.ink2,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Feature chips
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: const [
                          _AuthFeaturePill('🎟️ Instant QR Pass'),
                          _AuthFeaturePill('⚡ Gate Check-in'),
                          _AuthFeaturePill('🏆 Campus XP'),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ── Bottom Action Card ─────────────────────────────────────
                ZestCard(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    children: [
                      ZestButton(
                        text: 'Enter as Student ⚡',
                        fullWidth: true,
                        onPressed: () => context.go('/student/login'),
                      ),
                      const SizedBox(height: 12),
                      ZestButton(
                        text: 'Admin & Organizer Suite 🛡️',
                        variant: ZestButtonVariant.secondary,
                        fullWidth: true,
                        onPressed: () => context.go('/admin/login'),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Free for college students • Built for campuses',
                        textAlign: TextAlign.center,
                        style: ZestTokens.caption.copyWith(
                          color: ZestTokens.ink3,
                          fontSize: 12,
                        ),
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

class _AuthFeaturePill extends StatelessWidget {
  final String text;
  const _AuthFeaturePill(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: ZestTokens.fill,
        borderRadius: ZestTokens.borderPill,
        border: Border.all(color: ZestTokens.line),
      ),
      child: Text(
        text,
        style: ZestTokens.caption.copyWith(
          color: ZestTokens.ink,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
