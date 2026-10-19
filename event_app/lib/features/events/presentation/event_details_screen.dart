import 'dart:async';
import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/zest_tokens.dart';
import '../../../shared/widgets/shared_widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// EventDetailsScreen — Full Zest Event Experience
// Minimal, simple, modern, light UI matching Designjoy aesthetic.
// ─────────────────────────────────────────────────────────────────────────────

class EventDetailsScreen extends ConsumerStatefulWidget {
  final String eventId;
  const EventDetailsScreen({super.key, required this.eventId});

  @override
  ConsumerState<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends ConsumerState<EventDetailsScreen> {
  Map<String, dynamic>? _event;
  bool _isLoading = true;
  String? _error;
  bool _isRegistered = false;
  int _registrationCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchEvent();
  }

  Future<void> _fetchEvent() async {
    try {
      final res = await Supabase.instance.client
          .from('events')
          .select('*, event_categories(name)')
          .eq('id', widget.eventId)
          .maybeSingle();

      final user = Supabase.instance.client.auth.currentUser;
      bool alreadyRegistered = false;
      if (user != null) {
        final regRes = await Supabase.instance.client
            .from('registrations')
            .select('id')
            .eq('event_id', widget.eventId)
            .eq('student_id', user.id)
            .maybeSingle();
        alreadyRegistered = regRes != null;
      }

      final regCountRes = await Supabase.instance.client
          .from('registrations')
          .select('id')
          .eq('event_id', widget.eventId);

      if (mounted) {
        setState(() {
          _event = res;
          _isRegistered = alreadyRegistered;
          _registrationCount = (regCountRes as List).length;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching event: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  String _resolveEmoji(String title, String category) {
    final lower = '$title $category'.toLowerCase();
    if (lower.contains('tech') || lower.contains('hack') || lower.contains('code')) return '💻';
    if (lower.contains('music') || lower.contains('concert') || lower.contains('fest')) return '🎵';
    if (lower.contains('dance') || lower.contains('cultural')) return '🎭';
    if (lower.contains('design') || lower.contains('art')) return '🎨';
    if (lower.contains('sport') || lower.contains('cricket') || lower.contains('football')) return '⚡';
    if (lower.contains('ai') || lower.contains('robot')) return '🤖';
    if (lower.contains('quiz') || lower.contains('brain')) return '🧠';
    return '✨';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: ZestTokens.page,
        body: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ZestSkeleton(width: double.infinity, height: 300),
              SizedBox(height: 24),
              ZestSkeleton(width: 220, height: 32),
              SizedBox(height: 12),
              ZestSkeleton(width: 140, height: 16),
            ],
          ),
        ),
      );
    }

    if (_error != null || _event == null) {
      return Scaffold(
        backgroundColor: ZestTokens.page,
        appBar: AppBar(
          backgroundColor: ZestTokens.page,
          foregroundColor: ZestTokens.ink,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(LucideIcons.arrowLeft),
            onPressed: () => context.pop(),
          ),
        ),
        body: Center(
          child: ZestEmptyState(
            mascotMood: ZestMascotMood.sleepy,
            title: 'Event Not Found',
            subtitle: _error ?? 'This event might have been removed or is no longer accessible.',
            actionLabel: 'Back to Feed',
            onAction: () => context.pop(),
          ),
        ),
      );
    }

    final title = _event!['title']?.toString() ?? 'Campus Event';
    final shortDesc = _event!['short_description']?.toString() ?? '';
    final longDesc = _event!['long_description']?.toString() ?? '';
    final venue = _event!['venue']?.toString() ?? 'Campus Grounds';
    final coverImage = _event!['cover_image_url']?.toString();
    final category = _event!['event_categories']?['name']?.toString() ?? 'General';
    final eligibility = _event!['eligibility']?.toString() ?? '';
    final rules = _event!['rules']?.toString() ?? '';
    final rawCap = _event!['max_seats'] ?? _event!['max_capacity'];
    final maxCapacity = rawCap != null
        ? int.tryParse(rawCap.toString())
        : null;

    final startDateStr = _event!['start_date']?.toString();
    final endDateStr = _event!['end_date']?.toString();

    final DateTime? startDate = startDateStr != null ? DateTime.tryParse(startDateStr)?.toLocal() : null;
    final DateTime? endDate = endDateStr != null ? DateTime.tryParse(endDateStr)?.toLocal() : null;

    final dateString = startDate != null
        ? () {
            const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
            const days = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
            return '${days[startDate.weekday - 1]}, ${months[startDate.month - 1]} ${startDate.day}, ${startDate.year}';
          }()
        : 'Date TBA';

    final timeString = startDate != null
        ? '${startDate.hour.toString().padLeft(2, '0')}:${startDate.minute.toString().padLeft(2, '0')}'
        : 'Time TBA';

    final isPast = startDate != null && startDate.isBefore(DateTime.now());
    final int? remainingSeats = maxCapacity != null ? (maxCapacity - _registrationCount) : null;
    final double capacityProgress = (maxCapacity != null && maxCapacity > 0)
        ? (_registrationCount / maxCapacity).clamp(0.0, 1.0)
        : 0.0;

