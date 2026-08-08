import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/design_system.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  void _goToProfile() => setState(() => _selectedIndex = 2);

  @override
  Widget build(BuildContext context) {
    final pages = [
      _HomeFeed(onProfileTap: _goToProfile),
      _MyRegistrations(onProfileTap: _goToProfile),
      _ProfileTab(onProfileTap: _goToProfile),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          border: Border(top: BorderSide(color: AppColors.grey100, width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (i) => setState(() => _selectedIndex = i),
          backgroundColor: AppColors.white,
          selectedItemColor: AppColors.green,
          unselectedItemColor: AppColors.grey400,
          selectedLabelStyle: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700),
          unselectedLabelStyle: GoogleFonts.inter(fontSize: 11),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.explore_outlined),
              activeIcon: Icon(Icons.explore),
              label: 'Explore',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.how_to_reg_outlined),
              activeIcon: Icon(Icons.how_to_reg),
              label: 'My Events',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

// ── SHARED PROFILE AVATAR BUTTON ────────────────────
/// A small circular avatar used in every AppBar.
/// Shows the profile picture if available, otherwise shows initials.
/// Tapping it navigates to the Profile tab.
class _ProfileAvatarButton extends StatelessWidget {
  final Map<String, dynamic>? profile;
  final VoidCallback onTap;
  const _ProfileAvatarButton({required this.profile, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final name = profile?['name']?.toString() ?? 'S';
    final avatarUrl = profile?['avatar_url']?.toString();
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'S';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
        ),
        child: CircleAvatar(
          radius: 18,
          backgroundColor: AppColors.yellow,
          backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
              ? NetworkImage(avatarUrl)
              : null,
          child: (avatarUrl == null || avatarUrl.isEmpty)
              ? Text(
                  initial,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: AppColors.black,
                  ),
                )
              : null,
        ),
      ),
    );
  }
}

// ── HOME FEED ─────────────────────────────────
class _HomeFeed extends ConsumerStatefulWidget {
  final VoidCallback onProfileTap;
  const _HomeFeed({required this.onProfileTap});

  @override
  ConsumerState<_HomeFeed> createState() => _HomeFeedState();
}

