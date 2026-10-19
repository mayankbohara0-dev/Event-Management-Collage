import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../admin_colors.dart';

class RegistrationsScreen extends ConsumerStatefulWidget {
  const RegistrationsScreen({super.key});

  @override
  ConsumerState<RegistrationsScreen> createState() => _RegistrationsScreenState();
}

class _RegistrationsScreenState extends ConsumerState<RegistrationsScreen> {
  // Map of event_id -> event data + its registrations
  List<_EventGroup> _groups = [];
  bool _isLoading = true;
  String _globalFilter = 'all';
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      // Fetch all events that have at least one registration
      final regsRes = await Supabase.instance.client
          .from('registrations')
          .select(
            'id, status, registration_number, created_at, event_id, '
            'events(id, title, start_date, cover_image_url, max_seats), '
            'student_profiles(id, name, roll_number, enrollment_number, division, year, avatar_url)',
          )
          .order('created_at', ascending: false);

      final List<Map<String, dynamic>> allRegs = List<Map<String, dynamic>>.from(regsRes);

      // Group by event
      final Map<String, _EventGroup> grouped = {};
      for (final reg in allRegs) {
        final eventMap = reg['events'] as Map<String, dynamic>?;
        if (eventMap == null) continue;
        final eid = eventMap['id'] as String;
        grouped.putIfAbsent(eid, () => _EventGroup(event: eventMap));
        grouped[eid]!.registrations.add(reg);
      }

      // Also load events with 0 registrations (from events table)
      final eventsRes = await Supabase.instance.client
          .from('events')
          .select('id, title, start_date, cover_image_url, max_seats')
          .order('start_date', ascending: false);

      for (final ev in List<Map<String, dynamic>>.from(eventsRes)) {
        final eid = ev['id'] as String;
        if (!grouped.containsKey(eid)) {
          grouped[eid] = _EventGroup(event: ev);
        }
      }

      if (mounted) {
        setState(() {
          _groups = grouped.values.toList()
            ..sort((a, b) {
              final ad = a.event['start_date'] ?? '';
              final bd = b.event['start_date'] ?? '';
              return bd.compareTo(ad);
            });
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateStatus(String regId, String newStatus) async {
    try {
      await Supabase.instance.client
          .from('registrations')
          .update({'status': newStatus})
          .eq('id', regId);
      await _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Status updated to $newStatus'),
          backgroundColor: AdminColors.success,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AdminColors.error,
        ));
      }
    }
  }

