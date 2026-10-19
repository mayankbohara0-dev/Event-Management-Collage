import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../admin_colors.dart';


// ---------- Data Model ----------
class FormQuestionDraft {
  final String uid; // local unique id
  String title;
  String description;
  String type;
  bool isRequired;
  List<String> options;
  int scaleMin;
  int scaleMax;
  String scaleMinLabel;
  String scaleMaxLabel;
  int? charLimit;

  FormQuestionDraft({
    required this.uid,
    this.title = '',
    this.description = '',
    this.type = 'short_answer',
    this.isRequired = false,
    List<String>? options,
    this.scaleMin = 1,
    this.scaleMax = 5,
    this.scaleMinLabel = '',
    this.scaleMaxLabel = '',
    this.charLimit,
  }) : options = options ?? [];

  FormQuestionDraft copy() => FormQuestionDraft(
        uid: 'copy_${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        description: description,
        type: type,
        isRequired: isRequired,
        options: List.from(options),
        scaleMin: scaleMin,
        scaleMax: scaleMax,
        scaleMinLabel: scaleMinLabel,
        scaleMaxLabel: scaleMaxLabel,
        charLimit: charLimit,
      );
}

// ---------- Question Type Definitions ----------
const List<Map<String, dynamic>> kQuestionTypes = [
  // Text
  {'type': 'short_answer',  'label': 'Short Answer',        'icon': Icons.short_text,             'group': 'Text'},
  {'type': 'paragraph',     'label': 'Paragraph',           'icon': Icons.notes,                  'group': 'Text'},
  // Choice
  {'type': 'radio',         'label': 'Multiple Choice',     'icon': Icons.radio_button_checked,   'group': 'Choice'},
  {'type': 'checkbox',      'label': 'Checkboxes',          'icon': Icons.check_box,              'group': 'Choice'},
  {'type': 'dropdown',      'label': 'Dropdown',            'icon': Icons.arrow_drop_down_circle, 'group': 'Choice'},
  // Scale
  {'type': 'linear_scale',  'label': 'Linear Scale',        'icon': Icons.linear_scale,           'group': 'Scale'},
  {'type': 'rating',        'label': 'Rating (Stars)',      'icon': Icons.star_rate,              'group': 'Scale'},
  // Grid
  {'type': 'yes_no',        'label': 'Yes / No',            'icon': Icons.thumbs_up_down,         'group': 'Quick'},
  // Date & Time
  {'type': 'date',          'label': 'Date',                'icon': Icons.calendar_today,         'group': 'Date & Time'},
  {'type': 'time',          'label': 'Time',                'icon': Icons.access_time,            'group': 'Date & Time'},
  // Contact
  {'type': 'email',         'label': 'Email',               'icon': Icons.email,                  'group': 'Contact'},
  {'type': 'phone',         'label': 'Phone Number',        'icon': Icons.phone,                  'group': 'Contact'},
  {'type': 'number',        'label': 'Number',              'icon': Icons.numbers,                'group': 'Contact'},
  // File
  {'type': 'file_upload',   'label': 'File Upload',         'icon': Icons.upload_file,            'group': 'File'},
  {'type': 'image_upload',  'label': 'Image Upload',        'icon': Icons.add_photo_alternate,    'group': 'File'},
  // College-specific
  {'type': 'roll_number',   'label': 'Roll Number',         'icon': Icons.badge,                  'group': 'College'},
  {'type': 'department',    'label': 'Department',          'icon': Icons.school,                 'group': 'College'},
  {'type': 'semester',      'label': 'Semester',            'icon': Icons.class_,                 'group': 'College'},
];

bool _hasOptions(String type) => ['radio', 'checkbox', 'dropdown'].contains(type);
bool _isScale(String type)    => ['linear_scale', 'rating'].contains(type);

// ---------- Screen ----------
class FormBuilderScreen extends ConsumerStatefulWidget {
  final String eventId;
  const FormBuilderScreen({super.key, required this.eventId});

  @override
  ConsumerState<FormBuilderScreen> createState() => _FormBuilderScreenState();
}

