// lib/features/admin/events/presentation/events_table_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../admin_colors.dart';

// ── Status filter tabs ──────────────────────────
enum _StatusFilter { all, published, draft, archived }

class EventsTableScreen extends ConsumerStatefulWidget {
  const EventsTableScreen({super.key});

  @override
  ConsumerState<EventsTableScreen> createState() => _EventsTableScreenState();
}

class _EventsTableScreenState extends ConsumerState<EventsTableScreen> {
  List<Map<String, dynamic>> _events = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';
  _StatusFilter _statusFilter = _StatusFilter.all;

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final response = await Supabase.instance.client
          .from('events')
          .select('id, title, start_date, end_date, max_seats, visibility, venue, created_at')
          .order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          _events = List<Map<String, dynamic>>.from(response);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Admin events fetch error: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  /// Toggle an event's visibility between published ↔ draft, or un-archive it.
  Future<void> _toggleVisibility(Map<String, dynamic> event) async {
    final current = event['visibility']?.toString() ?? 'draft';
    final next = current == 'published' ? 'draft' : 'published';
    try {
      await Supabase.instance.client
          .from('events')
          .update({'visibility': next}).eq('id', event['id']);
      await _fetchEvents();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update visibility: $e'),
            backgroundColor: AdminColors.error,
          ),
        );
      }
    }
  }

  /// Archive an event (sets visibility to 'archived').
  Future<void> _archiveEvent(Map<String, dynamic> event) async {
    final confirmed = await _confirm(
      title: 'Archive Event',
      message:
          'Archive "${event['title']}"?\nIt will be hidden from students but not deleted.',
      confirmLabel: 'Archive',
      confirmColor: AdminColors.gold,
    );
    if (!confirmed) return;
    try {
      await Supabase.instance.client
          .from('events')
          .update({'visibility': 'archived'}).eq('id', event['id']);
      await _fetchEvents();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to archive: $e'),
            backgroundColor: AdminColors.error,
          ),
        );
      }
    }
  }

  /// Hard-delete an event.
  Future<void> _deleteEvent(Map<String, dynamic> event) async {
    final confirmed = await _confirm(
      title: 'Delete Event',
      message:
          'Permanently delete "${event['title']}"?\nThis will remove all registrations and form data. This cannot be undone.',
      confirmLabel: 'Delete',
      confirmColor: AdminColors.error,
    );
    if (!confirmed) return;
    try {
      await Supabase.instance.client
          .from('events')
          .delete()
          .eq('id', event['id']);
      await _fetchEvents();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Event deleted.'),
            backgroundColor: AdminColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete: $e'),
            backgroundColor: AdminColors.error,
          ),
        );
      }
    }
  }

  Future<bool> _confirm({
    required String title,
    required String message,
    required String confirmLabel,
    required Color confirmColor,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AdminColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title,
            style: const TextStyle(
                color: AdminColors.textPrimary, fontWeight: FontWeight.w700)),
        content: Text(message,
            style: const TextStyle(
                color: AdminColors.textSecondary, height: 1.5, fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel',
                style: TextStyle(color: AdminColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  List<Map<String, dynamic>> get _filteredEvents {
    return _events.where((e) {
      final vis = e['visibility']?.toString() ?? 'draft';
      final matchesStatus = _statusFilter == _StatusFilter.all ||
          (_statusFilter == _StatusFilter.published && vis == 'published') ||
          (_statusFilter == _StatusFilter.draft && vis == 'draft') ||
          (_statusFilter == _StatusFilter.archived && vis == 'archived');
      final matchesSearch = _searchQuery.isEmpty ||
          (e['title'] ?? '')
              .toString()
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());
      return matchesStatus && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Container(
      color: AdminColors.bg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top Bar ──────────────────────────────────
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 16 : 28,
              vertical: isMobile ? 14 : 20,
            ),
            decoration: const BoxDecoration(
              color: AdminColors.sidebar,
              border:
                  Border(bottom: BorderSide(color: AdminColors.border, width: 1)),
            ),
            child: isMobile
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Events (${_events.length})',
                            style: const TextStyle(
                                color: AdminColors.textPrimary,
                                fontSize: 20,
                                fontWeight: FontWeight.w800),
                          ),
                          Row(
                            children: [
                              IconButton(
                                onPressed: _fetchEvents,
                                icon: const Icon(Icons.refresh_rounded,
                                    color: AdminColors.textSecondary),
                                tooltip: 'Refresh',
                              ),
                              ElevatedButton.icon(
                                onPressed: () =>
                                    context.go('/admin/events/create'),
                                icon: const Icon(Icons.add_rounded, size: 16),
                                label: const Text('New'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AdminColors.accent,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 10),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  elevation: 0,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _SearchBar(
                          onChanged: (v) =>
                              setState(() => _searchQuery = v)),
                      const SizedBox(height: 10),
                      _StatusTabs(
                        selected: _statusFilter,
                        onChanged: (f) => setState(() => _statusFilter = f),
                        counts: _countsByStatus(),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Events (${_events.length})',
                                style: const TextStyle(
                                    color: AdminColors.textPrimary,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800),
                              ),
                              const Text('Manage all events',
                                  style: TextStyle(
                                      color: AdminColors.textSecondary,
                                      fontSize: 13)),
                            ],
                          ),
                          const Spacer(),
                          SizedBox(
                            width: 240,
                            child: _SearchBar(
                                onChanged: (v) =>
                                    setState(() => _searchQuery = v)),
                          ),
                          const SizedBox(width: 12),
                          IconButton(
                            onPressed: _fetchEvents,
                            icon: const Icon(Icons.refresh_rounded,
                                color: AdminColors.textSecondary),
                            tooltip: 'Refresh',
                          ),
                          const SizedBox(width: 4),
                          ElevatedButton.icon(
                            onPressed: () =>
                                context.go('/admin/events/create'),
                            icon: const Icon(Icons.add_rounded, size: 18),
                            label: const Text('Create Event'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AdminColors.accent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                              textStyle: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _StatusTabs(
                        selected: _statusFilter,
                        onChanged: (f) => setState(() => _statusFilter = f),
                        counts: _countsByStatus(),
                      ),
                    ],
                  ),
          ),

          // ── Content ──────────────────────────────────
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: AdminColors.accent))
                : _errorMessage != null
                    ? _ErrorView(
                        message: _errorMessage!,
                        onRetry: _fetchEvents,
                      )
                    : _filteredEvents.isEmpty
                        ? _EmptyView(
                            hasEvents: _events.isNotEmpty,
                            onCreateTap: () =>
                                context.go('/admin/events/create'),
                          )
                        : isMobile
                            ? _MobileEventList(
                                events: _filteredEvents,
                                onRefresh: _fetchEvents,
                                onToggleVisibility: _toggleVisibility,
                                onArchive: _archiveEvent,
                                onDelete: _deleteEvent,
                              )
                            : _DesktopEventTable(
                                events: _filteredEvents,
                                onToggleVisibility: _toggleVisibility,
                                onArchive: _archiveEvent,
                                onDelete: _deleteEvent,
                              ),
          ),
        ],
      ),
    );
  }

  Map<_StatusFilter, int> _countsByStatus() {
    final counts = {
      _StatusFilter.all: _events.length,
      _StatusFilter.published: 0,
      _StatusFilter.draft: 0,
      _StatusFilter.archived: 0,
    };
    for (final e in _events) {
      final vis = e['visibility']?.toString() ?? 'draft';
      if (vis == 'published') counts[_StatusFilter.published] = counts[_StatusFilter.published]! + 1;
      if (vis == 'draft') counts[_StatusFilter.draft] = counts[_StatusFilter.draft]! + 1;
      if (vis == 'archived') counts[_StatusFilter.archived] = counts[_StatusFilter.archived]! + 1;
    }
    return counts;
  }
}

