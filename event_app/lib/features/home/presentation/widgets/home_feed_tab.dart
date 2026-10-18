import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/category_chips.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/greeting_header.dart';
import '../../../../core/widgets/hero_event_card.dart';
import '../../../../core/widgets/skeleton_loader.dart';
import '../../../../core/widgets/stat_tile.dart';
import '../../../../core/widgets/zest_points_badge.dart';

/// Zest Home Feed Tab
/// Features greeting header, gamification points badge, hero carousel,
/// category chips, stats overview, and fresh event feed.
class HomeFeedTab extends ConsumerStatefulWidget {
  final VoidCallback onProfileTap;
  final VoidCallback onMyEventsTap;
  final void Function(bool visible)? onScrollDirectionChange;

  const HomeFeedTab({
    super.key,
    required this.onProfileTap,
    required this.onMyEventsTap,
    this.onScrollDirectionChange,
  });

  @override
  ConsumerState<HomeFeedTab> createState() => _HomeFeedTabState();
}

class _HomeFeedTabState extends ConsumerState<HomeFeedTab> {
  List<Map<String, dynamic>> _events = [];
  List<Map<String, dynamic>> _filtered = [];
  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = true;
  String _selectedCategory = 'All';
  int _selectedCategoryIndex = 0;
  final _searchController = TextEditingController();
  String _searchQuery = '';
  Map<String, dynamic>? _profile;
  int _attendedCount = 0;
  int _registeredCount = 0;
  int _unreadNotifications = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final results = await Future.wait<dynamic>([
          Supabase.instance.client
              .from('student_profiles')
              .select('*, avatar_url')
              .eq('id', user.id)
              .maybeSingle(),
          Supabase.instance.client
              .from('attendance')
              .select('id')
              .eq('student_id', user.id),
          Supabase.instance.client
              .from('registrations')
              .select('id')
              .eq('student_id', user.id),
          Supabase.instance.client
              .from('notifications')
              .select('id')
              .eq('user_id', user.id)
              .eq('is_read', false),
        ]);

