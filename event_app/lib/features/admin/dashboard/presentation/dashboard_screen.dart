import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../admin_colors.dart';
import 'widgets/analytics_charts.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _totalStudents = 0;
  int _upcomingEvents = 0;
  int _pendingRegistrations = 0;
  int _totalRegistrations = 0;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final now = DateTime.now().toUtc();
      final todayMidnight = DateTime.utc(now.year, now.month, now.day);
      final weekAgo = todayMidnight.subtract(const Duration(days: 6));

      final results = await Future.wait([
        // 0 — total students
        Supabase.instance.client.from('student_profiles').select('id'),
        // 1 — upcoming published events
        Supabase.instance.client
            .from('events')
            .select('id')
            .eq('visibility', 'published')
            .gte('start_date', DateTime.now().toIso8601String()),
        // 2 — pending registrations
        Supabase.instance.client
            .from('registrations')
            .select('id')
            .eq('status', 'pending'),
        // 3 — all-time registrations count
        Supabase.instance.client.from('registrations').select('id'),
      ]);

      if (mounted) {
        setState(() {
          _totalStudents = (results[0] as List).length;
          _upcomingEvents = (results[1] as List).length;
          _pendingRegistrations = (results[2] as List).length;
          _totalRegistrations = (results[3] as List).length;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching stats: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AdminColors.bg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top Bar ─────────────────────────────────────────────────
          _TopBar(onRefresh: _fetchStats),

          // ── Content ──────────────────────────────────────────────────
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AdminColors.accent),
                  )
                : _errorMessage != null
                    ? _ErrorView(
                        message: _errorMessage!,
                        onRetry: _fetchStats,
                      )
                    : RefreshIndicator(
                        color: AdminColors.accent,
                        onRefresh: _fetchStats,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // KPI grid — 2-across on wide, 1-across on narrow
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  final isNarrow = constraints.maxWidth < 500;
                                  final kpiCards = [
                                    _KpiCard(
                                      title: 'Total Students',
                                      value: _totalStudents.toString(),
                                      icon: Icons.people_rounded,
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      badge: 'All time',
                                      badgeGood: true,
                                    ),
                                    _KpiCard(
                                      title: 'Upcoming Events',
                                      value: _upcomingEvents.toString(),
                                      icon: Icons.event_available_rounded,
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFF065F46), Color(0xFF10B981)],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      badge: 'Published',
                                      badgeGood: true,
                                    ),
                                    _KpiCard(
                                      title: 'Pending Approvals',
                                      value: _pendingRegistrations.toString(),
                                      icon: Icons.pending_actions_rounded,
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFF92400E), Color(0xFFFFB800)],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      badge: _pendingRegistrations == 0
                                          ? 'All clear'
                                          : 'Action needed',
                                      badgeGood: _pendingRegistrations == 0,
                                    ),
                                    _KpiCard(
                                      title: 'Total Registrations',
                                      value: _totalRegistrations.toString(),
                                      icon: Icons.how_to_reg_rounded,
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFF4C1D95), Color(0xFF7C3AED)],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      badge: 'All time',
                                      badgeGood: true,
                                    ),
                                  ];

                                  if (isNarrow) {
                                    return Column(
                                      children: kpiCards
                                          .map((c) => Padding(
                                                padding: const EdgeInsets.only(bottom: 16),
                                                child: c,
                                              ))
                                          .toList(),
                                    );
                                  }

                                  // 2-column grid
                                  final cardWidth = (constraints.maxWidth - 16) / 2;
                                  return Wrap(
                                    spacing: 16,
                                    runSpacing: 16,
                                    children: kpiCards
                                        .map((c) =>
                                            SizedBox(width: cardWidth, child: c))
                                        .toList(),
                                  );
                                },
                              ),

                              const SizedBox(height: 28),
                              const AnalyticsSection(),
                              const SizedBox(height: 28),
                              _QuickActions(),
                            ],
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// TOP BAR
// ────────────────────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  final VoidCallback onRefresh;
  const _TopBar({required this.onRefresh});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
      decoration: const BoxDecoration(
        color: AdminColors.sidebar,
        border: Border(bottom: BorderSide(color: AdminColors.border)),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dashboard',
                style: GoogleFonts.inter(
                  color: AdminColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              Text(
                '${_greeting()}, Admin 👋',
                style: GoogleFonts.inter(
                  color: AdminColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const Spacer(),
          Tooltip(
            message: 'Refresh stats',
            child: IconButton(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh_rounded,
                  color: AdminColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// KPI CARD
// ────────────────────────────────────────────────────────────────────────────
class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final LinearGradient gradient;
  final String badge;
  final bool badgeGood;

  const _KpiCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.gradient,
    required this.badge,
    required this.badgeGood,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AdminColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AdminColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeGood
                      ? AdminColors.success.withValues(alpha: 0.12)
                      : AdminColors.gold.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  badge,
                  style: GoogleFonts.inter(
                    color: badgeGood ? AdminColors.success : AdminColors.gold,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: GoogleFonts.inter(
              color: AdminColors.textPrimary,
              fontSize: 34,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.inter(
              color: AdminColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}


// ────────────────────────────────────────────────────────────────────────────
// QUICK ACTIONS
// ────────────────────────────────────────────────────────────────────────────
class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    final actions = [
      (
        icon: Icons.add_circle_rounded,
        label: 'Create Event',
        subtitle: 'Add a new event',
        color: AdminColors.accent,
        route: '/admin/events/create',
      ),
      (
        icon: Icons.event_note_rounded,
        label: 'Manage Events',
        subtitle: 'View all events',
        color: const Color(0xFF3B82F6),
        route: '/admin/events',
      ),
      (
        icon: Icons.pending_actions_rounded,
        label: 'Registrations',
        subtitle: 'Approve / reject',
        color: AdminColors.gold,
        route: '/admin/registrations',
      ),
      (
        icon: Icons.delete_forever_rounded,
        label: 'DANGER',
        subtitle: 'Wipe all events',
        color: AdminColors.error,
        route: 'DELETE_ALL_EVENTS',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: GoogleFonts.inter(
            color: AdminColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: actions
              .map((a) => _QuickActionCard(
                    icon: a.icon,
                    label: a.label,
                    subtitle: a.subtitle,
                    color: a.color,
                    onTap: () async {
                      if (a.route == 'DELETE_ALL_EVENTS') {
                        try {
                          await Supabase.instance.client.from('events').delete().neq('id', '00000000-0000-0000-0000-000000000000');
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All Events Deleted! Refreshing...')));
                            context.go('/admin/dashboard');
                          }
                        } catch (e) {
                          if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: \$e')));
                        }
                      } else {
                        context.go(a.route);
                      }
                    },
                  ))
              .toList(),
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 190,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AdminColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AdminColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 14),
            Text(
              label,
              style: GoogleFonts.inter(
                color: AdminColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                color: AdminColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// ERROR VIEW
// ────────────────────────────────────────────────────────────────────────────
class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AdminColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: AdminColors.error,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load stats',
              style: GoogleFonts.inter(
                color: AdminColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: AdminColors.textSecondary,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AdminColors.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