class _HomeFeedState extends ConsumerState<_HomeFeed> {
  List<Map<String, dynamic>> _events = [];
  List<Map<String, dynamic>> _filtered = [];
  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = true;
  String _selectedCategory = 'All';
  final _searchController = TextEditingController();
  Map<String, dynamic>? _profile;
  int _attendedCount = 0;

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
        // Run profile and attendance count in parallel with explicit typed futures.
        final profileFuture = Supabase.instance.client
            .from('student_profiles')
            .select('*, avatar_url')
            .eq('id', user.id)
            .maybeSingle();
        final attendanceFuture = Supabase.instance.client
            .from('attendance')
            .select('id')
            .eq('student_id', user.id);
        final profileRes = await profileFuture;
        final attendanceRes = await attendanceFuture;
        _profile = profileRes;
        _attendedCount = (attendanceRes as List).length;
      }
      // Fetch categories from DB
      final cats = await Supabase.instance.client
          .from('event_categories')
          .select('id, name')
          .order('name');
      // Fetch events with category name join
      final events = await Supabase.instance.client
          .from('events')
          .select('id, title, short_description, start_date, end_date, venue, cover_image_url, category_id, event_categories(name)')
          .eq('visibility', 'published')
          .order('start_date', ascending: true);
      if (mounted) {
        setState(() {
          _categories = List<Map<String, dynamic>>.from(cats);
          _events = List<Map<String, dynamic>>.from(events);
          _filtered = _events;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _filter(String cat) {
    setState(() {
      _selectedCategory = cat;
      _filtered = cat == 'All'
          ? _events
          : _events.where((e) {
              final catName = e['event_categories']?['name']?.toString() ?? '';
              return catName == cat;
            }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final name = _profile?['name']?.toString().split(' ').first ?? 'Student';
    return RefreshIndicator(
      color: AppColors.green,
      onRefresh: _loadData,
      child: CustomScrollView(
        slivers: [
          // ── App Bar (green) ──
          SliverAppBar(
            pinned: true,
            expandedHeight: 160,
            backgroundColor: AppColors.green,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: AppColors.green,
                padding: const EdgeInsets.fromLTRB(20, 60, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Hi $name! 👋',
                                style: GoogleFonts.inter(
                                    color: AppColors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900)),
                            Text('What event are you looking for?',
                                style: GoogleFonts.inter(
                                    color: AppColors.white.withOpacity(0.8),
                                    fontSize: 13)),
                          ],
                        ),
                        // Avatar in app bar — taps to Profile tab
                        _ProfileAvatarButton(
                          profile: _profile,
                          onTap: widget.onProfileTap,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(52),
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (q) => setState(() {
                    _filtered = q.isEmpty
                        ? _events
                        : _events.where((e) =>
                            (e['title'] ?? '').toLowerCase().contains(q.toLowerCase())).toList();
                  }),
                  decoration: InputDecoration(
                    hintText: 'Search events...',
                    hintStyle: GoogleFonts.inter(color: AppColors.grey400, fontSize: 14),
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.grey400, size: 20),
                    filled: false,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
            actionsIconTheme: const IconThemeData(color: AppColors.white),
          ),

          // ── Points / Rewards card ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              child: _PointsCard(
                profile: _profile,
                attendedCount: _attendedCount,
              ),
            ),
          ),

          // ── Categories ──
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Categories',
                      style: GoogleFonts.inter(
                          fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.black)),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 38,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _categories.length + 1,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      final cat = i == 0 ? 'All' : _categories[i - 1]['name'].toString();
                      final selected = _selectedCategory == cat;
                      return GestureDetector(
                        onTap: () => _filter(cat),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: selected ? AppColors.green : AppColors.grey100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            cat,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: selected ? AppColors.white : AppColors.grey800,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),

          // ── Loading / Events ──
          if (_isLoading)
            SliverFillRemaining(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: 3,
                itemBuilder: (_, __) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Shimmer.fromColors(
                    baseColor: AppColors.grey100,
                    highlightColor: AppColors.white,
                    child: Container(
                      height: 250,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ),
            )
          else if (_filtered.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.network(
                      'https://illustrations.popsy.co/amber/surreal-hourglass.svg',
                      width: 150,
                      height: 150,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.event_busy_outlined, size: 64, color: AppColors.grey200),
                    ),
                    const SizedBox(height: 16),
                    Text('No events found', style: GoogleFonts.inter(color: AppColors.grey800, fontSize: 18, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Text('Check back later or adjust filters', style: GoogleFonts.inter(color: AppColors.grey400, fontSize: 14)),
                  ],
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) => _EventCard(event: _filtered[i]),
                childCount: _filtered.length,
              ),
            ),

          const SliverPadding(padding: EdgeInsets.only(bottom: 20)),
        ],
      ),
    );
  }
}

// ── POINTS CARD ───────────────────────────────
class _PointsCard extends StatelessWidget {
  final Map<String, dynamic>? profile;
  /// Number of events the student has actually checked in to.
  final int attendedCount;

  const _PointsCard({this.profile, required this.attendedCount});