  List<_EventGroup> get _visibleGroups {
    return _groups.where((g) {
      // Search: filter by event title
      if (_searchQuery.isNotEmpty &&
          !g.event['title'].toString().toLowerCase().contains(_searchQuery.toLowerCase())) {
        return false;
      }
      // Status filter: only show groups that have matching regs (or show all)
      if (_globalFilter != 'all') {
        return g.registrations.any((r) => r['status'] == _globalFilter);
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminColors.bg,
      body: Column(
        children: [
          _buildHeader(),
          _buildSearchAndFilter(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AdminColors.accent))
                : _visibleGroups.isEmpty
                    ? _buildEmpty()
                    : RefreshIndicator(
                        onRefresh: _load,
                        color: AdminColors.accent,
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                          itemCount: _visibleGroups.length,
                          itemBuilder: (_, i) => _EventRegistrationCard(
                            group: _visibleGroups[i],
                            globalFilter: _globalFilter,
                            onUpdateStatus: _updateStatus,
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final totalRegs = _groups.fold<int>(0, (sum, g) => sum + g.registrations.length);
    final pending = _groups.fold<int>(
        0, (sum, g) => sum + g.registrations.where((r) => r['status'] == 'pending').length);

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      decoration: const BoxDecoration(
        color: AdminColors.sidebar,
        border: Border(bottom: BorderSide(color: AdminColors.border)),
      ),
      child: Row(
        children: [
          const Icon(Icons.how_to_reg_rounded, color: AdminColors.accent, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Registration Management',
                    style: GoogleFonts.inter(
                        color: AdminColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w800)),
                Text(
                  '$totalRegs total registrations · ${_groups.length} events · $pending pending',
                  style: GoogleFonts.inter(color: AdminColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _load,
            icon: const Icon(Icons.refresh_rounded, color: AdminColors.textSecondary),
            tooltip: 'Refresh',
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      color: AdminColors.sidebar,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: (q) => setState(() => _searchQuery = q),
            style: const TextStyle(color: AdminColors.textPrimary, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Search by event name...',
              hintStyle: const TextStyle(color: AdminColors.textSecondary, fontSize: 13),
              prefixIcon: const Icon(Icons.search_rounded, color: AdminColors.textSecondary, size: 20),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, color: AdminColors.textSecondary, size: 18),
                      onPressed: () => setState(() {
                        _searchController.clear();
                        _searchQuery = '';
                      }),
                    )
                  : null,
              filled: true,
              fillColor: AdminColors.surfaceLight,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AdminColors.border)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AdminColors.border)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AdminColors.accent, width: 1.5)),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 34,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final f in ['all', 'pending', 'approved', 'rejected', 'waitlisted'])
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _globalFilter = f),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: _globalFilter == f ? _filterColor(f) : AdminColors.surfaceLight,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: _globalFilter == f ? _filterColor(f) : AdminColors.border),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          f == 'all' ? 'All' : f[0].toUpperCase() + f.substring(1),
                          style: GoogleFonts.inter(
                            color: _globalFilter == f
                                ? (_filterColor(f) == AdminColors.accent ? AdminColors.onAccent : Colors.white)
                                : AdminColors.textSecondary,
                            fontSize: 12,
                            fontWeight: _globalFilter == f ? FontWeight.w800 : FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _filterColor(String f) {
    switch (f) {
      case 'approved': return AdminColors.success;
      case 'rejected': return AdminColors.error;
      case 'waitlisted': return AdminColors.gold;
      case 'pending': return AdminColors.accent;
      default: return AdminColors.accent;
    }
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.inbox_rounded, size: 64, color: AdminColors.border),
          const SizedBox(height: 16),
          Text('No registrations found',
              style: GoogleFonts.inter(color: AdminColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text('Try a different search or status filter',
              style: GoogleFonts.inter(color: AdminColors.textSecondary, fontSize: 13)),
        ],
      ),
    );
  }
}

// ── Data model ─────────────────────────────────────────────────────────────
class _EventGroup {
  final Map<String, dynamic> event;
  final List<Map<String, dynamic>> registrations = [];
  _EventGroup({required this.event});
}

// ── Expandable event card ──────────────────────────────────────────────────
class _EventRegistrationCard extends StatefulWidget {
  final _EventGroup group;
  final String globalFilter;
  final Future<void> Function(String regId, String status) onUpdateStatus;

  const _EventRegistrationCard({
    required this.group,
    required this.globalFilter,
    required this.onUpdateStatus,
  });

  @override
  State<_EventRegistrationCard> createState() => _EventRegistrationCardState();
}

class _EventRegistrationCardState extends State<_EventRegistrationCard> {
  bool _expanded = false;

  List<Map<String, dynamic>> get _filteredRegs {
    final regs = widget.group.registrations;
    if (widget.globalFilter == 'all') return regs;
    return regs.where((r) => r['status'] == widget.globalFilter).toList();
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'approved': return AdminColors.success;
      case 'rejected': return AdminColors.error;
      case 'waitlisted': return AdminColors.gold;
      default: return AdminColors.accent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final event = widget.group.event;
    final regs = widget.group.registrations;
    final filtered = _filteredRegs;

    final total = regs.length;
    final approved = regs.where((r) => r['status'] == 'approved').length;
    final pending = regs.where((r) => r['status'] == 'pending').length;
    final rejected = regs.where((r) => r['status'] == 'rejected').length;
    final maxSeats = (event['max_seats'] ?? 0) as int;

    final startDate = event['start_date'] != null
        ? DateTime.tryParse(event['start_date'].toString())
        : null;
    final dateStr = startDate != null
        ? '${startDate.day} ${_month(startDate.month)} ${startDate.year}'
        : 'No date';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AdminColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _expanded ? AdminColors.accent.withValues(alpha: 0.5) : AdminColors.border),
      ),
      child: Column(
        children: [
          // ── Event header (always visible) ──
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Poster thumb
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: event['cover_image_url'] != null && (event['cover_image_url'] as String).isNotEmpty
                        ? Image.network(
                            event['cover_image_url'],
                            width: 56, height: 56, fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => _eventPlaceholder(),
                          )
                        : _eventPlaceholder(),
                  ),
                  const SizedBox(width: 14),
                  // Event info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event['title'] ?? 'Untitled Event',
                          style: GoogleFonts.inter(
                              color: AdminColors.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today_rounded, size: 12, color: AdminColors.textSecondary),
                            const SizedBox(width: 4),
                            Text(dateStr, style: GoogleFonts.inter(color: AdminColors.textSecondary, fontSize: 12)),
                            if (maxSeats > 0) ...[
                              const SizedBox(width: 12),
                              const Icon(Icons.chair_rounded, size: 12, color: AdminColors.textSecondary),
                              const SizedBox(width: 4),
                              Text('$approved/$maxSeats seats', style: GoogleFonts.inter(color: AdminColors.textSecondary, fontSize: 12)),
                            ],
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Status chips row
                        Row(
                          children: [
                            _StatChip(label: '$total Total', color: AdminColors.accent),
                            const SizedBox(width: 6),
                            if (pending > 0) _StatChip(label: '$pending Pending', color: AdminColors.accent),
                            if (pending > 0) const SizedBox(width: 6),
                            _StatChip(label: '$approved Approved', color: AdminColors.success),
                            const SizedBox(width: 6),
                            if (rejected > 0) _StatChip(label: '$rejected Rejected', color: AdminColors.error),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Expand arrow
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.keyboard_arrow_down_rounded,
                        color: AdminColors.textSecondary, size: 28),
                  ),
                ],
              ),
            ),
          ),

          // ── Registration rows (expandable) ──
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: filtered.isEmpty
                ? Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      border: Border(top: BorderSide(color: AdminColors.border)),
                    ),
                    child: Center(
                      child: Text(
                        'No registrations match the current filter',
                        style: GoogleFonts.inter(color: AdminColors.textSecondary, fontSize: 13),
                      ),
                    ),
                  )
                : Container(
                    decoration: const BoxDecoration(
                      border: Border(top: BorderSide(color: AdminColors.border)),
                    ),
                    child: Column(
                      children: filtered.asMap().entries.map((entry) {
                        final i = entry.key;
                        final reg = entry.value;
                        final student = reg['student_profiles'] as Map<String, dynamic>?;
                        final status = (reg['status'] ?? 'pending') as String;
                        final isLast = i == filtered.length - 1;

                        return Container(
                          decoration: BoxDecoration(
                            border: isLast
                                ? null
                                : const Border(bottom: BorderSide(color: AdminColors.border, width: 0.5)),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              // Student avatar
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: AdminColors.accent.withValues(alpha: 0.15),
                                backgroundImage: student?['avatar_url'] != null && (student!['avatar_url'] as String).isNotEmpty
                                    ? NetworkImage(student['avatar_url'])
                                    : null,
                                child: (student?['avatar_url'] == null || (student?['avatar_url'] as String? ?? '').isEmpty)
                                    ? Text(
                                        (student?['name'] ?? '?')[0].toUpperCase(),
                                        style: const TextStyle(
                                            color: AdminColors.accent, fontWeight: FontWeight.w700, fontSize: 14),
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              // Student info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      student?['name'] ?? 'Unknown',
                                      style: GoogleFonts.inter(
                                          color: AdminColors.textPrimary,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(height: 2),
                                    Wrap(
                                      spacing: 8,
                                      children: [
                                        if ((student?['roll_number'] ?? '').toString().isNotEmpty)
                                          Text('Roll: ${student!['roll_number']}',
                                              style: GoogleFonts.inter(color: AdminColors.textSecondary, fontSize: 11)),
                                        if ((student?['enrollment_number'] ?? '').toString().isNotEmpty)
                                          Text('PRN: ${student!['enrollment_number']}',
                                              style: GoogleFonts.inter(color: AdminColors.textSecondary, fontSize: 11)),
                                        if ((student?['division'] ?? '').toString().isNotEmpty)
                                          Text('Div: ${student!['division']}',
                                              style: GoogleFonts.inter(color: AdminColors.textSecondary, fontSize: 11)),
                                        if ((student?['year'] ?? '').toString().isNotEmpty)
                                          Text('Yr: ${student!['year']}',
                                              style: GoogleFonts.inter(color: AdminColors.textSecondary, fontSize: 11)),
                                      ],
                                    ),
                                    if ((reg['registration_number'] ?? '').toString().isNotEmpty)
                                      Text('# ${reg['registration_number']}',
                                          style: GoogleFonts.inter(color: AdminColors.textSecondary, fontSize: 11)),
                                  ],
                                ),
                              ),
                              // Date
                              Text(
                                reg['created_at'] != null
                                    ? DateTime.parse(reg['created_at']).toLocal().toString().split(' ')[0]
                                    : '',
                                style: GoogleFonts.inter(color: AdminColors.textSecondary, fontSize: 11),
                              ),
                              const SizedBox(width: 10),
                              // Status badge
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _statusColor(status).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: _statusColor(status).withValues(alpha: 0.3)),
                                ),
                                child: Text(
                                  status.toUpperCase(),
                                  style: GoogleFonts.inter(
                                      color: _statusColor(status), fontSize: 10, fontWeight: FontWeight.w800),
                                ),
                              ),
                              const SizedBox(width: 10),
                              // Actions
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (status != 'approved')
                                    _ActionBtn(
                                      icon: Icons.check_circle_rounded,
                                      label: 'Approve',
                                      color: AdminColors.success,
                                      onTap: () => widget.onUpdateStatus(reg['id'], 'approved'),
                                    ),
                                  if (status != 'approved' && status != 'rejected')
                                    const SizedBox(width: 6),
                                  if (status != 'rejected')
                                    _ActionBtn(
                                      icon: Icons.cancel_rounded,
                                      label: 'Reject',
                                      color: AdminColors.error,
                                      onTap: () => widget.onUpdateStatus(reg['id'], 'rejected'),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
            crossFadeState: _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }

  Widget _eventPlaceholder() {
    return Container(
      width: 56, height: 56,
      color: AdminColors.surfaceLight,
      child: const Icon(Icons.event_rounded, color: AdminColors.textSecondary, size: 28),
    );
  }

  String _month(int m) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return months[m - 1];
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final Color color;
  const _StatChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: GoogleFonts.inter(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionBtn({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
      ),
    );
  }
}