        _profile = results[0] as Map<String, dynamic>?;
        _attendedCount = (results[1] as List).length;
        _registeredCount = (results[2] as List).length;
        _unreadNotifications = (results[3] as List).length;
      }

      final cats = await Supabase.instance.client
          .from('event_categories')
          .select('id, name')
          .order('name');

      final events = await Supabase.instance.client
          .from('events')
          .select('id, title, short_description, start_date, end_date, venue, cover_image_url, category_id, max_capacity, event_categories(name)')
          .eq('visibility', 'published')
          .order('start_date', ascending: true);

      if (mounted) {
        setState(() {
          _categories = List<Map<String, dynamic>>.from(cats);
          _events = List<Map<String, dynamic>>.from(events);
          _applyFilters();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading home feed: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    List<Map<String, dynamic>> list = _events;

    if (_selectedCategory != 'All') {
      list = list.where((e) {
        final catName = e['event_categories']?['name']?.toString() ?? '';
        return catName == _selectedCategory;
      }).toList();
    }

    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((e) {
        final title = (e['title'] ?? '').toString().toLowerCase();
        final desc = (e['short_description'] ?? '').toString().toLowerCase();
        final venue = (e['venue'] ?? '').toString().toLowerCase();
        return title.contains(q) || desc.contains(q) || venue.contains(q);
      }).toList();
    }

    _filtered = list;
  }

  void _onCategorySelected(int index, List<ZestCategory> chipItems) {
    setState(() {
      _selectedCategoryIndex = index;
      _selectedCategory = chipItems[index].label;
      _applyFilters();
    });
  }

  @override
  Widget build(BuildContext context) {
    final name = _profile?['name']?.toString() ?? 'Student';
    final avatarUrl = _profile?['avatar_url']?.toString();
    final points = _profile?['points'] != null
        ? int.tryParse(_profile!['points'].toString()) ?? 60
        : 60;
    final zestLevel = (points ~/ 50) + 1;

    // Build category items list
    final categoryChipItems = [
      const ZestCategory(
        label: 'All',
        icon: '⚡',
        color: AppColors.coral,
      ),
      ..._categories.map((c) {
        final catName = c['name']?.toString() ?? '';
        return ZestCategory(
          label: catName,
          icon: _categoryEmoji(catName),
          color: _categoryColor(catName),
        );
      }),
    ];

    final featuredEvents = _events.take(4).toList();

    return RefreshIndicator(
      color: AppColors.coral,
      backgroundColor: AppColors.surface,
      onRefresh: _loadData,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        slivers: [
          // Top Safe Area Padding
          const SliverToBoxAdapter(child: SizedBox(height: 52)),

          // Greeting Header
          SliverToBoxAdapter(
            child: GreetingHeader(
              name: name,
              avatarUrl: avatarUrl,
              hasUnreadNotification: _unreadNotifications > 0,
              onBellTap: () => context.push('/notifications'),
              onAvatarTap: widget.onProfileTap,
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),

          // Zest Energy & Streak Banner
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
              child: Row(
                children: [
                  ZestPointsBadge(
                    points: points,
                    level: zestLevel,
                    compact: false,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: AppRadius.circularPill,
                        boxShadow: AppShadows.card,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('🔥', style: TextStyle(fontSize: 16)),
                          const SizedBox(width: 6),
                          Text(
                            'Active Explorer',
                            style: TextStyle(fontFamily: 'Bricolage Grotesque',
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.charcoal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.base)),

          // Search Pill
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppRadius.circularPill,
                  boxShadow: AppShadows.card,
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                      _applyFilters();
                    });
                  },
                  style: TextStyle(fontFamily: 'Bricolage Grotesque',
                    fontSize: 14,
                    color: AppColors.charcoal,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search fresh events, workshops, clubs...',
                    hintStyle: TextStyle(fontFamily: 'Bricolage Grotesque',
                      fontSize: 13,
                      color: AppColors.grey400,
                      fontWeight: FontWeight.w400,
                    ),
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.coral, size: 22),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.grey400),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                                _applyFilters();
                              });
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  ),
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),

          // Quick Impact Stats Row
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: widget.onMyEventsTap,
                      child: StatTile(
                        icon: Icons.confirmation_number_rounded,
                        value: '$_registeredCount',
                        label: 'Passes',
                        iconColor: AppColors.coral,
                        iconBg: AppColors.coralLight,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: StatTile(
                      icon: Icons.verified_rounded,
                      value: '$_attendedCount',
                      label: 'Attended',
                      iconColor: AppColors.teal,
                      iconBg: AppColors.tealLight,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: StatTile(
                      icon: Icons.bolt_rounded,
                      value: '$points',
                      label: 'Points',
                      iconColor: AppColors.mustard,
                      iconBg: AppColors.mustardLight,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),

          // Featured Carousel Section Header
          if (featuredEvents.isNotEmpty && _searchQuery.isEmpty && _selectedCategory == 'All') ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Featured Spotlight ⭐',
                      style: TextStyle(fontFamily: 'Bricolage Grotesque',
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.charcoal,
                      ),
                    ),
                    Text(
                      'Handpicked',
                      style: TextStyle(fontFamily: 'Bricolage Grotesque',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.coral,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sm)),

            // Hero Cards Carousel
            SliverToBoxAdapter(
              child: SizedBox(
                height: 190,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
                  itemCount: featuredEvents.length,
                  separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
                  itemBuilder: (context, i) {
                    final e = featuredEvents[i];
                    final catName = e['event_categories']?['name']?.toString() ?? 'Featured';
                    final date = _formatDate(e['start_date']?.toString());
                    final venue = e['venue']?.toString();

                    return HeroEventCard(
                      title: e['title']?.toString() ?? 'Event',
                      subtitle: e['short_description']?.toString() ?? 'Discover this experience',
                      tag: catName.toUpperCase(),
                      date: date,
                      venue: venue,
                      colorIndex: i,
                      heroTag: 'hero_featured_${e['id']}',
                      onTap: () => context.push('/student/event/${e['id']}'),
                    );
                  },
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
          ],

          // Category Chips
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
                  child: Text(
                    'Explore by Vibe ✨',
                    style: TextStyle(fontFamily: 'Bricolage Grotesque',
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.charcoal,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                CategoryChips(
                  categories: categoryChipItems,
                  selectedIndex: _selectedCategoryIndex,
                  onChanged: (idx) => _onCategorySelected(idx, categoryChipItems),
                ),
              ],
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),

          // Feed Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedCategory == 'All'
                        ? 'Fresh Events, Squeezed Daily 🍋'
                        : '$_selectedCategory Events',
                    style: TextStyle(fontFamily: 'Bricolage Grotesque',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.charcoal,
                    ),
                  ),
                  Text(
                    '${_filtered.length} found',
                    style: TextStyle(fontFamily: 'Bricolage Grotesque',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.grey400,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sm)),

          // Events Feed Body
          if (_isLoading)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, _) => const Padding(
                    padding: EdgeInsets.only(bottom: AppSpacing.md),
                    child: SkeletonEventCard(),
                  ),
                  childCount: 3,
                ),
              ),
            )
          else if (_filtered.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl2),
                child: EmptyState(
                  emoji: '🍋',
                  title: 'No Events Found',
                  subtitle: _searchQuery.isNotEmpty
                      ? "No events match '$_searchQuery'. Try clearing filters!"
                      : 'No events in this category yet. Check back soon for fresh drops!',
                  actionLabel: _searchQuery.isNotEmpty || _selectedCategory != 'All'
                      ? 'Clear Filters'
                      : null,
                  onAction: () {
                    setState(() {
                      _searchController.clear();
                      _searchQuery = '';
                      _selectedCategoryIndex = 0;
                      _selectedCategory = 'All';
                      _applyFilters();
                    });
                  },
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final event = _filtered[index];
                    return _ZestEventFeedCard(
                      event: event,
                      onTap: () => context.push('/student/event/${event['id']}'),
                    );
                  },
                  childCount: _filtered.length,
                ),
              ),
            ),

          // Bottom padding for floating pill nav bar
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }

  static String _formatDate(String? dateStr) {
    if (dateStr == null) return 'TBA';
    final d = DateTime.tryParse(dateStr)?.toLocal();
    if (d == null) return 'TBA';
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[d.month - 1]} ${d.day}';
  }

  static String _categoryEmoji(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('tech') || lower.contains('hack') || lower.contains('code')) return '💻';
    if (lower.contains('cultur') || lower.contains('music') || lower.contains('dance')) return '🎭';
    if (lower.contains('sport') || lower.contains('game')) return '🏆';
    if (lower.contains('work') || lower.contains('seminar')) return '🔬';
    if (lower.contains('art') || lower.contains('design')) return '🎨';
    if (lower.contains('lit') || lower.contains('quiz')) return '📚';
    return '🎯';
  }

  static Color _categoryColor(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('tech')) return AppColors.teal;
    if (lower.contains('cultur')) return AppColors.coral;
    if (lower.contains('sport')) return AppColors.orange;
    if (lower.contains('work')) return AppColors.periwinkle;
    return AppColors.mustard;
  }
}

