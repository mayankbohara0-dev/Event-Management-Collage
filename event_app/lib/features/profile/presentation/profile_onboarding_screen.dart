import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/zest_button.dart';
import '../../../core/widgets/zest_logo.dart';

class ProfileOnboardingScreen extends ConsumerStatefulWidget {
  final bool isEditing;
  const ProfileOnboardingScreen({super.key, this.isEditing = false});

  @override
  ConsumerState<ProfileOnboardingScreen> createState() =>
      _ProfileOnboardingScreenState();
}

class _ProfileOnboardingScreenState
    extends ConsumerState<ProfileOnboardingScreen> {
  final _nameController = TextEditingController();
  final _rollController = TextEditingController();
  final _prnController = TextEditingController();
  final _phoneController = TextEditingController();

  String? _selectedDepartmentId;
  String? _selectedYear;
  String? _selectedSemester;
  String? _selectedDivision;

  Uint8List? _avatarBytes;
  String? _existingAvatarUrl;
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = true;
  bool _isSaving = false;

  List<Map<String, dynamic>> _departments = [];

  static const List<String> _years = ['1', '2', '3', '4'];
  static const List<String> _semesters = ['1', '2', '3', '4', '5', '6', '7', '8'];
  static const List<String> _divisions = ['A', 'B', 'C', 'D', 'E', 'F'];

  @override
  void initState() {
    super.initState();
    _fetchDepartments();
  }

  Future<void> _fetchDepartments() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final profileRes = await Supabase.instance.client
            .from('student_profiles')
            .select('*')
            .eq('id', user.id)
            .maybeSingle();

        if (profileRes != null) {
          if (mounted) {
            setState(() {
              _existingAvatarUrl = profileRes['avatar_url'];
              if (profileRes['name'] != null) {
                _nameController.text = profileRes['name'].toString();
              }
              if (profileRes['roll_number'] != null) {
                _rollController.text = profileRes['roll_number'].toString();
              }
              if (profileRes['enrollment_number'] != null) {
                _prnController.text =
                    profileRes['enrollment_number'].toString();
              }
              if (profileRes['phone_number'] != null) {
                _phoneController.text = profileRes['phone_number'].toString();
              }
              if (profileRes['department_id'] != null) {
                _selectedDepartmentId =
                    profileRes['department_id'].toString();
              }
              if (profileRes['year'] != null) {
                _selectedYear = profileRes['year'].toString();
              }
              if (profileRes['semester'] != null) {
                _selectedSemester = profileRes['semester'].toString();
              }
              if (profileRes['division'] != null) {
                _selectedDivision = profileRes['division'].toString();
              }
            });
          }
        }
      }

      final res = await Supabase.instance.client
          .from('departments')
          .select('id, name')
          .order('name');
      if (mounted) {
        setState(() {
          _departments = List<Map<String, dynamic>>.from(res);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching data: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      if (mounted) setState(() => _avatarBytes = bytes);
    }
  }

  Future<String?> _uploadAvatar() async {
    if (_avatarBytes == null) return null;
    final user = Supabase.instance.client.auth.currentUser!;
    final path =
        '${user.id}/avatar-${DateTime.now().millisecondsSinceEpoch}.png';
    try {
      await Supabase.instance.client.storage
          .from('avatars')
          .uploadBinary(
            path,
            _avatarBytes!,
            fileOptions:
                const FileOptions(contentType: 'image/png', upsert: true),
          );
      return Supabase.instance.client.storage
          .from('avatars')
          .getPublicUrl(path);
    } catch (e) {
      debugPrint('Avatar upload error: $e');
      return null;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _rollController.dispose();
    _prnController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter your full name to continue.',
            style: AppTextStyles.body14.copyWith(color: AppColors.paper),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.circularMd),
        ),
      );
      return;
    }
    setState(() => _isSaving = true);
    try {
      final user = Supabase.instance.client.auth.currentUser!;
      // Upload new avatar if one was picked, otherwise keep the existing URL
      String? resolvedAvatarUrl = _existingAvatarUrl;
      if (_avatarBytes != null) {
        final uploaded = await _uploadAvatar();
        if (uploaded != null) resolvedAvatarUrl = uploaded;
      }

      final updateData = <String, dynamic>{
        'id': user.id,
        'name': _nameController.text.trim(),
        'roll_number': _rollController.text.trim().isEmpty
            ? null
            : _rollController.text.trim(),
        'enrollment_number': _prnController.text.trim().isEmpty
            ? null
            : _prnController.text.trim(),
        'phone_number': _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        'department_id': _selectedDepartmentId,
        'year': _selectedYear == null ? null : int.tryParse(_selectedYear!),
        'semester':
            _selectedSemester == null ? null : int.tryParse(_selectedSemester!),
        'division': _selectedDivision,
        'avatar_url': resolvedAvatarUrl,
      };

      await Supabase.instance.client
          .from('student_profiles')
          .upsert(updateData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Profile saved! 🎉',
              style: AppTextStyles.body14.copyWith(color: AppColors.ink),
            ),
            backgroundColor: AppColors.lime,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: AppRadius.circularMd),
          ),
        );
        if (widget.isEditing) {
          context.pop();
        } else {
          context.go('/student/home');
        }
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error.toString(),
              style: AppTextStyles.body14.copyWith(color: AppColors.paper),
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: AppRadius.circularMd),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Navigation Bar ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (widget.isEditing)
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceCard,
                          borderRadius: AppRadius.circularSm,
                          border:
                              Border.all(color: AppColors.borderDark, width: 1),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: AppColors.paper,
                          size: 18,
                        ),
                      ),
                    )
                  else
                    const ZestLogo.markSmall(size: 36),
                  Text(
                    widget.isEditing ? 'Edit Profile' : 'Create Profile',
                    style: AppTextStyles.sectionHeader.copyWith(
                      color: AppColors.paper,
                    ),
                  ),
                  if (!widget.isEditing && !widget.isEditing)
                    TextButton(
                      onPressed: () => context.go('/student/home'),
                      child: Text(
                        'Skip',
                        style: AppTextStyles.label13.copyWith(
                          color: AppColors.grey400,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 44),
                ],
              ),
            ),

            // ── Form Body ─────────────────────────────────────────────────────
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.lime,
                        strokeWidth: 2.5,
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Lime hero strip ───────────────────────────────
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: AppColors.limeGradient,
                              borderRadius: AppRadius.circularCard,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.isEditing
                                            ? "Update your info"
                                            : "What's your profile?",
                                        style: AppTextStyles.title24.copyWith(
                                          color: AppColors.ink,
                                          height: 1.1,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        widget.isEditing
                                            ? 'Keep your campus identity fresh.'
                                            : 'Help us personalise your experience.',
                                        style: AppTextStyles.body14.copyWith(
                                          color: AppColors.ink
                                              .withValues(alpha: 0.65),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Avatar picker
                                GestureDetector(
                                  onTap: _pickImage,
                                  child: Container(
                                    width: 72,
                                    height: 72,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color:
                                          AppColors.ink.withValues(alpha: 0.12),
                                      border: Border.all(
                                          color: AppColors.ink
                                              .withValues(alpha: 0.25),
                                          width: 2),
                                      image: _avatarBytes != null
                                          ? DecorationImage(
                                              image:
                                                  MemoryImage(_avatarBytes!),
                                              fit: BoxFit.cover)
                                          : (_existingAvatarUrl != null
                                              ? DecorationImage(
                                                  image: NetworkImage(
                                                      _existingAvatarUrl!),
                                                  fit: BoxFit.cover)
                                              : null),
                                    ),
                                    child: _avatarBytes == null &&
                                            _existingAvatarUrl == null
                                        ? const Icon(
                                            Icons.add_a_photo_rounded,
                                            size: 28,
                                            color: AppColors.ink,
                                          )
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // ── Personal Information Section ──────────────────
                          _SectionLabel('Personal Information'),
                          const SizedBox(height: 12),
                          _field(
                            label: 'FULL NAME *',
                            controller: _nameController,
                            hint: 'e.g. Mayank Bohara',
                            icon: Icons.person_outline_rounded,
                          ),
                          const SizedBox(height: 12),
                          _field(
                            label: 'PHONE NUMBER',
                            controller: _phoneController,
                            hint: '+91 00000 00000',
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                          ),

                          const SizedBox(height: 20),

                          // ── Academic Details Section ──────────────────────
                          _SectionLabel('Academic Details'),
                          const SizedBox(height: 12),
                          _field(
                            label: 'PRN NUMBER',
                            controller: _prnController,
                            hint: 'e.g. 1234567890',
                            icon: Icons.pin_outlined,
                          ),
                          const SizedBox(height: 12),
                          _field(
                            label: 'ROLL NUMBER',
                            controller: _rollController,
                            hint: 'e.g. 2023CS001',
                            icon: Icons.badge_outlined,
                          ),
                          const SizedBox(height: 12),

                          _isLoading
                              ? const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: CircularProgressIndicator(
                                        color: AppColors.lime),
                                  ),
                                )
                              : _dropdown<String>(
                                  label: 'DEPARTMENT',
                                  value: _selectedDepartmentId,
                                  items: _departments
                                      .map((d) => d['id'] as String)
                                      .toList(),
                                  itemLabel: (id) => _departments
                                      .firstWhere((d) => d['id'] == id)['name'],
                                  hint: 'Select Department',
                                  icon: Icons.school_outlined,
                                  onChanged: (v) => setState(
                                      () => _selectedDepartmentId = v),
                                ),

                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _dropdown<String>(
                                  label: 'YEAR',
                                  value: _selectedYear,
                                  items: _years,
                                  itemLabel: (s) =>
                                      '$s${s == '1' ? 'st' : s == '2' ? 'nd' : s == '3' ? 'rd' : 'th'} Year',
                                  hint: 'Year',
                                  icon: Icons.calendar_today_outlined,
                                  onChanged: (v) =>
                                      setState(() => _selectedYear = v),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _dropdown<String>(
                                  label: 'SEMESTER',
                                  value: _selectedSemester,
                                  items: _semesters,
                                  itemLabel: (s) => 'Sem $s',
                                  hint: 'Semester',
                                  icon: Icons.class_outlined,
                                  onChanged: (v) =>
                                      setState(() => _selectedSemester = v),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),
                          _dropdown<String>(
                            label: 'DIVISION',
                            value: _selectedDivision,
                            items: _divisions,
                            itemLabel: (s) => 'Division $s',
                            hint: 'Select Division',
                            icon: Icons.group_outlined,
                            onChanged: (v) =>
                                setState(() => _selectedDivision = v),
                          ),

                          const SizedBox(height: 32),

                          // ── Primary Save Button ───────────────────────────
                          ZestButton(
                            label: widget.isEditing
                                ? 'Save Profile ✓'
                                : 'Continue to Events ⚡',
                            variant: ZestButtonVariant.primary,
                            isLoading: _isSaving,
                            onPressed: _save,
                          ),

                          if (!widget.isEditing) ...[
                            const SizedBox(height: 12),
                            Center(
                              child: TextButton(
                                onPressed: () =>
                                    context.go('/student/home'),
                                child: Text(
                                  'Skip for now',
                                  style: AppTextStyles.label13.copyWith(
                                    color: AppColors.grey400,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.overline.copyWith(
            color: AppColors.grey400,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: AppTextStyles.body15.copyWith(color: AppColors.paper),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppColors.lime, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _dropdown<T>({
    required String label,
    required T? value,
    required List<T> items,
    required String Function(T) itemLabel,
    required String hint,
    required IconData icon,
    required void Function(T?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.overline.copyWith(
            color: AppColors.grey400,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceDark,
            borderRadius: AppRadius.circularInput,
            border: Border.all(color: AppColors.borderDark, width: 1.5),
          ),
          child: DropdownButtonFormField<T>(
            initialValue: value,
            onChanged: onChanged,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: AppColors.lime, size: 20),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 14, horizontal: 0),
            ),
            hint: Text(
              hint,
              style: AppTextStyles.body14.copyWith(color: AppColors.grey400),
            ),
            dropdownColor: AppColors.surfaceCard,
            style: AppTextStyles.body15.copyWith(color: AppColors.paper),
            items: items
                .map((item) => DropdownMenuItem<T>(
                      value: item,
                      child: Text(itemLabel(item)),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 18,
          decoration: BoxDecoration(
            color: AppColors.lime,
            borderRadius: AppRadius.circularPill,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: AppTextStyles.sectionHeader.copyWith(
            color: AppColors.paper,
            letterSpacing: -0.01,
          ),
        ),
      ],
    );
  }
}
