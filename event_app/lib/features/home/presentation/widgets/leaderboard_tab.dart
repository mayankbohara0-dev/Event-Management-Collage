import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/skeleton_loader.dart';

// ─────────────────────────────────────────────────────────────────────────────
// LeaderboardTab — Campus Rankings & Gamification
// Spec: Lime gradient header (radius 38), Weekly/All-Time pill toggle,
//       animated progress bars, leaderboard rows with rank badges.
// ─────────────────────────────────────────────────────────────────────────────

class LeaderboardTab extends StatefulWidget {
  const LeaderboardTab({super.key});

  @override
  State<LeaderboardTab> createState() => _LeaderboardTabState();
}

class _LeaderboardTabState extends State<LeaderboardTab> {
  bool _isLoading = true;
  int _selectedFilterIndex = 0; // 0: Weekly, 1: All-Time
  List<Map<String, dynamic>> _leaderboard = [];

  static const _filterOptions = ['This Week', 'All-Time'];

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    setState(() => _isLoading = true);
    try {
      final res = await Supabase.instance.client
          .from('student_profiles')
          .select('id, name, roll_number, participation_score, volunteer_score, departments(name)')
          .order('participation_score', ascending: false)
          .limit(30);

      final list = List<Map<String, dynamic>>.from(res as List);
      if (list.isNotEmpty) {
        // Calculate total points
        for (final item in list) {
          final pScore = (item['participation_score'] as num?)?.toInt() ?? 0;
          final vScore = (item['volunteer_score'] as num?)?.toInt() ?? 0;
          item['total_points'] = pScore + vScore;
        }
        list.sort((a, b) => (b['total_points'] as int).compareTo(a['total_points'] as int));
      }

      if (mounted) {
        setState(() {
          _leaderboard = list.isNotEmpty ? list : _demoLeaderboard;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading leaderboard: $e');
      if (mounted) {
        setState(() {
          _leaderboard = _demoLeaderboard;
          _isLoading = false;
        });
      }
    }
  }

  static final List<Map<String, dynamic>> _demoLeaderboard = [
    {
      'name': 'Aarav Sharma',
      'departments': {'name': 'Computer Eng.'},
      'total_points': 1420,
      'emoji': '🚀',
    },
    {
      'name': 'Priya Patel',
      'departments': {'name': 'Design & Media'},
      'total_points': 1280,
      'emoji': '🎨',
    },
    {
      'name': 'Rohan Mehta',
      'departments': {'name': 'Electronics'},
      'total_points': 1150,
      'emoji': '⚡',
    },
    {
      'name': 'Ananya Verma',
      'departments': {'name': 'Mechanical Eng.'},
      'total_points': 980,
      'emoji': '🛠️',
    },
    {
      'name': 'Devansh Rao',
      'departments': {'name': 'Information Tech.'},
      'total_points': 890,
      'emoji': '💻',
    },
    {
      'name': 'Sneha Kulkarni',
      'departments': {'name': 'Biotechnology'},
      'total_points': 760,
      'emoji': '🧬',
    },
    {
      'name': 'Kabir Nair',
      'departments': {'name': 'Architecture'},
      'total_points': 640,
      'emoji': '📐',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final topScore = _leaderboard.isNotEmpty
        ? (_leaderboard.first['total_points'] as num?)?.toDouble() ?? 1000.0
        : 1000.0;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: AppColors.ink,
        body: RefreshIndicator(
          color: AppColors.ink,
          backgroundColor: AppColors.lime,
          onRefresh: _loadLeaderboard,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              // ── Lime Gradient Header (Bottom Radius 38) ───────────────
              SliverToBoxAdapter(
                child: Container(
                  padding: EdgeInsets.fromLTRB(
                    18,
                    MediaQuery.of(context).padding.top + 20,
                    18,
                    28,
                  ),
                  decoration: const BoxDecoration(
                    gradient: AppColors.limeGradient,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(AppRadius.limeHeader),
                      bottomRight: Radius.circular(AppRadius.limeHeader),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Subtitle tag
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.ink.withValues(alpha: 0.12),
                              borderRadius: AppRadius.circularPill,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('🏆', style: TextStyle(fontSize: 13)),
                                const SizedBox(width: 6),
                                Text(
                                  'CAMPUS RANKINGS',
                                  style: AppTextStyles.metaLabel.copyWith(
                                    color: AppColors.ink,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Live dot
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.ink,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'LIVE',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.ink,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Leaderboard',
                        style: AppTextStyles.title38.copyWith(
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Compete in campus events, collect XP and top the hall of fame.',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.ink.withValues(alpha: 0.72),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Filter Segmented Pill Toggle
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.ink.withValues(alpha: 0.12),
                          borderRadius: AppRadius.circularPill,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(_filterOptions.length, (i) {
                            final isSel = i == _selectedFilterIndex;
                            return GestureDetector(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                setState(() => _selectedFilterIndex = i);
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 9,
                                ),
                                decoration: BoxDecoration(
                                  color: isSel ? AppColors.ink : Colors.transparent,
                                  borderRadius: AppRadius.circularPill,
                                ),
                                child: Text(
                                  _filterOptions[i],
                                  style: AppTextStyles.caption.copyWith(
                                    color: isSel ? AppColors.lime : AppColors.ink,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // ── Top 3 Podium (when data loaded) ───────────────────────
              if (!_isLoading && _leaderboard.length >= 3)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: _buildPodium(),
                  ),
                ),

              if (!_isLoading && _leaderboard.length >= 3)
                const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // ── Header for Full List ──────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Text(
                    'Full Rankings',
                    style: AppTextStyles.sectionHeader.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 12)),

              // ── Rankings List ─────────────────────────────────────────
              if (_isLoading)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: SkeletonLoader(
                          width: double.infinity,
                          height: 78,
                          radius: AppRadius.listRow,
                        ),
                      ),
                      childCount: 6,
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 120),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final item = _leaderboard[index];
                        final rank = index + 1;
                        final points = (item['total_points'] as num?)?.toInt() ?? 0;
                        final progress = (topScore > 0 ? points / topScore : 0.0)
                            .clamp(0.05, 1.0);

                        return _buildLeaderboardRow(
                          rank: rank,
                          item: item,
                          points: points,
                          progress: progress,
                        );
                      },
                      childCount: _leaderboard.length,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Podium Widget for Top 3 ────────────────────────────────────────────────
  Widget _buildPodium() {
    final first = _leaderboard[0];
    final second = _leaderboard[1];
    final third = _leaderboard[2];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // #2 Second Place (Left)
        Expanded(
          child: _buildPodiumCard(
            item: second,
            rank: 2,
            rankColor: AppColors.aqua,
            height: 160,
            badgeEmoji: '🥈',
          ),
        ),
        const SizedBox(width: 10),
        // #1 First Place (Center - Tallest)
        Expanded(
          child: _buildPodiumCard(
            item: first,
            rank: 1,
            rankColor: AppColors.mustard,
            height: 190,
            badgeEmoji: '👑',
            isFirst: true,
          ),
        ),
        const SizedBox(width: 10),
        // #3 Third Place (Right)
        Expanded(
          child: _buildPodiumCard(
            item: third,
            rank: 3,
            rankColor: AppColors.coral,
            height: 145,
            badgeEmoji: '🥉',
          ),
        ),
      ],
    );
  }

  Widget _buildPodiumCard({
    required Map<String, dynamic> item,
    required int rank,
    required Color rankColor,
    required double height,
    required String badgeEmoji,
    bool isFirst = false,
  }) {
    final name = (item['name']?.toString() ?? 'Student').split(' ').first;
    final points = (item['total_points'] as num?)?.toInt() ?? 0;

    return Container(
      height: height,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isFirst ? AppColors.surfaceCard : AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: isFirst
              ? AppColors.lime.withValues(alpha: 0.4)
              : AppColors.borderDark,
          width: isFirst ? 2 : 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Crown / Medal
          Text(badgeEmoji, style: const TextStyle(fontSize: 26)),
          const SizedBox(height: 6),

          // Name
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),

          // Points
          Text(
            '$points pts',
            style: AppTextStyles.caption.copyWith(
              color: isFirst ? AppColors.lime : AppColors.grey400,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Spacer(),

          // Rank Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: rankColor.withValues(alpha: 0.18),
              borderRadius: AppRadius.circularPill,
            ),
            child: Text(
              '#$rank',
              style: AppTextStyles.metaLabel.copyWith(
                color: rankColor,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Individual Leaderboard Row ─────────────────────────────────────────────
  Widget _buildLeaderboardRow({
    required int rank,
    required Map<String, dynamic> item,
    required int points,
    required double progress,
  }) {
    final name = item['name']?.toString() ?? 'Student';
    final dept = item['departments'] != null
        ? item['departments']['name']?.toString() ?? 'Campus Member'
        : 'Campus Member';

    Color rankColor;
    if (rank == 1) {
      rankColor = AppColors.mustard;
    } else if (rank == 2) {
      rankColor = AppColors.aqua;
    } else if (rank == 3) {
      rankColor = AppColors.coral;
    } else {
      rankColor = AppColors.grey400;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(AppRadius.listRow),
        border: Border.all(color: AppColors.borderDark, width: 1),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Rank indicator
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: rankColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '$rank',
                  style: TextStyle(
                    fontFamily: 'Bricolage Grotesque',
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: rankColor,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Student Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.title17.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dept,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.grey400,
                      ),
                    ),
                  ],
                ),
              ),

              // Points badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.ink,
                  borderRadius: AppRadius.circularPill,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$points',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.lime,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      'pts',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.grey400,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Animated progress bar
          ClipRRect(
            borderRadius: AppRadius.circularPill,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: progress),
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return LinearProgressIndicator(
                  value: value,
                  minHeight: 6,
                  backgroundColor: AppColors.ink,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    rank <= 3 ? AppColors.lime : AppColors.grey400,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
