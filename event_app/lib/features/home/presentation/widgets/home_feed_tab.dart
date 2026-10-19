import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/hero_event_card.dart';
import '../../../../core/widgets/skeleton_loader.dart';
import '../../../../core/widgets/zest_logo.dart';

// ─────────────────────────────────────────────────────────────────────────────
// HomeFeedTab — Zest Student Feed
// Spec-exact implementation:
// 1. Lime gradient header (bottom corners radius 38), 44px logo mark, date,
//    "Hi, {Name} 👋" 22sp, notification bell with coral dot, white search pill.
// 2. Journey card overlapping header by 14px (ink bg, radius 34, 56sp lime
//    points counter, animated progress bar, Z watermark).
// 3. Category chips (padding 11×18, rounded pill, active/inactive states).
// 4. Featured Spotlight carousel (250×290, radius 34, solid color, 64sp emoji,
//    27sp Bricolage title, 48px ink circle with lime arrow).
// 5. Fresh Events list rows (radius 26, 12px padding, 60px thumbnail with emoji,
//    title 17sp w800, date/venue, lime "Register" / "Going ✓" pill).
// ─────────────────────────────────────────────────────────────────────────────

class HomeFeedTab extends ConsumerStatefulWidget {
  final VoidCallback onProfileTap;
  final VoidCallback onMyEventsTap;
  final VoidCallback? onExploreTap;
  final void Function(bool visible)? onScrollDirectionChange;

  const HomeFeedTab({
    super.key,
    required this.onProfileTap,
    required this.onMyEventsTap,
    this.onExploreTap,
    this.onScrollDirectionChange,
  });

  @override
  ConsumerState<HomeFeedTab> createState() => _HomeFeedTabState();
}

