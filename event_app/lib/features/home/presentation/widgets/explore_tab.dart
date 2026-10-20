import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/zest_tokens.dart';
import '../../../../shared/widgets/shared_widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ExploreTab — Discover all campus events
// Minimal, clean, modern light UI matching Designjoy aesthetic.
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
      dynamic events;
      try {
        events = await Supabase.instance.client
            .from('events')
            .select(
                'id, title, short_description, start_date, venue, cover_image_url, '
                'max_seats, event_categories(name)')
            .eq('visibility', 'published')
            .order('start_date', ascending: true);
      } catch (err) {
        debugPrint('Explore detailed select failed, fallback to basic: $err');
        events = await Supabase.instance.client
            .from('events')
            .select(
                'id, title, short_description, start_date, venue, cover_image_url, '
                'max_seats')
            .eq('visibility', 'published')
            .order('start_date', ascending: true);
      }

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
    return Scaffold(
      backgroundColor: ZestTokens.page,
      body: RefreshIndicator(
        color: ZestTokens.blue,
        backgroundColor: Colors.white,
        onRefresh: _loadEvents,
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

            // ── Title + Subtitle ───────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: ZestTokens.horizontalPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Explore ',
                            style: ZestTokens.display.copyWith(fontSize: 32),
                          ),
                          TextSpan(
                            text: 'events',
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
                      'Discover what\'s happening across campus',
                      style: ZestTokens.body.copyWith(
                        color: ZestTokens.ink2,
                        fontSize: 14,
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
                padding: const EdgeInsets.symmetric(
                  horizontal: ZestTokens.horizontalPadding,
                ),
                child: Container(
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
                        _applyFilter();
                      });
                    },
                    style: ZestTokens.body.copyWith(
                      color: ZestTokens.ink,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search events, workshops, clubs...',
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
                                  _applyFilter();
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
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // ── Event Cards ───────────────────────────────────────────
            if (_isLoading)
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: ZestTokens.horizontalPadding,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => const Padding(
                      padding: EdgeInsets.only(bottom: 14),
                      child: ZestSkeleton(
                        width: double.infinity,
                        height: 124,
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                    ),
                    childCount: 5,
                  ),
                ),
              )
            else if (_filtered.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: ZestEmptyState(
                    mascotMood: ZestMascotMood.sleepy,
                    title: _searchQuery.isEmpty
                        ? 'No events yet'
                        : 'No events match "$_searchQuery"',
                    subtitle: _searchQuery.isEmpty
                        ? 'Check back soon for new events!'
                        : 'Try searching for something else.',
                    actionLabel: _searchQuery.isNotEmpty ? 'Clear Search' : null,
                    onAction: () {
                      setState(() {
                        _searchController.clear();
                        _searchQuery = '';
                        _applyFilter();
                      });
                    },
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
                    (context, i) {
                      final e = _filtered[i];
                      final date = _formatDate(e['start_date']?.toString());
                      final venue = e['venue']?.toString() ?? 'Campus';
                      final title = e['title']?.toString() ?? 'Event';
                      final cat = e['event_categories']?['name']?.toString() ?? 'General';
                      final rawCap = e['max_seats'] ?? e['max_capacity'];
                      final capacity = rawCap is int
                          ? rawCap
                          : int.tryParse(rawCap?.toString() ?? '') ?? 100;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _ExploreCard(
                          title: title,
                          category: cat,
                          date: date,
                          venue: venue,
                          seatsTotal: capacity,
                          seatsLeft: (capacity * 0.35).toInt(),
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
// _ExploreCard — Modern light Designjoy card
// ─────────────────────────────────────────────────────────────────────────────
class _ExploreCard extends StatelessWidget {
  const _ExploreCard({
    required this.title,
    required this.category,
    required this.date,
    required this.venue,
    required this.seatsTotal,
    required this.seatsLeft,
    this.onTap,
  });

  final String title;
  final String category;
  final String date;
  final String venue;
  final int seatsTotal;
  final int seatsLeft;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final progress = seatsTotal > 0 ? (seatsTotal - seatsLeft) / seatsTotal : 0.0;
    final isLowSeats = seatsLeft < (seatsTotal * 0.25);

    return GestureDetector(
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
            // Top Row: Category tag + Seats left badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  category.toUpperCase(),
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: ZestTokens.core,
                    letterSpacing: 0.8,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isLowSeats ? const Color(0xFFFEF2F2) : const Color(0xFFEFF6FF),
                    borderRadius: ZestTokens.borderPill,
                    border: Border.all(
                      color: isLowSeats ? const Color(0xFFFECACA) : const Color(0xFFBFDBFE),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isLowSeats ? '⚡ ' : '🎟️ ',
                        style: const TextStyle(fontSize: 10),
                      ),
                      Text(
                        '$seatsLeft seats left',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: isLowSeats ? ZestTokens.coral : ZestTokens.blue,
                        ),
                      ),
                    ],
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

            // Date & Venue
            Row(
              children: [
                if (date.isNotEmpty) ...[
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
                ],
                if (venue.isNotEmpty) ...[
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
              ],
            ),

            const SizedBox(height: 10),

            // Divider
            Container(height: 1, color: ZestTokens.line),

            const SizedBox(height: 8),

            // Bottom Row: Seats progress bar & +150 XP
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      SizedBox(
                        width: 70,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: progress.clamp(0.05, 1.0),
                            minHeight: 5,
                            backgroundColor: ZestTokens.line,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isLowSeats ? ZestTokens.coral : ZestTokens.core,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$seatsLeft of $seatsTotal left',
                        style: ZestTokens.caption.copyWith(
                          fontSize: 11,
                          color: ZestTokens.ink3,
                        ),
                      ),
                    ],
                  ),
                ),
                const Text(
                  '+150 XP',
                  style: TextStyle(
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
    );
  }
}