  @override
  Widget build(BuildContext context) {
    final points = attendedCount * 100;
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          // Decorative circle
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.white.withOpacity(0.08),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.yellow,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text('EVENT REWARDS',
                            style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1,
                                color: AppColors.black)),
                      ),
                      const SizedBox(height: 10),
                      Text('$points pts',
                          style: GoogleFonts.inter(
                              color: AppColors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w900)),
                      Text(
                        attendedCount == 0
                            ? 'Attend events to earn points'
                            : 'From $attendedCount event${attendedCount == 1 ? '' : 's'} attended',
                        style: GoogleFonts.inter(
                            color: AppColors.white.withOpacity(0.75),
                            fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.yellow,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('My Events',
                          style: GoogleFonts.inter(
                              color: AppColors.black,
                              fontSize: 13,
                              fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── EVENT CARD ────────────────────────────────
class _EventCard extends StatelessWidget {
  final Map<String, dynamic> event;
  const _EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final date = event['start_date'] != null
        ? DateTime.tryParse(event['start_date'].toString())
        : null;
    // Use the joined category name, not the UUID
    final categoryName = event['event_categories']?['name']?.toString() ?? 'General';
    final coverImage = event['cover_image_url']?.toString();

    return GestureDetector(
      onTap: () => context.push('/student/event/${event['id']}'),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover Image or colored banner
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: coverImage != null && coverImage.isNotEmpty
                  ? Image.network(
                      coverImage,
                      height: 160,
                      width: double.infinity,
                      cacheWidth: 800,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return _buildImagePlaceholder(categoryName, event['title'] ?? '');
                      },
                      errorBuilder: (_, __, ___) => _buildImagePlaceholder(categoryName, event['title'] ?? ''),
                    )
                  : _buildImagePlaceholder(categoryName, event['title'] ?? ''),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _categoryColor(categoryName).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          categoryName.toUpperCase(),
                          style: GoogleFonts.inter(
                              color: _categoryColor(categoryName),
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5),
                        ),
                      ),
                      const Spacer(),
                      if (date != null)
                        Text(
                          '${_month(date.month)} ${date.day}',
                          style: GoogleFonts.inter(
                              color: AppColors.grey400,
                              fontSize: 13,
                              fontWeight: FontWeight.w600),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    event['title'] ?? 'Event',
                    style: GoogleFonts.inter(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.black),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if ((event['short_description'] ?? '').toString().isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      event['short_description'].toString(),
                      style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.grey400,
                          height: 1.4),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      if ((event['venue'] ?? '').toString().isNotEmpty) ...[
                        const Icon(Icons.location_on_rounded, size: 14, color: AppColors.grey400),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event['venue'].toString(),
                            style: GoogleFonts.inter(
                                color: AppColors.grey400,
                                fontSize: 12,
                                fontWeight: FontWeight.w500),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.green,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'View Event',
                          style: GoogleFonts.inter(
                              color: AppColors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700),
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
    );
  }

  Widget _buildImagePlaceholder(String categoryName, String title) {
    final color = _categoryColor(categoryName);
    final icon = _categoryIcon(categoryName);
    return Container(
      height: 160,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Decorative circle
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            left: -20,
            bottom: -20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Colors.white.withOpacity(0.9), size: 40),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    title,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _categoryIcon(String cat) {
    switch (cat.toLowerCase()) {
      case 'hackathon':
      case 'tech':
        return Icons.code_rounded;
      case 'cultural':
        return Icons.celebration_rounded;
      case 'sports':
        return Icons.sports_rounded;
      case 'academic':
      case 'seminar':
        return Icons.school_rounded;
      case 'workshop':
        return Icons.build_rounded;
      case 'competition':
        return Icons.emoji_events_rounded;
      case 'music':
        return Icons.music_note_rounded;
      default:
        return Icons.event_rounded;
    }
  }

  Color _categoryColor(String cat) {
    switch (cat.toLowerCase()) {
      case 'hackathon':
      case 'tech':
        return const Color(0xFF0077FF);
      case 'cultural':
        return const Color(0xFFFF6B35);
      case 'sports':
        return const Color(0xFF00C853);
      case 'academic':
      case 'seminar':
        return const Color(0xFF7C3AED);
      case 'workshop':
        return const Color(0xFFFF8C00);
      default:
        return AppColors.green;
    }
  }

  String _month(int m) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return months[m - 1];
  }
}

// ── MY REGISTRATIONS ──────────────────────────
class _MyRegistrations extends ConsumerStatefulWidget {
  final VoidCallback onProfileTap;
  const _MyRegistrations({required this.onProfileTap});

  @override
  ConsumerState<_MyRegistrations> createState() => _MyRegistrationsState();
}

class _MyRegistrationsState extends ConsumerState<_MyRegistrations> {
  List<Map<String, dynamic>> _registrations = [];
  Map<String, dynamic>? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      // Load profile and registrations in parallel
      final results = await Future.wait([
        Supabase.instance.client
            .from('student_profiles')
            .select('name, avatar_url')
            .eq('id', user.id)
            .maybeSingle(),
        Supabase.instance.client
            .from('registrations')
            .select('*, events(title, start_date, venue, cover_image_url)')
            .eq('student_id', user.id)
            .order('created_at', ascending: false),
      ]);

      if (mounted) {
        setState(() {
          _profile = results[0] as Map<String, dynamic>?;
          _registrations = List<Map<String, dynamic>>.from(results[1] as List);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('My Events load error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.green,
        elevation: 0,
        title: Text('My Events', style: GoogleFonts.inter(color: AppColors.white, fontWeight: FontWeight.w800)),
        centerTitle: false,
        actions: [
          // Use cached _profile — no FutureBuilder needed
          _ProfileAvatarButton(
            profile: _profile,
            onTap: widget.onProfileTap,
          ),
        ],
      ),
      body: _isLoading
          ? ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 4,
              itemBuilder: (_, __) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Shimmer.fromColors(
                  baseColor: AppColors.grey100,
                  highlightColor: AppColors.white,
                  child: Container(
                    height: 80,
                    decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            )
          : _registrations.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.network(
                        'https://illustrations.popsy.co/amber/falling.svg',
                        width: 150,
                        height: 150,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.calendar_today_outlined, size: 64, color: AppColors.grey200),
                      ),
                      const SizedBox(height: 16),
                      Text("You haven't registered yet",
                          style: GoogleFonts.inter(
                              color: AppColors.grey800,
                              fontSize: 18,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      Text('Find events on the Explore tab',
                          style: GoogleFonts.inter(color: AppColors.grey400, fontSize: 14)),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _registrations.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final reg = _registrations[i];
                    final event = reg['events'] as Map<String, dynamic>? ?? {};
                    final status = (reg['status'] ?? 'pending').toString();
                    final statusColor = status == 'approved'
                        ? AppColors.green
                        : status == 'rejected'
                            ? AppColors.error
                            : AppColors.yellow;

                    return Container(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: AppColors.greenLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.event_note_rounded, color: AppColors.green),
                        ),
                        title: Text(
                          event['title'] ?? 'Event',
                          style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          event['venue'] ?? '',
                          style: GoogleFonts.inter(color: AppColors.grey400, fontSize: 12),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Status badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                status[0].toUpperCase() + status.substring(1),
                                style: GoogleFonts.inter(
                                    color: statusColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // QR Ticket button — always visible
                            IconButton(
                              icon: Icon(
                                Icons.qr_code_rounded,
                                color: status == 'rejected'
                                    ? AppColors.grey300
                                    : AppColors.green,
                              ),
                              tooltip: status == 'rejected'
                                  ? 'Registration rejected'
                                  : 'View Ticket',
                              onPressed: status == 'rejected'
                                  ? null
                                  : () => _showTicketDialog(context, reg, event, status, statusColor),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  void _showTicketDialog(
    BuildContext context,
    Map<String, dynamic> reg,
    Map<String, dynamic> event,
    String status,
    Color statusColor,
  ) {
    // Use qr_code_data if available, otherwise fall back to registration ID
    final qrData = reg['qr_code_data']?.toString().isNotEmpty == true
        ? reg['qr_code_data'].toString()
        : reg['id']?.toString() ?? 'NO_DATA';

    final eventTitle = event['title']?.toString() ?? 'Event';
    final venue = event['venue']?.toString() ?? '';
    final dateStr = event['start_date'] != null
        ? () {
            final d = DateTime.tryParse(event['start_date'].toString());
            if (d == null) return '';
            const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
            return '${months[d.month - 1]} ${d.day}, ${d.year}';
          }()
        : '';

    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Green header ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                decoration: BoxDecoration(
                  color: status == 'pending'
                      ? const Color(0xFFFFA000)
                      : AppColors.green,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  children: [
                    Icon(
                      status == 'approved'
                          ? Icons.confirmation_number_rounded
                          : Icons.hourglass_top_rounded,
                      color: Colors.white,
                      size: 36,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      status == 'approved' ? 'Your Ticket' : 'Registration Pending',
                      style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        status.toUpperCase(),
                        style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Dashed divider ──
              CustomPaint(
                size: const Size(double.infinity, 24),
                painter: _DashedDividerPainter(),
              ),

              // ── QR Code ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: QrImageView(
                  data: qrData,
                  version: QrVersions.auto,
                  size: 200.0,
                  eyeStyle: QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: status == 'pending'
                        ? const Color(0xFFFFA000)
                        : AppColors.green,
                  ),
                  dataModuleStyle: QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: status == 'pending'
                        ? const Color(0xFFFFA000)
                        : AppColors.green,
                  ),
                ),
              ),

              // ── Event details ──
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                child: Column(
                  children: [
                    Text(
                      eventTitle,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.black),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (dateStr.isNotEmpty || venue.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      if (dateStr.isNotEmpty)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.calendar_today_rounded,
                                size: 13, color: AppColors.grey400),
                            const SizedBox(width: 4),
                            Text(dateStr,
                                style: GoogleFonts.inter(
                                    color: AppColors.grey400, fontSize: 13)),
                          ],
                        ),
                      if (venue.isNotEmpty)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.location_on_outlined,
                                size: 13, color: AppColors.grey400),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                venue,
                                style: GoogleFonts.inter(
                                    color: AppColors.grey400, fontSize: 13),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                    ],
                    const SizedBox(height: 12),
                    Text(
                      status == 'approved'
                          ? 'Show this QR at the entrance to check in.'
                          : 'QR will be activated once your registration is approved.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                          color: AppColors.grey400, fontSize: 12, height: 1.4),
                    ),
                  ],
                ),
              ),

              // ── Close button ──
              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.greenLight,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text('Close',
                        style: GoogleFonts.inter(
                            color: AppColors.green,
                            fontWeight: FontWeight.w700,
                            fontSize: 15)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Paints a dashed horizontal line for the ticket perforation effect
class _DashedDividerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const dashWidth = 8.0;
    const dashSpace = 5.0;
    const circleRadius = 12.0;

    final paint = Paint()
      ..color = const Color(0xFFEEEEEE)
      ..style = PaintingStyle.fill;

    // Left circle cutout
    canvas.drawCircle(Offset(-circleRadius, size.height / 2), circleRadius, paint);
    // Right circle cutout
    canvas.drawCircle(Offset(size.width + circleRadius, size.height / 2), circleRadius, paint);

    // Dashed line
    final linePaint = Paint()
      ..color = const Color(0xFFDDDDDD)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, size.height / 2),
        Offset(startX + dashWidth, size.height / 2),
        linePaint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── PROFILE TAB ───────────────────────────────
class _ProfileTab extends ConsumerStatefulWidget {
  final VoidCallback onProfileTap;
  const _ProfileTab({required this.onProfileTap});

  @override
  ConsumerState<_ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends ConsumerState<_ProfileTab> {
  Map<String, dynamic>? _profile;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    try {
      final p = await Supabase.instance.client
          .from('student_profiles')
          .select('*, departments(name)')
          .eq('id', user.id)
          .maybeSingle();
      if (mounted) setState(() => _profile = p);
    } catch (e) {
      debugPrint('Error loading profile: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = _profile?['name']?.toString() ?? 'Student';
    final email = Supabase.instance.client.auth.currentUser?.email ?? '';
    final dept = (_profile?['departments'] != null) ? _profile!['departments']['name']?.toString() ?? '' : '';
    final prn = _profile?['enrollment_number']?.toString() ?? '';
    final roll = _profile?['roll_number']?.toString() ?? '';
    final year = _profile?['year']?.toString() ?? '';
    final sem = _profile?['semester']?.toString() ?? '';
    final div = _profile?['division']?.toString() ?? '';
    final avatarUrl = _profile?['avatar_url']?.toString();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors.green,
            expandedHeight: 200,
            pinned: true,
            actions: [
              // Small avatar stays visible when bar is collapsed
              _ProfileAvatarButton(
                profile: _profile,
                onTap: widget.onProfileTap,
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: AppColors.green,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Camera/edit overlay on avatar
                    GestureDetector(
                      onTap: () async {
                        await context.push('/student/edit-profile');
                        if (mounted) _load();
                      },
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 44,
                            backgroundColor: AppColors.yellow,
                            backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                            child: avatarUrl == null
                                ? Text(
                                    name.isNotEmpty ? name[0].toUpperCase() : 'S',
                                    style: GoogleFonts.inter(
                                        fontSize: 34,
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.black),
                                  )
                                : null,
                          ),
                          Positioned(
                            bottom: 2,
                            right: 2,
                            child: Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                color: AppColors.green,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: const Icon(Icons.camera_alt_rounded,
                                  size: 13, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(name,
                        style: GoogleFonts.inter(
                            color: AppColors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800)),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _InfoCard(label: 'Email', value: email, icon: Icons.email_outlined),
                  const SizedBox(height: 12),
                  if (prn.isNotEmpty) ...[
                    _InfoCard(label: 'PRN NO.', value: prn, icon: Icons.pin_outlined),
                    const SizedBox(height: 12),
                  ],
                  if (roll.isNotEmpty) ...[
                    _InfoCard(label: 'Roll Number', value: roll, icon: Icons.badge_outlined),
                    const SizedBox(height: 12),
                  ],
                  if (dept.isNotEmpty) ...[
                    _InfoCard(label: 'Department', value: dept, icon: Icons.school_outlined),
                    const SizedBox(height: 12),
                  ],
                  if (year.isNotEmpty) ...[
                    _InfoCard(label: 'Year', value: '$year${year == '1' ? 'st' : year == '2' ? 'nd' : year == '3' ? 'rd' : 'th'} Year', icon: Icons.calendar_today_outlined),
                    const SizedBox(height: 12),
                  ],
                  if (sem.isNotEmpty) ...[
                    _InfoCard(label: 'Semester', value: 'Semester $sem', icon: Icons.class_outlined),
                    const SizedBox(height: 12),
                  ],
                  if (div.isNotEmpty) ...[
                    _InfoCard(label: 'Division', value: 'Div $div', icon: Icons.group_outlined),
                    const SizedBox(height: 12),
                  ],
                  const SizedBox(height: 8),
                  // Edit Profile
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await context.push('/student/edit-profile');
                        // Reload profile data when returning from edit
                        if (mounted) _load();
                      },
                      icon: const Icon(Icons.edit_rounded, size: 18),
                      label: Text('Edit Profile',
                          style: GoogleFonts.inter(
                              fontWeight: FontWeight.w700,
                              fontSize: 15)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.green,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Logout
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await Supabase.instance.client.auth.signOut();
                        if (context.mounted) context.go('/');
                      },
                      icon: const Icon(Icons.logout_rounded, color: AppColors.error, size: 18),
                      label: Text('Sign Out',
                          style: GoogleFonts.inter(
                              color: AppColors.error,
                              fontWeight: FontWeight.w700,
                              fontSize: 15)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: AppColors.error),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
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

class _InfoCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _InfoCard({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.greenLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.green, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.grey400,
                        letterSpacing: 0.5)),
                Text(value,
                    style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.black)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
