import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/design_system.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    const pages = [
      _HomeFeed(),
      _MyRegistrations(),
      _ProfileTab(),
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

// ── HOME FEED ─────────────────────────────────
class _HomeFeed extends ConsumerStatefulWidget {
  const _HomeFeed();

  @override
  ConsumerState<_HomeFeed> createState() => _HomeFeedState();
}

class _HomeFeedState extends ConsumerState<_HomeFeed> {
  List<Map<String, dynamic>> _events = [];
  List<Map<String, dynamic>> _filtered = [];
  bool _isLoading = true;
  String _selectedCategory = 'All';
  final _searchController = TextEditingController();
  Map<String, dynamic>? _profile;

  static const List<String> _categories = ['All', 'Tech', 'Cultural', 'Sports', 'Academic', 'Workshop'];

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
        final p = await Supabase.instance.client
            .from('student_profiles')
            .select()
            .eq('id', user.id)
            .maybeSingle();
        _profile = p;
      }
      final events = await Supabase.instance.client
          .from('events')
          .select('id, title, short_description, long_description, start_date, end_date, venue, max_seats, visibility, category_id')
          .eq('visibility', 'published')
          .order('start_date', ascending: true);
      if (mounted) {
        setState(() {
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
          : _events.where((e) => (e['category'] ?? '') == cat).toList();
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
                        GestureDetector(
                          onTap: () {},
                          child: Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: AppColors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.notifications_outlined, color: AppColors.white, size: 22),
                          ),
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

          // ── Rewards / Points Card ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: _PointsCard(profile: _profile),
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
                    itemCount: _categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      final cat = _categories[i];
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
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator(color: AppColors.green)),
            )
          else if (_filtered.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.event_busy_outlined, size: 64, color: AppColors.grey200),
                    const SizedBox(height: 16),
                    Text('No events found', style: GoogleFonts.inter(color: AppColors.grey400, fontSize: 16, fontWeight: FontWeight.w600)),
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
  const _PointsCard({this.profile});

  @override
  Widget build(BuildContext context) {
    final regCount = 0;
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
                      Text('${regCount * 100} pts',
                          style: GoogleFonts.inter(
                              color: AppColors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w900)),
                      Text('Earn 100 pts per event attended',
                          style: GoogleFonts.inter(
                              color: AppColors.white.withOpacity(0.75),
                              fontSize: 12)),
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
                      child: Text('View All',
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
    final category = (event['category_id'] ?? 'Event').toString();

    return GestureDetector(
      onTap: () => context.push('/student/event/${event['id']}/register'),
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
            // Top color banner
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: _categoryColor(category),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
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
                          color: _categoryColor(category).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          category.toUpperCase(),
                          style: GoogleFonts.inter(
                              color: _categoryColor(category),
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
                        Text(
                          event['venue'].toString(),
                          style: GoogleFonts.inter(
                              color: AppColors.grey400,
                              fontSize: 12,
                              fontWeight: FontWeight.w500),
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
                          'Register',
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

  Color _categoryColor(String cat) {
    switch (cat.toLowerCase()) {
      case 'tech':
        return const Color(0xFF0077FF);
      case 'cultural':
        return const Color(0xFFFF6B35);
      case 'sports':
        return const Color(0xFF00C853);
      case 'academic':
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
  const _MyRegistrations();

  @override
  ConsumerState<_MyRegistrations> createState() => _MyRegistrationsState();
}

class _MyRegistrationsState extends ConsumerState<_MyRegistrations> {
  List<Map<String, dynamic>> _registrations = [];
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
      final data = await Supabase.instance.client
          .from('registrations')
          .select('*, events(title, start_date, venue)')
          .eq('student_id', user.id)
          .order('created_at', ascending: false);
      if (mounted) {
        setState(() {
          _registrations = List<Map<String, dynamic>>.from(data);
          _isLoading = false;
        });
      }
    } catch (_) {
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
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.green))
          : _registrations.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 64, color: AppColors.grey200),
                      const SizedBox(height: 16),
                      Text("You haven't registered yet",
                          style: GoogleFonts.inter(
                              color: AppColors.grey400,
                              fontSize: 16,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Text('Find events on the Explore tab',
                          style: GoogleFonts.inter(color: AppColors.grey400, fontSize: 13)),
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
                        trailing: Container(
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
                      ),
                    );
                  },
                ),
    );
  }
}

// ── PROFILE TAB ───────────────────────────────
class _ProfileTab extends ConsumerStatefulWidget {
  const _ProfileTab();

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

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors.green,
            expandedHeight: 180,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: AppColors.green,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: AppColors.yellow,
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : 'S',
                        style: GoogleFonts.inter(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: AppColors.black),
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
