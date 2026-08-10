import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../../core/design_system.dart';

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
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) {
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
          if (token != null) {
            if (studentRes != null) {
              await Supabase.instance.client.from('student_profiles').update({'fcm_token': token}).eq('id', user.id);
            } else if (adminRes != null) {
              await Supabase.instance.client.from('admin_profiles').update({'fcm_token': token}).eq('id', user.id);
            }
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

    } catch (e) {
      debugPrint('Auth check error: $e');
    }

    if (mounted) setState(() => _isChecking = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return const Scaffold(
        backgroundColor: AppColors.white,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.green),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Hero banner — green like 7-Eleven
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: AppColors.heroGradient,
                ),
                child: Stack(
                  children: [
                    // Pattern overlay
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.08,
                        child: CustomPaint(painter: _DotPattern()),
                      ),
                    ),
                    // Content
                    Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          // App name
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.yellow,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'EVENT COLLAGE',
                              style: GoogleFonts.inter(
                                color: AppColors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'ALWAYS\nCONNECTED.\nALWAYS\nINSPIRED.',
                            style: GoogleFonts.inter(
                              color: AppColors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Your campus event hub.\nDiscover. Register. Attend.',
                            style: GoogleFonts.inter(
                              color: AppColors.white.withOpacity(0.85),
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom sheet options
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              color: AppColors.white,
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () => context.go('/student/login'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.black,
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      'Sign In as Student',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => context.go('/admin/login'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 52),
                      side: const BorderSide(color: AppColors.grey200, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      'Admin Portal',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'By continuing, you agree to the Event Collage\nPrivacy Policy and Terms of Use',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.grey400,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DotPattern extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1
      ..style = PaintingStyle.fill;
    const gap = 24.0;
    for (double x = 0; x < size.width; x += gap) {
      for (double y = 0; y < size.height; y += gap) {
        canvas.drawCircle(Offset(x, y), 2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
