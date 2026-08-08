import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../dashboard/presentation/dashboard_layout.dart';

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

class EventCreateScreen extends ConsumerStatefulWidget {
  final String? eventId;
  const EventCreateScreen({super.key, this.eventId});

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

  final _eligibilityController = TextEditingController();
  
  String? _categoryId;
  List<Map<String, dynamic>> _categories = [];

  DateTime? _startDate;
  DateTime? _endDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  
  String _visibility = 'draft';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCategories().then((_) {
      if (widget.eventId != null) {
        _fetchEvent();
      }
    });
  }

  Future<void> _fetchEvent() async {
    try {
      final res = await Supabase.instance.client
          .from('events')
          .select()
          .eq('id', widget.eventId!)
          .maybeSingle();

      if (res != null && mounted) {
        setState(() {
          _titleController.text = res['title'] ?? '';
          _shortDescController.text = res['short_description'] ?? '';
          _longDescController.text = res['long_description'] ?? '';
          _venueController.text = res['venue'] ?? '';
          _maxSeatsController.text = (res['max_seats'] ?? '').toString();
          _coordinatorController.text = res['coordinator'] ?? '';
          _contactController.text = res['contact_email'] ?? '';
          _eligibilityController.text = res['eligibility'] ?? '';
          _categoryId = res['category_id'];
          _visibility = res['visibility'] ?? 'draft';

          if (res['start_date'] != null) {
            final start = DateTime.parse(res['start_date']);
            _startDate = start;
            _startTime = TimeOfDay.fromDateTime(start);
          }
          if (res['end_date'] != null) {
            final end = DateTime.parse(res['end_date']);
            _endDate = end;
            _endTime = TimeOfDay.fromDateTime(end);
          }
        });
      }
    } catch (e) {
      debugPrint('Error fetching event for edit: $e');
    }
  }

  Future<void> _fetchCategories() async {
    try {
      final res = await Supabase.instance.client
          .from('event_categories')
          .select('id, name')
          .order('name');
      if (mounted) {
        setState(() {
          _categories = List<Map<String, dynamic>>.from(res);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AdminColors.accent,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      if (mounted) {
        final time = await showTimePicker(
          context: context,
          initialTime: const TimeOfDay(hour: 9, minute: 0),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: AdminColors.accent,
                  onPrimary: Colors.white,
                ),
              ),
              child: child!,
            );
          },
        );
        if (time != null) {
          setState(() {
            if (isStart) {
              _startDate = picked;
              _startTime = time;
            } else {
              _endDate = picked;
              _endTime = time;
            }
          });
        }
      }
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
      final eventData = {
        'title': _titleController.text.trim(),
        'short_description': _shortDescController.text.trim(),
        'long_description': _longDescController.text.trim(),
        'venue': _venueController.text.trim(),
        'max_seats': int.tryParse(_maxSeatsController.text) ?? 100,
        'coordinator': _coordinatorController.text.trim(),
        'contact_email': _contactController.text.trim(),
        'category_id': _categoryId,
        'eligibility': _eligibilityController.text.trim(),
        'start_date': DateTime(
          _startDate!.year, _startDate!.month, _startDate!.day,
          _startTime!.hour, _startTime!.minute,
        ).toUtc().toIso8601String(),
        'end_date': DateTime(
          _endDate!.year, _endDate!.month, _endDate!.day,
          _endTime!.hour, _endTime!.minute,
        ).toUtc().toIso8601String(),
        'visibility': _visibility,
        if (widget.eventId == null) 'created_by': user?.id,
      };

      if (widget.eventId != null) {
        await Supabase.instance.client
            .from('events')
            .update(eventData)
            .eq('id', widget.eventId!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Event updated successfully!'), backgroundColor: AdminColors.success));
          context.pop();
        }
      } else {
        final response = await Supabase.instance.client
            .from('events')
            .insert(eventData)
            .select()
            .single();
            
        // Create registration form
        await Supabase.instance.client
            .from('registration_forms')
            .insert({'event_id': response['id']});
            
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Event created! Now let\'s build the registration form.'), backgroundColor: AdminColors.success));
          context.go('/admin/events/${response['id']}/builder');
        }
      }
    } catch (e) {
      debugPrint('Save error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving event: $e'), backgroundColor: AdminColors.error));
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminColors.bg,
      appBar: AppBar(
        title: Row(
          children: [
            GestureDetector(
              onTap: () => context.pop(),
              child: const Icon(Icons.arrow_back, color: AdminColors.textPrimary),
            ),
            const SizedBox(width: 16),
            Text(
              widget.eventId != null ? 'Edit Event' : 'Create New Event',
              style: const TextStyle(
                color: AdminColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        backgroundColor: AdminColors.sidebar,
        elevation: 1,
        automaticallyImplyLeading: false,
      ),
      body: _isLoading ? const Center(child: CircularProgressIndicator()) : SingleChildScrollView(
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
                      DropdownButtonFormField<String>(
                        value: _categoryId,
                        decoration: _inputDeco('Category', Icons.category),
                        dropdownColor: AdminColors.surfaceLight,
                        items: _categories.map((c) => DropdownMenuItem<String>(
                          value: c['id'],
                          child: Text(c['name']),
                        )).toList(),
                        onChanged: (v) => setState(() => _categoryId = v),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDateBtn('Start Time *', _startDate, _startTime, true),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDateBtn('End Time *', _endDate, _endTime, false),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildCard(
                    title: 'Logistics & Eligibility',
                    children: [
                      _buildTextField(_eligibilityController, 'Eligibility Criteria', Icons.verified_user, required: false),
                      const SizedBox(height: 16),
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

  Widget _buildDateBtn(String label, DateTime? date, TimeOfDay? time, bool isStart) {
    return OutlinedButton.icon(
      icon: Icon(Icons.calendar_today, color: AdminColors.textSecondary, size: 20),
      label: Text(
        date == null ? label : '${date.toLocal().toString().split(' ')[0]} ${time != null ? '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}' : ''}',
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
    _eligibilityController.dispose();
    super.dispose();
  }
}
