import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dashboard_layout.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _totalStudents = 0;
  int _upcomingEvents = 0;
  int _pendingRegistrations = 0;
  // Registrations per day for the last 7 days (index 0 = oldest, 6 = today)
  List<double> _weeklyRegs = List.filled(7, 0);
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    setState(() => _isLoading = true);
    try {
      // Compute the 7-day window boundaries (UTC midnight).
      final now = DateTime.now().toUtc();
      final todayMidnight = DateTime.utc(now.year, now.month, now.day);
      final weekAgo = todayMidnight.subtract(const Duration(days: 6));

      final results = await Future.wait([
        Supabase.instance.client.from('student_profiles').select('id'),
        Supabase.instance.client
            .from('events')
            .select('id')
            .eq('visibility', 'published')
            .gte('start_date', DateTime.now().toIso8601String()),
        Supabase.instance.client
            .from('registrations')
            .select('id')
            .eq('status', 'pending'),
        // Fetch registrations created in the last 7 days for the chart.
        Supabase.instance.client
            .from('registrations')
            .select('created_at')
            .gte('created_at', weekAgo.toIso8601String()),
      ]);

      // Bucket registrations by day-of-week offset (0 = 6 days ago … 6 = today).
      final weeklyRegs = List<double>.filled(7, 0);
      final recentRegs = results[3] as List;
      for (final reg in recentRegs) {
        final createdAt = DateTime.tryParse(reg['created_at'].toString())?.toUtc();
        if (createdAt == null) continue;
        final dayOffset = createdAt
            .difference(weekAgo)
            .inDays
            .clamp(0, 6);
        weeklyRegs[dayOffset] += 1;
      }

      if (mounted) {
        setState(() {
          _totalStudents = (results[0] as List).length;
          _upcomingEvents = (results[1] as List).length;
          _pendingRegistrations = (results[2] as List).length;
          _weeklyRegs = weeklyRegs;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching stats: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AdminColors.bg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top Bar ─────────────────────────────────────────────
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
            decoration: const BoxDecoration(
              color: AdminColors.sidebar,
              border: Border(
                  bottom: BorderSide(color: AdminColors.border, width: 1)),
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Dashboard',
                      style: TextStyle(
                        color: AdminColors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    Text(
                      'Welcome back, Admin 👋',
                      style: TextStyle(
                          color: AdminColors.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
                const Spacer(),
                // Refresh button
                IconButton(
                  onPressed: _fetchStats,
                  icon: const Icon(Icons.refresh_rounded,
                      color: AdminColors.textSecondary),
                  tooltip: 'Refresh',
                ),
              ],
            ),
          ),

          // ── Content ──────────────────────────────────────────────
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: AdminColors.accent))
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // KPI Cards
                        Row(
                          children: [
                            _KpiCard(
                              title: 'Total Students',
                              value: _totalStudents.toString(),
                              icon: Icons.people_rounded,
                              gradient: const LinearGradient(
                                colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              // No made-up trend — show a neutral label
                              trend: 'All time',
                              trendUp: true,
                            ),
                            const SizedBox(width: 16),
                            _KpiCard(
                              title: 'Upcoming Events',
                              value: _upcomingEvents.toString(),
                              icon: Icons.event_available_rounded,
                              gradient: const LinearGradient(
                                colors: [Color(0xFF065F46), Color(0xFF10B981)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              trend: 'Published',
                              trendUp: true,
                            ),
                            const SizedBox(width: 16),
                            _KpiCard(
                              title: 'Pending Approvals',
                              value: _pendingRegistrations.toString(),
                              icon: Icons.pending_actions_rounded,
                              gradient: const LinearGradient(
                                colors: [Color(0xFF92400E), Color(0xFFFFB800)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              trend: _pendingRegistrations == 0
                                  ? 'All clear'
                                  : 'Action needed',
                              trendUp: _pendingRegistrations == 0,
                            ),
                          ],
                        ),

                        const SizedBox(height: 28),

                        // Chart — real data
                        _ChartCard(weeklyRegs: _weeklyRegs),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// KPI CARD
// ─────────────────────────────────────────────
class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final LinearGradient gradient;
  final String trend;
  final bool trendUp;

  const _KpiCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.gradient,
    required this.trend,
    required this.trendUp,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AdminColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AdminColors.border),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: trendUp
                        ? AdminColors.success.withOpacity(0.15)
                        : AdminColors.gold.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    trend,
                    style: TextStyle(
                      color: trendUp ? AdminColors.success : AdminColors.gold,
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
              style: const TextStyle(
                color: AdminColors.textPrimary,
                fontSize: 34,
                fontWeight: FontWeight.w800,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                  color: AdminColors.textSecondary, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// CHART CARD  — real 7-day registrations
// ─────────────────────────────────────────────
class _ChartCard extends StatelessWidget {
  /// Registration counts indexed [0]=6 days ago … [6]=today.
  final List<double> weeklyRegs;

  const _ChartCard({required this.weeklyRegs});

  @override
  Widget build(BuildContext context) {
    final maxY = weeklyRegs.reduce((a, b) => a > b ? a : b);
    // Ensure a sensible minimum height so the chart isn't flat when there's no data.
    final chartMaxY = (maxY < 5 ? 5 : maxY + (maxY * 0.2)).ceilToDouble();

    // Build day labels: starting from 6 days ago up to today.
    final now = DateTime.now();
    final dayLabels = List.generate(7, (i) {
      final d = now.subtract(Duration(days: 6 - i));
      const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return names[d.weekday - 1];
    });

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AdminColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AdminColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Registration Trends',
                style: TextStyle(
                  color: AdminColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AdminColors.surfaceLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('Last 7 Days',
                    style: TextStyle(
                        color: AdminColors.textSecondary, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 220,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: chartMaxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: AdminColors.border,
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx >= 0 && idx < dayLabels.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              dayLabels[idx],
                              style: const TextStyle(
                                  color: AdminColors.textSecondary,
                                  fontSize: 12),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) => Text(
                        value.toInt().toString(),
                        style: const TextStyle(
                            color: AdminColors.textSecondary, fontSize: 11),
                      ),
                    ),
                  ),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(7, (i) => _bar(i, weeklyRegs[i])),
              ),
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _bar(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          gradient: const LinearGradient(
            colors: [Color(0xFF7C3AED), Color(0xFF5B21B6)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          width: 28,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
        ),
      ],
    );
  }
}
