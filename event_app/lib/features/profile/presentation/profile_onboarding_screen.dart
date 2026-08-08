import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import '../../../core/design_system.dart';

class ProfileOnboardingScreen extends ConsumerStatefulWidget {
  final bool isEditing;
  const ProfileOnboardingScreen({super.key, this.isEditing = false});

  @override
  ConsumerState<ProfileOnboardingScreen> createState() => _ProfileOnboardingScreenState();
}

class _ProfileOnboardingScreenState extends ConsumerState<ProfileOnboardingScreen> {
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
  static const List<String> _semesters = ['1','2','3','4','5','6','7','8'];
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
                _prnController.text = profileRes['enrollment_number'].toString();
              }
              if (profileRes['phone_number'] != null) {
                _phoneController.text = profileRes['phone_number'].toString();
              }
              if (profileRes['department_id'] != null) {
                _selectedDepartmentId = profileRes['department_id'].toString();
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
    final path = '${user.id}/avatar-${DateTime.now().millisecondsSinceEpoch}.png';
    
    try {
      await Supabase.instance.client.storage
          .from('avatars')
          .uploadBinary(
            path,
            _avatarBytes!,
            fileOptions: const FileOptions(contentType: 'image/png', upsert: true),
          );
      return Supabase.instance.client.storage.from('avatars').getPublicUrl(path);
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
        const SnackBar(content: Text('Please enter your name'), backgroundColor: AppColors.error),
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
        'roll_number': _rollController.text.trim().isEmpty ? null : _rollController.text.trim(),
        'enrollment_number': _prnController.text.trim().isEmpty ? null : _prnController.text.trim(),
        'phone_number': _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        'department_id': _selectedDepartmentId,
        'year': _selectedYear == null ? null : int.tryParse(_selectedYear!),
        'semester': _selectedSemester == null ? null : int.tryParse(_selectedSemester!),
        'division': _selectedDivision,
        'avatar_url': resolvedAvatarUrl,
      };

      await Supabase.instance.client.from('student_profiles').upsert(updateData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile saved successfully!'),
            backgroundColor: AppColors.green,
            duration: Duration(seconds: 2),
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
          SnackBar(content: Text(error.toString()), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(color: AppColors.green),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (widget.isEditing)
                        GestureDetector(
                          onTap: () => context.pop(),
                          child: const Padding(
                            padding: EdgeInsets.only(right: 12),
                            child: Icon(Icons.arrow_back_rounded, color: AppColors.white, size: 24),
                          ),
                        ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.yellow,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'EVENT COLLAGE',
                          style: GoogleFonts.inter(
                            color: AppColors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.isEditing ? 'Edit Profile' : "What's your profile?",
                    style: GoogleFonts.inter(
                        color: AppColors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w900)),
                  Text(
                    widget.isEditing
                        ? 'Update your personal information.'
                        : 'Help us personalize your experience.',
                    style: GoogleFonts.inter(
                        color: AppColors.white.withOpacity(0.8),
                        fontSize: 13)),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Center(
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.grey100,
                            border: Border.all(color: AppColors.green, width: 2),
                            image: _avatarBytes != null
                                ? DecorationImage(image: MemoryImage(_avatarBytes!), fit: BoxFit.cover)
                                : (_existingAvatarUrl != null
                                    ? DecorationImage(image: NetworkImage(_existingAvatarUrl!), fit: BoxFit.cover)
                                    : null),
                          ),
                          child: _avatarBytes == null && _existingAvatarUrl == null
                              ? const Icon(Icons.add_a_photo_rounded, size: 32, color: AppColors.green)
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _SectionLabel('Personal Information'),
                    const SizedBox(height: 12),
                    _field(label: 'Full Name *', controller: _nameController,
                        hint: 'e.g. Mayank Bohara', icon: Icons.person_outline),
                    const SizedBox(height: 12),
                    _field(label: 'Phone Number', controller: _phoneController,
                        hint: '+91 00000 00000', icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone),

                    const SizedBox(height: 20),
                    _SectionLabel('Academic Details'),
                    const SizedBox(height: 12),
                    _field(label: 'PRN NO.', controller: _prnController,
                        hint: 'e.g. 1234567890', icon: Icons.pin_outlined),
                    const SizedBox(height: 12),
                    _field(label: 'Roll Number', controller: _rollController,
                        hint: 'e.g. 2023CS001', icon: Icons.badge_outlined),
                    const SizedBox(height: 12),
                    _isLoading 
                        ? const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()))
                        : _dropdown<String>(
                            label: 'Department',
                            value: _selectedDepartmentId,
                            items: _departments.map((d) => d['id'] as String).toList(),
                            itemLabel: (id) => _departments.firstWhere((d) => d['id'] == id)['name'],
                            hint: 'Select Department',
                            icon: Icons.school_outlined,
                            onChanged: (v) => setState(() => _selectedDepartmentId = v),
                          ),
                    const SizedBox(height: 12),
                    _dropdown<String>(
                      label: 'Year',
                      value: _selectedYear,
                      items: _years,
                      itemLabel: (s) => '$s${s == '1' ? 'st' : s == '2' ? 'nd' : s == '3' ? 'rd' : 'th'} Year',
                      hint: 'Select Year',
                      icon: Icons.calendar_today_outlined,
                      onChanged: (v) => setState(() => _selectedYear = v),
                    ),
                    const SizedBox(height: 12),
                    _dropdown<String>(
                      label: 'Semester',
                      value: _selectedSemester,
                      items: _semesters,
                      itemLabel: (s) => 'Semester $s',
                      hint: 'Select Semester',
                      icon: Icons.class_outlined,
                      onChanged: (v) => setState(() => _selectedSemester = v),
                    ),
                    const SizedBox(height: 12),
                    _dropdown<String>(
                      label: 'Division',
                      value: _selectedDivision,
                      items: _divisions,
                      itemLabel: (s) => 'Div $s',
                      hint: 'Select Division',
                      icon: Icons.group_outlined,
                      onChanged: (v) => setState(() => _selectedDivision = v),
                    ),

                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        child: _isSaving
                            ? const SizedBox(height: 20, width: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Text(
                                widget.isEditing ? 'Save Profile' : 'Continue to Events',
                                style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.white)),
                      ),
                    ),
                    if (!widget.isEditing) ...[
                      const SizedBox(height: 12),
                      Center(
                        child: TextButton(
                          onPressed: () => context.go('/student/home'),
                          child: Text('Skip for now',
                              style: GoogleFonts.inter(
                                  color: AppColors.grey400,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500)),
                        ),
                      ),
                    ],
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
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.grey600)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppColors.grey400, size: 20),
            filled: true,
            fillColor: AppColors.white,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.grey200)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.grey200)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.green, width: 2)),
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
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.grey600)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.grey200),
          ),
          child: DropdownButtonFormField<T>(
            value: value,
            onChanged: onChanged,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: AppColors.grey400, size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
            hint: Text(hint, style: GoogleFonts.inter(color: AppColors.grey400, fontSize: 14)),
            dropdownColor: AppColors.white,
            style: GoogleFonts.inter(color: AppColors.black, fontSize: 15),
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
        Container(width: 4, height: 18, decoration: BoxDecoration(
            color: AppColors.green, borderRadius: BorderRadius.circular(4))),
        const SizedBox(width: 8),
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.black)),
      ],
    );
  }
}
