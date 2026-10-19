import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:add_2_calendar/add_2_calendar.dart';
import 'dart:async';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/skeleton_loader.dart';
import '../../../core/widgets/zest_button.dart';

// ─────────────────────────────────────────────────────────────────────────────
// EventDetailsScreen — Full Zest Event Experience
// Spec: 300px event-colored banner (bottom radius 42), floating circular back
//       button, huge emoji / cover image, 38sp title, category ink pill with
//       lime text, seats-left progress bar, countdown card, sticky register bar
//       with ZestButton (Done state: "You're in! ✓").
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
        backgroundColor: AppColors.ink,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              SkeletonLoader(width: double.infinity, height: 300),
              SizedBox(height: 24),
              SkeletonLoader(width: 220, height: 32),
              SizedBox(height: 12),
              SkeletonLoader(width: 140, height: 16),
            ],
          ),
        ),
      );
    }

    if (_error != null || _event == null) {
      return Scaffold(
        backgroundColor: AppColors.ink,
        appBar: AppBar(
          backgroundColor: AppColors.ink,
          foregroundColor: AppColors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.pop(),
          ),
        ),
        body: Center(
          child: EmptyState(
            emoji: '🔍',
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
    final maxCapacity = _event!['max_capacity'] != null
        ? int.tryParse(_event!['max_capacity'].toString())
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

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: AppColors.ink,
        body: Stack(
          children: [
            CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                // ── 300px Event Banner with Bottom Radius 42 ───────────────
                SliverToBoxAdapter(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(AppRadius.bottomSheetBanner),
                      bottomRight: Radius.circular(AppRadius.bottomSheetBanner),
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
                              errorBuilder: (_, _, _) => _buildBannerFallback(emoji),
                            )
                          else
                            _buildBannerFallback(emoji),

                          // Dark Gradient Overlay
                          Positioned.fill(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withValues(alpha: 0.35),
                                    Colors.transparent,
                                    Colors.black.withValues(alpha: 0.85),
                                  ],
                                  stops: const [0.0, 0.45, 1.0],
                                ),
                              ),
                            ),
                          ),

                          // Floating Back Button
                          Positioned(
                            top: MediaQuery.of(context).padding.top + 10,
                            left: 16,
                            child: GestureDetector(
                              onTap: () => context.pop(),
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppColors.ink.withValues(alpha: 0.75),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.borderDark),
                                ),
                                child: const Icon(
                                  Icons.arrow_back_rounded,
                                  color: AppColors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),

                          // Floating Calendar Sync Button
                          if (startDate != null && endDate != null)
                            Positioned(
                              top: MediaQuery.of(context).padding.top + 10,
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
                                    color: AppColors.ink.withValues(alpha: 0.75),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppColors.borderDark),
                                  ),
                                  child: const Icon(
                                    Icons.calendar_month_rounded,
                                    color: AppColors.lime,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),

                          // Bottom Banner Info (Category pill + Status)
                          Positioned(
                            bottom: 20,
                            left: 20,
                            right: 20,
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.ink,
                                    borderRadius: AppRadius.circularPill,
                                    border: Border.all(color: AppColors.lime.withValues(alpha: 0.4)),
                                  ),
                                  child: Text(
                                    category.toUpperCase(),
                                    style: AppTextStyles.pillTag.copyWith(
                                      color: AppColors.lime,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                if (_isRegistered)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AppColors.lime,
                                      borderRadius: AppRadius.circularPill,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.check_circle_rounded, size: 14, color: AppColors.ink),
                                        const SizedBox(width: 5),
                                        Text(
                                          'PASS CONFIRMED',
                                          style: AppTextStyles.metaLabel.copyWith(
                                            color: AppColors.ink,
                                            fontWeight: FontWeight.w900,
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
                    padding: const EdgeInsets.fromLTRB(18, 24, 18, 140),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title 38sp Bricolage 800
                        Text(
                          title,
                          style: AppTextStyles.title38.copyWith(
                            color: AppColors.white,
                            height: 1.15,
                          ),
                        ),

                        if (shortDesc.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            shortDesc,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.lime,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],

                        const SizedBox(height: 24),

                        // Countdown Timer Card
                        if (startDate != null && !isPast) ...[
                          _ZestCountdownCard(eventDate: startDate),
                          const SizedBox(height: 20),
                        ],

                        // Capacity / Seats Left Progress Bar
                        if (maxCapacity != null && maxCapacity > 0) ...[
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceDark,
                              borderRadius: BorderRadius.circular(AppRadius.card),
                              border: Border.all(color: AppColors.borderDark),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Seat Availability',
                                      style: AppTextStyles.title17.copyWith(
                                        color: AppColors.white,
                                      ),
                                    ),
                                    Text(
                                      remainingSeats != null && remainingSeats > 0
                                          ? '$remainingSeats spots left ⚡'
                                          : 'Sold Out!',
                                      style: AppTextStyles.caption.copyWith(
                                        color: (remainingSeats != null && remainingSeats <= 10)
                                            ? AppColors.coral
                                            : AppColors.lime,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                ClipRRect(
                                  borderRadius: AppRadius.circularPill,
                                  child: LinearProgressIndicator(
                                    value: capacityProgress,
                                    minHeight: 8,
                                    backgroundColor: AppColors.ink3,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      capacityProgress > 0.9 ? AppColors.coral : AppColors.lime,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],

                        // Key Event Information Bento Grid
                        Text(
                          'Event Highlights 📍',
                          style: AppTextStyles.title24.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                        const SizedBox(height: 14),

                        Row(
                          children: [
                            Expanded(
                              child: _buildHighlightTile(
                                icon: Icons.calendar_today_rounded,
                                label: 'Date',
                                value: dateString,
                                accentColor: AppColors.coral,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildHighlightTile(
                                icon: Icons.access_time_rounded,
                                label: 'Time',
                                value: timeString,
                                accentColor: AppColors.mustard,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        _buildHighlightTile(
                          icon: Icons.location_on_rounded,
                          label: 'Venue',
                          value: venue,
                          accentColor: AppColors.aqua,
                        ),

                        if (eligibility.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          _buildHighlightTile(
                            icon: Icons.verified_user_outlined,
                            label: 'Eligibility',
                            value: eligibility,
                            accentColor: AppColors.lavender,
                          ),
                        ],

                        const SizedBox(height: 28),

                        // Long Description
                        if (longDesc.isNotEmpty) ...[
                          Text(
                            'About this Event 📝',
                            style: AppTextStyles.title24.copyWith(
                              color: AppColors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceDark,
                              borderRadius: BorderRadius.circular(AppRadius.card),
                              border: Border.all(color: AppColors.borderDark),
                            ),
                            child: Text(
                              longDesc,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.grey400,
                                height: 1.6,
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),
                        ],

                        // Event Guidelines / Rules
                        if (rules.isNotEmpty) ...[
                          Text(
                            'Rules & Guidelines 📌',
                            style: AppTextStyles.title24.copyWith(
                              color: AppColors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceDark,
                              borderRadius: BorderRadius.circular(AppRadius.card),
                              border: Border.all(color: AppColors.borderDark),
                            ),
                            child: Text(
                              rules,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.grey400,
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
                  18,
                  14,
                  18,
                  MediaQuery.of(context).padding.bottom + 14,
                ),
                decoration: BoxDecoration(
                  color: AppColors.ink.withValues(alpha: 0.95),
                  border: const Border(
                    top: BorderSide(color: AppColors.borderDark, width: 1.5),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 24,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: _buildActionButton(context, isPast),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBannerFallback(String emoji) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.ink, Color(0xFF26262C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
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
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: accentColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.grey400,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.title17.copyWith(
                    color: AppColors.white,
                    fontSize: 14,
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
      return ZestButton(
        label: 'Event Concluded 🏁',
        variant: ZestButtonVariant.ghost,
        fullWidth: true,
        onPressed: null,
      );
    }

    if (_isRegistered) {
      return ZestButton(
        label: 'View Your Entry Pass 🎟️',
        icon: Icons.confirmation_number_rounded,
        isDone: true,
        doneLabel: "You're in! View Pass 🎟️",
        fullWidth: true,
        onPressed: () => context.go('/student/home'),
      );
    }

    return ZestButton(
      label: 'Claim Your Spot ⚡',
      icon: Icons.bolt_rounded,
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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Row(
            children: [
              const Text('⏱️', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Text(
                'Starts in',
                style: AppTextStyles.title17.copyWith(
                  color: AppColors.white,
                  fontSize: 14,
                ),
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
    return Text(
      ':',
      style: AppTextStyles.title24.copyWith(
        color: AppColors.lime,
        fontWeight: FontWeight.w900,
      ),
    );
  }

  Widget _timeDigit(String val, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.ink,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.borderDark),
          ),
          child: Text(
            val,
            style: AppTextStyles.title17.copyWith(
              color: AppColors.lime,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            fontSize: 9,
            fontWeight: FontWeight.w800,
            color: AppColors.grey400,
          ),
        ),
      ],
    );
  }
}
