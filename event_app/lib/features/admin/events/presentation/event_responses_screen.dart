import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

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

class EventResponsesScreen extends ConsumerStatefulWidget {
  final String eventId;
  const EventResponsesScreen({super.key, required this.eventId});

  @override
  ConsumerState<EventResponsesScreen> createState() => _EventResponsesScreenState();
}

class _EventResponsesScreenState extends ConsumerState<EventResponsesScreen> {
  bool _isLoading = true;
  String _eventTitle = '';

  List<Map<String, dynamic>> _questions = [];
  List<Map<String, dynamic>> _registrations = [];
  Map<String, Map<String, String>> _answers = {};

  @override
  void initState() {
    super.initState();
    _loadResponses();
  }

  Future<void> _loadResponses() async {
    setState(() => _isLoading = true);
    try {
      final event = await Supabase.instance.client
          .from('events')
          .select('title')
          .eq('id', widget.eventId)
          .single();
      _eventTitle = event['title'];

      final formRes = await Supabase.instance.client
          .from('registration_forms')
          .select('id, form_sections(form_questions(id, title, order_index))')
          .eq('event_id', widget.eventId)
          .maybeSingle();

      if (formRes != null) {
        final List<dynamic> sections = formRes['form_sections'] ?? [];
        final List<Map<String, dynamic>> allQuestions = [];
        for (final section in sections) {
          final qs = (section['form_questions'] as List?) ?? [];
          allQuestions.addAll(List<Map<String, dynamic>>.from(qs));
        }
        allQuestions.sort((a, b) => (a['order_index'] ?? 0).compareTo(b['order_index'] ?? 0));
        _questions = allQuestions;
      }

      final regsRes = await Supabase.instance.client
          .from('registrations')
          .select('id, status, registration_number, created_at, student_profiles(name, roll_number, enrollment_number)')
          .eq('event_id', widget.eventId)
          .order('created_at', ascending: true);

      _registrations = List<Map<String, dynamic>>.from(regsRes);

      if (_registrations.isNotEmpty) {
        final regIds = _registrations.map((r) => r['id']).toList();
        final answersRes = await Supabase.instance.client
            .from('registration_answers')
            .select('registration_id, question_id, answer_value')
            .inFilter('registration_id', regIds);

        final Map<String, Map<String, String>> answerMap = {};
        for (final a in answersRes) {
          final regId = a['registration_id'];
          final qId = a['question_id'];
          final val = a['answer_value'] ?? '';
          answerMap[regId] ??= {};
          answerMap[regId]![qId] = val;
        }
        _answers = answerMap;
      }

      setState(() => _isLoading = false);
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading responses: $e'), backgroundColor: AdminColors.error),
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

  Future<void> _updateStatus(String registrationId, String newStatus) async {
    try {
      await Supabase.instance.client
          .from('registrations')
          .update({'status': newStatus})
          .eq('id', registrationId);
      _loadResponses();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Status updated to $newStatus'), backgroundColor: AdminColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AdminColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminColors.bg,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Event Responses', style: TextStyle(fontWeight: FontWeight.bold, color: AdminColors.textPrimary)),
            Text(_eventTitle, style: const TextStyle(fontSize: 12, color: AdminColors.textSecondary)),
          ],
        ),
        backgroundColor: AdminColors.sidebar,
        elevation: 1,
        iconTheme: const IconThemeData(color: AdminColors.textPrimary),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/admin/events'),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 24, top: 10, bottom: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AdminColors.surfaceLight,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AdminColors.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.people_rounded, size: 16, color: AdminColors.accent),
                  const SizedBox(width: 8),
                  Text(
                    '${_registrations.length} Response${_registrations.length == 1 ? '' : 's'}',
                    style: const TextStyle(color: AdminColors.textPrimary, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AdminColors.accent))
          : _registrations.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: const BoxDecoration(color: AdminColors.surfaceLight, shape: BoxShape.circle),
                        child: const Icon(Icons.inbox_rounded, size: 48, color: AdminColors.textSecondary),
                      ),
                      const SizedBox(height: 16),
                      Text('No responses yet for "$_eventTitle"', style: const TextStyle(fontSize: 18, color: AdminColors.textPrimary, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      const Text('Responses will appear here once students register.', style: TextStyle(color: AdminColors.textSecondary)),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(24),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AdminColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AdminColors.border),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: DataTable(
                            headingRowColor: WidgetStateProperty.all(AdminColors.surfaceLight),
                            dataRowColor: WidgetStateProperty.resolveWith((states) {
                              if (states.contains(WidgetState.hovered)) return AdminColors.accent.withOpacity(0.05);
                              return Colors.transparent;
                            }),
                            dividerThickness: 1,
                            columnSpacing: 24,
                            headingTextStyle: const TextStyle(color: AdminColors.textSecondary, fontWeight: FontWeight.w600, fontSize: 13),
                            dataTextStyle: const TextStyle(color: AdminColors.textPrimary, fontSize: 13),
                            columns: [
                              const DataColumn(label: Text('#')),
                              const DataColumn(label: Text('Student Name')),
                              const DataColumn(label: Text('Roll Number')),
                              const DataColumn(label: Text('Submitted')),
                              const DataColumn(label: Text('Status')),
                              ..._questions.map((q) => DataColumn(
                                label: ConstrainedBox(
                                  constraints: const BoxConstraints(maxWidth: 180),
                                  child: Text(q['title'] ?? '', overflow: TextOverflow.ellipsis),
                                ),
                              )),
                              const DataColumn(label: Text('Actions')),
                            ],
                            rows: _registrations.asMap().entries.map((entry) {
                              final index = entry.key;
                              final reg = entry.value;
                              final student = reg['student_profiles'] as Map<String, dynamic>?;
                              final regAnswers = _answers[reg['id']] ?? {};
                              final status = reg['status'] ?? 'pending';

                              return DataRow(
                                cells: [
                                  DataCell(Text('${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold, color: AdminColors.textSecondary))),
                                  DataCell(Text(student?['name'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.w600))),
                                  DataCell(Text(student?['roll_number'] ?? student?['enrollment_number'] ?? 'N/A')),
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
                                        style: TextStyle(color: _statusColor(status), fontSize: 11, fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                  ),
                                  ..._questions.map((q) => DataCell(
                                    ConstrainedBox(
                                      constraints: const BoxConstraints(maxWidth: 180),
                                      child: Text(
                                        regAnswers[q['id']] ?? '—',
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(color: regAnswers[q['id']] == null ? AdminColors.textSecondary : AdminColors.textPrimary),
                                      ),
                                    ),
                                  )),
                                  DataCell(
                                    Row(
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
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
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