// ── STATUS TABS ───────────────────────────────
class _StatusTabs extends StatelessWidget {
  final _StatusFilter selected;
  final void Function(_StatusFilter) onChanged;
  final Map<_StatusFilter, int> counts;

  const _StatusTabs(
      {required this.selected,
      required this.onChanged,
      required this.counts});

  @override
  Widget build(BuildContext context) {
    final tabs = [
      (_StatusFilter.all, 'All', AdminColors.textSecondary),
      (_StatusFilter.published, 'Published', AdminColors.success),
      (_StatusFilter.draft, 'Draft', AdminColors.textSecondary),
      (_StatusFilter.archived, 'Archived', AdminColors.gold),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: tabs.map((t) {
          final (filter, label, color) = t;
          final isSelected = selected == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onChanged(filter),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: isSelected
                      ? color.withValues(alpha: 0.12)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? color : AdminColors.border,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: isSelected ? color : AdminColors.textSecondary,
                        fontSize: 12,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? color.withValues(alpha: 0.15)
                            : AdminColors.surfaceLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${counts[filter] ?? 0}',
                        style: TextStyle(
                          color: isSelected
                              ? color
                              : AdminColors.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── SEARCH BAR ────────────────────────────────
class _SearchBar extends StatelessWidget {
  final void Function(String) onChanged;
  const _SearchBar({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: TextField(
        style:
            const TextStyle(color: AdminColors.textPrimary, fontSize: 14),
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Search events...',
          hintStyle: const TextStyle(
              color: AdminColors.textSecondary, fontSize: 14),
          prefixIcon: const Icon(Icons.search_rounded,
              color: AdminColors.textSecondary, size: 18),
          filled: true,
          fillColor: AdminColors.surfaceLight,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AdminColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AdminColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: AdminColors.accent, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14),
        ),
      ),
    );
  }
}

// ── ERROR VIEW ────────────────────────────────
class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AdminColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline_rounded,
                  size: 48, color: AdminColors.error),
            ),
            const SizedBox(height: 16),
            const Text('Failed to load events',
                style: TextStyle(
                    color: AdminColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: AdminColors.textSecondary,
                  fontSize: 13,
                  height: 1.5),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AdminColors.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── EMPTY VIEW ────────────────────────────────
class _EmptyView extends StatelessWidget {
  final bool hasEvents; // true = filtered to zero, false = no events at all
  final VoidCallback onCreateTap;
  const _EmptyView({required this.hasEvents, required this.onCreateTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
                color: AdminColors.surfaceLight, shape: BoxShape.circle),
            child: const Icon(Icons.event_busy_outlined,
                size: 40, color: AdminColors.textSecondary),
          ),
          const SizedBox(height: 16),
          Text(
            hasEvents ? 'No events match your filter' : 'No events yet',
            style: const TextStyle(
                color: AdminColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          if (!hasEvents)
            TextButton.icon(
              onPressed: onCreateTap,
              icon: const Icon(Icons.add_rounded,
                  color: AdminColors.accent, size: 18),
              label: const Text('Create your first event',
                  style: TextStyle(color: AdminColors.accent)),
            ),
        ],
      ),
    );
  }
}

// ── MOBILE CARD LIST ─────────────────────────
class _MobileEventList extends StatelessWidget {
  final List<Map<String, dynamic>> events;
  final Future<void> Function() onRefresh;
  final Future<void> Function(Map<String, dynamic>) onToggleVisibility;
  final Future<void> Function(Map<String, dynamic>) onArchive;
  final Future<void> Function(Map<String, dynamic>) onDelete;

