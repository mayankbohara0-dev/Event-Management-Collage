import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/zest_tokens.dart';
import '../../../../shared/widgets/shared_widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// HomeFeedTab — Zest Student Feed
// Minimal, simple, modern, light UI matching the blue lemon blob brand.
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

      dynamic events;
      try {
        events = await Supabase.instance.client
            .from('events')
            .select('id, title, short_description, start_date, end_date, venue, cover_image_url, category_id, max_seats, event_categories(name)')
            .eq('visibility', 'published')
            .order('start_date', ascending: true);
      } catch (err) {
        debugPrint('Detailed select failed, falling back to basic: $err');
        events = await Supabase.instance.client
            .from('events')
            .select('id, title, short_description, start_date, end_date, venue, cover_image_url, category_id, max_seats')
            .eq('visibility', 'published')
            .order('start_date', ascending: true);
      }

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
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${days[now.weekday - 1].toUpperCase()}, ${months[now.month - 1].toUpperCase()} ${now.day}';
  }

  @override
  Widget build(BuildContext context) {
    final name = _profile?['name']?.toString() ?? 'Student';
    final firstName = name.split(' ').first;
    final rawPoints = _profile?['points'] != null
        ? int.tryParse(_profile!['points'].toString()) ?? 0
        : 0;
    // Fix legacy default 60 points if user has never attended an event
    final points = (rawPoints == 60 && _attendedCount == 0) ? 0 : rawPoints;
    final zestLevel = (points ~/ 50) + 1;
    final pointsIntoLevel = points % 50;
    final levelProgress = points == 0 ? 0.0 : (pointsIntoLevel / 50.0).clamp(0.05, 1.0);

    final categoryList = ['All', ..._categories.map((c) => c['name']?.toString() ?? '')];
    final featuredEvents = _events.take(5).toList();

    return Scaffold(
      backgroundColor: ZestTokens.page,
      body: RefreshIndicator(
        color: ZestTokens.blue,
        backgroundColor: Colors.white,
        onRefresh: _loadData,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            // ── 1. Top Header ──────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  ZestTokens.horizontalPadding,
                  MediaQuery.of(context).padding.top + 14,
                  ZestTokens.horizontalPadding,
                  12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Bar: Logo, Date/Greeting, Bell Notification
                    Row(
                      children: [
                        // 40px Zest Blob Logo
                        GestureDetector(
                          onTap: widget.onProfileTap,
                          child: const ZestBlobLogo(size: 40),
                        ),
                        const SizedBox(width: 14),

                        // Date & Hi, Name
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _dateString(),
                                style: ZestTokens.labelCaps.copyWith(
                                  fontSize: 11,
                                  color: ZestTokens.ink3,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              const SizedBox(height: 2),
                              RichText(
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Hi, ',
                                      style: ZestTokens.title.copyWith(fontSize: 22),
                                    ),
                                    TextSpan(
                                      text: firstName,
                                      style: ZestTokens.accentItalic.copyWith(
                                        fontSize: 26,
                                        color: ZestTokens.blue,
                                      ),
                                    ),
                                    TextSpan(
                                      text: ' 👋',
                                      style: ZestTokens.title.copyWith(fontSize: 20),
                                    ),
                                  ],
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
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: ZestTokens.line),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x0A0B1220),
                                  blurRadius: 10,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                const Icon(
                                  LucideIcons.bell,
                                  color: ZestTokens.ink,
                                  size: 20,
                                ),
                                if (_unreadNotifications > 0)
                                  Positioned(
                                    top: 10,
                                    right: 10,
                                    child: Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: ZestTokens.coral,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // Search Pill
                    Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: ZestTokens.borderPill,
                        border: Border.all(color: ZestTokens.line),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x080B1220),
                            blurRadius: 16,
                            offset: Offset(0, 4),
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
                        style: ZestTokens.body.copyWith(
                          color: ZestTokens.ink,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search fresh events, clubs...',
                          hintStyle: ZestTokens.body.copyWith(
                            color: ZestTokens.ink3,
                          ),
                          prefixIcon: const Icon(
                            LucideIcons.search,
                            color: ZestTokens.ink3,
                            size: 19,
                          ),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(
                                    LucideIcons.x,
                                    size: 18,
                                    color: ZestTokens.ink2,
                                  ),
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
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 6)),

            // ── 2. Journey Card ────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: ZestTokens.horizontalPadding,
                ),
                child: _buildJourneyCard(
                  points: points,
                  level: zestLevel,
                  progress: levelProgress,
                  nextTarget: (zestLevel * 50),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // ── 3. Category Chips ──────────────────────────────────────────
            SliverToBoxAdapter(
              child: SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: ZestTokens.horizontalPadding,
                  ),
                  itemCount: categoryList.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final cat = categoryList[i];
                    final isSelected = i == _selectedCategoryIndex;
                    return ZestChip(
                      label: cat,
                      isSelected: isSelected,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() {
                          _selectedCategoryIndex = i;
                          _selectedCategory = cat;
                          _applyFilters();
                        });
                      },
                    );
                  },
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // ── 4. Featured Spotlight Carousel ─────────────────────────────
            if (featuredEvents.isNotEmpty &&
                _searchQuery.isEmpty &&
                _selectedCategory == 'All') ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: ZestTokens.horizontalPadding,
                  ),
                  child: ZestSectionHeader(
                    title: 'Featured',
                    accentWord: 'spotlight',
                    actionLabel: widget.onExploreTap != null ? 'See all' : null,
                    onActionTap: widget.onExploreTap,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 14)),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 290,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: ZestTokens.horizontalPadding,
                    ),
                    itemCount: featuredEvents.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 16),
                    itemBuilder: (context, i) {
                      final e = featuredEvents[i];
                      final catName =
                          e['event_categories']?['name']?.toString() ?? 'Featured';
                      final date = _formatDate(e['start_date']?.toString());
                      final venue = e['venue']?.toString() ?? 'Campus';

                      return _buildFeaturedCard(
                        event: e,
                        category: catName,
                        date: date,
                        venue: venue,
                        onTap: () => context.push('/student/event/${e['id']}'),
                      );
                    },
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 28)),
            ],

            // ── 5. Fresh Events Section Header ─────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: ZestTokens.horizontalPadding,
                ),
                child: ZestSectionHeader(
                  title: _selectedCategory == 'All' ? 'Fresh' : _selectedCategory,
                  accentWord: 'events',
                  badgeText: '${_filtered.length} events',
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            // ── Events List Rows ───────────────────────────────────────────
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
                        height: 84,
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                    ),
                    childCount: 4,
                  ),
                ),
              )
            else if (_filtered.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
                  child: ZestEmptyState(
                    mascotMood: ZestMascotMood.sleepy,
                    title: 'No Events Found',
                    subtitle: _searchQuery.isNotEmpty
                        ? "No events match '$_searchQuery'. Try clearing your search!"
                        : 'No events in this category yet. Check back soon for fresh drops!',
                    actionLabel:
                        _searchQuery.isNotEmpty || _selectedCategory != 'All'
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
                padding: const EdgeInsets.symmetric(
                  horizontal: ZestTokens.horizontalPadding,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final event = _filtered[index];
                      final isRegistered =
                          _registeredEventIds.contains(event['id']);
                      return _buildEventListRow(
                        event: event,
                        isRegistered: isRegistered,
                        onTap: () =>
                            context.push('/student/event/${event['id']}'),
                      );
                    },
                    childCount: _filtered.length,
                  ),
                ),
              ),

            // Bottom padding for floating pill nav bar
            const SliverToBoxAdapter(child: SizedBox(height: 110)),
          ],
        ),
      ),
    );
  }

  // ── Journey Card Widget (matches Landing Page Hero Preview) ───────────────
  Widget _buildJourneyCard({
    required int points,
    required int level,
    required double progress,
    required int nextTarget,
  }) {
    final levelTitle = _getLevelTitle(level);
    final needed = (nextTarget - points).clamp(0, 9999);
    final batchYear = DateTime.now().year % 100;

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [ZestTokens.core, ZestTokens.blue],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x330AA5F0),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Level Title · Role  |  ⚡ XP Counter
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Level $level · $levelTitle',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: -0.1,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    LucideIcons.zap,
                    size: 13,
                    color: Color(0xFFFFD84D),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$points XP',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFFFD84D),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Sleek Progress Bar (aqua to lemon gradient)
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Container(
              height: 6,
              width: double.infinity,
              color: Colors.white.withValues(alpha: 0.22),
              child: Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: progress.clamp(0.04, 1.0),
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF6CE3FF), Color(0xFFFFD84D)],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Bottom Info Row: Batch '26  |  XP to next level
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Batch '$batchYear",
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.75),
                ),
              ),
              Text(
                '$needed XP to Level ${level + 1}',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.75),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Featured Spotlight Card ────────────────────────────────────────────────
  Widget _buildFeaturedCard({
    required Map<String, dynamic> event,
    required String category,
    required String date,
    required String venue,
    required VoidCallback onTap,
  }) {
    final gradient = ZestTokens.categoryGradient(category);
    final emoji = _categoryEmoji(category);
    final title = event['title']?.toString() ?? 'Featured Event';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 250,
        height: 290,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: ZestTokens.borderHero,
          boxShadow: const [
            BoxShadow(
              color: Color(0x200063F0),
              blurRadius: 20,
              offset: Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: Tag Pill + Big Emoji
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    borderRadius: ZestTokens.borderPill,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Text(
                    category.toUpperCase(),
                    style: ZestTokens.labelCaps.copyWith(
                      color: Colors.white,
                      fontSize: 10,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
                Text(
                  emoji,
                  style: const TextStyle(fontSize: 42, height: 1.0),
                ),
              ],
            ),

            const Spacer(),

            // Title
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 1.2,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 6),

            // Date / Venue
            Text(
              '$date • $venue',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),

            const SizedBox(height: 16),

            // Bottom Row: "FEATURED" pill + white circle with blue arrow
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: ZestTokens.borderPill,
                  ),
                  child: Text(
                    'FEATURED',
                    style: ZestTokens.labelCaps.copyWith(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                  ),
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x1A000000),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      LucideIcons.arrowRight,
                      color: ZestTokens.blue,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Spec-Exact Event List Row (matches Landing Page Hero Preview) ──────────
  Widget _buildEventListRow({
    required Map<String, dynamic> event,
    required bool isRegistered,
    required VoidCallback onTap,
  }) {
    final title = event['title']?.toString() ?? 'Event';
    final venue = event['venue']?.toString() ?? 'Campus Hall';
    final catName = event['event_categories']?['name']?.toString() ?? 'CAMPUS';
    final date = _formatDate(event['start_date']?.toString());
    final rawSeats = event['max_seats'] ?? event['max_capacity'];
    final seatsTotal = rawSeats is int ? rawSeats : int.tryParse(rawSeats?.toString() ?? '') ?? 100;
    final seatsLeft = (seatsTotal * 0.35).toInt();
    final xpReward = event['points_awarded'] ?? 150;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: ZestTokens.line),
            boxShadow: const [
              BoxShadow(
                color: Color(0x060B1220),
                blurRadius: 12,
                offset: Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Club / Category uppercase + Status Pill
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    catName.toUpperCase(),
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: ZestTokens.core,
                      letterSpacing: 0.8,
                    ),
                  ),
                  if (isRegistered)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: ZestTokens.borderPill,
                        border: Border.all(color: const Color(0xFFA7F3D0)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(LucideIcons.checkCircle2, size: 10, color: Color(0xFF10B981)),
                          SizedBox(width: 4),
                          Text(
                            'Going ✓',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF059669),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: ZestTokens.borderPill,
                        border: Border.all(color: const Color(0xFFBFDBFE)),
                      ),
                      child: const Text(
                        'Register',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: ZestTokens.blue,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 7),

              // Title
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: ZestTokens.ink,
                  letterSpacing: -0.2,
                ),
              ),

              const SizedBox(height: 8),

              // Date & Venue metadata row
              Row(
                children: [
                  const Icon(LucideIcons.calendar, size: 11.5, color: ZestTokens.ink3),
                  const SizedBox(width: 4),
                  Text(
                    date,
                    style: ZestTokens.caption.copyWith(
                      color: ZestTokens.ink3,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(LucideIcons.mapPin, size: 11.5, color: ZestTokens.ink3),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      venue,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: ZestTokens.caption.copyWith(
                        color: ZestTokens.ink3,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Divider
              Container(height: 1, color: ZestTokens.line),

              const SizedBox(height: 8),

              // Bottom Row: Seats Left | +XP Reward
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('⚡', style: TextStyle(fontSize: 11)),
                      const SizedBox(width: 3),
                      Text(
                        '$seatsLeft seats left',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: ZestTokens.coral,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '+$xpReward XP',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: ZestTokens.core,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getLevelTitle(int level) {
    if (level <= 1) return 'Fresher';
    if (level == 2) return 'Explorer';
    if (level == 3) return 'Trailblazer';
    if (level == 4) return 'Champion';
    return 'Campus Legend';
  }

  static String _formatDate(String? dateStr) {
    if (dateStr == null) return 'TBA';
    final d = DateTime.tryParse(dateStr)?.toLocal();
    if (d == null) return 'TBA';
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
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
