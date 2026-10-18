import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:add_2_calendar/add_2_calendar.dart';
import 'dart:async';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/skeleton_loader.dart';
import '../../../core/widgets/zest_button.dart';

/// Zest Event Details Screen
/// Displays hero event banner, countdown timer, seats remaining indicator,
/// details highlights, description, calendar sync, and registration action.
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

      // Count total registrations for this event
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.charcoal,
          foregroundColor: Colors.white,
          title: Text('Loading Event...', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        ),
        body: const Padding(
          padding: EdgeInsets.all(AppSpacing.pagePadding),
          child: Column(
            children: [
              SkeletonLoader(height: 240),
              SizedBox(height: AppSpacing.base),
              SkeletonLoader(height: 32),
              SizedBox(height: AppSpacing.sm),
              SkeletonLoader(height: 60),
            ],
          ),
        ),
      );
    }

    if (_error != null || _event == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.charcoal,
          foregroundColor: Colors.white,
          title: Text('Event Details', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
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

    final title = _event!['title']?.toString() ?? 'Event';
    final shortDesc = _event!['short_description']?.toString() ?? '';
    final longDesc = _event!['long_description']?.toString() ?? '';
    final venue = _event!['venue']?.toString() ?? 'Campus';
    final coverImage = _event!['cover_image_url']?.toString();
    final category = _event!['event_categories']?['name']?.toString() ?? 'General';
    final eligibility = _event!['eligibility']?.toString() ?? '';
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

    // Capacity calculation
    final int? remainingSeats = maxCapacity != null ? (maxCapacity - _registrationCount) : null;
    final double capacityProgress = (maxCapacity != null && maxCapacity > 0)
        ? (_registrationCount / maxCapacity).clamp(0.0, 1.0)
        : 0.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            slivers: [
              // Parallax Hero Header Image
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                backgroundColor: AppColors.charcoal,
                elevation: 0,
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.45),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                ),
                actions: [
                  if (startDate != null && endDate != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: GestureDetector(
                        onTap: () {
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
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.45),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.calendar_month_rounded, color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
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
                      // Bottom gradient overlay
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.7),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Content Body
              SliverToBoxAdapter(
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(AppRadius.xl3),
                      topRight: Radius.circular(AppRadius.xl3),
                    ),
                  ),
                  transform: Matrix4.translationValues(0, -24, 0),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.pagePadding, 24, AppSpacing.pagePadding, 140),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category pill & status
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                gradient: AppColors.zestGradient,
                                borderRadius: AppRadius.circularPill,
                              ),
                              child: Text(
                                category.toUpperCase(),
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ),
                            const Spacer(),
                            if (_isRegistered)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.tealLight,
                                  borderRadius: AppRadius.circularPill,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.check_circle_rounded, size: 14, color: AppColors.teal),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Pass Confirmed',
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.teal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),

                        const SizedBox(height: AppSpacing.base),

                        // Title
                        Text(
                          title,
                          style: GoogleFonts.poppins(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: AppColors.charcoal,
                            height: 1.2,
                          ),
                        ),

                        if (shortDesc.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            shortDesc,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.coral,
                              height: 1.4,
                            ),
                          ),
                        ],

                        const SizedBox(height: AppSpacing.lg),

                        // Countdown Timer Card
                        if (startDate != null && !isPast) ...[
                          _ZestCountdownCard(eventDate: startDate),
                          const SizedBox(height: AppSpacing.base),
                        ],

                        // Capacity Bar if set
                        if (maxCapacity != null && maxCapacity > 0) ...[
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.base),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: AppRadius.circularLg,
                              boxShadow: AppShadows.card,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Seat Availability',
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.charcoal,
                                      ),
                                    ),
                                    Text(
                                      remainingSeats != null && remainingSeats > 0
                                          ? '$remainingSeats spots left ⚡'
                                          : 'Sold Out!',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: (remainingSeats != null && remainingSeats <= 5)
                                            ? AppColors.error
                                            : AppColors.teal,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: AppRadius.circularPill,
                                  child: LinearProgressIndicator(
                                    value: capacityProgress,
                                    minHeight: 8,
                                    backgroundColor: AppColors.grey100,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      capacityProgress > 0.9 ? AppColors.coral : AppColors.teal,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.base),
                        ],

                        // Key Information Highlights
                        Text(
                          'Event Highlights 📍',
                          style: GoogleFonts.poppins(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: AppColors.charcoal,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),

                        Row(
                          children: [
                            Expanded(
                              child: _ZestDetailTile(
                                icon: Icons.calendar_today_rounded,
                                label: 'Date',
                                value: dateString,
                                iconColor: AppColors.coral,
                                iconBg: AppColors.coralLight,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: _ZestDetailTile(
                                icon: Icons.access_time_rounded,
                                label: 'Time',
                                value: timeString,
                                iconColor: AppColors.mustard,
                                iconBg: AppColors.mustardLight,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: AppSpacing.sm),

                        _ZestDetailTile(
                          icon: Icons.location_on_outlined,
                          label: 'Venue',
                          value: venue,
                          iconColor: AppColors.teal,
                          iconBg: AppColors.tealLight,
                        ),

                        if (eligibility.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.sm),
                          _ZestDetailTile(
                            icon: Icons.verified_user_outlined,
                            label: 'Eligibility',
                            value: eligibility,
                            iconColor: AppColors.periwinkle,
                            iconBg: AppColors.periwinkleLight,
                          ),
                        ],

                        const SizedBox(height: AppSpacing.xl),

                        // Long Description
                        Text(
                          'About this Event 📖',
                          style: GoogleFonts.poppins(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: AppColors.charcoal,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),

                        Text(
                          longDesc.isNotEmpty ? longDesc : 'No additional information provided.',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: AppColors.grey600,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Sticky Bottom Registration Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(AppSpacing.pagePadding, 16, AppSpacing.pagePadding, 24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                boxShadow: AppShadows.hero,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xl2)),
              ),
              child: SafeArea(
                top: false,
                child: _buildActionButton(context, isPast),
              ),
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
        variant: ZestButtonVariant.secondary,
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

  Widget _fallbackBanner() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.charcoal, Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(Icons.event_rounded, size: 72, color: Colors.white24),
      ),
    );
  }
}

class _ZestDetailTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;
  final Color iconBg;

  const _ZestDetailTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
    required this.iconBg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.circularLg,
        boxShadow: AppShadows.card,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: AppRadius.circularMd,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppColors.grey400,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppColors.charcoal,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Zest countdown card with energetic digits
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.circularLg,
        boxShadow: AppShadows.card,
        border: Border.all(color: AppColors.mustardLight, width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Row(
            children: [
              const Text('⏱️', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                'Starts in',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.charcoal,
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
      style: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w900,
        color: AppColors.mustard,
      ),
    );
  }

  Widget _timeDigit(String val, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.mustardLight,
            borderRadius: AppRadius.circularSm,
          ),
          child: Text(
            val,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: AppColors.charcoal,
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: AppColors.grey400,
          ),
        ),
      ],
    );
  }
}