  const _MobileEventList({
    required this.events,
    required this.onRefresh,
    required this.onToggleVisibility,
    required this.onArchive,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AdminColors.accent,
      backgroundColor: AdminColors.surface,
      onRefresh: onRefresh,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: events.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final event = events[i];
          return _MobileEventCard(
            event: event,
            onToggleVisibility: () => onToggleVisibility(event),
            onArchive: () => onArchive(event),
            onDelete: () => onDelete(event),
          );
        },
      ),
    );
  }
}

class _MobileEventCard extends StatelessWidget {
  final Map<String, dynamic> event;
  final VoidCallback onToggleVisibility;
  final VoidCallback onArchive;
  final VoidCallback onDelete;

  const _MobileEventCard({
    required this.event,
    required this.onToggleVisibility,
    required this.onArchive,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final vis = event['visibility']?.toString() ?? 'draft';
    final isPublished = vis == 'published';
    final isArchived = vis == 'archived';
    final statusColor = isPublished
        ? AdminColors.success
        : isArchived
            ? AdminColors.gold
            : AdminColors.textSecondary;

    final dateStr = event['start_date'] != null
        ? DateTime.parse(event['start_date']).toLocal().toString().split(' ')[0]
        : 'TBA';

    // Compute live status label
    final now = DateTime.now();
    String liveLabel = '';
    if (event['start_date'] != null && event['end_date'] != null) {
      final start = DateTime.parse(event['start_date']).toLocal();
      final end = DateTime.parse(event['end_date']).toLocal();
      if (now.isAfter(start) && now.isBefore(end)) liveLabel = 'ONGOING';
      if (now.isAfter(end)) liveLabel = 'ENDED';
    }

    return Container(
      decoration: BoxDecoration(
        color: AdminColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AdminColors.border),
      ),
      child: Column(
        children: [
          // Colored top strip
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title + badges row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        event['title'] ?? 'Untitled',
                        style: const TextStyle(
                          color: AdminColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _VisBadge(visibility: vis),
                        if (liveLabel.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          _LiveBadge(label: liveLabel),
                        ],
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Meta row
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: 13, color: AdminColors.textSecondary),
                    const SizedBox(width: 5),
                    Text(dateStr,
                        style: const TextStyle(
                            color: AdminColors.textSecondary, fontSize: 12)),
                    const SizedBox(width: 14),
                    const Icon(Icons.location_on_outlined,
                        size: 13, color: AdminColors.textSecondary),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        event['venue'] ?? '—',
                        style: const TextStyle(
                            color: AdminColors.textSecondary, fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.event_seat_outlined,
                        size: 13, color: AdminColors.textSecondary),
                    const SizedBox(width: 5),
                    Text(
                      '${event['max_seats']?.toString() ?? 'Unlimited'} seats',
                      style: const TextStyle(
                          color: AdminColors.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Action buttons row 1
                Row(
                  children: [
                    Expanded(
                      child: _MobileActionBtn(
                        icon: Icons.bar_chart_rounded,
                        label: 'Responses',
                        color: AdminColors.accent,
                        onTap: () => context.go(
                            '/admin/events/${event['id']}/responses'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _MobileActionBtn(
                        icon: Icons.edit_document,
                        label: 'Form Builder',
                        color: const Color(0xFF3B82F6),
                        onTap: () => context
                            .go('/admin/events/${event['id']}/builder'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Action buttons row 2
                Row(
                  children: [
                    Expanded(
                      child: _MobileActionBtn(
                        icon: Icons.edit_rounded,
                        label: 'Edit',
                        color: AdminColors.gold,
                        onTap: () => context
                            .go('/admin/events/${event['id']}/edit'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _MobileActionBtn(
                        icon: Icons.qr_code_scanner_rounded,
                        label: 'Scanner',
                        color: const Color(0xFF8B5CF6),
                        onTap: () => context
                            .go('/admin/events/${event['id']}/scanner'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Action buttons row 3 — status controls
                Row(
                  children: [
                    Expanded(
                      child: _MobileActionBtn(
                        icon: isPublished
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                        label: isPublished ? 'Unpublish' : 'Publish',
                        color: isPublished
                            ? AdminColors.textSecondary
                            : AdminColors.success,
                        onTap: isArchived ? () {} : onToggleVisibility,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (!isArchived)
                      Expanded(
                        child: _MobileActionBtn(
                          icon: Icons.archive_rounded,
                          label: 'Archive',
                          color: AdminColors.gold,
                          onTap: onArchive,
                        ),
                      )
                    else
                      Expanded(
                        child: _MobileActionBtn(
                          icon: Icons.unarchive_rounded,
                          label: 'Unarchive',
                          color: AdminColors.success,
                          onTap: onToggleVisibility,
                        ),
                      ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _MobileActionBtn(
                        icon: Icons.delete_outline_rounded,
                        label: 'Delete',
                        color: AdminColors.error,
                        onTap: onDelete,
                      ),
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

class _MobileActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _MobileActionBtn(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 15),
            const SizedBox(width: 5),
            Flexible(
              child: Text(label,
                  style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.w700),
                  overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }
}

// ── DESKTOP TABLE ─────────────────────────────
class _DesktopEventTable extends StatelessWidget {
  final List<Map<String, dynamic>> events;
  final Future<void> Function(Map<String, dynamic>) onToggleVisibility;
  final Future<void> Function(Map<String, dynamic>) onArchive;
  final Future<void> Function(Map<String, dynamic>) onDelete;

  const _DesktopEventTable({
    required this.events,
    required this.onToggleVisibility,
    required this.onArchive,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          color: AdminColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AdminColors.border),
        ),
        // Use LayoutBuilder + SingleChildScrollView so the table has a
        // constrained height and never renders blank.
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints:
                        BoxConstraints(minWidth: constraints.maxWidth),
                    child: DataTable(
                      headingRowColor:
                          WidgetStateProperty.all(AdminColors.surfaceLight),
                      dataRowColor:
                          WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.hovered)) {
                          return AdminColors.accent.withValues(alpha: 0.04);
                        }
                        return Colors.transparent;
                      }),
                      dividerThickness: 1,
                      columnSpacing: 24,
                      headingTextStyle: const TextStyle(
                          color: AdminColors.textSecondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13),
                      dataTextStyle: const TextStyle(
                          color: AdminColors.textPrimary, fontSize: 13),
                      columns: const [
                        DataColumn(label: Text('Event')),
                        DataColumn(label: Text('Date')),
                        DataColumn(label: Text('Venue')),
                        DataColumn(label: Text('Seats')),
                        DataColumn(label: Text('Status')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: events.map((event) {
                        final vis =
                            event['visibility']?.toString() ?? 'draft';
                        final isPublished = vis == 'published';
                        final isArchived = vis == 'archived';

                        final dateStr = event['start_date'] != null
                            ? DateTime.parse(event['start_date'])
                                .toLocal()
                                .toString()
                                .split(' ')[0]
                            : 'TBA';

                        // Live status
                        String liveLabel = '';
                        if (event['start_date'] != null &&
                            event['end_date'] != null) {
                          final start = DateTime.parse(event['start_date'])
                              .toLocal();
                          final end =
                              DateTime.parse(event['end_date']).toLocal();
                          final now = DateTime.now();
                          if (now.isAfter(start) && now.isBefore(end)) {
                            liveLabel = 'ONGOING';
                          } else if (now.isAfter(end)) {
                            liveLabel = 'ENDED';
                          }
                        }

                        return DataRow(cells: [
                          // Event title + live badge
                          DataCell(
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  event['title'] ?? 'Untitled',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (liveLabel.isNotEmpty)
                                  _LiveBadge(label: liveLabel),
                              ],
                            ),
                          ),
                          DataCell(Text(dateStr)),
                          DataCell(Text(
                            event['venue'] ?? '—',
                            overflow: TextOverflow.ellipsis,
                          )),
                          DataCell(Text(
                              event['max_seats']?.toString() ?? 'Unlimited')),
                          // Status badge
                          DataCell(_VisBadge(visibility: vis)),
                          // Actions
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _ActionBtn(
                                  icon: Icons.bar_chart_rounded,
                                  label: 'Responses',
                                  color: AdminColors.accent,
                                  onTap: () => context.go(
                                      '/admin/events/${event['id']}/responses'),
                                ),
                                const SizedBox(width: 6),
                                _ActionBtn(
                                  icon: Icons.edit_document,
                                  label: 'Form Builder',
                                  color: const Color(0xFF3B82F6),
                                  onTap: () => context.go(
                                      '/admin/events/${event['id']}/builder'),
                                ),
                                const SizedBox(width: 6),
                                _ActionBtn(
                                  icon: Icons.edit_rounded,
                                  label: 'Edit',
                                  color: AdminColors.gold,
                                  onTap: () => context.go(
                                      '/admin/events/${event['id']}/edit'),
                                ),
                                const SizedBox(width: 6),
                                _ActionBtn(
                                  icon: Icons.star_rounded,
                                  label: 'Feedback',
                                  color: Colors.amber,
                                  onTap: () => context.go(
                                      '/admin/events/${event['id']}/feedback'),
                                ),
                                const SizedBox(width: 6),
                                _ActionBtn(
                                  icon: Icons.qr_code_scanner_rounded,
                                  label: 'Scanner',
                                  color: const Color(0xFF8B5CF6),
                                  onTap: () => context.go(
                                      '/admin/events/${event['id']}/scanner'),
                                ),
                                const SizedBox(width: 6),
                                // Publish / Unpublish toggle
                                if (!isArchived)
                                  _ActionBtn(
                                    icon: isPublished
                                        ? Icons.visibility_off_rounded
                                        : Icons.visibility_rounded,
                                    label: isPublished
                                        ? 'Unpublish'
                                        : 'Publish',
                                    color: isPublished
                                        ? AdminColors.textSecondary
                                        : AdminColors.success,
                                    onTap: () => onToggleVisibility(event),
                                  ),
                                if (!isArchived) ...[
                                  const SizedBox(width: 6),
                                  _ActionBtn(
                                    icon: Icons.archive_rounded,
                                    label: 'Archive',
                                    color: AdminColors.gold,
                                    onTap: () => onArchive(event),
                                  ),
                                ] else ...[
                                  const SizedBox(width: 6),
                                  _ActionBtn(
                                    icon: Icons.unarchive_rounded,
                                    label: 'Unarchive',
                                    color: AdminColors.success,
                                    onTap: () => onToggleVisibility(event),
                                  ),
                                ],
                                const SizedBox(width: 6),
                                _ActionBtn(
                                  icon: Icons.delete_outline_rounded,
                                  label: 'Delete',
                                  color: AdminColors.error,
                                  onTap: () => onDelete(event),
                                ),
                              ],
                            ),
                          ),
                        ]);
                      }).toList(),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// ── SHARED BADGE WIDGETS ─────────────────────
class _VisBadge extends StatelessWidget {
  final String visibility;
  const _VisBadge({required this.visibility});

  @override
  Widget build(BuildContext context) {
    final Color color;
    switch (visibility) {
      case 'published':
        color = AdminColors.success;
        break;
      case 'archived':
        color = AdminColors.gold;
        break;
      default:
        color = AdminColors.textSecondary;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        visibility.toUpperCase(),
        style: TextStyle(
            fontSize: 10, fontWeight: FontWeight.w800, color: color),
      ),
    );
  }
}

class _LiveBadge extends StatelessWidget {
  final String label; // 'ONGOING' or 'ENDED'
  const _LiveBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    final isOngoing = label == 'ONGOING';
    final color =
        isOngoing ? const Color(0xFF0EA5E9) : AdminColors.textSecondary;
    return Container(
      margin: const EdgeInsets.only(top: 3),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isOngoing)
            Container(
              width: 6,
              height: 6,
              margin: const EdgeInsets.only(right: 4),
              decoration: BoxDecoration(
                  color: color, shape: BoxShape.circle),
            ),
          Text(
            label,
            style: TextStyle(
                fontSize: 9, fontWeight: FontWeight.w800, color: color),
          ),
        ],
      ),
    );
  }
}

// ── ACTION BUTTON (desktop) ───────────────────
class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionBtn(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});

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
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 17),
        ),
      ),
    );
  }
}