class _HomeFeedTabState extends ConsumerState<HomeFeedTab> {
  List<Map<String, dynamic>> _events = [];
  List<Map<String, dynamic>> _filtered = [];
  List<Map<String, dynamic>> _categories = [];
  Set<String> _registeredEventIds = {};
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
              .select('id, event_id')
              .eq('student_id', user.id),
          Supabase.instance.client
              .from('notifications')
              .select('id')
              .eq('user_id', user.id)
              .eq('is_read', false),
        ]);

        _profile = results[0] as Map<String, dynamic>?;
        _attendedCount = (results[1] as List).length;
        final regList = (results[2] as List);
        _registeredCount = regList.length;
        _registeredEventIds = regList
            .map((r) => r['event_id']?.toString() ?? '')
            .where((id) => id.isNotEmpty)
            .toSet();
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

  String _dateString() {
    final now = DateTime.now();
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    const days = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
    return '${days[now.weekday - 1].toUpperCase()}, ${months[now.month - 1].toUpperCase()} ${now.day}';
  }

  @override
  Widget build(BuildContext context) {
    final name = _profile?['name']?.toString() ?? 'Student';
    final firstName = name.split(' ').first;
    final points = _profile?['points'] != null
        ? int.tryParse(_profile!['points'].toString()) ?? 140
        : 140;
    final zestLevel = (points ~/ 50) + 1;
    final pointsIntoLevel = points % 50;
    final levelProgress = (pointsIntoLevel / 50.0).clamp(0.05, 1.0);

    // Build category list
    final categoryList = ['All', ..._categories.map((c) => c['name']?.toString() ?? '')];
    final featuredEvents = _events.take(5).toList();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: AppColors.ink,
        body: RefreshIndicator(
          color: AppColors.ink,
          backgroundColor: AppColors.lime,
          onRefresh: _loadData,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              // ── 1. Lime Gradient Header (Bottom Radius 38) ─────────────
              SliverToBoxAdapter(
                child: Container(
                  padding: EdgeInsets.fromLTRB(
                    18,
                    MediaQuery.of(context).padding.top + 16,
                    18,
                    36,
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
                      // Top Row: Logo, Date/Greeting, Bell Notification
                      Row(
                        children: [
                          // 44px Zest Logo Mark
                          GestureDetector(
                            onTap: widget.onProfileTap,
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.ink,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              alignment: Alignment.center,
                              child: const ZestLogo.markSmall(size: 26),
                            ),
                          ),
                          const SizedBox(width: 14),

                          // Date & Hi, Name
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _dateString(),
                                  style: AppTextStyles.metaLabel.copyWith(
                                    color: AppColors.ink.withValues(alpha: 0.65),
                                    fontSize: 11,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Hi, $firstName 👋',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.title22.copyWith(
                                    color: AppColors.ink,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Notification Bell with Coral Dot
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              context.push('/notifications');
                            },
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: AppColors.ink.withValues(alpha: 0.12),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.notifications_outlined,
                                    color: AppColors.ink,
                                    size: 22,
                                  ),
                                ),
                                if (_unreadNotifications > 0)
                                  Positioned(
                                    top: 10,
                                    right: 10,
                                    child: Container(
                                      width: 9,
                                      height: 9,
                                      decoration: const BoxDecoration(
                                        color: AppColors.coral,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // White Search Pill
                      Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: AppRadius.circularPill,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.ink.withValues(alpha: 0.08),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (val) {
                            setState(() {
                              _searchQuery = val;
                              _applyFilters();
                            });
                          },
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.ink,
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search fresh events, clubs...',
                            hintStyle: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.grey400,
                              fontWeight: FontWeight.w500,
                            ),
                            prefixIcon: const Icon(
                              Icons.search_rounded,
                              color: AppColors.ink,
                              size: 22,
                            ),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.ink),
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
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── 2. Journey Card (Overlapping Lime Header by 14px) ───────
              SliverToBoxAdapter(
                child: Transform.translate(
                  offset: const Offset(0, -14),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: _buildJourneyCard(
                      points: points,
                      level: zestLevel,
                      progress: levelProgress,
                      nextTarget: (zestLevel * 50),
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 8)),

              // ── 3. Category Chips (11×18 padding, fully rounded) ────────
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 44,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    itemCount: categoryList.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, i) {
                      final cat = categoryList[i];
                      final isSelected = i == _selectedCategoryIndex;
                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() {
                            _selectedCategoryIndex = i;
                            _selectedCategory = cat;
                            _applyFilters();
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 11,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.lime : AppColors.surfaceDark,
                            borderRadius: AppRadius.circularPill,
                            border: Border.all(
                              color: isSelected ? AppColors.lime : AppColors.borderDark,
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              cat,
                              style: AppTextStyles.caption.copyWith(
                                color: isSelected ? AppColors.ink : AppColors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 28)),

              // ── 4. Featured Spotlight Carousel ─────────────────────────
              if (featuredEvents.isNotEmpty && _searchQuery.isEmpty && _selectedCategory == 'All') ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Featured Spotlight ⭐',
                          style: AppTextStyles.title24.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                        if (widget.onExploreTap != null)
                          GestureDetector(
                            onTap: widget.onExploreTap,
                            child: Text(
                              'See all',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.lime,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 305,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      itemCount: featuredEvents.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 16),
                      itemBuilder: (context, i) {
                        final e = featuredEvents[i];
                        final catName = e['event_categories']?['name']?.toString() ?? 'Featured';
                        final date = _formatDate(e['start_date']?.toString());
                        final venue = e['venue']?.toString();

                        return HeroEventCard(
                          title: e['title']?.toString() ?? 'Campus Event',
                          subtitle: e['short_description']?.toString() ?? 'Join the campus buzz',
                          tag: catName,
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
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],

              // ── 5. Fresh Events Section Header ─────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedCategory == 'All'
                            ? 'Fresh Events 🎪'
                            : '$_selectedCategory Events',
                        style: AppTextStyles.title24.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceDark,
                          borderRadius: AppRadius.circularPill,
                          border: Border.all(color: AppColors.borderDark),
                        ),
                        child: Text(
                          '${_filtered.length} events',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.grey400,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 14)),

              // ── Events List Rows ───────────────────────────────────────
              if (_isLoading)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: SkeletonLoader(
                          width: double.infinity,
                          height: 84,
                          radius: AppRadius.listRow,
                        ),
                      ),
                      childCount: 4,
                    ),
                  ),
                )
              else if (_filtered.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: EmptyState(
                      emoji: '🍋',
                      title: 'No Events Found',
                      subtitle: _searchQuery.isNotEmpty
                          ? "No events match '$_searchQuery'. Try clearing your search!"
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
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final event = _filtered[index];
                        final isRegistered = _registeredEventIds.contains(event['id']);
                        return _buildEventListRow(
                          event: event,
                          colorIndex: index,
                          isRegistered: isRegistered,
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
        ),
      ),
    );
  }

  // ── Journey Card Widget ────────────────────────────────────────────────────
  Widget _buildJourneyCard({
    required int points,
    required int level,
    required double progress,
    required int nextTarget,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(AppRadius.journeyCard),
        border: Border.all(color: AppColors.borderDark, width: 1.5),
        boxShadow: AppShadows.card,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.journeyCard),
        child: Stack(
          children: [
            // Watermark Z in bottom-right
            Positioned(
              right: -20,
              bottom: -25,
              child: Opacity(
                opacity: 0.05,
                child: Text(
                  'Z',
                  style: TextStyle(
                    fontFamily: 'Bricolage Grotesque',
                    fontSize: 180,
                    fontWeight: FontWeight.w900,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),

            // Card Content
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: Tag + Level Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.lime.withValues(alpha: 0.15),
                          borderRadius: AppRadius.circularPill,
                        ),
                        child: Text(
                          'YOUR ZEST XP',
                          style: AppTextStyles.pillTag.copyWith(
                            color: AppColors.lime,
                            fontSize: 11,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceCard,
                          borderRadius: AppRadius.circularPill,
                          border: Border.all(color: AppColors.borderDark),
                        ),
                        child: Text(
                          'LEVEL $level',
                          style: AppTextStyles.metaLabel.copyWith(
                            color: AppColors.lime,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Big Points Counter (56sp Bricolage Lime)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      TweenAnimationBuilder<int>(
                        tween: IntTween(begin: 0, end: points),
                        duration: const Duration(milliseconds: 1300),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, _) {
                          return Text(
                            '$value',
                            style: AppTextStyles.display56.copyWith(
                              color: AppColors.lime,
                              height: 1.0,
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'pts',
                        style: AppTextStyles.title24.copyWith(
                          color: AppColors.grey400,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // Progress explanation
                  Text(
                    '${nextTarget - points} pts to Level ${level + 1} • $_registeredCount passes • $_attendedCount attended',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.grey400,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Animated Progress Bar
                  ClipRRect(
                    borderRadius: AppRadius.circularPill,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0.0, end: progress),
                      duration: const Duration(milliseconds: 1600),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, _) {
                        return LinearProgressIndicator(
                          value: value,
                          minHeight: 8,
                          backgroundColor: AppColors.ink3,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.lime),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Spec-Exact Event List Row ──────────────────────────────────────────────
  Widget _buildEventListRow({
    required Map<String, dynamic> event,
    required int colorIndex,
    required bool isRegistered,
    required VoidCallback onTap,
  }) {
    final title = event['title']?.toString() ?? 'Event';
    final venue = event['venue']?.toString() ?? 'Campus Hall';
    final catName = event['event_categories']?['name']?.toString() ?? 'General';
    final date = _formatDate(event['start_date']?.toString());
    final emoji = _categoryEmoji(catName);

    const thumbnailColors = [
      AppColors.coral,
      AppColors.lavender,
      AppColors.mustard,
      AppColors.aqua,
      AppColors.teal,
      AppColors.orange,
    ];
    final thumbColor = thumbnailColors[colorIndex % thumbnailColors.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(AppRadius.listRow),
        border: Border.all(color: AppColors.borderDark, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.listRow),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.listRow),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // 60px thumbnail with solid event color + 28sp emoji
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: thumbColor,
                    borderRadius: BorderRadius.circular(AppRadius.thumbnail),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    emoji,
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
                const SizedBox(width: 14),

                // Center Info: Title 17sp w800, date/venue 13sp muted
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.title17.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$date • $venue',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.grey400,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),

                // Right: Lime Pill "Register" or "Going ✓"
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isRegistered
                        ? AppColors.ink
                        : AppColors.lime,
                    borderRadius: AppRadius.circularPill,
                    border: isRegistered
                        ? Border.all(color: AppColors.lime.withValues(alpha: 0.5))
                        : null,
                  ),
                  child: Text(
                    isRegistered ? 'Going ✓' : 'Register',
                    style: AppTextStyles.caption.copyWith(
                      color: isRegistered ? AppColors.lime : AppColors.ink,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
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
    return '⚡';
  }
}
