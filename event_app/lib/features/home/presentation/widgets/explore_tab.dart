import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/skeleton_loader.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ExploreTab — Discover all campus events
// Spec: "Explore" 38sp title + muted subtitle, search pill, explore cards
//   (radius 30, thumbnail + title + meta, seats-left progress bar 8px, caption)
//   Empty state: 'No events match "query"'
// ─────────────────────────────────────────────────────────────────────────────

class ExploreTab extends StatefulWidget {
  final void Function(bool visible)? onScrollDirectionChange;

  const ExploreTab({super.key, this.onScrollDirectionChange});

  @override
  State<ExploreTab> createState() => _ExploreTabState();
}

class _ExploreTabState extends State<ExploreTab> {
  List<Map<String, dynamic>> _events = [];
  List<Map<String, dynamic>> _filtered = [];
  bool _isLoading = true;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadEvents() async {
    setState(() => _isLoading = true);
    try {
      final events = await Supabase.instance.client
          .from('events')
          .select(
              'id, title, short_description, start_date, venue, cover_image_url, '
              'max_capacity, event_categories(name)')
          .eq('visibility', 'published')
          .order('start_date', ascending: true);

      if (mounted) {
        setState(() {
          _events = List<Map<String, dynamic>>.from(events);
          _applyFilter();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Explore load error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _applyFilter() {
    if (_searchQuery.trim().isEmpty) {
      _filtered = _events;
      return;
    }
    final q = _searchQuery.toLowerCase();
    _filtered = _events.where((e) {
      final title = (e['title'] ?? '').toString().toLowerCase();
      final desc = (e['short_description'] ?? '').toString().toLowerCase();
      final venue = (e['venue'] ?? '').toString().toLowerCase();
      return title.contains(q) || desc.contains(q) || venue.contains(q);
    }).toList();
  }

  static const _eventColors = [
    AppColors.coral,
    AppColors.lavender,
    AppColors.mustard,
    AppColors.aqua,
    AppColors.mint,
  ];

  Color _colorForIndex(int i) => _eventColors[i % _eventColors.length];

  String _formatDate(String? iso) {
    if (iso == null) return '';
    try {
      final dt = DateTime.parse(iso).toLocal();
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${months[dt.month - 1]} ${dt.day}';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: RefreshIndicator(
        color: AppColors.lime,
        backgroundColor: AppColors.ink2,
        onRefresh: _loadEvents,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics()),
          slivers: [
            // Safe area top
            const SliverToBoxAdapter(child: SizedBox(height: 52)),

            // ── Title + Subtitle ───────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Explore',
                      style: AppTextStyles.title38.copyWith(
                        color: AppColors.paper,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Discover what\'s happening on campus',
                      style: AppTextStyles.body15.copyWith(
                        color: AppColors.grey400,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // ── Search Pill ───────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.ink2,
                    borderRadius: AppRadius.circularPill,
                    border: Border.all(color: AppColors.borderDark, width: 1.5),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                        _applyFilter();
                      });
                    },
                    style: AppTextStyles.body15.copyWith(
                      color: AppColors.paper,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search events, workshops, clubs...',
                      hintStyle: AppTextStyles.body15.copyWith(
                        color: AppColors.grey400,
                      ),
                      prefixIcon: const Icon(Icons.search_rounded,
                          color: AppColors.grey400, size: 22),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close_rounded,
                                  size: 18, color: AppColors.grey400),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                  _applyFilter();
                                });
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                    ),
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // ── Event Cards ───────────────────────────────────────────
            if (_isLoading)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: SkeletonLoader(
                        width: double.infinity,
                        height: 120,
                        radius: AppRadius.exploreCard,
                      ),
                    ),
                    childCount: 5,
                  ),
                ),
              )
            else if (_filtered.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: EmptyState(
                    emoji: '🔍',
                    title: _searchQuery.isEmpty
                        ? 'No events yet'
                        : 'No events match "$_searchQuery"',
                    subtitle: _searchQuery.isEmpty
                        ? 'Check back soon for new events!'
                        : 'Try a different search term.',
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 120),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final e = _filtered[i];
                      final color = _colorForIndex(i);
                      final date = _formatDate(e['start_date']?.toString());
                      final venue = e['venue']?.toString() ?? '';
                      final title = e['title']?.toString() ?? 'Event';
                      final cat = e['event_categories']?['name']?.toString() ?? '';
                      final capacity = e['max_capacity'] is int
                          ? (e['max_capacity'] as int)
                          : int.tryParse(e['max_capacity']?.toString() ?? '') ?? 100;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _ExploreCard(
                          title: title,
                          category: cat,
                          date: date,
                          venue: venue,
                          color: color,
                          seatsTotal: capacity,
                          seatsLeft: (capacity * 0.35).toInt(), // placeholder until we join registrations
                          onTap: () => context.push('/student/event/${e['id']}'),
                        ),
                      );
                    },
                    childCount: _filtered.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ExploreCard — spec: radius 30, padding 18, thumbnail + title + meta,
