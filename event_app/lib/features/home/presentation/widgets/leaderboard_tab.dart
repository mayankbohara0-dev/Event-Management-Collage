import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/zest_tokens.dart';
import '../../../../shared/widgets/shared_widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// LeaderboardTab — Campus Rankings & Gamification
// Minimal, clean, modern light UI matching Designjoy aesthetic.
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

    return Scaffold(
      backgroundColor: ZestTokens.page,
      body: RefreshIndicator(
        color: ZestTokens.blue,
        backgroundColor: Colors.white,
        onRefresh: _loadLeaderboard,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            // Safe area top
            SliverToBoxAdapter(
              child: SizedBox(
                height: MediaQuery.of(context).padding.top + 16,
              ),
            ),

            // ── Screen Header ──────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: ZestTokens.horizontalPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Subtitle tag + LIVE indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F6FE),
                            borderRadius: ZestTokens.borderPill,
                            border: Border.all(color: ZestTokens.sky.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('🏆', style: TextStyle(fontSize: 12)),
                              const SizedBox(width: 5),
                              Text(
                                'CAMPUS RANKINGS',
                                style: ZestTokens.labelCaps.copyWith(
                                  color: ZestTokens.blue,
                                  fontSize: 10,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Live dot indicator
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: ZestTokens.borderPill,
                            border: Border.all(color: ZestTokens.line),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 7,
                                height: 7,
                                decoration: const BoxDecoration(
                                  color: ZestTokens.success,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                'LIVE',
                                style: ZestTokens.labelCaps.copyWith(
                                  color: ZestTokens.ink,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Leader',
                            style: ZestTokens.display.copyWith(fontSize: 32),
                          ),
                          TextSpan(
                            text: 'board',
                            style: ZestTokens.accentItalic.copyWith(
                              fontSize: 36,
                              color: ZestTokens.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Compete in campus events, collect XP and top the hall of fame',
                      style: ZestTokens.body.copyWith(
                        color: ZestTokens.ink2,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Filter Toggle
                    ZestSegmentedToggle(
                      segments: _filterOptions,
                      selectedIndex: _selectedFilterIndex,
                      onChanged: (i) {
                        HapticFeedback.selectionClick();
                        setState(() => _selectedFilterIndex = i);
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // ── Top 3 Podium ───────────────────────────────────────────
            if (!_isLoading && _leaderboard.length >= 3)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: ZestTokens.horizontalPadding,
                  ),
                  child: _buildPodium(),
                ),
              ),

            if (!_isLoading && _leaderboard.length >= 3)
              const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // ── Section Header for Full List ───────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: ZestTokens.horizontalPadding,
                ),
                child: ZestSectionHeader(
                  title: 'Full',
                  accentWord: 'rankings',
                  badgeText: '${_leaderboard.length} students',
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            // ── Rankings List ──────────────────────────────────────────
            if (_isLoading)
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: ZestTokens.horizontalPadding,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => const Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: ZestSkeleton(
                        width: double.infinity,
                        height: 76,
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                    ),
                    childCount: 6,
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  ZestTokens.horizontalPadding,
                  0,
                  ZestTokens.horizontalPadding,
                  110,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = _leaderboard[index];
                      final rank = index + 1;
                      final points =
                          (item['total_points'] as num?)?.toInt() ?? 0;
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
            rankColor: ZestTokens.blue,
            height: 165,
            badgeEmoji: '🥈',
          ),
        ),
        const SizedBox(width: 10),
        // #1 First Place (Center - Tallest)
        Expanded(
          child: _buildPodiumCard(
            item: first,
            rank: 1,
            rankColor: ZestTokens.lemon,
            height: 195,
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
            rankColor: ZestTokens.coral,
            height: 150,
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isFirst ? ZestTokens.core : ZestTokens.line,
          width: isFirst ? 1.5 : 1,
        ),
        boxShadow: isFirst
            ? const [
                BoxShadow(
                  color: Color(0x200063F0),
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ]
            : ZestTokens.cardShadow,
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
            style: ZestTokens.bodyBold.copyWith(
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 2),

          // Points
          Text(
            '$points pts',
            style: ZestTokens.caption.copyWith(
              color: isFirst ? ZestTokens.blue : ZestTokens.ink2,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
          const Spacer(),

          // Rank Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: isFirst ? const Color(0xFFE8F6FE) : ZestTokens.fill,
              borderRadius: ZestTokens.borderPill,
            ),
            child: Text(
              '#$rank',
              style: ZestTokens.labelCaps.copyWith(
                color: isFirst ? ZestTokens.blue : ZestTokens.ink2,
                fontWeight: FontWeight.w700,
                fontSize: 11,
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

    final isTop3 = rank <= 3;
    Color rankColor;
    if (rank == 1) {
      rankColor = const Color(0xFFD97706);
    } else if (rank == 2) {
      rankColor = ZestTokens.blue;
    } else if (rank == 3) {
      rankColor = ZestTokens.coral;
    } else {
      rankColor = ZestTokens.ink3;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ZestCard(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                // Rank indicator
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isTop3
                        ? rankColor.withValues(alpha: 0.12)
                        : ZestTokens.fill,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$rank',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
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
                        style: ZestTokens.bodyBold.copyWith(
                          fontSize: 14.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        dept,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: ZestTokens.caption.copyWith(
                          color: ZestTokens.ink3,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                // Points badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F6FE),
                    borderRadius: ZestTokens.borderPill,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$points',
                        style: ZestTokens.caption.copyWith(
                          color: ZestTokens.blue,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        'pts',
                        style: ZestTokens.caption.copyWith(
                          color: ZestTokens.ink3,
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
            ZestProgressBar(
              value: progress,
              height: 5,
              progressGradient: isTop3
                  ? ZestTokens.brandGradient
                  : LinearGradient(
                      colors: [
                        ZestTokens.ink3.withValues(alpha: 0.4),
                        ZestTokens.ink3.withValues(alpha: 0.6),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
