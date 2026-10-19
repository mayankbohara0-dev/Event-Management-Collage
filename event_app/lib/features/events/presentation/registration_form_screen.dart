import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/zest_tokens.dart';
import '../../../shared/widgets/shared_widgets.dart';

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
  final Set<String> _autofilledQuestionIds = {};
  final _formKey = GlobalKey<FormState>();
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
    _fetchForm();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _fetchForm() async {
    try {
      // Fetch event info
      final eventRes = await Supabase.instance.client
          .from('events')
          .select('title, short_description, venue, start_date, cover_image_url, event_categories(name)')
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

      var formRes = await Supabase.instance.client
          .from('registration_forms')
          .select('id, max_responses, close_on_limit, form_open_date, form_close_date, auto_approval')
          .eq('event_id', widget.eventId)
          .maybeSingle();

      if (formRes == null) {
        try {
          final inserted = await Supabase.instance.client
              .from('registration_forms')
              .insert({'event_id': widget.eventId, 'auto_approval': true})
              .select('id, max_responses, close_on_limit, form_open_date, form_close_date, auto_approval')
              .single();
          formRes = inserted;
        } catch (_) {}
      }

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
            final qId = q['id'] as String;
            if (title.contains('name') && profile['name'] != null) {
              _answers[qId] = profile['name'];
              _autofilledQuestionIds.add(qId);
            } else if ((title.contains('roll') || title.contains('enrollment')) && profile['roll_number'] != null) {
              _answers[qId] = profile['roll_number'];
              _autofilledQuestionIds.add(qId);
            } else if (title.contains('phone') && profile['phone'] != null) {
              _answers[qId] = profile['phone'];
              _autofilledQuestionIds.add(qId);
            } else if (title.contains('branch') && profile['branch'] != null) {
              _answers[qId] = profile['branch'];
              _autofilledQuestionIds.add(qId);
            } else if (title.contains('semester') && profile['semester'] != null) {
              _answers[qId] = profile['semester'].toString();
              _autofilledQuestionIds.add(qId);
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
    ZestDialog.show(
      context,
      title: 'Registration Unavailable',
      message: message,
      confirmText: 'Go Back',
      cancelText: '',
      mascotMood: ZestMascotMood.sleepy,
    ).then((_) {
      if (mounted) context.pop();
    });
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
        _confettiController.play();
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        ZestSnack.show(
          context,
          message: 'Registration Failed: $e',
          type: ZestSnackType.error,
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
      builder: (ctx) => Stack(
        alignment: Alignment.center,
        children: [
          ZestDialog(
            title: "You're Registered! 🎉",
            message: _autoApproval
                ? 'Your entry pass has been approved. Check your passes to see your verified ticket!'
                : 'Your registration has been submitted. Check your passes tab for status updates!',
            confirmText: 'View My Passes 🎟️',
            mascotMood: ZestMascotMood.celebrate,
            onConfirm: () {
              Navigator.of(ctx).pop();
              if (mounted) context.go('/student/home');
            },
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                ZestTokens.blue,
                ZestTokens.sky,
                ZestTokens.lemon,
                ZestTokens.coral,
                ZestTokens.mint,
              ],
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
    final isAutofilled = _autofilledQuestionIds.contains(id);
    final options =
        List<Map<String, dynamic>>.from(question['question_options'] ?? []);

    Widget inputField;

    switch (type) {
      case 'short_answer':
      case 'number':
        final initVal = _answers[id]?.toString();
        inputField = TextFormField(
          initialValue: initVal,
          keyboardType:
              type == 'number' ? TextInputType.number : TextInputType.text,
          style: ZestTokens.body.copyWith(color: ZestTokens.ink),
          decoration: InputDecoration(
            hintText: placeholder ?? 'Your answer',
            hintStyle: ZestTokens.body.copyWith(color: ZestTokens.ink3),
            filled: true,
            fillColor: ZestTokens.fill,
            border: OutlineInputBorder(
              borderRadius: ZestTokens.borderInput,
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: ZestTokens.borderInput,
              borderSide: const BorderSide(color: ZestTokens.core, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
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
          style: ZestTokens.body.copyWith(color: ZestTokens.ink),
          decoration: InputDecoration(
            hintText: placeholder ?? 'Your answer',
            hintStyle: ZestTokens.body.copyWith(color: ZestTokens.ink3),
            filled: true,
            fillColor: ZestTokens.fill,
            alignLabelWithHint: true,
            border: OutlineInputBorder(
              borderRadius: ZestTokens.borderInput,
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: ZestTokens.borderInput,
              borderSide: const BorderSide(color: ZestTokens.core, width: 1.5),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
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
          style: ZestTokens.body.copyWith(color: ZestTokens.ink),
          decoration: InputDecoration(
            hintText: placeholder ?? 'your@email.com',
            hintStyle: ZestTokens.body.copyWith(color: ZestTokens.ink3),
            prefixIcon: const Icon(LucideIcons.mail, size: 18, color: ZestTokens.ink3),
            filled: true,
            fillColor: ZestTokens.fill,
            border: OutlineInputBorder(
              borderRadius: ZestTokens.borderInput,
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: ZestTokens.borderInput,
              borderSide: const BorderSide(color: ZestTokens.core, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
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
          style: ZestTokens.body.copyWith(color: ZestTokens.ink),
          decoration: InputDecoration(
            hintText: placeholder ?? '+91-XXXXX-XXXXX',
            hintStyle: ZestTokens.body.copyWith(color: ZestTokens.ink3),
            prefixIcon: const Icon(LucideIcons.phone, size: 18, color: ZestTokens.ink3),
            filled: true,
            fillColor: ZestTokens.fill,
            border: OutlineInputBorder(
              borderRadius: ZestTokens.borderInput,
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: ZestTokens.borderInput,
              borderSide: const BorderSide(color: ZestTokens.core, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          onChanged: (val) => _answers[id] = val,
          validator: (val) =>
              isRequired && (val == null || val.isEmpty)
                  ? 'This field is required'
                  : null,
        );
        break;

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
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        decoration: BoxDecoration(
                          color: selected ? const Color(0xFFE8F6FE) : ZestTokens.fill,
                          border: Border.all(
                            color: selected ? ZestTokens.blue : Colors.transparent,
                            width: selected ? 1.5 : 1,
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              opt == 'Yes'
                                  ? LucideIcons.checkCircle2
                                  : LucideIcons.xCircle,
                              color: selected ? ZestTokens.blue : ZestTokens.ink3,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              opt,
                              style: ZestTokens.bodyBold.copyWith(
                                color: selected ? ZestTokens.blue : ZestTokens.ink2,
                                fontSize: 14,
                              ),
                            ),
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
                  child: Text(
                    state.errorText!,
                    style: const TextStyle(
                      color: ZestTokens.danger,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        );
        break;

      case 'dropdown':
        inputField = DropdownButtonFormField<String>(
          initialValue: _answers[id] as String?,
          decoration: InputDecoration(
            hintText: placeholder ?? 'Select an option',
            hintStyle: ZestTokens.body.copyWith(color: ZestTokens.ink3),
            filled: true,
            fillColor: ZestTokens.fill,
            border: OutlineInputBorder(
              borderRadius: ZestTokens.borderInput,
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          isExpanded: true,
          items: options
              .map((o) => DropdownMenuItem(
                  value: o['value'].toString(),
                  child: Text(o['label'] ?? o['value'].toString(),
                      style: ZestTokens.body.copyWith(color: ZestTokens.ink))))
              .toList(),
          onChanged: (val) => setState(() => _answers[id] = val),
          validator: (val) =>
              isRequired && val == null ? 'This field is required' : null,
        );
        break;

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
                          ? const Color(0xFFE8F6FE)
                          : ZestTokens.fill,
                      border: Border.all(
                        color: selected ? ZestTokens.blue : Colors.transparent,
                        width: selected ? 1.5 : 1,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: selected ? ZestTokens.blue : ZestTokens.line,
                              width: 2,
                            ),
                          ),
                          child: selected
                              ? Center(
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: ZestTokens.blue,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            label,
                            style: ZestTokens.body.copyWith(
                              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                              color: selected ? ZestTokens.blue : ZestTokens.ink,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              if (state.hasError)
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 4),
                  child: Text(
                    state.errorText!,
                    style: const TextStyle(
                      color: ZestTokens.danger,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        );
        break;

      case 'checkbox':
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
                          ? const Color(0xFFE8F6FE)
                          : ZestTokens.fill,
                      border: Border.all(
                        color: checked ? ZestTokens.blue : Colors.transparent,
                        width: checked ? 1.5 : 1,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: checked ? ZestTokens.blue : ZestTokens.line,
                              width: 2,
                            ),
                            color: checked ? ZestTokens.blue : Colors.transparent,
                          ),
                          child: checked
                              ? const Icon(LucideIcons.check,
                                  size: 14, color: Colors.white)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            label,
                            style: ZestTokens.body.copyWith(
                              fontWeight: checked ? FontWeight.w600 : FontWeight.w400,
                              color: checked ? ZestTokens.blue : ZestTokens.ink,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              if (state.hasError)
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 4),
                  child: Text(
                    state.errorText!,
                    style: const TextStyle(
                      color: ZestTokens.danger,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        );
        break;

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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: ZestTokens.fill,
                border: Border.all(
                  color: state.hasError ? ZestTokens.danger : Colors.transparent,
                ),
                borderRadius: ZestTokens.borderInput,
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.calendar, size: 18, color: ZestTokens.blue),
                  const SizedBox(width: 10),
                  Text(
                    _answers[id]?.toString() ?? 'Pick a date',
                    style: ZestTokens.body.copyWith(
                      color: _answers[id] != null ? ZestTokens.ink : ZestTokens.ink3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
        break;

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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: ZestTokens.fill,
                border: Border.all(
                  color: state.hasError ? ZestTokens.danger : Colors.transparent,
                ),
                borderRadius: ZestTokens.borderInput,
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.clock, size: 18, color: ZestTokens.blue),
                  const SizedBox(width: 10),
                  Text(
                    _answers[id]?.toString() ?? 'Pick a time',
                    style: ZestTokens.body.copyWith(
                      color: _answers[id] != null ? ZestTokens.ink : ZestTokens.ink3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
        break;

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
                      padding: const EdgeInsets.only(right: 8),
                      child: Icon(
                        starVal <= current
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        color: starVal <= current
                            ? const Color(0xFFF59E0B)
                            : ZestTokens.line,
                        size: 38,
                      ),
                    ),
                  );
                }),
              ),
              if (state.hasError)
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 4),
                  child: Text(
                    state.errorText!,
                    style: const TextStyle(
                      color: ZestTokens.danger,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        );
        break;

      default:
        inputField = TextFormField(
          style: ZestTokens.body.copyWith(color: ZestTokens.ink),
          decoration: InputDecoration(
            hintText: placeholder ?? 'Your answer',
            filled: true,
            fillColor: ZestTokens.fill,
            border: OutlineInputBorder(
              borderRadius: ZestTokens.borderInput,
              borderSide: BorderSide.none,
            ),
          ),
          onChanged: (val) => _answers[id] = val,
          validator: (val) =>
              isRequired && (val == null || val.isEmpty)
                  ? 'This field is required'
                  : null,
        );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ZestCard(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: ZestTokens.bodyBold.copyWith(
                      fontSize: 15,
                    ),
                  ),
                ),
                if (isRequired)
                  const Text(' *',
                      style: TextStyle(
                          color: ZestTokens.danger,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
              ],
            ),
            if (question['description'] != null) ...[
              const SizedBox(height: 4),
              Text(
                question['description'],
                style: ZestTokens.caption.copyWith(
                  color: ZestTokens.ink3,
                ),
              ),
            ],
            if (isAutofilled) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(LucideIcons.sparkles, size: 12, color: ZestTokens.blue),
                  const SizedBox(width: 4),
                  Text(
                    'Autofilled from your profile',
                    style: ZestTokens.caption.copyWith(
                      color: ZestTokens.blue,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 14),
            inputField,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: ZestTokens.page,
        body: const Center(
          child: CircularProgressIndicator(color: ZestTokens.blue),
        ),
      );
    }

    if (_formId == null) {
      return Scaffold(
        backgroundColor: ZestTokens.page,
        appBar: AppBar(
          title: const Text('Registration'),
          backgroundColor: ZestTokens.page,
          foregroundColor: ZestTokens.ink,
          elevation: 0,
        ),
        body: Center(
          child: ZestEmptyState(
            mascotMood: ZestMascotMood.sleepy,
            title: 'No Form Available',
            subtitle: 'No registration form is available for this event.',
            actionLabel: 'Back to Event',
            onAction: () => context.pop(),
          ),
        ),
      );
    }

    final eventTitle = _eventData?['title'] ?? 'Event Registration';
    final categoryName =
        _eventData?['event_categories']?['name']?.toString() ?? 'Event';
    final gradient = ZestTokens.categoryGradient(categoryName);

    return Scaffold(
      backgroundColor: ZestTokens.page,
      appBar: AppBar(
        backgroundColor: ZestTokens.page,
        foregroundColor: ZestTokens.ink,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Registration',
          style: ZestTokens.title.copyWith(fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Event Summary Card ──────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                ZestTokens.horizontalPadding,
                8,
                ZestTokens.horizontalPadding,
                16,
              ),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: ZestTokens.borderHero,
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1F0063F0),
                      blurRadius: 18,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.22),
                        borderRadius: ZestTokens.borderPill,
                      ),
                      child: Text(
                        'REGISTERING FOR',
                        style: ZestTokens.labelCaps.copyWith(
                          color: Colors.white,
                          fontSize: 10,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      eventTitle,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Form Sections ───────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: ZestTokens.horizontalPadding,
            ),
            sliver: SliverToBoxAdapter(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var section in _sections) ...[
                      // Section Header
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12, top: 8),
                        child: ZestSectionHeader(
                          title: section['title'] ?? 'Section',
                          accentWord: '',
                        ),
                      ),
                      for (var question in section['form_questions'])
                        _buildQuestionWidget(question),
                      const SizedBox(height: 6),
                    ],

                    const SizedBox(height: 16),

                    // Submit Button
                    ZestButton(
                      text: 'Submit Registration',
                      variant: ZestButtonVariant.primary,
                      prefixIcon: LucideIcons.send,
                      isLoading: _isSubmitting,
                      fullWidth: true,
                      onPressed: _isSubmitting ? null : _submitRegistration,
                    ),
                    const SizedBox(height: 48),
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