//   seats-left progress bar (8px, ink fill), "N of M seats left" caption
// ─────────────────────────────────────────────────────────────────────────────
class _ExploreCard extends StatelessWidget {
  const _ExploreCard({
    required this.title,
    required this.category,
    required this.date,
    required this.venue,
    required this.color,
    required this.seatsTotal,
    required this.seatsLeft,
    this.onTap,
  });

  final String title;
  final String category;
  final String date;
  final String venue;
  final Color color;
  final int seatsTotal;
  final int seatsLeft;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final progress = seatsTotal > 0 ? seatsLeft / seatsTotal : 0.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.ink2,
          borderRadius: AppRadius.circularExplore,
          border: Border.all(color: AppColors.borderDark, width: 1.5),
        ),
        child: Row(
          children: [
            // Thumbnail
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.25),
                borderRadius: const BorderRadius.all(
                    Radius.circular(AppRadius.thumbnail)),
              ),
              child: Center(
                child: Text(
                  _emojiForCategory(category),
                  style: const TextStyle(fontSize: 26),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category tag
                  if (category.isNotEmpty)
                    Text(
                      category.toUpperCase(),
                      style: AppTextStyles.caption12.copyWith(
                        color: color,
                        letterSpacing: 0.6,
                      ),
                    ),
                  const SizedBox(height: 2),
                  Text(
                    title,
                    style: AppTextStyles.title17.copyWith(
                      color: AppColors.paper,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (date.isNotEmpty) ...[
                        const Icon(Icons.calendar_today_outlined,
                            size: 11, color: AppColors.grey400),
                        const SizedBox(width: 3),
                        Text(date,
                            style: AppTextStyles.caption12
                                .copyWith(color: AppColors.grey400)),
                        const SizedBox(width: 8),
                      ],
                      if (venue.isNotEmpty) ...[
                        const Icon(Icons.location_on_outlined,
                            size: 11, color: AppColors.grey400),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(venue,
                              style: AppTextStyles.caption12
                                  .copyWith(color: AppColors.grey400),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Seats progress bar
                  ClipRRect(
                    borderRadius: AppRadius.circularPill,
                    child: LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      minHeight: 8,
                      backgroundColor: AppColors.ink3,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$seatsLeft of $seatsTotal seats left',
                    style: AppTextStyles.caption12
                        .copyWith(color: AppColors.grey400),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.grey400, size: 20),
          ],
        ),
      ),
    );
  }

  static String _emojiForCategory(String cat) {
    final c = cat.toLowerCase();
    if (c.contains('tech') || c.contains('hack')) return '💻';
    if (c.contains('cultur') || c.contains('fest')) return '🎭';
    if (c.contains('sport')) return '🏅';
    if (c.contains('workshop')) return '🔧';
    if (c.contains('music')) return '🎵';
    if (c.contains('art')) return '🎨';
    if (c.contains('food')) return '🍕';
    return '⭐';
  }
}
