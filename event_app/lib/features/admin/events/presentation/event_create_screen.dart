import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../admin_colors.dart';


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

  // Poster state
  String? _coverImageUrl;
  Uint8List? _posterPreviewBytes;
  bool _isUploadingPoster = false;

  @override
  void initState() {
    super.initState();
    _fetchCategories().then((_) {
      if (widget.eventId != null) {
        _fetchEvent();
      } else {
        if (mounted) setState(() => _isLoading = false);
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
          _contactController.text = res['email'] ?? '';
          _eligibilityController.text = res['eligibility'] ?? '';
          _categoryId = res['category_id'];
          _visibility = res['visibility'] ?? 'draft';
          _coverImageUrl = res['cover_image_url'];
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
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching event: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchCategories() async {
    try {
      final res = await Supabase.instance.client
          .from('event_categories')
          .select('id, name')
          .order('name');
      if (mounted) setState(() => _categories = List<Map<String, dynamic>>.from(res));
    } catch (e) {
      debugPrint('Error fetching categories: $e');
    }
  }

  Future<void> _pickAndUploadPoster() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final bytes = await picked.readAsBytes();
    final name = picked.name;

    setState(() {
      _posterPreviewBytes = bytes;
      _isUploadingPoster = true;
    });

    try {
      final ext = name.contains('.') ? name.split('.').last.toLowerCase() : 'jpg';
      final ts = DateTime.now().millisecondsSinceEpoch;
      final eventId = widget.eventId ?? 'tmp_$ts';
      final path = 'posters/$eventId/$ts.$ext';

      await Supabase.instance.client.storage
          .from('event-posters')
          .uploadBinary(
            path,
            bytes,
            fileOptions: FileOptions(contentType: 'image/$ext', upsert: true),
          );

      final url = Supabase.instance.client.storage
          .from('event-posters')
          .getPublicUrl(path);

      if (mounted) setState(() => _coverImageUrl = url);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e'), backgroundColor: AdminColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploadingPoster = false);
    }
  }

  void _removePoster() => setState(() {
    _coverImageUrl = null;
    _posterPreviewBytes = null;
  });

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AdminColors.accent, onPrimary: Colors.white),
        ),
        child: child!,
      ),
    );
    if (picked != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: const TimeOfDay(hour: 9, minute: 0),
        builder: (context, child) => Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AdminColors.accent, onPrimary: Colors.white),
          ),
          child: child!,
        ),
      );
      if (time != null) {
        setState(() {
          if (isStart) { _startDate = picked; _startTime = time; }
          else { _endDate = picked; _endTime = time; }
        });
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
        'email': _contactController.text.trim(),
        'category_id': _categoryId,
        'eligibility': _eligibilityController.text.trim(),
        'cover_image_url': _coverImageUrl,
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
        await Supabase.instance.client.from('events').update(eventData).eq('id', widget.eventId!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Event updated successfully!'), backgroundColor: AdminColors.success));
          context.pop();
        }
      } else {
        final response = await Supabase.instance.client
            .from('events').insert(eventData).select().single();
        await Supabase.instance.client
            .from('registration_forms').insert({'event_id': response['id']});
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Event created! Now build the registration form.'), backgroundColor: AdminColors.success));
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

  void _goBack() {
    if (context.canPop()) context.pop();
    else context.go('/admin/events');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminColors.bg,
      appBar: AppBar(
        backgroundColor: AdminColors.sidebar,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AdminColors.textPrimary),
          onPressed: _goBack,
        ),
        title: Text(
          widget.eventId != null ? 'Edit Event' : 'Create New Event',
          style: const TextStyle(color: AdminColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w700),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AdminColors.border),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPosterCard(),
                        const SizedBox(height: 16),
                        _buildCard(title: 'Basic Details', children: [
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
                              value: c['id'], child: Text(c['name']),
                            )).toList(),
                            onChanged: (v) => setState(() => _categoryId = v),
                          ),
                          const SizedBox(height: 16),
                          Row(children: [
                            Expanded(child: _buildDateBtn('Start Time *', _startDate, _startTime, true)),
                            const SizedBox(width: 16),
                            Expanded(child: _buildDateBtn('End Time *', _endDate, _endTime, false)),
                          ]),
                        ]),
                        const SizedBox(height: 16),
                        _buildCard(title: 'Logistics & Eligibility', children: [
                          _buildTextField(_eligibilityController, 'Eligibility Criteria', Icons.verified_user, required: false),
                          const SizedBox(height: 16),
                          Row(children: [
                            Expanded(child: _buildTextField(_venueController, 'Venue', Icons.location_on, required: false)),
                            const SizedBox(width: 16),
                            Expanded(child: _buildTextField(_maxSeatsController, 'Max Seats', Icons.people, isNumber: true, required: false)),
                          ]),
                          const SizedBox(height: 16),
                          Row(children: [
                            Expanded(child: _buildTextField(_coordinatorController, 'Coordinator', Icons.person, required: false)),
                            const SizedBox(width: 16),
                            Expanded(child: _buildTextField(_contactController, 'Contact Number', Icons.phone, required: false)),
                          ]),
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
                        ]),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton.icon(
                            onPressed: (_isLoading || _isUploadingPoster) ? null : _saveEvent,
                            icon: (_isLoading || _isUploadingPoster)
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Icon(Icons.arrow_forward),
                            label: Text(
                              _isUploadingPoster ? 'Uploading poster...' : 'Save & Build Registration Form',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
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

  Widget _buildPosterCard() {
    final hasImage = _posterPreviewBytes != null ||
        (_coverImageUrl != null && _coverImageUrl!.isNotEmpty);

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
          Row(
            children: [
              const Icon(Icons.image_rounded, color: AdminColors.accent, size: 22),
              const SizedBox(width: 10),
              const Text(
                'Event Poster / Flyer',
                style: TextStyle(color: AdminColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AdminColors.accent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('Optional', style: TextStyle(color: AdminColors.accent, fontSize: 11, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Shown as the event card banner on the student home screen. Students tap it to open the event.',
            style: TextStyle(color: AdminColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 20),
          if (!hasImage)
            GestureDetector(
              onTap: _isUploadingPoster ? null : _pickAndUploadPoster,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AdminColors.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AdminColors.accent.withOpacity(0.45), width: 2),
                ),
                child: _isUploadingPoster
                    ? const Center(child: CircularProgressIndicator(color: AdminColors.accent))
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 64, height: 64,
                            decoration: BoxDecoration(color: AdminColors.accent.withOpacity(0.1), shape: BoxShape.circle),
                            child: const Icon(Icons.add_photo_alternate_rounded, color: AdminColors.accent, size: 32),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Click to upload poster / flyer',
                            style: TextStyle(color: AdminColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 6),
                          const Text('PNG · JPG · JPEG · WEBP', style: TextStyle(color: AdminColors.textSecondary, fontSize: 12)),
                        ],
                      ),
              ),
            )
          else
            Column(
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: _posterPreviewBytes != null
                          ? Image.memory(_posterPreviewBytes!, height: 240, width: double.infinity, fit: BoxFit.cover)
                          : Image.network(
                              _coverImageUrl!,
                              height: 240, width: double.infinity, fit: BoxFit.cover,
                              loadingBuilder: (ctx, child, prog) {
                                if (prog == null) return child;
                                return Container(
                                  height: 240, color: AdminColors.surfaceLight,
                                  child: const Center(child: CircularProgressIndicator(color: AdminColors.accent)),
                                );
                              },
                              errorBuilder: (_, __, ___) => Container(
                                height: 240, color: AdminColors.surfaceLight,
                                child: const Center(child: Icon(Icons.broken_image_rounded, size: 48, color: AdminColors.textSecondary)),
                              ),
                            ),
                    ),
                    if (_isUploadingPoster)
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            color: Colors.black45,
                            child: const Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircularProgressIndicator(color: Colors.white),
                                  SizedBox(height: 12),
                                  Text('Uploading...', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isUploadingPoster ? null : _pickAndUploadPoster,
                        icon: const Icon(Icons.swap_horiz_rounded, size: 18),
                        label: const Text('Replace Poster'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AdminColors.accent,
                          side: const BorderSide(color: AdminColors.accent),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: _isUploadingPoster ? null : _removePoster,
                      icon: const Icon(Icons.delete_outline_rounded, size: 18),
                      label: const Text('Remove'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AdminColors.error,
                        side: const BorderSide(color: AdminColors.error),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      ),
                    ),
                  ],
                ),
              ],
            ),
        ],
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

  Widget _buildTextField(TextEditingController controller, String label, IconData icon,
      {int maxLines = 1, bool isNumber = false, bool required = true}) {
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
        date == null
            ? label
            : '${date.toLocal().toString().split(' ')[0]} ${time != null ? '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}' : ''}',
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


