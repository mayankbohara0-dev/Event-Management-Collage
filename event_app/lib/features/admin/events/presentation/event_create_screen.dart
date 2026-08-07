import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../dashboard/presentation/dashboard_layout.dart';

class AdminColors {
  static const Color bg = Color(0xFF0F0F1A);
  static const Color sidebar = Color(0xFF14142B);
  static const Color surface = Color(0xFF1A1A2E);
  static const Color surfaceLight = Color(0xFF242440);
  static const Color accent = Color(0xFF7C3AED);
  static const Color gold = Color(0xFFFFB800);
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color textPrimary = Color(0xFFF1F1F8);
  static const Color textSecondary = Color(0xFF8B8BA8);
  static const Color border = Color(0xFF2A2A4A);

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF1A1A2E), Color(0xFF7C3AED)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class EventCreateScreen extends ConsumerStatefulWidget {
  const EventCreateScreen({super.key});

  @override
  ConsumerState<EventCreateScreen> createState() => _EventCreateScreenState();
}

class _EventCreateScreenState extends ConsumerState<EventCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _shortDescController = TextEditingController();
  final _longDescController = TextEditingController();
  final _venueController = TextEditingController();
  final _maxSeatsController = TextEditingController();
  final _coordinatorController = TextEditingController();
  final _contactController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  String _visibility = 'draft';
  bool _isLoading = false;

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AdminColors.accent,
              onPrimary: Colors.white,
              surface: AdminColors.surface,
              onSurface: AdminColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStart) _startDate = picked;
        else _endDate = picked;
      });
    }
  }

  Future<void> _saveEvent() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select start and end dates'), backgroundColor: AdminColors.error),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      final response = await Supabase.instance.client
          .from('events')
          .insert({
            'title': _titleController.text.trim(),
            'short_description': _shortDescController.text.trim(),
            'long_description': _longDescController.text.trim(),
            'venue': _venueController.text.trim(),
            'max_seats': int.tryParse(_maxSeatsController.text) ?? 100,
            'coordinator': _coordinatorController.text.trim(),
            'contact_number': _contactController.text.trim(),
            'start_date': _startDate!.toIso8601String(),
            'end_date': _endDate!.toIso8601String(),
            'visibility': _visibility,
            'created_by': user?.id,
          })
          .select('id')
          .single();

      final eventId = response['id'];

      // Also create a blank registration form for this event
      await Supabase.instance.client
          .from('registration_forms')
          .insert({'event_id': eventId});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event created! Now build the registration form.'), backgroundColor: AdminColors.success),
        );
        context.go('/admin/events/$eventId/builder');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AdminColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminColors.bg,
      appBar: AppBar(
        title: const Text('Create New Event', style: TextStyle(fontWeight: FontWeight.bold, color: AdminColors.textPrimary)),
        backgroundColor: AdminColors.sidebar,
        elevation: 1,
        iconTheme: const IconThemeData(color: AdminColors.textPrimary),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/admin/events'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCard(
                    title: 'Basic Details',
                    children: [
                      _buildTextField(_titleController, 'Event Title *', Icons.title),
                      const SizedBox(height: 16),
                      _buildTextField(_shortDescController, 'Short Description *', Icons.short_text, maxLines: 2),
                      const SizedBox(height: 16),
                      _buildTextField(_longDescController, 'Full Description', Icons.notes, maxLines: 4, required: false),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDateBtn('Start Date *', _startDate, true),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDateBtn('End Date *', _endDate, false),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildCard(
                    title: 'Logistics',
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(_venueController, 'Venue', Icons.location_on, required: false),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(_maxSeatsController, 'Max Seats', Icons.people, isNumber: true, required: false),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(_coordinatorController, 'Coordinator', Icons.person, required: false),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(_contactController, 'Contact Number', Icons.phone, required: false),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _visibility,
                        decoration: _inputDeco('Visibility', Icons.visibility),
                        dropdownColor: AdminColors.surfaceLight,
                        style: const TextStyle(color: AdminColors.textPrimary, fontSize: 14),
                        items: const [
                          DropdownMenuItem(value: 'draft', child: Text('Draft (Hidden)')),
                          DropdownMenuItem(value: 'published', child: Text('Published (Visible)')),
                        ],
                        onChanged: (v) => setState(() => _visibility = v!),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _saveEvent,
                      icon: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.arrow_forward),
                      label: const Text('Save & Build Registration Form', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AdminColors.accent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard({required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AdminColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AdminColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: AdminColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {int maxLines = 1, bool isNumber = false, bool required = true}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: AdminColors.textPrimary, fontSize: 14),
      decoration: _inputDeco(label, icon),
      validator: required ? (v) => v!.isEmpty ? 'Required' : null : null,
    );
  }

  InputDecoration _inputDeco(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AdminColors.textSecondary, fontSize: 14),
      prefixIcon: Icon(icon, color: AdminColors.textSecondary, size: 20),
      filled: true,
      fillColor: AdminColors.surfaceLight,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AdminColors.border)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AdminColors.border)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AdminColors.accent, width: 1.5)),
    );
  }

  Widget _buildDateBtn(String label, DateTime? date, bool isStart) {
    return OutlinedButton.icon(
      icon: Icon(Icons.calendar_today, color: AdminColors.textSecondary, size: 20),
      label: Text(
        date == null ? label : '${isStart ? 'Start:' : 'End:'} ${date.toLocal().toString().split(' ')[0]}',
        style: TextStyle(color: date == null ? AdminColors.textSecondary : AdminColors.textPrimary),
      ),
      onPressed: () => _pickDate(isStart),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        side: const BorderSide(color: AdminColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        alignment: Alignment.centerLeft,
        backgroundColor: AdminColors.surfaceLight,
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _shortDescController.dispose();
    _longDescController.dispose();
    _venueController.dispose();
    _maxSeatsController.dispose();
    _coordinatorController.dispose();
    _contactController.dispose();
    super.dispose();
  }
}
