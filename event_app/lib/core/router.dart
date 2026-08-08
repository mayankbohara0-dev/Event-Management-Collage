import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Landing
import '../features/landing/presentation/landing_screen.dart';

// Student Features
import '../features/auth/presentation/login_screen.dart' as student_auth;
import '../features/profile/presentation/profile_onboarding_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/events/presentation/registration_form_screen.dart';
import '../features/events/presentation/event_details_screen.dart';

// Admin Features
import '../features/admin/auth/presentation/login_screen.dart' as admin_auth;
import '../features/admin/dashboard/presentation/dashboard_layout.dart';
import '../features/admin/dashboard/presentation/dashboard_screen.dart';
import '../features/admin/events/presentation/events_table_screen.dart';
import '../features/admin/events/presentation/event_create_screen.dart';
import '../features/admin/events/presentation/form_builder_screen.dart';
import '../features/admin/events/presentation/event_responses_screen.dart';
import '../features/admin/events/presentation/scanner_screen.dart';
import '../features/admin/registrations/presentation/registrations_screen.dart';

import 'providers.dart';

final routerProvider = Provider<GoRouter>((ref) {
  // Rebuild the router whenever auth state changes so redirects re-evaluate.
  ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) async {
      final session = Supabase.instance.client.auth.currentSession;
      final path = state.matchedLocation;

      // ── Unauthenticated user ─────────────────────────────────────────
      if (session == null) {
        // Allow public routes through
        final publicRoutes = ['/', '/student/login', '/admin/login'];
        if (publicRoutes.contains(path)) return null;
        // Bounce everything else back to landing
        return '/';
      }

      // ── Authenticated user ───────────────────────────────────────────
      final userId = session.user.id;
      final client = Supabase.instance.client;

      // Determine role by checking which profile table has a row for this user.
      final isAdmin = await client
          .from('admin_profiles')
          .select('id')
          .eq('id', userId)
          .maybeSingle()
          .then((r) => r != null);

      final isStudent = !isAdmin &&
          await client
              .from('student_profiles')
              .select('id')
              .eq('id', userId)
              .maybeSingle()
              .then((r) => r != null);

      // --- Admin trying to access student/public routes ---
      if (isAdmin) {
        if (path == '/' || path == '/admin/login' || path == '/student/login') {
          return '/admin/dashboard';
        }
        // Block admins from student-only routes
        if (path.startsWith('/student/')) return '/admin/dashboard';
        return null; // allow all /admin/** routes
      }

      // --- Student trying to access admin routes ---
      if (isStudent) {
        if (path == '/' || path == '/student/login' || path == '/admin/login') {
          return '/student/home';
        }
        if (path.startsWith('/admin/')) return '/student/home';
        return null; // allow all /student/** routes
      }

      // --- Logged in but no profile yet (new sign-up edge case) ---
      // Send to student onboarding if they hit a non-login route
      if (path != '/student/onboarding' && path != '/student/login') {
        return '/student/onboarding';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const LandingScreen(),
      ),

      // ---------- Student Routes ----------
      GoRoute(
        path: '/student/login',
        builder: (context, state) => const student_auth.LoginScreen(),
      ),
      GoRoute(
        path: '/student/onboarding',
        builder: (context, state) => const ProfileOnboardingScreen(),
      ),
      GoRoute(
        path: '/student/edit-profile',
        builder: (context, state) => const ProfileOnboardingScreen(isEditing: true),
      ),
      GoRoute(
        path: '/student/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/student/event/:id',
        builder: (context, state) {
          final eventId = state.pathParameters['id']!;
          return EventDetailsScreen(eventId: eventId);
        },
      ),
      GoRoute(
        path: '/student/event/:id/register',
        builder: (context, state) {
          final eventId = state.pathParameters['id']!;
          return RegistrationFormScreen(eventId: eventId);
        },
      ),

      // ---------- Admin Routes ----------
      GoRoute(
        path: '/admin/login',
        builder: (context, state) => const admin_auth.AdminLoginScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return DashboardLayout(child: child);
        },
        routes: [
          GoRoute(
            path: '/admin/dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/admin/events',
            builder: (context, state) => const EventsTableScreen(),
          ),
          GoRoute(
            path: '/admin/events/create',
            builder: (context, state) => const EventCreateScreen(),
          ),
          GoRoute(
            path: '/admin/events/:eventId/edit',
            builder: (context, state) => EventCreateScreen(
              eventId: state.pathParameters['eventId'],
            ),
          ),
          GoRoute(
            path: '/admin/events/:eventId/scanner',
            builder: (context, state) => ScannerScreen(
              eventId: state.pathParameters['eventId']!,
            ),
          ),
          GoRoute(
            path: '/admin/events/:eventId/builder',
            builder: (context, state) => FormBuilderScreen(
              eventId: state.pathParameters['eventId']!,
            ),
          ),
          GoRoute(
            path: '/admin/events/:eventId/responses',
            builder: (context, state) => EventResponsesScreen(
              eventId: state.pathParameters['eventId']!,
            ),
          ),
          GoRoute(
            path: '/admin/registrations',
            builder: (context, state) => const RegistrationsScreen(),
          ),
        ],
      ),
    ],
  );
});
