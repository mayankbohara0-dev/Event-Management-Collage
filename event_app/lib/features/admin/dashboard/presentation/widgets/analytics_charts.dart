import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../admin_colors.dart';

class AnalyticsSection extends StatefulWidget {
  const AnalyticsSection({super.key});

  @override
  State<AnalyticsSection> createState() => _AnalyticsSectionState();
}

class _AnalyticsSectionState extends State<AnalyticsSection> {
  bool _isLoading = true;
  List<double> _monthlyRegs = List.filled(30, 0);
  Map<String, int> _categoryStats = {};

  @override
  void initState() {
    super.initState();
    _fetchAnalytics();
  }

  Future<void> _fetchAnalytics() async {
    try {
      final now = DateTime.now().toUtc();
      final todayMidnight = DateTime.utc(now.year, now.month, now.day);
      final thirtyDaysAgo = todayMidnight.subtract(const Duration(days: 29));

      final results = await Future.wait([
        // 0 - 30 days registrations
        Supabase.instance.client
            .from('registrations')
            .select('created_at')
            .gte('created_at', thirtyDaysAgo.toIso8601String()),
        // 1 - Category stats (events count per category)
        Supabase.instance.client
            .from('events')
            .select('id, event_categories(name)'),
      ]);

      // Process 30-day registrations
      final regs = results[0] as List;
      final monthly = List<double>.filled(30, 0);
      for (final reg in regs) {
        final createdAt = DateTime.tryParse(reg['created_at'].toString())?.toUtc();
        if (createdAt == null) continue;
        final dayOffset = createdAt.difference(thirtyDaysAgo).inDays.clamp(0, 29);
        monthly[dayOffset] += 1;
      }

      // Process Category Stats
      final events = results[1] as List;
      final catStats = <String, int>{};
      for (final event in events) {
        final catObj = event['event_categories'];
        if (catObj != null && catObj is Map && catObj['name'] != null) {
          final name = catObj['name'] as String;
          catStats[name] = (catStats[name] ?? 0) + 1;
        } else {
          catStats['Uncategorized'] = (catStats['Uncategorized'] ?? 0) + 1;
        }
      }

      if (mounted) {
        setState(() {
          _monthlyRegs = monthly;
          _categoryStats = catStats;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching analytics: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 300,
        child: Center(child: CircularProgressIndicator(color: AdminColors.accent)),
      );
    }

    return LayoutBuilder(builder: (context, constraints) {
      final isNarrow = constraints.maxWidth < 800;
      
      final lineChart = _LineChartCard(monthlyRegs: _monthlyRegs);
      final pieChart = _PieChartCard(categoryStats: _categoryStats);

      if (isNarrow) {
        return Column(
          children: [
            lineChart,
            const SizedBox(height: 24),
            pieChart,
          ],
        );
      }

      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 3, child: lineChart),
          const SizedBox(width: 24),
          Expanded(flex: 2, child: pieChart),
        ],
      );
    });
  }
}

class _LineChartCard extends StatelessWidget {
  final List<double> monthlyRegs;
  const _LineChartCard({required this.monthlyRegs});

  @override
  Widget build(BuildContext context) {
    final maxY = monthlyRegs.isEmpty ? 5 : monthlyRegs.reduce((a, b) => a > b ? a : b);
    final chartMaxY = (maxY < 5 ? 5 : maxY + (maxY * 0.2)).ceilToDouble();

    List<FlSpot> spots = [];
    for (int i = 0; i < monthlyRegs.length; i++) {
      spots.add(FlSpot(i.toDouble(), monthlyRegs[i]));
    }

    return Container(
      padding: const EdgeInsets.all(24),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Registration Trends',
                    style: GoogleFonts.inter(
                      color: AdminColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'New registrations (Last 30 days)',
                    style: GoogleFonts.inter(
                      color: AdminColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 250,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => const FlLine(
                    color: AdminColors.border,
                    strokeWidth: 1,
                    dashArray: [5, 5],
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 7,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx == 0) return const Text('30d ago', style: TextStyle(fontSize: 10, color: AdminColors.textSecondary));
                        if (idx == 29) return const Text('Today', style: TextStyle(fontSize: 10, color: AdminColors.textSecondary));
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
                        style: GoogleFonts.inter(
                          color: AdminColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 29,
                minY: 0,
                maxY: chartMaxY,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: AdminColors.gold,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AdminColors.gold.withValues(alpha: 0.3),
                          AdminColors.gold.withValues(alpha: 0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PieChartCard extends StatelessWidget {
  final Map<String, int> categoryStats;
  const _PieChartCard({required this.categoryStats});

  @override
  Widget build(BuildContext context) {
    final colors = [
      const Color(0xFF3B82F6),
      const Color(0xFF10B981),
      const Color(0xFFF59E0B),
      const Color(0xFF8B5CF6),
      const Color(0xFFEF4444),
      const Color(0xFF14B8A6),
    ];

    final entries = categoryStats.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value)); // Sort descending

    final sections = <PieChartSectionData>[];
    for (int i = 0; i < entries.length; i++) {
      final isLarge = entries[i].value > 0;
      sections.add(
        PieChartSectionData(
          color: colors[i % colors.length],
          value: entries[i].value.toDouble(),
          title: '${entries[i].value}',
          radius: isLarge ? 50 : 40,
          titleStyle: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(24),
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
          Text(
            'Event Distribution',
            style: GoogleFonts.inter(
              color: AdminColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            'Events by category',
            style: GoogleFonts.inter(
              color: AdminColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 200,
            child: sections.isEmpty
                ? const Center(child: Text('No categories found'))
                : PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: sections,
                    ),
                  ),
          ),
          const SizedBox(height: 24),
          // Legend
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: List.generate(entries.length, (i) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: colors[i % colors.length],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    entries[i].key,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AdminColors.textSecondary,
                    ),
                  ),
                ],
              );
            }),
          )
        ],
      ),
    );
  }
}
