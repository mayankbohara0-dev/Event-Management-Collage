import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:qr_flutter/qr_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/zest_tokens.dart';
import '../../../../shared/widgets/shared_widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MyEventsTab — Zest Student Passes & Tickets
// Minimal, simple, modern, light UI matching the blue lemon blob brand.
// ─────────────────────────────────────────────────────────────────────────────

class MyEventsTab extends ConsumerStatefulWidget {
  final VoidCallback onProfileTap;
  final VoidCallback onExploreTap;

  const MyEventsTab({
    super.key,
    required this.onProfileTap,
    required this.onExploreTap,
  });

  @override
  ConsumerState<MyEventsTab> createState() => _MyEventsTabState();
}

class _MyEventsTabState extends ConsumerState<MyEventsTab> {
  List<Map<String, dynamic>> _registrations = [];
  List<Map<String, dynamic>> _filtered = [];
  Set<String> _attendedEventIds = {};
  Map<String, dynamic>? _profile;
  bool _isLoading = true;
  int _selectedFilterIndex = 0; // 0: Upcoming, 1: Attended

  static const _filterOptions = ['Upcoming Passes', 'Attended Events 🏆'];

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

      final results = await Future.wait<dynamic>([
        Supabase.instance.client
            .from('student_profiles')
            .select('name, avatar_url, roll_number, enrollment_number')
            .eq('id', user.id)
            .maybeSingle(),
        Supabase.instance.client
            .from('registrations')
            .select('*, events(id, title, start_date, end_date, venue, cover_image_url)')
            .eq('student_id', user.id)
            .order('created_at', ascending: false),
        Supabase.instance.client
            .from('attendance')
            .select('event_id')
            .eq('student_id', user.id),
      ]);

      if (mounted) {
        final attList = (results[2] as List);
        _attendedEventIds = attList
            .map((a) => a['event_id']?.toString() ?? '')
            .where((id) => id.isNotEmpty)
            .toSet();

        setState(() {
          _profile = results[0] as Map<String, dynamic>?;
          _registrations = List<Map<String, dynamic>>.from(results[1] as List);
          _applyFilter();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading my events: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _applyFilter() {
    if (_selectedFilterIndex == 0) {
      // Upcoming: not attended yet
      _filtered = _registrations.where((r) {
        final eventId = r['event_id']?.toString() ?? '';
        return !_attendedEventIds.contains(eventId);
      }).toList();
    } else {
      // Attended
      _filtered = _registrations.where((r) {
        final eventId = r['event_id']?.toString() ?? '';
        return _attendedEventIds.contains(eventId) || r['status'] == 'attended';
      }).toList();
    }
  }

  void _onFilterChanged(int index) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedFilterIndex = index;
      _applyFilter();
    });
  }

