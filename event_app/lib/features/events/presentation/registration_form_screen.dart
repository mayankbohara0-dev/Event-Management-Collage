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

      final formRes = await Supabase.instance.client
          .from('registration_forms')
          .select('id, max_responses, close_on_limit, form_open_date, form_close_date')
          .eq('event_id', widget.eventId)
          .maybeSingle();

      if (formRes == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      _formId = formRes['id'];

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

      final regRes = await Supabase.instance.client
          .from('registrations')
          .insert({
            'event_id': widget.eventId,
            'student_id': user.id,
            'status': 'pending',
          })
          .select('id')
          .single();

      final registrationId = regRes['id'];

      final answersToInsert = _answers.entries
          .map((e) => {
                'registration_id': registrationId,
                'question_id': e.key,
                'answer_value': e.value.toString(),
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
    final options =
        List<Map<String, dynamic>>.from(question['question_options'] ?? []);

    Widget inputField;

    switch (type) {
      case 'short_answer':
      case 'number':
        inputField = TextFormField(
          keyboardType:
              type == 'number' ? TextInputType.number : TextInputType.text,
          decoration: const InputDecoration(hintText: 'Your answer'),
          onChanged: (val) => _answers[id] = val,
          validator: (val) =>
              isRequired && (val == null || val.isEmpty)
                  ? 'This field is required'
                  : null,
        );
        break;
      case 'paragraph':
        inputField = TextFormField(
          maxLines: 4,
          decoration: const InputDecoration(
              hintText: 'Your answer', alignLabelWithHint: true),
          onChanged: (val) => _answers[id] = val,
          validator: (val) =>
              isRequired && (val == null || val.isEmpty)
                  ? 'This field is required'
                  : null,
        );
        break;
      case 'yes_no':
        inputField = DropdownButtonFormField<String>(
          decoration: const InputDecoration(hintText: 'Select option'),
          items: const [
            DropdownMenuItem(value: 'Yes', child: Text('Yes')),
            DropdownMenuItem(value: 'No', child: Text('No')),
          ],
          onChanged: (val) => _answers[id] = val,
          validator: (val) =>
              isRequired && val == null ? 'This field is required' : null,
        );
        break;
      case 'dropdown':
        inputField = DropdownButtonFormField<String>(
          decoration: const InputDecoration(hintText: 'Select option'),
          items: options
              .map((o) => DropdownMenuItem(
                  value: o['value'].toString(),
                  child: Text(o['label'] ?? o['value'].toString())))
              .toList(),
          onChanged: (val) => _answers[id] = val,
          validator: (val) =>
              isRequired && val == null ? 'This field is required' : null,
        );
        break;
      default:
        inputField = Text('Unsupported type: $type',
            style: const TextStyle(color: AppColors.error));
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
            color: Colors.black.withOpacity(0.03),
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
                              AppColors.primary.withOpacity(0.6),
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
                          color: AppColors.accent.withOpacity(0.85),
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
                                              .withOpacity(0.75),
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
