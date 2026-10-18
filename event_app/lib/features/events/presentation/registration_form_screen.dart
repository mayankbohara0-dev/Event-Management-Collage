import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../core/design_system.dart';

class RegistrationFormScreen extends ConsumerStatefulWidget {
  final String eventId;
  const RegistrationFormScreen({super.key, required this.eventId});

  @override
  ConsumerState<RegistrationFormScreen> createState() =>
      _RegistrationFormScreenState();
}

class _RegistrationFormScreenState
    extends ConsumerState<RegistrationFormScreen> {
  bool _isLoading = true;
  bool _isSubmitting = false;
  bool _autoApproval = false;
  String? _formId;
  List<dynamic> _sections = [];
  Map<String, dynamic>? _eventData;
  final Map<String, dynamic> _answers = {};
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _fetchForm();
  }

  Future<void> _fetchForm() async {
    try {
      // Fetch event info
      final eventRes = await Supabase.instance.client
          .from('events')
          .select('title, short_description, venue, start_date, cover_image_url')
          .eq('id', widget.eventId)
          .maybeSingle();
      _eventData = eventRes;

      // Fetch user profile for autofill
      final user = Supabase.instance.client.auth.currentUser;
      Map<String, dynamic>? profile;
      if (user != null) {
        profile = await Supabase.instance.client
            .from('student_profiles')
            .select('*')
            .eq('id', user.id)
            .maybeSingle();
      }

      final formRes = await Supabase.instance.client
          .from('registration_forms')
          .select('id, max_responses, close_on_limit, form_open_date, form_close_date, auto_approval')
          .eq('event_id', widget.eventId)
          .maybeSingle();

      if (formRes == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      _formId = formRes['id'];
      _autoApproval = formRes['auto_approval'] == true;

      // Check schedule
      final now = DateTime.now();
      if (formRes['form_open_date'] != null) {
        final openDate = DateTime.parse(formRes['form_open_date']);
        if (now.isBefore(openDate)) {
          if (mounted) {
            setState(() => _isLoading = false);
            _showClosedDialog(
                'Registration hasn\'t opened yet.\nOpens on: ${openDate.toLocal().toString().split('.')[0]}');
          }
          return;
        }
      }
      if (formRes['form_close_date'] != null) {
        final closeDate = DateTime.parse(formRes['form_close_date']);
        if (now.isAfter(closeDate)) {
          if (mounted) {
            setState(() => _isLoading = false);
            _showClosedDialog(
                'Registration has closed.\nClosed on: ${closeDate.toLocal().toString().split('.')[0]}');
          }
          return;
        }
      }

      // Check capacity
      if (formRes['close_on_limit'] == true &&
          formRes['max_responses'] != null) {
        final countRes = await Supabase.instance.client
            .from('registrations')
            .select('id')
            .eq('event_id', widget.eventId);
        final count = (countRes as List).length;
        if (count >= (formRes['max_responses'] as int)) {
          if (mounted) {
            setState(() => _isLoading = false);
            _showClosedDialog(
                'Registration is full. The maximum of ${formRes['max_responses']} seats has been reached.');
          }
          return;
        }
      }

      // Fetch sections + questions
      final sectionsRes = await Supabase.instance.client
          .from('form_sections')
          .select('''
            id, title, description, order_index,
            form_questions (
              id, question_type, title, description, is_required, order_index,
              question_options (id, value, label, order_index)
            )
          ''')
          .eq('form_id', _formId!)
          .order('order_index', ascending: true);

      for (var section in sectionsRes) {
        final questions =
            List<Map<String, dynamic>>.from(section['form_questions'] ?? []);
        questions.sort((a, b) =>
            (a['order_index'] as int).compareTo(b['order_index'] as int));
        for (var q in questions) {
          final options =
              List<Map<String, dynamic>>.from(q['question_options'] ?? []);
          options.sort((a, b) =>
              (a['order_index'] as int).compareTo(b['order_index'] as int));
          q['question_options'] = options;

          // Auto-fill logic
          if (profile != null) {
            final title = (q['title'] as String).toLowerCase();
            if (title.contains('name') && profile['name'] != null) {
              _answers[q['id']] = profile['name'];
            } else if ((title.contains('roll') || title.contains('enrollment')) && profile['roll_number'] != null) {
              _answers[q['id']] = profile['roll_number'];
            } else if (title.contains('phone') && profile['phone'] != null) {
              _answers[q['id']] = profile['phone'];
            } else if (title.contains('branch') && profile['branch'] != null) {
              _answers[q['id']] = profile['branch'];
            } else if (title.contains('semester') && profile['semester'] != null) {
              _answers[q['id']] = profile['semester'].toString();
            }
          }
        }
        section['form_questions'] = questions;
      }

      if (mounted) {
        setState(() {
          _sections = sectionsRes;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showClosedDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.goldLight,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.lock_clock_rounded,
              color: AppColors.warning, size: 32),
        ),
        title: const Text('Registration Unavailable',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.grey500)),
        actions: [
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                if (mounted) context.pop();
              },
              child: const Text('Go Back'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitRegistration() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('Not logged in');

      final qrData = '${user.id}_${widget.eventId}_${DateTime.now().millisecondsSinceEpoch}';
      final status = _autoApproval ? 'approved' : 'pending';

      final regRes = await Supabase.instance.client
          .from('registrations')
          .insert({
            'event_id': widget.eventId,
            'student_id': user.id,
            'status': status,
            'qr_code_data': status == 'approved' ? qrData : null,
          })
          .select('id')
          .single();

      final registrationId = regRes['id'];

      final answersToInsert = _answers.entries
          .map((e) {
            // Checkbox answers stored as List<String> — join them
            final val = e.value is List
                ? (e.value as List).join(', ')
                : e.value.toString();
            return {
              'registration_id': registrationId,
              'question_id': e.key,
              'answer_value': val,
            };
          })
          .toList();

      if (answersToInsert.isNotEmpty) {
        await Supabase.instance.client
            .from('registration_answers')
            .insert(answersToInsert);
      }

      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration Failed: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
              color: AppColors.successLight, shape: BoxShape.circle),
          child: const Icon(Icons.check_circle_rounded,
              color: AppColors.success, size: 36),
        ),
        title: const Text('You\'re Registered!',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text(
          'Your registration has been submitted. Check your tickets in the app!',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.grey500),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.success,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
                if (mounted) context.go('/student/home');
              },
              child: const Text('View My Tickets'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionWidget(Map<String, dynamic> question) {
    final type = question['question_type'] as String;
    final id = question['id'] as String;
    final isRequired = question['is_required'] == true;
    final title = question['title'] as String;
    final placeholder = question['placeholder'] as String?;
    final options =
        List<Map<String, dynamic>>.from(question['question_options'] ?? []);

    Widget inputField;

    switch (type) {
      // ── TEXT FIELDS ──────────────────────────────────────────────────
      case 'short_answer':
      case 'number':
        final initVal = _answers[id]?.toString();
        inputField = TextFormField(
          initialValue: initVal,
          keyboardType:
              type == 'number' ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(hintText: placeholder ?? 'Your answer'),
          onChanged: (val) => _answers[id] = val,
          validator: (val) =>
              isRequired && (val == null || val.isEmpty)
                  ? 'This field is required'
                  : null,
        );
        break;

      case 'paragraph':
        final initVal = _answers[id]?.toString();
        inputField = TextFormField(
          initialValue: initVal,
          maxLines: 4,
          decoration: InputDecoration(
              hintText: placeholder ?? 'Your answer',
              alignLabelWithHint: true),
          onChanged: (val) => _answers[id] = val,
          validator: (val) =>
              isRequired && (val == null || val.isEmpty)
                  ? 'This field is required'
                  : null,
        );
        break;

      case 'email':
        final initVal = _answers[id]?.toString();
        inputField = TextFormField(
          initialValue: initVal,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
              hintText: placeholder ?? 'your@email.com',
              prefixIcon: const Icon(Icons.email_outlined, size: 18)),
          onChanged: (val) => _answers[id] = val,
          validator: (val) {
            if (isRequired && (val == null || val.isEmpty)) {
              return 'This field is required';
            }
            if (val != null && val.isNotEmpty && !val.contains('@')) {
              return 'Please enter a valid email';
            }
            return null;
          },
        );
        break;

      case 'phone':
        final initVal = _answers[id]?.toString();
        inputField = TextFormField(
          initialValue: initVal,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
              hintText: placeholder ?? '+91-XXXXX-XXXXX',
              prefixIcon: const Icon(Icons.phone_outlined, size: 18)),
          onChanged: (val) => _answers[id] = val,
          validator: (val) =>
              isRequired && (val == null || val.isEmpty)
                  ? 'This field is required'
                  : null,
        );
        break;

      // ── YES/NO ────────────────────────────────────────────────────────
      case 'yes_no':
        inputField = FormField<String>(
          initialValue: _answers[id] as String?,
          validator: (val) =>
              isRequired && val == null ? 'This field is required' : null,
          builder: (state) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: ['Yes', 'No'].map((opt) {
                  final selected = _answers[id] == opt;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() {
                        _answers[id] = opt;
                        state.didChange(opt);
                      }),
                      child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.accent.withValues(alpha: 0.12)
                              : AppColors.grey100.withValues(alpha: 0.5),
                          border: Border.all(
                            color: selected
                                ? AppColors.accent
                                : AppColors.grey200,
                            width: selected ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              opt == 'Yes'
                                  ? Icons.check_circle_rounded
                                  : Icons.cancel_rounded,
                              color: selected
                                  ? AppColors.accent
                                  : AppColors.grey400,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(opt,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: selected
                                      ? AppColors.accent
                                      : AppColors.grey600,
                                )),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              if (state.hasError)
                Padding(
                  padding: const EdgeInsets.only(top: 6, left: 4),
                  child: Text(state.errorText!,
                      style: const TextStyle(
                          color: AppColors.error, fontSize: 12)),
                ),
            ],
          ),
        );
        break;

      // ── DROPDOWN ─────────────────────────────────────────────────────
      case 'dropdown':
        inputField = DropdownButtonFormField<String>(
          initialValue: _answers[id] as String?,
          decoration: InputDecoration(
              hintText: placeholder ?? 'Select an option'),
          isExpanded: true,
          items: options
              .map((o) => DropdownMenuItem(
                  value: o['value'].toString(),
                  child: Text(o['label'] ?? o['value'].toString())))
              .toList(),
          onChanged: (val) => setState(() => _answers[id] = val),
          validator: (val) =>
              isRequired && val == null ? 'This field is required' : null,
        );
        break;

      // ── RADIO (single choice) ─────────────────────────────────────────
      case 'radio':
        inputField = FormField<String>(
          initialValue: _answers[id] as String?,
          validator: (val) =>
              isRequired && (val == null || val.isEmpty)
                  ? 'Please select an option'
                  : null,
          builder: (state) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...options.map((o) {
                final val = o['value'].toString();
                final label = (o['label'] ?? val).toString();
                final selected = _answers[id] == val;
                return GestureDetector(
                  onTap: () => setState(() {
                    _answers[id] = val;
                    state.didChange(val);
                  }),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 13),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.accent.withValues(alpha: 0.08)
                          : Colors.transparent,
                      border: Border.all(
                        color: selected
                            ? AppColors.accent
                            : AppColors.grey200,
                        width: selected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: selected
                                  ? AppColors.accent
                                  : AppColors.grey300,
                              width: 2,
                            ),
                          ),
                          child: selected
                              ? Center(
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.accent,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(label,
                              style: TextStyle(
                                fontWeight: selected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                color: selected
                                    ? AppColors.accent
                                    : AppColors.grey800,
                              )),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              if (state.hasError)
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 4),
                  child: Text(state.errorText!,
                      style: const TextStyle(
                          color: AppColors.error, fontSize: 12)),
                ),
            ],
          ),
        );
        break;

      // ── CHECKBOX (multi-select) ───────────────────────────────────────
      case 'checkbox':
        // Store as comma-separated list in _answers
        if (_answers[id] == null) _answers[id] = <String>[];
        inputField = FormField<List<String>>(
          initialValue: (_answers[id] as List<String>),
          validator: (val) =>
              isRequired && (val == null || val.isEmpty)
                  ? 'Please select at least one option'
                  : null,
          builder: (state) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...options.map((o) {
                final val = o['value'].toString();
                final label = (o['label'] ?? val).toString();
                final currentList =
                    List<String>.from(_answers[id] as List<String>? ?? []);
                final checked = currentList.contains(val);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      final list =
                          List<String>.from(_answers[id] as List<String>? ?? []);
                      if (checked) {
                        list.remove(val);
                      } else {
                        list.add(val);
                      }
                      _answers[id] = list;
                      state.didChange(list);
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 13),
                    decoration: BoxDecoration(
                      color: checked
                          ? AppColors.accent.withValues(alpha: 0.08)
                          : Colors.transparent,
                      border: Border.all(
                        color: checked
                            ? AppColors.accent
                            : AppColors.grey200,
                        width: checked ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              color: checked
                                  ? AppColors.accent
                                  : AppColors.grey300,
                              width: 2,
                            ),
                            color: checked
                                ? AppColors.accent
                                : Colors.transparent,
                          ),
                          child: checked
                              ? const Icon(Icons.check_rounded,
                                  size: 14, color: Colors.white)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(label,
                              style: TextStyle(
                                fontWeight: checked
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                color: checked
                                    ? AppColors.accent
                                    : AppColors.grey800,
                              )),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              if (state.hasError)
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 4),
                  child: Text(state.errorText!,
                      style: const TextStyle(
                          color: AppColors.error, fontSize: 12)),
                ),
            ],
          ),
        );
        break;

      // ── DATE PICKER ──────────────────────────────────────────────────
      case 'date':
        inputField = FormField<String>(
          initialValue: _answers[id] as String?,
          validator: (val) =>
              isRequired && (val == null || val.isEmpty)
                  ? 'Please pick a date'
                  : null,
          builder: (state) => GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (picked != null) {
                final formatted =
                    '${picked.day}/${picked.month}/${picked.year}';
                setState(() {
                  _answers[id] = formatted;
                  state.didChange(formatted);
                });
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(
                    color: state.hasError
                        ? AppColors.error
                        : AppColors.grey200),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_rounded,
                      size: 18, color: AppColors.accent),
                  const SizedBox(width: 10),
                  Text(
                    _answers[id]?.toString() ?? 'Pick a date',
                    style: TextStyle(
                        color: _answers[id] != null
                            ? AppColors.grey900
                            : AppColors.grey400),
                  ),
                ],
              ),
            ),
          ),
        );
        break;

      // ── TIME PICKER ──────────────────────────────────────────────────
      case 'time':
        inputField = FormField<String>(
          initialValue: _answers[id] as String?,
          validator: (val) =>
              isRequired && (val == null || val.isEmpty)
                  ? 'Please pick a time'
                  : null,
          builder: (state) => GestureDetector(
            onTap: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );
              if (picked != null && mounted) {
                final formatted = picked.format(context);
                setState(() {
                  _answers[id] = formatted;
                  state.didChange(formatted);
                });
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(
                    color: state.hasError
                        ? AppColors.error
                        : AppColors.grey200),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.access_time_rounded,
                      size: 18, color: AppColors.accent),
                  const SizedBox(width: 10),
                  Text(
                    _answers[id]?.toString() ?? 'Pick a time',
                    style: TextStyle(
                        color: _answers[id] != null
                            ? AppColors.grey900
                            : AppColors.grey400),
                  ),
                ],
              ),
            ),
          ),
        );
        break;

      // ── RATING (1-5 stars) ───────────────────────────────────────────
      case 'rating':
        if (_answers[id] == null) _answers[id] = 0;
        inputField = FormField<int>(
          initialValue: (_answers[id] as int?) ?? 0,
          validator: (val) =>
              isRequired && (val == null || val == 0)
                  ? 'Please provide a rating'
                  : null,
          builder: (state) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: List.generate(5, (i) {
                  final starVal = i + 1;
                  final current = (_answers[id] as int?) ?? 0;
                  return GestureDetector(
                    onTap: () => setState(() {
                      _answers[id] = starVal;
                      state.didChange(starVal);
                    }),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Icon(
                        starVal <= current
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        color: starVal <= current
                            ? AppColors.gold
                            : AppColors.grey300,
                        size: 36,
                      ),
                    ),
                  );
                }),
              ),
              if (state.hasError)
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 4),
                  child: Text(state.errorText!,
                      style: const TextStyle(
                          color: AppColors.error, fontSize: 12)),
                ),
            ],
          ),
        );
        break;

      default:
        // Graceful fallback for any unsupported type — treat as text
        inputField = TextFormField(
          decoration: InputDecoration(
              hintText: placeholder ?? 'Your answer',
              helperText: 'Field type: $type'),
          onChanged: (val) => _answers[id] = val,
          validator: (val) =>
              isRequired && (val == null || val.isEmpty)
                  ? 'This field is required'
                  : null,
        );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: AppColors.grey900,
                  ),
                ),
              ),
              if (isRequired)
                const Text(' *',
                    style: TextStyle(
                        color: AppColors.error,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
            ],
          ),
          if (question['description'] != null) ...[
            const SizedBox(height: 4),
            Text(
              question['description'],
              style: const TextStyle(
                  color: AppColors.grey500, fontSize: 13, height: 1.4),
            ),
          ],
          const SizedBox(height: 14),
          inputField,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(
            child: CircularProgressIndicator(color: AppColors.accent)),
      );
    }

    if (_formId == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Registration'),
          backgroundColor: AppColors.background,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                    color: AppColors.goldLight, shape: BoxShape.circle),
                child: const Icon(Icons.info_outline_rounded,
                    size: 40, color: AppColors.warning),
              ),
              const SizedBox(height: 16),
              const Text('No Form Available',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.grey900)),
              const SizedBox(height: 8),
              const Text('No registration form is available for this event.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.grey500)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── Event Header ────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: _eventData != null ? 200 : 80,
            pinned: true,
            backgroundColor: AppColors.primary,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white),
              onPressed: () => context.pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: AppColors.heroGradient,
                  image: _eventData?['cover_image_url'] != null
                      ? DecorationImage(
                          image: NetworkImage(
                              _eventData!['cover_image_url']),
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(
                              AppColors.primary.withValues(alpha: 0.6),
                              BlendMode.darken),
                        )
                      : null,
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text('REGISTRATION FORM',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1)),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _eventData?['title'] ?? 'Event Registration',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Form Sections ───────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var section in _sections) ...[
                      // Section header
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: AppColors.cardGradient1,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.list_alt_rounded,
                                color: Colors.white, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    section['title'] ?? 'Section',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                    ),
                                  ),
                                  if (section['description'] != null)
                                    Text(
                                      section['description'],
                                      style: TextStyle(
                                          color: Colors.white
                                              .withValues(alpha: 0.75),
                                          fontSize: 12),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Questions
                      for (var question in section['form_questions'])
                        _buildQuestionWidget(question),
                      const SizedBox(height: 8),
                    ],

                    // Submit Button
                    SizedBox(
                      height: 56,
                      child: FilledButton.icon(
                        onPressed: _isSubmitting ? null : _submitRegistration,
                        icon: _isSubmitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.send_rounded),
                        label: Text(
                          _isSubmitting ? 'Submitting...' : 'Submit Registration',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