/// Chunky rounded feed card with cover image, category badge, date, venue, and title
class _ZestEventFeedCard extends StatelessWidget {
  final Map<String, dynamic> event;
  final VoidCallback onTap;

  const _ZestEventFeedCard({
    required this.event,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final title = event['title']?.toString() ?? 'Event';
    final desc = event['short_description']?.toString() ?? '';
    final venue = event['venue']?.toString() ?? 'Campus';
    final coverImage = event['cover_image_url']?.toString();
    final catName = event['event_categories']?['name']?.toString() ?? 'General';
    final startDateStr = event['start_date']?.toString();
    final startDate = startDateStr != null ? DateTime.tryParse(startDateStr)?.toLocal() : null;

    final dateLabel = startDate != null
        ? () {
            const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
            return '${months[startDate.month - 1]} ${startDate.day}';
          }()
        : 'TBA';

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.base),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.circularXl2,
            boxShadow: AppShadows.card,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover image
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xl2)),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (coverImage != null && coverImage.isNotEmpty)
                        Image.network(
                          coverImage,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _fallbackBanner(),
                        )
                      else
                        _fallbackBanner(),
                      // Gradient overlay at bottom
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.6),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Category Tag Top Left
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            borderRadius: AppRadius.circularPill,
                            boxShadow: AppShadows.card,
                          ),
                          child: Text(
                            catName.toUpperCase(),
                            style: TextStyle(fontFamily: 'Bricolage Grotesque',
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.charcoal,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                      // Date Chip Bottom Right
                      Positioned(
                        bottom: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.charcoal.withValues(alpha: 0.85),
                            borderRadius: AppRadius.circularPill,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.calendar_today_rounded, size: 12, color: AppColors.white),
                              const SizedBox(width: 4),
                              Text(
                                dateLabel,
                                style: TextStyle(fontFamily: 'Bricolage Grotesque',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Content Body
              Padding(
                padding: const EdgeInsets.all(AppSpacing.base),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontFamily: 'Bricolage Grotesque',
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.charcoal,
                        height: 1.25,
                      ),
                    ),
                    if (desc.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        desc,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontFamily: 'Bricolage Grotesque',
                          fontSize: 12,
                          color: AppColors.grey600,
                          height: 1.4,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 14, color: AppColors.coral),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            venue,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontFamily: 'Bricolage Grotesque',
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.grey600,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.coralLight,
                            borderRadius: AppRadius.circularPill,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'View Pass',
                                style: TextStyle(fontFamily: 'Bricolage Grotesque',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.coral,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.arrow_forward_rounded, size: 12, color: AppColors.coral),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fallbackBanner() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.coral, AppColors.orange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(Icons.local_activity_rounded, size: 48, color: Colors.white30),
      ),
    );
  }
}