    final emoji = _resolveEmoji(title, category);
    final gradient = ZestTokens.categoryGradient(category);

    return Scaffold(
      backgroundColor: ZestTokens.page,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              // ── 300px Event Banner with Bottom Radius 40 ───────────────
              SliverToBoxAdapter(
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                  child: SizedBox(
                    height: 300,
                    width: double.infinity,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (coverImage != null && coverImage.isNotEmpty)
                          Image.network(
                            coverImage,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => _buildBannerFallback(emoji, gradient),
                          )
                        else
                          _buildBannerFallback(emoji, gradient),

                        // Soft Gradient Overlay
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withValues(alpha: 0.35),
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.75),
                                ],
                                stops: const [0.0, 0.45, 1.0],
                              ),
                            ),
                          ),
                        ),

                        // Floating Back Button
                        Positioned(
                          top: MediaQuery.of(context).padding.top + 12,
                          left: 16,
                          child: GestureDetector(
                            onTap: () => context.pop(),
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(color: ZestTokens.line),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x1A000000),
                                    blurRadius: 10,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                LucideIcons.arrowLeft,
                                color: ZestTokens.ink,
                                size: 20,
                              ),
                            ),
                          ),
                        ),

                        // Floating Calendar Sync Button
                        if (startDate != null && endDate != null)
                          Positioned(
                            top: MediaQuery.of(context).padding.top + 12,
                            right: 16,
                            child: GestureDetector(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                final Event calEvent = Event(
                                  title: title,
                                  description: shortDesc,
                                  location: venue,
                                  startDate: startDate,
                                  endDate: endDate,
                                );
                                Add2Calendar.addEvent2Cal(calEvent);
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
                                      color: Color(0x1A000000),
                                      blurRadius: 10,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  LucideIcons.calendarPlus,
                                  color: ZestTokens.blue,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),

                        // Bottom Banner Info (Category pill + Pass confirmed badge)
                        Positioned(
                          bottom: 20,
                          left: 20,
                          right: 20,
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.25),
                                  borderRadius: ZestTokens.borderPill,
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.4),
                                  ),
                                ),
                                child: Text(
                                  category.toUpperCase(),
                                  style: ZestTokens.labelCaps.copyWith(
                                    color: Colors.white,
                                    fontSize: 10.5,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              if (_isRegistered)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: ZestTokens.borderPill,
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0x20000000),
                                        blurRadius: 10,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        LucideIcons.checkCircle2,
                                        size: 14,
                                        color: ZestTokens.success,
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        'PASS CONFIRMED',
                                        style: ZestTokens.labelCaps.copyWith(
                                          color: ZestTokens.blue,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Event Content Details ──────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    ZestTokens.horizontalPadding,
                    22,
                    ZestTokens.horizontalPadding,
                    130,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        title,
                        style: ZestTokens.display.copyWith(
                          fontSize: 28,
                          letterSpacing: -0.6,
                        ),
                      ),

                      if (shortDesc.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          shortDesc,
                          style: ZestTokens.body.copyWith(
                            color: ZestTokens.blue,
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                          ),
                        ),
                      ],

                      const SizedBox(height: 20),

                      // Countdown Timer Card
                      if (startDate != null && !isPast) ...[
                        _ZestCountdownCard(eventDate: startDate),
                        const SizedBox(height: 18),
                      ],

                      // Capacity / Seats Left Progress Bar
                      if (maxCapacity != null && maxCapacity > 0) ...[
                        ZestCard(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Seat Availability',
                                    style: ZestTokens.bodyBold.copyWith(
                                      fontSize: 15,
                                    ),
                                  ),
                                  Text(
                                    remainingSeats != null && remainingSeats > 0
                                        ? '$remainingSeats spots left ⚡'
                                        : 'Sold Out!',
                                    style: ZestTokens.caption.copyWith(
                                      color: (remainingSeats != null && remainingSeats <= 10)
                                          ? ZestTokens.coral
                                          : ZestTokens.blue,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              ZestProgressBar(
                                value: capacityProgress,
                                height: 8,
                                progressGradient: capacityProgress > 0.85
                                    ? const LinearGradient(
                                        colors: [ZestTokens.coral, Color(0xFFFF8FA3)],
                                      )
                                    : ZestTokens.brandGradient,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Key Event Information Bento Grid
                      ZestSectionHeader(
                        title: 'Event',
                        accentWord: 'highlights',
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: _buildHighlightTile(
                              icon: LucideIcons.calendar,
                              label: 'Date',
                              value: dateString,
                              accentColor: ZestTokens.coral,
                              bgTint: const Color(0xFFFFF1F2),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildHighlightTile(
                              icon: LucideIcons.clock,
                              label: 'Time',
                              value: timeString,
                              accentColor: const Color(0xFFD97706),
                              bgTint: const Color(0xFFFEF3C7),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      _buildHighlightTile(
                        icon: LucideIcons.mapPin,
                        label: 'Venue',
                        value: venue,
                        accentColor: ZestTokens.blue,
                        bgTint: const Color(0xFFE8F6FE),
                      ),

                      if (eligibility.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        _buildHighlightTile(
                          icon: LucideIcons.shieldCheck,
                          label: 'Eligibility',
                          value: eligibility,
                          accentColor: const Color(0xFF7E22CE),
                          bgTint: const Color(0xFFFAF5FF),
                        ),
                      ],

                      const SizedBox(height: 24),

                      // Long Description
                      if (longDesc.isNotEmpty) ...[
                        ZestSectionHeader(
                          title: 'About',
                          accentWord: 'this event',
                        ),
                        const SizedBox(height: 12),
                        ZestCard(
                          padding: const EdgeInsets.all(18),
                          child: Text(
                            longDesc,
                            style: ZestTokens.body.copyWith(
                              color: ZestTokens.ink2,
                              height: 1.6,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Event Guidelines / Rules
                      if (rules.isNotEmpty) ...[
                        ZestSectionHeader(
                          title: 'Rules &',
                          accentWord: 'guidelines',
                        ),
                        const SizedBox(height: 12),
                        ZestCard(
                          padding: const EdgeInsets.all(18),
                          child: Text(
                            rules,
                            style: ZestTokens.body.copyWith(
                              color: ZestTokens.ink2,
                              height: 1.6,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── Sticky Registration Bottom Bar ─────────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                ZestTokens.horizontalPadding,
                14,
                ZestTokens.horizontalPadding,
                MediaQuery.of(context).padding.bottom + 14,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: ZestTokens.line, width: 1.0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x100B1220),
                    blurRadius: 20,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: _buildActionButton(context, isPast),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerFallback(String emoji, LinearGradient gradient) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
      ),
      child: Center(
        child: Text(
          emoji,
          style: const TextStyle(fontSize: 78),
        ),
      ),
    );
  }

  Widget _buildHighlightTile({
    required IconData icon,
    required String label,
    required String value,
    required Color accentColor,
    required Color bgTint,
  }) {
    return ZestCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: bgTint,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: accentColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: ZestTokens.caption.copyWith(
                    color: ZestTokens.ink3,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ZestTokens.bodyBold.copyWith(
                    fontSize: 13.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, bool isPast) {
    if (isPast) {
      return const ZestButton(
        text: 'Event Concluded 🏁',
        variant: ZestButtonVariant.ghost,
        fullWidth: true,
        onPressed: null,
      );
    }

    if (_isRegistered) {
      return ZestButton(
        text: "You're in! View Pass 🎟️",
        prefixIcon: LucideIcons.ticket,
        fullWidth: true,
        onPressed: () => context.go('/student/home'),
      );
    }

    return ZestButton(
      text: 'Claim Your Spot ⚡',
      prefixIcon: LucideIcons.zap,
      fullWidth: true,
      onPressed: () => context.push('/student/event/${widget.eventId}/register'),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Countdown Timer Component
// ─────────────────────────────────────────────────────────────────────────────

class _ZestCountdownCard extends StatefulWidget {
  final DateTime eventDate;
  const _ZestCountdownCard({required this.eventDate});

  @override
  State<_ZestCountdownCard> createState() => _ZestCountdownCardState();
}

class _ZestCountdownCardState extends State<_ZestCountdownCard> {
  late Timer _timer;
  Duration _timeLeft = Duration.zero;

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());
  }

  void _updateTime() {
    final now = DateTime.now();
    if (widget.eventDate.isAfter(now)) {
      if (mounted) {
        setState(() => _timeLeft = widget.eventDate.difference(now));
      }
    } else {
      if (mounted) {
        setState(() => _timeLeft = Duration.zero);
      }
      _timer.cancel();
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_timeLeft == Duration.zero) return const SizedBox.shrink();

    return ZestCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Row(
            children: [
              const Text('⏱️', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                'Starts in',
                style: ZestTokens.bodyBold.copyWith(fontSize: 13.5),
              ),
            ],
          ),
          _timeDigit(_timeLeft.inDays.toString().padLeft(2, '0'), 'DAYS'),
          _colon(),
          _timeDigit((_timeLeft.inHours % 24).toString().padLeft(2, '0'), 'HRS'),
          _colon(),
          _timeDigit((_timeLeft.inMinutes % 60).toString().padLeft(2, '0'), 'MIN'),
          _colon(),
          _timeDigit((_timeLeft.inSeconds % 60).toString().padLeft(2, '0'), 'SEC'),
        ],
      ),
    );
  }

  Widget _colon() {
    return const Text(
      ':',
      style: TextStyle(
        fontFamily: 'Inter',
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: ZestTokens.blue,
      ),
    );
  }

  Widget _timeDigit(String val, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F6FE),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            val,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: ZestTokens.blue,
            ),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: ZestTokens.caption.copyWith(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: ZestTokens.ink3,
          ),
        ),
      ],
    );
  }
}
