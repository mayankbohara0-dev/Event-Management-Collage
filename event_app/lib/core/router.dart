import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Landing
import '../features/landing/presentation/landing_screen.dart';

// Student Features
import '../features/auth/presentation/login_screen.dart' as student_auth;
import '../features/profile/presentation/profile_onboarding_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/events/presentation/registration_form_screen.dart';

// Admin Features
import '../features/admin/auth/presentation/login_screen.dart' as admin_auth;
import '../features/admin/dashboard/presentation/dashboard_layout.dart';
import '../features/admin/dashboard/presentation/dashboard_screen.dart';
import '../features/admin/events/presentation/events_table_screen.dart';
import '../features/admin/events/presentation/event_create_screen.dart';
import '../features/admin/events/presentation/form_builder_screen.dart';
import '../features/admin/events/presentation/event_responses_screen.dart';
import '../features/admin/registrations/presentation/registrations_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
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
        path: '/student/home',
        builder: (context, state) => const HomeScreen(),
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
