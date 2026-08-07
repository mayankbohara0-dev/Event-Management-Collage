import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../dashboard/presentation/dashboard_layout.dart'; // To get AdminColors if defined there, or I can redefine it here

// Redefining AdminColors for simplicity and self-containment if not exported globally
class AdminColors {
  static const Color bg = Color(0xFFF7F7F7);
  static const Color sidebar = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFF9FAFB);
  static const Color accent = Color(0xFF00843D);
  static const Color gold = Color(0xFFFFB700);
  static const Color success = Color(0xFF00843D);
  static const Color error = Color(0xFFE31837);
  static const Color textPrimary = Color(0xFF111111);
  static const Color textSecondary = Color(0xFF616161);
  static const Color border = Color(0xFFE5E5E5);

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF006630), Color(0xFF00843D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class RegistrationsScreen extends ConsumerStatefulWidget {
  const RegistrationsScreen({super.key});

  @override
  ConsumerState<RegistrationsScreen> createState() => _RegistrationsScreenState();
}

class _RegistrationsScreenState extends ConsumerState<RegistrationsScreen> {
  List<Map<String, dynamic>> _registrations = [];
  bool _isLoading = true;
  String _filterStatus = 'all';

  @override
  void initState() {
    super.initState();
    _fetchRegistrations();
  }

  Future<void> _fetchRegistrations() async {
    setState(() => _isLoading = true);
    try {
      var query = Supabase.instance.client
          .from('registrations')
          .select('id, status, registration_number, created_at, events(title), student_profiles(name, roll_number, enrollment_number, division, year)');

      if (_filterStatus != 'all') {
        query = query.eq('status', _filterStatus);
      }

      final response = await query.order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          _registrations = List<Map<String, dynamic>>.from(response);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load registrations: $e'),
            backgroundColor: AdminColors.error,
          ),
        );
      }
    }
  }

  Future<void> _updateStatus(String registrationId, String newStatus) async {
    try {
      await Supabase.instance.client
          .from('registrations')
          .update({'status': newStatus})
          .eq('id', registrationId);
      _fetchRegistrations();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status updated to $newStatus'),
            backgroundColor: AdminColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AdminColors.error,
          ),
        );
      }
    }
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
    return Container(
      color: AdminColors.bg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top Bar ───────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
            decoration: const BoxDecoration(
              color: AdminColors.sidebar,
              border: Border(
                bottom: BorderSide(color: AdminColors.border, width: 1),
              ),
            ),
            child: Row(
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Registration Management',
                      style: TextStyle(
                        color: AdminColors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    Text(
                      'Review and approve event registrations',
                      style: TextStyle(
                        color: AdminColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                // Filter Dropdown
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AdminColors.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AdminColors.border),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _filterStatus,
                      dropdownColor: AdminColors.surfaceLight,
                      icon: const Icon(Icons.arrow_drop_down, color: AdminColors.textSecondary),
                      style: const TextStyle(color: AdminColors.textPrimary, fontSize: 14),
                      items: const [
                        DropdownMenuItem(value: 'all', child: Text('All Statuses')),
                        DropdownMenuItem(value: 'pending', child: Text('Pending')),
                        DropdownMenuItem(value: 'approved', child: Text('Approved')),
                        DropdownMenuItem(value: 'rejected', child: Text('Rejected')),
                        DropdownMenuItem(value: 'waitlisted', child: Text('Waitlisted')),
                      ],
                      onChanged: (v) {
                        setState(() => _filterStatus = v!);
                        _fetchRegistrations();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Table ─────────────────────────────────────────────────
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AdminColors.accent))
                : _registrations.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: const BoxDecoration(
                                color: AdminColors.surfaceLight,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.inbox_rounded, size: 48, color: AdminColors.textSecondary),
                            ),
                            const SizedBox(height: 16),
                            const Text('No registrations found', style: TextStyle(color: AdminColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
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
                                headingRowColor: WidgetStateProperty.all(AdminColors.surfaceLight),
                                dataRowColor: WidgetStateProperty.resolveWith((states) {
                                  if (states.contains(WidgetState.hovered)) {
                                    return AdminColors.accent.withOpacity(0.05);
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
                                  DataColumn(label: Text('Student')),
                                  DataColumn(label: Text('Event')),
                                  DataColumn(label: Text('Reg. Number')),
                                  DataColumn(label: Text('Date')),
                                  DataColumn(label: Text('Status')),
                                  DataColumn(label: Text('Actions')),
                                ],
                                rows: _registrations.map((reg) {
                                  final student = reg['student_profiles'] as Map<String, dynamic>?;
                                  final event = reg['events'] as Map<String, dynamic>?;
                                  final status = reg['status'] ?? 'pending';

                                  return DataRow(cells: [
                                    DataCell(Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(student?['name'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.w600)),
                                        if (student?['enrollment_number'] != null && student!['enrollment_number'].toString().isNotEmpty)
                                          Text('PRN: ${student['enrollment_number']}', style: const TextStyle(fontSize: 12, color: AdminColors.textSecondary)),
                                        if (student?['roll_number'] != null && student!['roll_number'].toString().isNotEmpty)
                                          Text('Roll: ${student['roll_number']}', style: const TextStyle(fontSize: 12, color: AdminColors.textSecondary)),
                                        if (student?['division'] != null && student!['division'].toString().isNotEmpty)
                                          Text('Div: ${student['division']}', style: const TextStyle(fontSize: 12, color: AdminColors.textSecondary)),
                                      ],
                                    )),
                                    DataCell(Text(event?['title'] ?? 'Unknown', overflow: TextOverflow.ellipsis)),
                                    DataCell(Text(reg['registration_number'] ?? 'N/A')),
                                    DataCell(Text(DateTime.parse(reg['created_at']).toLocal().toString().split(' ')[0])),
                                    DataCell(
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: _statusColor(status).withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          status.toUpperCase(),
                                          style: TextStyle(
                                            color: _statusColor(status),
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                    DataCell(Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (status != 'approved')
                                          _ActionBtn(
                                            icon: Icons.check_circle_rounded,
                                            label: 'Approve',
                                            color: AdminColors.success,
                                            onTap: () => _updateStatus(reg['id'], 'approved'),
                                          ),
                                        if (status != 'approved' && status != 'rejected')
                                          const SizedBox(width: 8),
                                        if (status != 'rejected')
                                          _ActionBtn(
                                            icon: Icons.cancel_rounded,
                                            label: 'Reject',
                                            color: AdminColors.error,
                                            onTap: () => _updateStatus(reg['id'], 'rejected'),
                                          ),
                                      ],
                                    )),
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
