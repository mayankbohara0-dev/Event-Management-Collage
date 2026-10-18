import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/pill_toggle.dart';
import '../../../../core/widgets/skeleton_loader.dart';

/// Zest My Events Tab
/// Displays student event registrations, ticket passes with QR codes,
/// status badges, and filter toggles.
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
  Map<String, dynamic>? _profile;
  bool _isLoading = true;
  int _selectedFilterIndex = 0; // 0: All, 1: Approved, 2: Pending

  static const _filterOptions = ['All Passes', 'Approved 🎟️', 'Pending ⏳'];

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
            .select('name, avatar_url, roll_number')
            .eq('id', user.id)
            .maybeSingle(),
        Supabase.instance.client
            .from('registrations')
            .select('*, events(id, title, start_date, end_date, venue, cover_image_url)')
            .eq('student_id', user.id)
            .order('created_at', ascending: false),
      ]);

      if (mounted) {
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
    if (_selectedFilterIndex == 1) {
      _filtered = _registrations.where((r) => r['status'] == 'approved').toList();
    } else if (_selectedFilterIndex == 2) {
      _filtered = _registrations.where((r) => r['status'] == 'pending').toList();
    } else {
      _filtered = _registrations;
    }
  }

  void _onFilterChanged(int index) {
    setState(() {
      _selectedFilterIndex = index;
      _applyFilter();
    });
  }

  @override
  Widget build(BuildContext context) {
    final avatarUrl = _profile?['avatar_url']?.toString();
    final name = _profile?['name']?.toString() ?? 'S';

    return RefreshIndicator(
      color: AppColors.coral,
      backgroundColor: AppColors.surface,
      onRefresh: _load,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        slivers: [
          // Safe top area
          const SliverToBoxAdapter(child: SizedBox(height: 52)),

          // Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'My Event Passes 🎟️',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppColors.charcoal,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Your tickets to campus life and energy',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: AppColors.grey600,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: widget.onProfileTap,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: AppShadows.card,
                      ),
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.mustard,
                        backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty)
                            ? NetworkImage(avatarUrl)
                            : null,
                        child: (avatarUrl == null || avatarUrl.isEmpty)
                            ? Text(
                                name.isNotEmpty ? name[0].toUpperCase() : 'S',
                                style: GoogleFonts.poppins(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
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

          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),

          // Filter Pills
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
              child: PillToggle(
                options: _filterOptions,
                selectedIndex: _selectedFilterIndex,
                onChanged: _onFilterChanged,
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),

          // Registrations Body
          if (_isLoading)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, _) => const Padding(
                    padding: EdgeInsets.only(bottom: AppSpacing.md),
                    child: SkeletonEventCard(),
                  ),
                  childCount: 3,
                ),
              ),
            )
          else if (_filtered.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl2),
                child: EmptyState(
                  emoji: '🎟️',
                  title: _selectedFilterIndex == 0
                      ? 'No Event Passes Yet'
                      : 'No ${_filterOptions[_selectedFilterIndex]} Passes',
                  subtitle: _selectedFilterIndex == 0
                      ? "Your event passport is waiting! Squeeze some fun into your semester."
                      : "No passes found under this filter.",
                  actionLabel: _selectedFilterIndex == 0 ? 'Explore Events 🚀' : 'Show All Passes',
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
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final reg = _filtered[index];
                    final event = (reg['events'] as Map<String, dynamic>?) ?? {};
                    return _ZestTicketCard(
                      registration: reg,
                      event: event,
                      studentName: name,
                      onTap: () {
                        final eventId = event['id']?.toString() ?? reg['event_id']?.toString();
                        if (eventId != null) {
                          context.push('/student/event/$eventId');
                        }
                      },
                      onViewTicket: () => _showTicketDialog(context, reg, event),
                    );
                  },
                  childCount: _filtered.length,
                ),
              ),
            ),

          // Bottom padding
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }

  void _showTicketDialog(
    BuildContext context,
    Map<String, dynamic> reg,
    Map<String, dynamic> event,
  ) {
    final status = (reg['status'] ?? 'pending').toString().toLowerCase();
    final qrData = reg['qr_code_data']?.toString().isNotEmpty == true
        ? reg['qr_code_data'].toString()
        : reg['id']?.toString() ?? 'ZEST_PASS';

    final eventTitle = event['title']?.toString() ?? 'Campus Event';
    final venue = event['venue']?.toString() ?? 'Main Auditorium';
    final studentName = _profile?['name']?.toString() ?? 'Student';
    final rollNumber = _profile?['roll_number']?.toString() ?? '';

    final dateStr = event['start_date'] != null
        ? () {
            final d = DateTime.tryParse(event['start_date'].toString());
            if (d == null) return 'Date TBA';
            const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
            return '${months[d.month - 1]} ${d.day}, ${d.year}';
          }()
        : 'Date TBA';

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.circularXl3,
            boxShadow: AppShadows.hero,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Ticket Header Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                decoration: BoxDecoration(
                  gradient: status == 'approved'
                      ? AppColors.zestGradient
                      : const LinearGradient(
                          colors: [Color(0xFFFFA000), Color(0xFFFFB74D)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xl3)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.asset(
                            'assets/logo.png',
                            width: 24,
                            height: 24,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'ZEST CAMPUS PASS',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      status == 'approved' ? 'Verified Ticket 🎟️' : 'Registration Pending ⏳',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        borderRadius: AppRadius.circularPill,
                      ),
                      child: Text(
                        status.toUpperCase(),
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Perforated Dashed Divider
              CustomPaint(
                size: const Size(double.infinity, 28),
                painter: _ZestTicketDividerPainter(),
              ),

              // QR Code
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: QrImageView(
                  data: qrData,
                  version: QrVersions.auto,
                  size: 190.0,
                  eyeStyle: QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: status == 'approved' ? AppColors.charcoal : const Color(0xFFFFA000),
                  ),
                  dataModuleStyle: QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: status == 'approved' ? AppColors.charcoal : const Color(0xFFFFA000),
                  ),
                ),
              ),

              // Event & Student Details
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    Text(
                      eventTitle,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.charcoal,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.person_outline, size: 13, color: AppColors.grey600),
                        const SizedBox(width: 4),
                        Text(
                          studentName + (rollNumber.isNotEmpty ? ' ($rollNumber)' : ''),
                          style: GoogleFonts.poppins(fontSize: 12, color: AppColors.grey600, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.calendar_today_rounded, size: 12, color: AppColors.coral),
                        const SizedBox(width: 4),
                        Text(
                          dateStr,
                          style: GoogleFonts.poppins(fontSize: 12, color: AppColors.coral, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 10),
                        const Icon(Icons.location_on_outlined, size: 13, color: AppColors.teal),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            venue,
                            style: GoogleFonts.poppins(fontSize: 12, color: AppColors.teal, fontWeight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      status == 'approved'
                          ? 'Scan at event check-in for entry & +10 Zest points!'
                          : 'Your registration is being reviewed by the club organizer.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: AppColors.grey400,
                        fontSize: 11,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              // Close Button
              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.charcoal,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: AppRadius.circularPill),
                      elevation: 0,
                    ),
                    child: Text(
                      'Done',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
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

/// Ticket card with notch effect, status badge, date, venue, and QR action
class _ZestTicketCard extends StatelessWidget {
  final Map<String, dynamic> registration;
  final Map<String, dynamic> event;
  final String studentName;
  final VoidCallback onTap;
  final VoidCallback onViewTicket;

  const _ZestTicketCard({
    required this.registration,
    required this.event,
    required this.studentName,
    required this.onTap,
    required this.onViewTicket,
  });

  @override
  Widget build(BuildContext context) {
    final status = (registration['status'] ?? 'pending').toString().toLowerCase();
    final eventTitle = event['title']?.toString() ?? 'Event';
    final venue = event['venue']?.toString() ?? 'Campus';
    final coverImage = event['cover_image_url']?.toString();

    final startDateStr = event['start_date']?.toString();
    final startDate = startDateStr != null ? DateTime.tryParse(startDateStr)?.toLocal() : null;
    final dateLabel = startDate != null
        ? () {
            const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
            return '${months[startDate.month - 1]} ${startDate.day}';
          }()
        : 'TBA';

    final Color statusColor;
    final Color statusBg;
    final String statusLabel;

    if (status == 'approved') {
      statusColor = AppColors.teal;
      statusBg = AppColors.tealLight;
      statusLabel = 'Approved ✓';
    } else if (status == 'rejected') {
      statusColor = AppColors.error;
      statusBg = const Color(0xFFFFEBEE);
      statusLabel = 'Declined';
    } else {
      statusColor = const Color(0xFFF57C00);
      statusBg = const Color(0xFFFFF3E0);
      statusLabel = 'Pending ⏳';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.circularXl2,
          boxShadow: AppShadows.card,
        ),
        child: Column(
          children: [
            InkWell(
              onTap: onTap,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xl2)),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.base),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Mini event thumbnail
                    ClipRRect(
                      borderRadius: AppRadius.circularMd,
                      child: Container(
                        width: 58,
                        height: 58,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.coral, AppColors.orange],
                          ),
                        ),
                        child: coverImage != null && coverImage.isNotEmpty
                            ? Image.network(
                                coverImage,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => const Icon(Icons.event, color: Colors.white),
                              )
                            : const Icon(Icons.event, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    // Title and metadata
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: statusBg,
                                  borderRadius: AppRadius.circularPill,
                                ),
                                child: Text(
                                  statusLabel,
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: statusColor,
                                  ),
                                ),
                              ),
                              Text(
                                dateLabel,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.coral,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            eventTitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.charcoal,
                              height: 1.25,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined, size: 12, color: AppColors.grey400),
                              const SizedBox(width: 3),
                              Expanded(
                                child: Text(
                                  venue,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: AppColors.grey600,
                                  ),
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
            ),

            // Perforated line
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: CustomPaint(
                size: const Size(double.infinity, 12),
                painter: _ZestCardPerforationPainter(),
              ),
            ),

            // Ticket Action Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.base, 4, AppSpacing.base, AppSpacing.sm),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Entry Pass ID: #${(registration['id'] ?? '').toString().takeLast(6)}',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.grey400,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: status == 'rejected' ? null : onViewTicket,
                    icon: Icon(
                      Icons.qr_code_rounded,
                      size: 18,
                      color: status == 'rejected' ? AppColors.grey300 : AppColors.coral,
                    ),
                    label: Text(
                      'View QR Pass',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: status == 'rejected' ? AppColors.grey300 : AppColors.coral,
                      ),
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

extension _StringExt on String {
  String takeLast(int n) {
    if (length <= n) return this;
    return substring(length - n);
  }
}

/// Paints the ticket dialog perforation line with cutouts
class _ZestTicketDividerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const dashWidth = 8.0;
    const dashSpace = 5.0;
    const circleRadius = 14.0;

    final cutoutPaint = Paint()
      ..color = const Color(0xFFF6F8FA) // Matches dialog barrier / background
      ..style = PaintingStyle.fill;

    // Left and right circular punch-outs
    canvas.drawCircle(Offset(0, size.height / 2), circleRadius, cutoutPaint);
    canvas.drawCircle(Offset(size.width, size.height / 2), circleRadius, cutoutPaint);

    final linePaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    double startX = circleRadius + 6;
    final endX = size.width - (circleRadius + 6);
    while (startX < endX) {
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

/// Paints a subtle perforated line for card bottoms
class _ZestCardPerforationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const dashWidth = 6.0;
    const dashSpace = 4.0;

    final linePaint = Paint()
      ..color = const Color(0xFFEEF2F6)
      ..strokeWidth = 1.2
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
