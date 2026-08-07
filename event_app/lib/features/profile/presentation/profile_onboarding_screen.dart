import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../core/design_system.dart';

class ProfileOnboardingScreen extends ConsumerStatefulWidget {
  const ProfileOnboardingScreen({super.key});

  @override
  ConsumerState<ProfileOnboardingScreen> createState() =>
      _ProfileOnboardingScreenState();
}

class _ProfileOnboardingScreenState
    extends ConsumerState<ProfileOnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isFetchingDepts = true;

  final _nameController = TextEditingController();
  final _rollNumberController = TextEditingController();
  final _enrollmentNumberController = TextEditingController();
  final _phoneController = TextEditingController();

  String? _selectedDepartment;
  String? _selectedYear;
  String? _selectedSemester;
  String? _selectedGender;
  String? _selectedBloodGroup;

  final List<Map<String, dynamic>> _departments = [];

  @override
  void initState() {
    super.initState();
    _fetchDepartments();
  }

  Future<void> _fetchDepartments() async {
    try {
      final data = await Supabase.instance.client
          .from('departments')
          .select('id, name');
      setState(() {
        _departments.addAll(List<Map<String, dynamic>>.from(data));
        _isFetchingDepts = false;
      });
    } catch (e) {
      debugPrint('Error fetching departments: $e');
      setState(() => _isFetchingDepts = false);
    }
  }

  Future<void> _submitProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('Not logged in');

      await Supabase.instance.client.from('student_profiles').upsert({
        'id': user.id,
        'name': _nameController.text.trim(),
        'roll_number': _rollNumberController.text.trim(),
        'enrollment_number': _enrollmentNumberController.text.trim(),
        'department_id': _selectedDepartment,
        'year': int.tryParse(_selectedYear ?? '1'),
        'semester': int.tryParse(_selectedSemester ?? '1'),
        'gender': _selectedGender,
        'phone_number': _phoneController.text.trim(),
        'blood_group': _selectedBloodGroup,
      });

      if (mounted) context.go('/student/home');
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $error'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _rollNumberController.dispose();
    _enrollmentNumberController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── Header ─────────────────────────────────────────────────
          Container(
            padding: EdgeInsets.fromLTRB(
                24, MediaQuery.of(context).padding.top + 24, 24, 28),
            decoration: const BoxDecoration(
              gradient: AppColors.heroGradient,
              borderRadius:
                  BorderRadius.vertical(bottom: Radius.circular(32)),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.person_add_rounded,
                      color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Complete Your Profile',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'Fill in your details to get started',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.65),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Form ───────────────────────────────────────────────────
          Expanded(
            child: _isFetchingDepts
                ? const Center(
                    child:
                        CircularProgressIndicator(color: AppColors.accent))
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Personal Details Section
                          _SectionHeader(
                            icon: Icons.person_rounded,
                            title: 'Personal Details',
                          ),
                          const SizedBox(height: 16),
                          _StyledField(
                            controller: _nameController,
                            label: 'Full Name',
                            icon: Icons.badge_outlined,
                            validator: (v) =>
                                v!.isEmpty ? 'Required' : null,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _StyledDropdown<String>(
                                  label: 'Gender',
                                  icon: Icons.people_outline,
                                  value: _selectedGender,
                                  items: ['Male', 'Female', 'Other']
                                      .map((g) => DropdownMenuItem(
                                          value: g, child: Text(g)))
                                      .toList(),
                                  onChanged: (v) =>
                                      setState(() => _selectedGender = v),
                                  validator: (v) =>
                                      v == null ? 'Required' : null,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: _StyledField(
                                  controller: _phoneController,
                                  label: 'Phone',
                                  icon: Icons.phone_outlined,
                                  keyboardType: TextInputType.phone,
                                  validator: (v) =>
                                      v!.isEmpty ? 'Required' : null,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _StyledDropdown<String>(
                            label: 'Blood Group',
                            icon: Icons.bloodtype_outlined,
                            value: _selectedBloodGroup,
                            items: ['A+', 'A−', 'B+', 'B−', 'O+', 'O−', 'AB+', 'AB−']
                                .map((g) =>
                                    DropdownMenuItem(value: g, child: Text(g)))
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _selectedBloodGroup = v),
                          ),

                          const SizedBox(height: 28),
                          // Academic Details Section
                          _SectionHeader(
                            icon: Icons.school_rounded,
                            title: 'Academic Details',
                          ),
                          const SizedBox(height: 16),
                          _StyledField(
                            controller: _rollNumberController,
                            label: 'Roll Number',
                            icon: Icons.tag_rounded,
                            validator: (v) =>
                                v!.isEmpty ? 'Required' : null,
                          ),
                          const SizedBox(height: 16),
                          _StyledField(
                            controller: _enrollmentNumberController,
                            label: 'Enrollment Number',
                            icon: Icons.numbers_rounded,
                          ),
                          const SizedBox(height: 16),
                          _StyledDropdown<String>(
                            label: 'Department',
                            icon: Icons.account_tree_outlined,
                            value: _selectedDepartment,
                            items: _departments
                                .map((d) => DropdownMenuItem<String>(
                                    value: d['id'],
                                    child: Text(d['name'])))
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _selectedDepartment = v),
                            validator: (v) =>
                                v == null ? 'Required' : null,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _StyledDropdown<String>(
                                  label: 'Year',
                                  icon: Icons.calendar_month_outlined,
                                  value: _selectedYear,
                                  items: ['1', '2', '3', '4', '5']
                                      .map((y) => DropdownMenuItem(
                                          value: y,
                                          child: Text('Year $y')))
                                      .toList(),
                                  onChanged: (v) =>
                                      setState(() => _selectedYear = v),
                                  validator: (v) =>
                                      v == null ? 'Required' : null,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: _StyledDropdown<String>(
                                  label: 'Semester',
                                  icon: Icons.format_list_numbered_rounded,
                                  value: _selectedSemester,
                                  items: List.generate(10, (i) => (i + 1).toString())
                                      .map((s) => DropdownMenuItem(
                                          value: s,
                                          child: Text('Sem $s')))
                                      .toList(),
                                  onChanged: (v) =>
                                      setState(() => _selectedSemester = v),
                                  validator: (v) =>
                                      v == null ? 'Required' : null,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 36),
                          // Submit Button
                          SizedBox(
                            height: 56,
                            child: FilledButton(
                              onPressed: _isLoading ? null : _submitProfile,
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.accent,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2, color: Colors.white))
                                  : const Text(
                                      'Complete Profile & Explore Events',
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 24),
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

// ─────────────────────────────────────────────
// REUSABLE WIDGETS
// ─────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SectionHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.accentLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.accent, size: 18),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.grey900,
          ),
        ),
      ],
    );
  }
}

class _StyledField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;

  const _StyledField({
    required this.controller,
    required this.label,
    required this.icon,
    this.validator,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20, color: AppColors.grey500),
      ),
    );
  }
}

class _StyledDropdown<T> extends StatelessWidget {
  final String label;
  final IconData icon;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final String? Function(T?)? validator;

  const _StyledDropdown({
    required this.label,
    required this.icon,
    required this.value,
    required this.items,
    required this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: onChanged,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20, color: AppColors.grey500),
      ),
    );
  }
}
