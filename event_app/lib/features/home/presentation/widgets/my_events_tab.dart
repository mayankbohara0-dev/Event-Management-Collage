import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/skeleton_loader.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MyEventsTab — Zest Student Passes & Tickets
// Spec: "My Passes" title 38sp, Upcoming/Attended segmented toggle,
//       lime background ticket cards with side notches at ~62% height,
//       dashed divider 3px 35% ink, 128px QR with animated scan line,
//       "Show this at the gate" caption, "Certificate ready + 80pts" for attended.
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

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: AppColors.ink,
        body: RefreshIndicator(
          color: AppColors.ink,
          backgroundColor: AppColors.lime,
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
                    18,
                    MediaQuery.of(context).padding.top + 20,
                    18,
                    16,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.lime.withValues(alpha: 0.15),
                              borderRadius: AppRadius.circularPill,
                            ),
                            child: Text(
                              'CAMPUS ACCESS',
                              style: AppTextStyles.pillTag.copyWith(
                                color: AppColors.lime,
                                fontSize: 11,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'My Passes',
                            style: AppTextStyles.title38.copyWith(
                              color: AppColors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Your verified entry tickets to campus events.',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.grey400,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: widget.onProfileTap,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.lime, width: 2),
                          ),
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: AppColors.surfaceCard,
                            backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty)
                                ? NetworkImage(avatarUrl)
                                : null,
                            child: (avatarUrl == null || avatarUrl.isEmpty)
                                ? Text(
                                    name.isNotEmpty ? name[0].toUpperCase() : 'S',
                                    style: AppTextStyles.title17.copyWith(
                                      color: AppColors.lime,
                                    ),
                                  )
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Upcoming / Attended Segmented Pill Toggle ─────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDark,
                      borderRadius: AppRadius.circularPill,
                      border: Border.all(color: AppColors.borderDark),
                    ),
                    child: Row(
                      children: List.generate(_filterOptions.length, (i) {
                        final isSel = i == _selectedFilterIndex;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => _onFilterChanged(i),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 11),
                              decoration: BoxDecoration(
                                color: isSel ? AppColors.lime : Colors.transparent,
                                borderRadius: AppRadius.circularPill,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                _filterOptions[i],
                                style: AppTextStyles.caption.copyWith(
                                  color: isSel ? AppColors.ink : AppColors.grey400,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 20)),

              // ── Passes List / Tickets ──────────────────────────────────
              if (_isLoading)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: SkeletonLoader(
                          width: double.infinity,
                          height: 320,
                          radius: AppRadius.ticketCard,
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
                    child: EmptyState(
                      emoji: _selectedFilterIndex == 0 ? '🎟️' : '🏆',
                      title: _selectedFilterIndex == 0
                          ? 'No Upcoming Passes'
                          : 'No Attended Events Yet',
                      subtitle: _selectedFilterIndex == 0
                          ? 'Explore campus workshops, hackathons, and concerts to reserve your ticket.'
                          : 'Attend registered events to get verified, earn XP, and unlock certificates!',
                      actionLabel: _selectedFilterIndex == 0 ? 'Explore Events 🚀' : 'View Upcoming Passes',
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
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 120),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final reg = _filtered[index];
                        final event = (reg['events'] as Map<String, dynamic>?) ?? {};
                        final isAttended = _selectedFilterIndex == 1;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: _ZestLimeTicket(
                            registration: reg,
                            event: event,
                            studentName: name,
                            rollNumber: rollNumber,
                            isAttended: isAttended,
                            onTap: () {
                              final eventId = event['id']?.toString() ?? reg['event_id']?.toString();
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
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Spec-Exact Lime Ticket Card with Notches, Perforation, and Animated QR
// ─────────────────────────────────────────────────────────────────────────────

class _ZestLimeTicket extends StatefulWidget {
  final Map<String, dynamic> registration;
  final Map<String, dynamic> event;
  final String studentName;
  final String rollNumber;
  final bool isAttended;
  final VoidCallback onTap;

  const _ZestLimeTicket({
    required this.registration,
    required this.event,
    required this.studentName,
    required this.rollNumber,
    required this.isAttended,
    required this.onTap,
  });

  @override
  State<_ZestLimeTicket> createState() => _ZestLimeTicketState();
}

class _ZestLimeTicketState extends State<_ZestLimeTicket>
    with SingleTickerProviderStateMixin {
  late AnimationController _scanController;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final status = (widget.registration['status'] ?? 'approved').toString().toLowerCase();
    final eventTitle = widget.event['title']?.toString() ?? 'Campus Event';
    final venue = widget.event['venue']?.toString() ?? 'Main Campus';
    final startDateStr = widget.event['start_date']?.toString();
    final startDate = startDateStr != null ? DateTime.tryParse(startDateStr)?.toLocal() : null;

    final dateStr = startDate != null
        ? () {
            const months = ['JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC'];
            const days = ['MON','TUE','WED','THU','FRI','SAT','SUN'];
            return '${days[startDate.weekday - 1]}, ${months[startDate.month - 1]} ${startDate.day}';
          }()
        : 'DATE TBA';

    final qrData = widget.registration['qr_code_data']?.toString().isNotEmpty == true
        ? widget.registration['qr_code_data'].toString()
        : widget.registration['id']?.toString() ?? 'ZEST_PASS';

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.lime,
          borderRadius: BorderRadius.circular(AppRadius.ticketCard),
          boxShadow: [
            BoxShadow(
              color: AppColors.lime.withValues(alpha: 0.18),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            // ── Top Ticket Section ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pass tag & Date
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.ink,
                          borderRadius: AppRadius.circularPill,
                        ),
                        child: Text(
                          widget.isAttended
                              ? 'ATTENDED ✓'
                              : (status == 'approved' ? 'VERIFIED PASS' : 'PENDING APPROVAL'),
                          style: AppTextStyles.pillTag.copyWith(
                            color: AppColors.lime,
                            fontSize: 10,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      Text(
                        dateStr,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.ink.withValues(alpha: 0.75),
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Event Title (Bricolage 800 ink)
                  Text(
                    eventTitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.title24.copyWith(
                      color: AppColors.ink,
                      height: 1.15,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Venue & Time
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded, size: 14, color: AppColors.ink),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          venue,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.ink.withValues(alpha: 0.72),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Attendee Info Box
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.ink.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.studentName,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.ink,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (widget.rollNumber.isNotEmpty)
                          Text(
                            widget.rollNumber,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.ink.withValues(alpha: 0.65),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Perforated Notches & Dashed Divider ────────────────────
            CustomPaint(
              size: const Size(double.infinity, 24),
              painter: _TicketNotchPainter(),
            ),

            // ── Bottom Section (QR + Scanner OR Certificate) ───────────
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 22),
              child: widget.isAttended
                  ? _buildAttendedFooter()
                  : _buildScannerFooter(qrData),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScannerFooter(String qrData) {
    return Column(
      children: [
        // 128px QR Code with Scan Line Animation
        SizedBox(
          width: 128,
          height: 128,
          child: Stack(
            alignment: Alignment.center,
            children: [
              QrImageView(
                data: qrData,
                version: QrVersions.auto,
                size: 128.0,
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: AppColors.ink,
                ),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: AppColors.ink,
                ),
              ),
              // Animated scan line sweeping down
              AnimatedBuilder(
                animation: _scanController,
                builder: (context, _) {
                  return Positioned(
                    top: _scanController.value * 120,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 3,
                      decoration: BoxDecoration(
                        color: AppColors.coral,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.coral.withValues(alpha: 0.8),
                            blurRadius: 6,
                            spreadRadius: 2,
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

        const SizedBox(height: 12),

        // Caption per spec
        Text(
          'Show this at the gate',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.ink,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildAttendedFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('📜', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                'Certificate ready + 80pts',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.lime,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Attendance verified by campus faculty',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.grey400,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Custom Painter for ticket side notches + 3px dashed divider at 35% ink
// ─────────────────────────────────────────────────────────────────────────────

class _TicketNotchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const cutoutRadius = 14.0;
    const centerY = 12.0;

    // Cutout circles that match the scaffold background (AppColors.ink)
    final cutoutPaint = Paint()
      ..color = AppColors.ink
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(0, centerY), cutoutRadius, cutoutPaint);
    canvas.drawCircle(Offset(size.width, centerY), cutoutRadius, cutoutPaint);

    // Dashed line 3px thick, 35% ink opacity per spec
    final linePaint = Paint()
      ..color = AppColors.ink.withValues(alpha: 0.35)
      ..strokeWidth = 3.0
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
