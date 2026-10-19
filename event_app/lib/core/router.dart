import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Landing
import '../features/landing/presentation/landing_screen.dart';
import '../features/dev/widget_gallery_screen.dart';

// Student Features
import '../features/auth/presentation/login_screen.dart' as student_auth;
import '../features/profile/presentation/profile_onboarding_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/events/presentation/registration_form_screen.dart';
import '../features/events/presentation/event_details_screen.dart';
import '../features/auth/presentation/forgot_password_screen.dart';
import '../features/auth/presentation/reset_password_screen.dart';
import '../features/auth/presentation/email_verification_screen.dart';

// Admin Features
import '../features/admin/auth/presentation/login_screen.dart' as admin_auth;
import '../features/admin/dashboard/presentation/dashboard_layout.dart';
import '../features/admin/dashboard/presentation/dashboard_screen.dart';
import '../features/admin/events/presentation/events_table_screen.dart';
import '../features/admin/events/presentation/event_create_screen.dart';
import '../features/admin/events/presentation/form_builder_screen.dart';
import '../features/admin/events/presentation/event_responses_screen.dart';
import '../features/admin/events/presentation/scanner_screen.dart';
import '../features/admin/events/presentation/event_feedback_screen.dart';
import '../features/admin/registrations/presentation/registrations_screen.dart';
import '../features/admin/users/presentation/users_screen.dart';
import '../features/admin/notifications/presentation/admin_notifications_screen.dart';
import '../features/notifications/presentation/notifications_screen.dart';

import 'providers.dart';

final routerProvider = Provider<GoRouter>((ref) {
  // Rebuild the router whenever auth state changes so redirects re-evaluate.
  ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final session = Supabase.instance.client.auth.currentSession;
      final path = state.matchedLocation;

      // ── Unauthenticated user ─────────────────────────────────────────
      if (session == null) {
        // Allow public routes through
        final publicRoutes = ['/', '/dev/gallery', '/student/login', '/admin/login', '/auth/forgot-password', '/auth/reset-password', '/auth/verify-email'];
        if (publicRoutes.contains(path)) return null;
        // Bounce everything else back to landing
        return '/';
      }

      // ── Authenticated: let LandingScreen handle role-based redirect ──
      // Allow everything through — individual screens protect themselves.
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const LandingScreen(),
      ),
      GoRoute(
        path: '/dev/gallery',
        builder: (context, state) => const WidgetGalleryScreen(),
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
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
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
      GoRoute(
        path: '/auth/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/auth/reset-password',
        builder: (context, state) => const ResetPasswordScreen(),
      ),
      GoRoute(
        path: '/auth/verify-email',
        builder: (context, state) {
          final email = (state.extra as String?) ?? '';
          return EmailVerificationScreen(email: email);
        },
      ),

      // ── Detail/full-screen admin routes (no sidebar shell) ──────────
      // These screens have their own Scaffold + AppBar so they must live
      // outside the ShellRoute to avoid double-Scaffold issues.
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
        path: '/admin/events/:id/scanner',
        builder: (context, state) => ScannerScreen(
          eventId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/admin/events/:id/feedback',
        builder: (context, state) => EventFeedbackScreen(
          eventId: state.pathParameters['id']!,
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

      // ── Shell routes (sidebar layout) ───────────────────────────────
      ShellRoute(
        builder: (context, state, child) {
          return DashboardLayout(
            currentLocation: state.matchedLocation,
            child: child,
          );
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
            path: '/admin/registrations',
            builder: (context, state) => const RegistrationsScreen(),
          ),
          GoRoute(
            path: '/admin/users',
            builder: (context, state) => const UsersScreen(),
          ),
          GoRoute(
            path: '/admin/notifications',
            builder: (context, state) => const AdminNotificationsScreen(),
          ),
        ],
      ),
    ],
  );
});
