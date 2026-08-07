import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../dashboard/presentation/dashboard_layout.dart';

class EventsTableScreen extends ConsumerStatefulWidget {
  const EventsTableScreen({super.key});

  @override
  ConsumerState<EventsTableScreen> createState() => _EventsTableScreenState();
}

class _EventsTableScreenState extends ConsumerState<EventsTableScreen> {
  List<Map<String, dynamic>> _events = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    setState(() => _isLoading = true);
    try {
      final response = await Supabase.instance.client
          .from('events')
          .select('id, title, start_date, max_seats, visibility, venue')
          .order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          _events = List<Map<String, dynamic>>.from(response);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to load events'),
            backgroundColor: AdminColors.error,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  List<Map<String, dynamic>> get _filteredEvents {
    if (_searchQuery.isEmpty) return _events;
    return _events
        .where((e) => (e['title'] ?? '')
            .toString()
            .toLowerCase()
            .contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AdminColors.bg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top Bar ───────────────────────────────────────────────
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
            decoration: const BoxDecoration(
              color: AdminColors.sidebar,
              border: Border(
                  bottom: BorderSide(color: AdminColors.border, width: 1)),
            ),
            child: Row(
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Events',
                      style: TextStyle(
                        color: AdminColors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    Text(
                      'Manage all events',
                      style: TextStyle(
                          color: AdminColors.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
                const Spacer(),
                // Search bar
                SizedBox(
                  width: 240,
                  height: 42,
                  child: TextField(
                    style: const TextStyle(
                        color: AdminColors.textPrimary, fontSize: 14),
                    onChanged: (v) => setState(() => _searchQuery = v),
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
                        borderSide:
                            const BorderSide(color: AdminColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: AdminColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: AdminColors.accent, width: 1.5),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Create button
                ElevatedButton.icon(
                  onPressed: () => context.go('/admin/events/create'),
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
          ),

          // ── Table ─────────────────────────────────────────────────
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AdminColors.accent))
                : _filteredEvents.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AdminColors.surfaceLight,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.event_busy_outlined,
                                  size: 40, color: AdminColors.textSecondary),
                            ),
                            const SizedBox(height: 16),
                            const Text('No events found',
                                style: TextStyle(
                                    color: AdminColors.textPrimary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(20),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AdminColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AdminColors.border),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: SingleChildScrollView(
                              child: DataTable(
                                headingRowColor:
                                    WidgetStateProperty.all(AdminColors.surfaceLight),
                                dataRowColor:
                                    WidgetStateProperty.resolveWith((states) {
                                  if (states.contains(WidgetState.hovered)) {
                                    return AdminColors.accent
                                        .withOpacity(0.05);
                                  }
                                  return Colors.transparent;
                                }),
                                dividerThickness: 1,
                                headingTextStyle: const TextStyle(
                                  color: AdminColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                                dataTextStyle: const TextStyle(
                                  color: AdminColors.textPrimary,
                                  fontSize: 13,
                                ),
                                columns: const [
                                  DataColumn(
                                      label: Text('Event Title')),
                                  DataColumn(label: Text('Start Date')),
                                  DataColumn(label: Text('Venue')),
                                  DataColumn(label: Text('Capacity')),
                                  DataColumn(label: Text('Status')),
                                  DataColumn(label: Text('Actions')),
                                ],
                                rows: _filteredEvents.map((event) {
                                  final isPublished =
                                      event['visibility'] == 'published';
                                  final dateStr = event['start_date'] != null
                                      ? DateTime.parse(event['start_date'])
                                          .toLocal()
                                          .toString()
                                          .split(' ')[0]
                                      : 'TBA';

                                  return DataRow(cells: [
                                    DataCell(
                                      Text(
                                        event['title'] ?? 'Untitled',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                    DataCell(Text(dateStr)),
                                    DataCell(
                                        Text(event['venue'] ?? '—')),
                                    DataCell(Text(
                                        event['max_seats']
                                                ?.toString() ??
                                            'Unlimited')),
                                    DataCell(
                                      Container(
                                        padding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 10,
                                                vertical: 4),
                                        decoration: BoxDecoration(
                                          color: isPublished
                                              ? AdminColors.success
                                                  .withOpacity(0.15)
                                              : AdminColors.textSecondary
                                                  .withOpacity(0.15),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          event['visibility']
                                                  ?.toString()
                                                  .toUpperCase() ??
                                              'DRAFT',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: isPublished
                                                ? AdminColors.success
                                                : AdminColors.textSecondary,
                                          ),
                                        ),
                                      ),
                                    ),
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
                                          const SizedBox(width: 8),
                                          _ActionBtn(
                                            icon:
                                                Icons.edit_document,
                                            label: 'Builder',
                                            color: const Color(0xFF3B82F6),
                                            onTap: () => context.go(
                                                '/admin/events/${event['id']}/builder'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ]);
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

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
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
      ),
    );
  }
}