class _FormBuilderScreenState extends ConsumerState<FormBuilderScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<FormQuestionDraft> _questions = [];
  String? _formId;
  String? _sectionId;
  bool _isLoading = true;
  bool _isSaving = false;
  String _eventTitle = 'Event';

  // Form settings
  bool _autoApproval = false;
  bool _allowWaitlist = false;
  bool _oneResponseOnly = true;
  bool _editableResponse = false;
  String _confirmationMessage = 'Thank you for registering!';
  // New: Limits & Scheduling
  int? _maxResponses;
  bool _closeOnLimit = false;
  DateTime? _formOpenDate;
  DateTime? _formCloseDate;
  final _maxResponsesController = TextEditingController();

  int? _selectedQuestionIndex;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadForm();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _maxResponsesController.dispose();
    super.dispose();
  }

  Future<void> _loadForm() async {
    setState(() => _isLoading = true);
    try {
      final event = await Supabase.instance.client
          .from('events').select('title').eq('id', widget.eventId).single();
      _eventTitle = event['title'];

      var formRes = await Supabase.instance.client
          .from('registration_forms')
          .select('id, auto_approval, allow_waitlist, one_response_only, editable_response, confirmation_message, max_responses, close_on_limit, form_open_date, form_close_date')
          .eq('event_id', widget.eventId)
          .maybeSingle();

      if (formRes == null) {
        final nf = await Supabase.instance.client
            .from('registration_forms')
            .insert({'event_id': widget.eventId}).select('id').single();
        _formId = nf['id'];
      } else {
        _formId = formRes['id'];
        _autoApproval        = formRes['auto_approval'] ?? false;
        _allowWaitlist       = formRes['allow_waitlist'] ?? false;
        _oneResponseOnly     = formRes['one_response_only'] ?? true;
        _editableResponse    = formRes['editable_response'] ?? false;
        _confirmationMessage = formRes['confirmation_message'] ?? 'Thank you for registering!';
        _maxResponses        = formRes['max_responses'];
        _closeOnLimit        = formRes['close_on_limit'] ?? false;
        if (formRes['form_open_date'] != null) {
          _formOpenDate = DateTime.parse(formRes['form_open_date']);
        }
        if (formRes['form_close_date'] != null) {
          _formCloseDate = DateTime.parse(formRes['form_close_date']);
        }
        if (_maxResponses != null) {
          _maxResponsesController.text = _maxResponses.toString();
        }
      }

      var sectionRes = await Supabase.instance.client
          .from('form_sections').select('id').eq('form_id', _formId!).maybeSingle();

      if (sectionRes == null) {
        final ns = await Supabase.instance.client
            .from('form_sections')
            .insert({'form_id': _formId!, 'title': 'Registration Details', 'order_index': 0})
            .select('id').single();
        _sectionId = ns['id'];
      } else {
        _sectionId = sectionRes['id'];
      }

      final qRes = await Supabase.instance.client
          .from('form_questions')
          .select('id, title, description, question_type, is_required, character_limit, min_value, max_value, question_options(value, order_index)')
          .eq('section_id', _sectionId!)
          .order('order_index');

      setState(() {
        _questions = (qRes as List).map((q) {
          final rawOpts = (q['question_options'] as List);
          rawOpts.sort((a, b) => (a['order_index'] ?? 0).compareTo(b['order_index'] ?? 0));
          final opts = rawOpts.map((o) => o['value'].toString()).toList();
          return FormQuestionDraft(
            uid: q['id'],
            title: q['title'] ?? '',
            description: q['description'] ?? '',
            type: q['question_type'] ?? 'short_answer',
            isRequired: q['is_required'] ?? false,
            options: opts,
            scaleMin: (q['min_value'] as num?)?.toInt() ?? 1,
            scaleMax: (q['max_value'] as num?)?.toInt() ?? 5,
            charLimit: q['character_limit'],
          );
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveForm() async {
    if (_sectionId == null || _formId == null) return;
    setState(() => _isSaving = true);

    try {
      // Save form settings
      await Supabase.instance.client.from('registration_forms').update({
        'auto_approval': _autoApproval,
        'allow_waitlist': _allowWaitlist,
        'one_response_only': _oneResponseOnly,
        'editable_response': _editableResponse,
        'confirmation_message': _confirmationMessage,
        'max_responses': _maxResponses,
        'close_on_limit': _closeOnLimit,
        'form_open_date': _formOpenDate?.toIso8601String(),
        'form_close_date': _formCloseDate?.toIso8601String(),
      }).eq('id', _formId!);

      // Delete and re-insert questions
      await Supabase.instance.client.from('form_questions').delete().eq('section_id', _sectionId!);

      for (int i = 0; i < _questions.length; i++) {
        final q = _questions[i];
        if (q.title.trim().isEmpty) continue;

        final qRes = await Supabase.instance.client.from('form_questions').insert({
          'section_id': _sectionId!,
          'title': q.title.trim(),
          'description': q.description.trim().isEmpty ? null : q.description.trim(),
          'question_type': q.type,
          'is_required': q.isRequired,
          'order_index': i,
          'character_limit': q.charLimit,
          'min_value': _isScale(q.type) ? q.scaleMin.toDouble() : null,
          'max_value': _isScale(q.type) ? q.scaleMax.toDouble() : null,
        }).select('id').single();

        if (_hasOptions(q.type) && q.options.isNotEmpty) {
          await Supabase.instance.client.from('question_options').insert(
            q.options.asMap().entries
                .where((e) => e.value.trim().isNotEmpty)
                .map((e) => {
                      'question_id': qRes['id'],
                      'value': e.value.trim(),
                      'label': e.value.trim(),
                      'order_index': e.key,
                    })
                .toList(),
          );
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Form saved successfully!'), backgroundColor: AdminColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving form: $e'), backgroundColor: AdminColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _addQuestion(String type) {
    setState(() {
      final newQ = FormQuestionDraft(
        uid: 'new_${DateTime.now().millisecondsSinceEpoch}',
        type: type,
        options: _hasOptions(type) ? ['Option 1', 'Option 2'] : [],
      );
      _questions.add(newQ);
      _selectedQuestionIndex = _questions.length - 1;
    });
  }

  void _duplicateQuestion(int index) {
    setState(() {
      final copy = _questions[index].copy();
      _questions.insert(index + 1, copy);
      _selectedQuestionIndex = index + 1;
    });
  }

  void _removeQuestion(int index) {
    setState(() {
      _questions.removeAt(index);
      _selectedQuestionIndex = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminColors.bg,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Form Builder', style: TextStyle(fontWeight: FontWeight.bold, color: AdminColors.textPrimary)),
            Text(_eventTitle, style: const TextStyle(fontSize: 12, color: AdminColors.textSecondary)),
          ],
        ),
        backgroundColor: AdminColors.sidebar,
        elevation: 1,
        iconTheme: const IconThemeData(color: AdminColors.textPrimary),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/admin/events');
            }
          },
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.dynamic_form), text: 'Questions'),
            Tab(icon: Icon(Icons.settings), text: 'Settings'),
          ],
          labelColor: AdminColors.accent,
          unselectedLabelColor: AdminColors.textSecondary,
          indicatorColor: AdminColors.accent,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 24, top: 8, bottom: 8),
            child: ElevatedButton.icon(
              onPressed: _isSaving ? null : _saveForm,
              icon: _isSaving
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AdminColors.onAccent))
                  : const Icon(Icons.save_rounded),
              label: const Text('Save Form'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AdminColors.accent,
                foregroundColor: AdminColors.onAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AdminColors.accent))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildQuestionsTab(),
                _buildSettingsTab(),
              ],
            ),
    );
  }

  // ── Questions Tab ──────────────────────────────────────────────
  Widget _buildQuestionsTab() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Toolbox
        _buildToolbox(),
        // Canvas
        Expanded(child: _buildCanvas()),
      ],
    );
  }

  Widget _buildToolbox() {
    // Group the question types
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (final qt in kQuestionTypes) {
      grouped.putIfAbsent(qt['group'] as String, () => []).add(qt);
    }

    return Container(
      width: 240,
      decoration: const BoxDecoration(
        color: AdminColors.sidebar,
        border: Border(right: BorderSide(color: AdminColors.border, width: 1)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            alignment: Alignment.centerLeft,
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AdminColors.border))),
            child: const Text('Question Types', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AdminColors.textPrimary)),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: grouped.entries.map((entry) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                      child: Text(
                        entry.key.toUpperCase(),
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AdminColors.textSecondary, letterSpacing: 1),
                      ),
                    ),
                    ...entry.value.map((qt) => _toolboxTile(qt)),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: Divider(height: 1, color: AdminColors.border),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _toolboxTile(Map<String, dynamic> qt) {
    return InkWell(
      onTap: () => _addQuestion(qt['type'] as String),
      hoverColor: AdminColors.surfaceLight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Icon(qt['icon'] as IconData, size: 20, color: AdminColors.accent),
            const SizedBox(width: 12),
            Text(qt['label'] as String, style: const TextStyle(fontSize: 13, color: AdminColors.textPrimary)),
          ],
        ),
      ),
    );
  }

  Widget _buildCanvas() {
    if (_questions.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(color: AdminColors.surfaceLight, shape: BoxShape.circle),
              child: const Icon(Icons.add_box_outlined, size: 48, color: AdminColors.textSecondary),
            ),
            const SizedBox(height: 24),
            const Text('Select a question type from the left panel to get started.',
                style: TextStyle(color: AdminColors.textSecondary, fontSize: 15)),
          ],
        ),
      );
    }

    return ReorderableListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: _questions.length,
      // ignore: deprecated_member_use
      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (newIndex > oldIndex) newIndex--;
          final item = _questions.removeAt(oldIndex);
          _questions.insert(newIndex, item);
          _selectedQuestionIndex = newIndex;
        });
      },
      itemBuilder: (context, index) {
        return _buildQuestionCard(_questions[index], index, key: ValueKey(_questions[index].uid));
      },
    );
  }

  Widget _buildQuestionCard(FormQuestionDraft q, int index, {required Key key}) {
    final isSelected = _selectedQuestionIndex == index;
    final typeLabel = kQuestionTypes.firstWhere(
      (t) => t['type'] == q.type,
      orElse: () => {'label': q.type},
    )['label'] as String;

    return Container(
      key: key,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AdminColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isSelected ? AdminColors.accent : AdminColors.border, width: isSelected ? 2 : 1),
      ),
      child: InkWell(
        onTap: () => setState(() => _selectedQuestionIndex = index),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  const Icon(Icons.drag_indicator_rounded, color: AdminColors.textSecondary, size: 20),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AdminColors.accent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(typeLabel, style: const TextStyle(fontSize: 11, color: AdminColors.accent, fontWeight: FontWeight.bold)),
                  ),
                  const Spacer(),
                  // Required toggle
                  const Text('Required', style: TextStyle(fontSize: 13, color: AdminColors.textSecondary, fontWeight: FontWeight.w600)),
                  const SizedBox(width: 8),
                  Switch(
                    value: q.isRequired,
                    onChanged: (v) => setState(() => q.isRequired = v),
                    activeThumbColor: AdminColors.accent,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Title field
              if (isSelected) ...[
                TextFormField(
                  initialValue: q.title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AdminColors.textPrimary),
                  decoration: const InputDecoration(
                    hintText: 'Question',
                    hintStyle: TextStyle(color: AdminColors.textSecondary),
                    filled: true,
                    fillColor: AdminColors.surfaceLight,
                    border: OutlineInputBorder(borderSide: BorderSide.none),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  onChanged: (v) => q.title = v,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: q.description,
                  style: const TextStyle(fontSize: 14, color: AdminColors.textPrimary),
                  decoration: const InputDecoration(
                    hintText: 'Description (optional)',
                    hintStyle: TextStyle(color: AdminColors.textSecondary),
                    filled: true,
                    fillColor: AdminColors.surfaceLight,
                    border: OutlineInputBorder(borderSide: BorderSide.none),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onChanged: (v) => q.description = v,
                ),
              ] else ...[
                Text(
                  q.title.isEmpty ? 'Untitled Question' : q.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: q.title.isEmpty ? AdminColors.textSecondary : AdminColors.textPrimary,
                  ),
                ),
                if (q.description.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(q.description, style: const TextStyle(fontSize: 14, color: AdminColors.textSecondary)),
                  ),
              ],
              const SizedBox(height: 24),
              // Question-type specific UI
              _buildQuestionPreview(q, isSelected),
              // Bottom actions (only when selected)
              if (isSelected) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Divider(height: 1, color: AdminColors.border),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.copy_rounded, color: AdminColors.textSecondary),
                      tooltip: 'Duplicate',
                      onPressed: () => _duplicateQuestion(index),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: AdminColors.error),
                      tooltip: 'Delete',
                      onPressed: () => _removeQuestion(index),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionPreview(FormQuestionDraft q, bool isSelected) {
    switch (q.type) {
      case 'short_answer':
        return _dummyField('Short answer text', Icons.short_text);
      case 'paragraph':
        return _dummyField('Long answer text', Icons.notes, maxLines: 3);
      case 'email':
        return _dummyField('email@example.com', Icons.email);
      case 'phone':
        return _dummyField('+91 00000 00000', Icons.phone);
      case 'number':
        return _dummyField('0', Icons.numbers);
      case 'date':
        return _dummyField('DD/MM/YYYY', Icons.calendar_today);
      case 'time':
        return _dummyField('HH:MM', Icons.access_time);
      case 'roll_number':
        return _dummyField('e.g. 2023CS001', Icons.badge);
      case 'department':
        return _dummyField('Auto-filled from profile', Icons.school);
      case 'semester':
        return _dummyField('Auto-filled from profile', Icons.class_);
      case 'yes_no':
        return Row(
          children: [
            OutlinedButton.icon(
              icon: const Icon(Icons.thumb_up_rounded, size: 16),
              label: const Text('Yes'),
              onPressed: null,
              style: OutlinedButton.styleFrom(disabledForegroundColor: AdminColors.textSecondary, side: const BorderSide(color: AdminColors.border)),
            ),
            const SizedBox(width: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.thumb_down_rounded, size: 16),
              label: const Text('No'),
              onPressed: null,
              style: OutlinedButton.styleFrom(disabledForegroundColor: AdminColors.textSecondary, side: const BorderSide(color: AdminColors.border)),
            ),
          ],
        );
      case 'file_upload':
      case 'image_upload':
        return OutlinedButton.icon(
          icon: Icon(q.type == 'image_upload' ? Icons.add_photo_alternate : Icons.upload_file, size: 18),
          label: Text(q.type == 'image_upload' ? 'Choose Image' : 'Choose File'),
          onPressed: null,
          style: OutlinedButton.styleFrom(disabledForegroundColor: AdminColors.textSecondary, side: const BorderSide(color: AdminColors.border)),
        );
      case 'rating':
        return Row(
          children: List.generate(5, (i) => const Icon(Icons.star_border_rounded, color: AdminColors.gold, size: 32)),
        );
      case 'linear_scale':
        return isSelected ? _buildLinearScaleEditor(q) : _buildLinearScalePreview(q);
      case 'radio':
      case 'checkbox':
      case 'dropdown':
        return _buildOptionsEditor(q, isSelected);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _dummyField(String hint, IconData icon, {int maxLines = 1}) {
    return TextFormField(
      enabled: false,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AdminColors.textSecondary),
        prefixIcon: Icon(icon, color: AdminColors.textSecondary, size: 18),
        filled: true,
        fillColor: AdminColors.surfaceLight,
        disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AdminColors.border)),
      ),
    );
  }

  Widget _buildLinearScalePreview(FormQuestionDraft q) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (q.scaleMinLabel.isNotEmpty)
              Text(q.scaleMinLabel, style: const TextStyle(fontSize: 12, color: AdminColors.textSecondary)),
            const Spacer(),
            if (q.scaleMaxLabel.isNotEmpty)
              Text(q.scaleMaxLabel, style: const TextStyle(fontSize: 12, color: AdminColors.textSecondary)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            q.scaleMax - q.scaleMin + 1,
            (i) => Column(
              children: [
                // ignore: deprecated_member_use
                Radio(value: i, groupValue: -1, onChanged: null, fillColor: WidgetStateProperty.all(AdminColors.textSecondary)),
                Text('${q.scaleMin + i}', style: const TextStyle(fontSize: 12, color: AdminColors.textSecondary)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLinearScaleEditor(FormQuestionDraft q) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('From:', style: TextStyle(fontSize: 14, color: AdminColors.textPrimary)),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(color: AdminColors.surfaceLight, borderRadius: BorderRadius.circular(8)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: q.scaleMin,
                  dropdownColor: AdminColors.surfaceLight,
                  style: const TextStyle(color: AdminColors.textPrimary),
                  items: [0, 1].map((v) => DropdownMenuItem(value: v, child: Text('$v'))).toList(),
                  onChanged: (v) => setState(() => q.scaleMin = v!),
                ),
              ),
            ),
            const SizedBox(width: 32),
            const Text('To:', style: TextStyle(fontSize: 14, color: AdminColors.textPrimary)),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(color: AdminColors.surfaceLight, borderRadius: BorderRadius.circular(8)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: q.scaleMax,
                  dropdownColor: AdminColors.surfaceLight,
                  style: const TextStyle(color: AdminColors.textPrimary),
                  items: [2, 3, 4, 5, 6, 7, 8, 9, 10]
                      .map((v) => DropdownMenuItem(value: v, child: Text('$v')))
                      .toList(),
                  onChanged: (v) => setState(() => q.scaleMax = v!),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: q.scaleMinLabel,
                style: const TextStyle(color: AdminColors.textPrimary, fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'Label for ${q.scaleMin} (optional)',
                  labelStyle: const TextStyle(color: AdminColors.textSecondary),
                  filled: true,
                  fillColor: AdminColors.surfaceLight,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                  isDense: true,
                ),
                onChanged: (v) => q.scaleMinLabel = v,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                initialValue: q.scaleMaxLabel,
                style: const TextStyle(color: AdminColors.textPrimary, fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'Label for ${q.scaleMax} (optional)',
                  labelStyle: const TextStyle(color: AdminColors.textSecondary),
                  filled: true,
                  fillColor: AdminColors.surfaceLight,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                  isDense: true,
                ),
                onChanged: (v) => q.scaleMaxLabel = v,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOptionsEditor(FormQuestionDraft q, bool isSelected) {
    final icon = q.type == 'checkbox' ? Icons.check_box_outline_blank_rounded : Icons.radio_button_unchecked_rounded;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...q.options.asMap().entries.map((entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Icon(q.type == 'dropdown' ? Icons.arrow_drop_down_rounded : icon, size: 22, color: AdminColors.textSecondary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: isSelected
                        ? TextFormField(
                            initialValue: entry.value,
                            style: const TextStyle(color: AdminColors.textPrimary, fontSize: 14),
                            decoration: const InputDecoration(
                              hintText: 'Option',
                              hintStyle: TextStyle(color: AdminColors.textSecondary),
                              border: InputBorder.none,
                              isDense: true,
                            ),
                            onChanged: (v) => q.options[entry.key] = v,
                          )
                        : Text(entry.value.isEmpty ? 'Option ${entry.key + 1}' : entry.value,
                            style: const TextStyle(fontSize: 14, color: AdminColors.textPrimary)),
                  ),
                  if (isSelected)
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 18, color: AdminColors.textSecondary),
                      onPressed: () => setState(() => q.options.removeAt(entry.key)),
                    ),
                ],
              ),
            )),
        if (isSelected)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => setState(() => q.options.add('Option ${q.options.length + 1}')),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Add Option'),
              style: TextButton.styleFrom(foregroundColor: AdminColors.accent),
            ),
          ),
      ],
    );
  }

  // ── Settings Tab ──────────────────────────────────────────────
  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _settingsCard(
                title: 'Responses',
                children: [
                  _settingsTile(
                    'Collect only one response per student',
                    'Prevents a student from submitting the form more than once.',
                    Switch(value: _oneResponseOnly, onChanged: (v) => setState(() => _oneResponseOnly = v), activeThumbColor: AdminColors.accent),
                  ),
                  _settingsTile(
                    'Allow response editing',
                    'Students can edit their submitted response.',
                    Switch(value: _editableResponse, onChanged: (v) => setState(() => _editableResponse = v), activeThumbColor: AdminColors.accent),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _settingsCard(
                title: 'Registration Management',
                children: [
                  _settingsTile(
                    'Auto-approve registrations',
                    'Registrations are approved immediately without admin review.',
                    Switch(value: _autoApproval, onChanged: (v) => setState(() => _autoApproval = v), activeThumbColor: AdminColors.accent),
                  ),
                  _settingsTile(
                    'Allow waitlist',
                    'When seats are full, students join a waitlist.',
                    Switch(value: _allowWaitlist, onChanged: (v) => setState(() => _allowWaitlist = v), activeThumbColor: AdminColors.accent),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _settingsCard(
                title: 'Registration Limits',
                children: [
                  _settingsTile(
                    'Maximum registrations',
                    'Cap on registrations. Leave blank for unlimited.',
                    SizedBox(
                      width: 120,
                      child: TextField(
                        controller: _maxResponsesController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: AdminColors.textPrimary, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: '∞ unlimited',
                          hintStyle: const TextStyle(color: AdminColors.textSecondary),
                          filled: true,
                          fillColor: AdminColors.surfaceLight,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        onChanged: (v) => setState(() => _maxResponses = int.tryParse(v)),
                      ),
                    ),
                  ),
                  _settingsTile(
                    'Auto-close when limit reached',
                    'Stop accepting new registrations automatically when the cap is hit.',
                    Switch(value: _closeOnLimit, onChanged: (v) => setState(() => _closeOnLimit = v), activeThumbColor: AdminColors.accent),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _settingsCard(
                title: 'Form Schedule',
                children: [
                  _settingsTile(
                    'Form opens on',
                    _formOpenDate == null ? 'Immediately (no restriction)' : _formOpenDate!.toLocal().toString().split('.000')[0],
                    Row(mainAxisSize: MainAxisSize.min, children: [
                      if (_formOpenDate != null)
                        IconButton(icon: const Icon(Icons.clear_rounded, size: 20, color: AdminColors.textSecondary), onPressed: () => setState(() => _formOpenDate = null)),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.calendar_today_rounded, size: 16),
                        label: const Text('Set'),
                        onPressed: () async {
                          final date = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now().subtract(const Duration(days: 365)), lastDate: DateTime.now().add(const Duration(days: 365)));
                          if (date != null && mounted) {
                            final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                            if (time != null && mounted) setState(() => _formOpenDate = DateTime(date.year, date.month, date.day, time.hour, time.minute));
                          }
                        },
                        style: OutlinedButton.styleFrom(foregroundColor: AdminColors.textPrimary, side: const BorderSide(color: AdminColors.border)),
                      ),
                    ]),
                  ),
                  _settingsTile(
                    'Form closes on',
                    _formCloseDate == null ? 'Never (no deadline)' : _formCloseDate!.toLocal().toString().split('.000')[0],
                    Row(mainAxisSize: MainAxisSize.min, children: [
                      if (_formCloseDate != null)
                        IconButton(icon: const Icon(Icons.clear_rounded, size: 20, color: AdminColors.textSecondary), onPressed: () => setState(() => _formCloseDate = null)),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.event_busy_rounded, size: 16),
                        label: const Text('Set Deadline'),
                        style: OutlinedButton.styleFrom(foregroundColor: AdminColors.error, side: const BorderSide(color: AdminColors.border)),
                        onPressed: () async {
                          final date = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now().subtract(const Duration(days: 365)), lastDate: DateTime.now().add(const Duration(days: 365)));
                          if (date != null && mounted) {
                            final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                            if (time != null && mounted) setState(() => _formCloseDate = DateTime(date.year, date.month, date.day, time.hour, time.minute));
                          }
                        },
                      ),
                    ]),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _settingsCard(
                title: 'Confirmation',
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: TextFormField(
                      initialValue: _confirmationMessage,
                      style: const TextStyle(color: AdminColors.textPrimary, fontSize: 14),
                      decoration: InputDecoration(
                        labelText: 'Confirmation message shown to students after submission',
                        labelStyle: const TextStyle(color: AdminColors.textSecondary),
                        filled: true,
                        fillColor: AdminColors.surfaceLight,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AdminColors.border)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AdminColors.border)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AdminColors.accent, width: 1.5)),
                      ),
                      maxLines: 3,
                      onChanged: (v) => _confirmationMessage = v,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : () async {
                    await _saveForm();
                    if (mounted) context.go('/admin/events');
                  },
                  icon: _isSaving
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AdminColors.onAccent))
                      : const Icon(Icons.check_circle_outline, size: 22),
                  label: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text('Save Form & Finish', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AdminColors.accent,
                    foregroundColor: AdminColors.onAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _settingsCard({required String title, required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: AdminColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AdminColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AdminColors.textPrimary)),
          ),
          const Divider(height: 1, color: AdminColors.border),
          ...children,
        ],
      ),
    );
  }

  Widget _settingsTile(String title, String subtitle, Widget trailing) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // FIX: Prevent unbounded height
              children: [
                Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AdminColors.textPrimary)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(fontSize: 13, color: AdminColors.textSecondary)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          trailing,
        ],
      ),
    );
  }
}