  @override
  Widget build(BuildContext context) {
    final avatarUrl = _profile?['avatar_url']?.toString();
    final name = _profile?['name']?.toString() ?? 'Student';
    final rollNumber = _profile?['roll_number']?.toString() ??
        _profile?['enrollment_number']?.toString() ?? '';

    return Scaffold(
      backgroundColor: ZestTokens.page,
      body: RefreshIndicator(
        color: ZestTokens.blue,
        backgroundColor: Colors.white,
        onRefresh: _load,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            // ── Top Safe Area + Screen Title ───────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  ZestTokens.horizontalPadding,
                  MediaQuery.of(context).padding.top + 16,
                  ZestTokens.horizontalPadding,
                  14,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'My ',
                                style: ZestTokens.display.copyWith(fontSize: 32),
                              ),
                              TextSpan(
                                text: 'passes',
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
                          'Your verified entry tickets to campus events',
                          style: ZestTokens.body.copyWith(
                            color: ZestTokens.ink2,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: widget.onProfileTap,
                      child: ZestAvatar(
                        imageUrl: avatarUrl,
                        name: name,
                        size: 44,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Upcoming / Attended Segmented Pill Toggle ─────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: ZestTokens.horizontalPadding,
                ),
                child: ZestSegmentedToggle(
                  segments: _filterOptions,
                  selectedIndex: _selectedFilterIndex,
                  onChanged: _onFilterChanged,
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // ── Passes List / Tickets ──────────────────────────────────
            if (_isLoading)
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: ZestTokens.horizontalPadding,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => const Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: ZestSkeleton(
                        width: double.infinity,
                        height: 320,
                        borderRadius: BorderRadius.all(Radius.circular(28)),
                      ),
                    ),
                    childCount: 2,
                  ),
                ),
              )
            else if (_filtered.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: ZestEmptyState(
                    mascotMood: _selectedFilterIndex == 0
                        ? ZestMascotMood.idle
                        : ZestMascotMood.happy,
                    title: _selectedFilterIndex == 0
                        ? 'No Upcoming Passes'
                        : 'No Attended Events Yet',
                    subtitle: _selectedFilterIndex == 0
                        ? 'Explore campus workshops, hackathons, and concerts to reserve your ticket.'
                        : 'Attend registered events to get verified, earn XP, and unlock certificates!',
                    actionLabel: _selectedFilterIndex == 0
                        ? 'Explore Events 🚀'
                        : 'View Upcoming Passes',
                    onAction: () {
                      if (_selectedFilterIndex == 0) {
                        widget.onExploreTap();
                      } else {
                        _onFilterChanged(0);
                      }
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
                    (context, index) {
                      final reg = _filtered[index];
                      final event =
                          (reg['events'] as Map<String, dynamic>?) ?? {};
                      final isAttended = _selectedFilterIndex == 1;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: _ZestTicket(
                          registration: reg,
                          event: event,
                          studentName: name,
                          rollNumber: rollNumber,
                          isAttended: isAttended,
                          onTap: () {
                            final eventId = event['id']?.toString() ??
                                reg['event_id']?.toString();
                            if (eventId != null) {
                              context.push('/student/event/$eventId');
                            }
                          },
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
// Signature Brand Ticket Card with Side Notches, Dashed Divider, and Laser QR
// ─────────────────────────────────────────────────────────────────────────────

class _ZestTicket extends StatefulWidget {
  final Map<String, dynamic> registration;
  final Map<String, dynamic> event;
  final String studentName;
  final String rollNumber;
  final bool isAttended;
  final VoidCallback onTap;

  const _ZestTicket({
    required this.registration,
    required this.event,
    required this.studentName,
    required this.rollNumber,
    required this.isAttended,
    required this.onTap,
  });

  @override
  State<_ZestTicket> createState() => _ZestTicketState();
}

class _ZestTicketState extends State<_ZestTicket>
    with SingleTickerProviderStateMixin {
  late AnimationController _scanController;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final status =
        (widget.registration['status'] ?? 'approved').toString().toLowerCase();
    final eventTitle = widget.event['title']?.toString() ?? 'Campus Event';
    final venue = widget.event['venue']?.toString() ?? 'Main Campus';
    final clubOrCollege = widget.event['club_name']?.toString() ??
        widget.event['category']?.toString() ??
        'CAMPUS PASS';
    final startDateStr = widget.event['start_date']?.toString();
    final startDate =
        startDateStr != null ? DateTime.tryParse(startDateStr)?.toLocal() : null;

    final dateStr = startDate != null
        ? () {
            const months = [
              'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
              'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
            ];
            const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
            return '${days[startDate.weekday - 1]}, ${months[startDate.month - 1]} ${startDate.day}';
          }()
        : 'Date TBA';

    final qrData =
        widget.registration['qr_code_data']?.toString().isNotEmpty == true
            ? widget.registration['qr_code_data'].toString()
            : widget.registration['id']?.toString() ?? 'ZEST_PASS';

    final regId = widget.registration['id']?.toString() ?? 'PASS';
    final ticketIdDisplay = regId.length > 8
        ? regId.substring(0, 8).toUpperCase()
        : regId.toUpperCase();

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF38BDF8),
              Color(0xFF0AA5F0),
              Color(0xFF0063F0),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.4),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0063F0).withValues(alpha: 0.32),
              blurRadius: 28,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          children: [
            // ── Ticket Header ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const ZestBlobLogo(size: 26),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                clubOrCollege.toUpperCase(),
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.1,
                                  color: Colors.white.withValues(alpha: 0.8),
                                ),
                              ),
                              const Text(
                                'ZEST Event Pass',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  height: 1.1,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      // Status Pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: widget.isAttended
                              ? const Color(0xFF10B981)
                              : Colors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(99),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (widget.isAttended) ...[
                              const Icon(
                                LucideIcons.check,
                                size: 12,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 4),
                            ],
                            Text(
                              widget.isAttended
                                  ? 'Attended ✓'
                                  : (status == 'approved'
                                      ? 'Valid Entry'
                                      : 'Pending'),
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Official Badge + Event title
                  const Text(
                    'OFFICIAL BADGE',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      color: Color(0xFFFFD84D), // Lemon yellow brand accent
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    eventTitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.22,
                      letterSpacing: -0.3,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Date & Venue Row
                  Row(
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            LucideIcons.calendar,
                            size: 13,
                            color: Color(0xFF6CE3FF), // Sky cyan
                          ),
                          const SizedBox(width: 5),
                          Text(
                            dateStr,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withValues(alpha: 0.95),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(
                              LucideIcons.mapPin,
                              size: 13,
                              color: Color(0xFFFFD84D), // Lemon
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                venue,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withValues(alpha: 0.95),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Circular side notches & dashed perforation ──────────
            CustomPaint(
              size: const Size(double.infinity, 22),
              painter: _TicketNotchPainter(),
            ),

            // ── Attendee row & White rounded QR tile ────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Left: Attendee Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ATTENDEE',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.studentName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        if (widget.rollNumber.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              widget.rollNumber,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withValues(alpha: 0.85),
                              ),
                            ),
                          ),
                        const SizedBox(height: 4),
                        Text(
                          'ID: $ticketIdDisplay',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 10,
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3.5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.25),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                LucideIcons.sparkles,
                                size: 10,
                                color: Color(0xFFFFD84D),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                widget.isAttended
                                    ? 'VERIFIED · +80 XP'
                                    : '+80 XP UPON SCAN',
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 14),

                  // Right: White rounded QR tile with sweeping laser line
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.14),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: widget.isAttended
                        ? Container(
                            color: const Color(0xFF10B981),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  LucideIcons.check,
                                  size: 32,
                                  color: Colors.white,
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'CHECKED IN',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Stack(
                            alignment: Alignment.center,
                            children: [
                              QrImageView(
                                data: qrData,
                                version: QrVersions.auto,
                                size: 78.0,
                                padding: EdgeInsets.zero,
                                eyeStyle: const QrEyeStyle(
                                  eyeShape: QrEyeShape.square,
                                  color: ZestTokens.ink,
                                ),
                                dataModuleStyle: const QrDataModuleStyle(
                                  dataModuleShape: QrDataModuleShape.square,
                                  color: ZestTokens.ink,
                                ),
                              ),
                              // Sweeping coral laser line
                              AnimatedBuilder(
                                animation: _scanController,
                                builder: (context, _) {
                                  return Positioned(
                                    top: 8 + (_scanController.value * 76),
                                    left: 6,
                                    right: 6,
                                    child: Container(
                                      height: 2.2,
                                      decoration: const BoxDecoration(
                                        color: ZestTokens.coral,
                                        boxShadow: [
                                          BoxShadow(
                                            color: ZestTokens.coral,
                                            blurRadius: 6,
                                            spreadRadius: 1.5,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
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
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Custom Painter for ticket side notches + dashed divider
// ─────────────────────────────────────────────────────────────────────────────

class _TicketNotchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const cutoutRadius = 14.0;
    const centerY = 12.0;

    // Cutout circles that match page background
    final cutoutPaint = Paint()
      ..color = ZestTokens.page
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(0, centerY), cutoutRadius, cutoutPaint);
    canvas.drawCircle(Offset(size.width, centerY), cutoutRadius, cutoutPaint);

    // Dashed white line
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    const dashWidth = 8.0;
    const dashSpace = 6.0;
    double currentX = cutoutRadius + 8.0;
    final maxX = size.width - (cutoutRadius + 8.0);

    while (currentX < maxX) {
      canvas.drawLine(
        Offset(currentX, centerY),
        Offset(currentX + dashWidth, centerY),
        linePaint,
      );
      currentX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
