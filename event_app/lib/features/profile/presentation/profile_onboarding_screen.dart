import 'dart:typed_data';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/theme.dart';
import '../../../shared/widgets/shared_widgets.dart';

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
  int? _existingPoints;
  final ImagePicker _picker = ImagePicker();


  bool _isLoading = true;
  bool _isSaving = false;
  bool _isSuccess = false;

  late final ConfettiController _confettiController;
  List<Map<String, dynamic>> _departments = [];

  static const List<String> _years = ['1', '2', '3', '4'];
  static const List<String> _semesters = ['1', '2', '3', '4', '5', '6', '7', '8'];
  static const List<String> _divisions = ['A', 'B', 'C', 'D', 'E', 'F'];

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 1));
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
              final pts = profileRes['points'] != null
                  ? int.tryParse(profileRes['points'].toString())
                  : null;
              // Reset unearned legacy 60 default points to 0
              _existingPoints = (pts == 60) ? 0 : pts;
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
    _confettiController.dispose();
    _nameController.dispose();
    _rollController.dispose();
    _prnController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) {
      ZestSnack.error(context, 'Please enter your full name to continue.');
      return;
    }

    setState(() => _isSaving = true);
    try {
      final user = Supabase.instance.client.auth.currentUser!;
      String? resolvedAvatarUrl = _existingAvatarUrl;
      if (_avatarBytes != null) {
        final uploaded = await _uploadAvatar();
        if (uploaded != null) resolvedAvatarUrl = uploaded;
      }

      final updateData = <String, dynamic>{
        'id': user.id,
        'name': _nameController.text.trim(),
        'points': _existingPoints ?? 0,
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
        setState(() => _isSuccess = true);
        _confettiController.play();
        ZestSnack.success(context, 'Profile saved! 🎉 Welcome to ZEST.');

        await Future.delayed(const Duration(milliseconds: 1100));
        if (mounted) {
          if (widget.isEditing) {
            context.pop();
          } else {
            context.go('/student/home');
          }
        }
      }
    } catch (error) {
      if (mounted) {
        ZestSnack.error(context, error.toString());
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _openDepartmentPicker() {
    String searchQuery = '';

    ZestBottomSheet.show(
      context: context,
      title: 'Select Department',
      child: StatefulBuilder(
        builder: (context, setSheetState) {
          final filtered = _departments.where((d) {
            final name = (d['name'] ?? '').toString().toLowerCase();
            return name.contains(searchQuery.toLowerCase());
          }).toList();

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ZestTextField(
                  hintText: 'Search departments...',
                  prefixIcon: const Icon(Icons.search_rounded, size: 20, color: ZestTokens.ink3),
                  onChanged: (val) {
                    setSheetState(() => searchQuery = val);
                  },
                ),
                const SizedBox(height: 12),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 300),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: filtered.length,
                    separatorBuilder: (context, index) => const Divider(color: ZestTokens.line, height: 1),

                    itemBuilder: (context, index) {
                      final dept = filtered[index];
                      final isSelected = dept['id'].toString() == _selectedDepartmentId;

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                        title: Text(
                          dept['name'] ?? '',
                          style: ZestTokens.body.copyWith(
                            color: isSelected ? ZestTokens.blue : ZestTokens.ink,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check_circle_rounded, color: ZestTokens.blue, size: 20)
                            : null,
                        onTap: () {
                          setState(() {
                            _selectedDepartmentId = dept['id'].toString();
                          });
                          Navigator.of(context).pop();
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  String _getDepartmentName() {
    if (_selectedDepartmentId == null) return 'Choose Department';
    final found = _departments.firstWhere(
      (d) => d['id'].toString() == _selectedDepartmentId,
      orElse: () => {'name': 'Choose Department'},
    );
    return found['name'] ?? 'Choose Department';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZestTokens.page,
      appBar: AppBar(
        leading: widget.isEditing
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                onPressed: () => context.pop(),
              )
            : const Padding(
                padding: EdgeInsets.only(left: 18),
                child: Center(child: ZestBlobLogo(size: 32)),
              ),
        title: Text(
          widget.isEditing ? 'Edit Profile' : 'Student Profile',
          style: ZestTokens.title.copyWith(fontSize: 20),
        ),
        actions: [
          if (!widget.isEditing)
            TextButton(
              onPressed: () => context.go('/student/home'),
              child: Text(
                'Skip',
                style: ZestTokens.caption.copyWith(
                  color: ZestTokens.ink3,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          if (_isLoading)
            const Center(
              child: ZestMascot(size: 70, mood: MascotMood.idle),
            )
          else
            Column(
              children: [
                // Visual progress dots at top: Photo · Details · Academics
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildStepDot('1', 'Photo', true),
                      _buildStepLine(),
                      _buildStepDot('2', 'Details', _nameController.text.isNotEmpty),
                      _buildStepLine(),
                      _buildStepDot('3', 'Academics', _selectedDepartmentId != null),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 1. Photo Card
                        ZestCard(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: _pickImage,
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Container(
                                      width: 84,
                                      height: 84,
                                      padding: const EdgeInsets.all(3),
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: ZestTokens.brandGradient,
                                      ),
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white,
                                        ),
                                        child: ClipOval(
                                          child: _avatarBytes != null
                                              ? Image.memory(
                                                  _avatarBytes!,
                                                  fit: BoxFit.cover,
                                                  width: 76,
                                                  height: 76,
                                                )
                                              : (_existingAvatarUrl != null && _existingAvatarUrl!.isNotEmpty)
                                                  ? Image.network(
                                                      _existingAvatarUrl!,
                                                      fit: BoxFit.cover,
                                                      width: 76,
                                                      height: 76,
                                                      errorBuilder: (context, error, stackTrace) => _buildAvatarPlaceholder(),

                                                    )
                                                  : _buildAvatarPlaceholder(),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      right: 0,
                                      bottom: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: ZestTokens.brandGradient,
                                        ),
                                        child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 14),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 18),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.isEditing ? 'Profile Photo' : 'Add your photo',
                                      style: ZestTokens.section.copyWith(fontSize: 17),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Displayed on your passes and campus leaderboard.',
                                      style: ZestTokens.caption.copyWith(color: ZestTokens.ink2),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 18),

                        // 2. Personal Details Card
                        ZestCard(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Personal Details', style: ZestTokens.section.copyWith(fontSize: 17)),
                              const SizedBox(height: 16),
                              ZestTextField(
                                controller: _nameController,
                                label: 'FULL NAME *',
                                hintText: 'Aarav Sharma',
                                prefixIcon: const Icon(Icons.person_outline_rounded, color: ZestTokens.ink3, size: 20),
                              ),
                              const SizedBox(height: 14),
                              ZestTextField(
                                controller: _phoneController,
                                label: 'PHONE NUMBER',
                                hintText: '+91 98765 43210',
                                keyboardType: TextInputType.phone,
                                prefixIcon: const Icon(Icons.phone_outlined, color: ZestTokens.ink3, size: 20),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 18),

                        // 3. Academic Details Card
                        ZestCard(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Academic Information', style: ZestTokens.section.copyWith(fontSize: 17)),
                              const SizedBox(height: 16),

                              // Roll Number & PRN row
                              Row(
                                children: [
                                  Expanded(
                                    child: ZestTextField(
                                      controller: _rollController,
                                      label: 'ROLL NUMBER',
                                      hintText: '22BCS1048',
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ZestTextField(
                                      controller: _prnController,
                                      label: 'PRN / ENROLLMENT',
                                      hintText: '1032220489',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Department picker button
                              Text('DEPARTMENT', style: ZestTokens.caption.copyWith(fontWeight: FontWeight.w600, color: ZestTokens.ink)),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: _openDepartmentPicker,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                                  decoration: BoxDecoration(
                                    color: ZestTokens.fill,
                                    borderRadius: ZestTokens.borderInput,
                                    border: Border.all(color: ZestTokens.line),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          _getDepartmentName(),
                                          style: ZestTokens.body.copyWith(
                                            color: _selectedDepartmentId != null ? ZestTokens.ink : ZestTokens.ink3,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const Icon(Icons.keyboard_arrow_down_rounded, color: ZestTokens.ink3),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Year pill grid
                              Text('YEAR', style: ZestTokens.caption.copyWith(fontWeight: FontWeight.w600, color: ZestTokens.ink)),
                              const SizedBox(height: 8),
                              Row(
                                children: _years.map((y) {
                                  final isSelected = _selectedYear == y;
                                  return Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 6.0),
                                      child: _buildSelectPill(
                                        y,
                                        isSelected,
                                        () => setState(() => _selectedYear = y),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 16),

                              // Semester pill grid
                              Text('SEMESTER', style: ZestTokens.caption.copyWith(fontWeight: FontWeight.w600, color: ZestTokens.ink)),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _semesters.map((s) {
                                  final isSelected = _selectedSemester == s;
                                  return SizedBox(
                                    width: 44,
                                    child: _buildSelectPill(
                                      s,
                                      isSelected,
                                      () => setState(() => _selectedSemester = s),
                                    ),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 16),

                              // Division pill grid
                              Text('DIVISION', style: ZestTokens.caption.copyWith(fontWeight: FontWeight.w600, color: ZestTokens.ink)),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _divisions.map((d) {
                                  final isSelected = _selectedDivision == d;
                                  return SizedBox(
                                    width: 44,
                                    child: _buildSelectPill(
                                      d,
                                      isSelected,
                                      () => setState(() => _selectedDivision = d),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Sticky Bottom Action Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(top: BorderSide(color: ZestTokens.line)),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x0A0B1220),
                        blurRadius: 16,
                        offset: Offset(0, -4),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: ZestButton(
                      text: widget.isEditing
                          ? 'Save Profile Changes'
                          : 'Save profile & enter ZEST ⚡',
                      fullWidth: true,
                      isLoading: _isSaving,
                      isSuccess: _isSuccess,
                      onPressed: _save,
                    ),
                  ),
                ),
              ],
            ),

          // Confetti celebration widget
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                ZestTokens.sky,
                ZestTokens.core,
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

  Widget _buildAvatarPlaceholder() {
    return Container(
      width: 76,
      height: 76,
      color: const Color(0xFFE6F4FE),
      child: const Center(
        child: Icon(Icons.person_rounded, size: 40, color: ZestTokens.blue),
      ),
    );
  }

  Widget _buildStepDot(String num, String label, bool isDone) {
    return Row(
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDone ? ZestTokens.blue : ZestTokens.line,
          ),
          child: Center(
            child: Text(
              num,
              style: TextStyle(
                color: isDone ? Colors.white : ZestTokens.ink3,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: ZestTokens.caption.copyWith(
            fontWeight: isDone ? FontWeight.w600 : FontWeight.w500,
            color: isDone ? ZestTokens.ink : ZestTokens.ink3,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine() {
    return Container(
      width: 20,
      height: 1.5,
      color: ZestTokens.line,
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  Widget _buildSelectPill(String text, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: isSelected ? null : ZestTokens.fill,
          gradient: isSelected ? ZestTokens.brandGradient : null,
          borderRadius: ZestTokens.borderPill,
          border: isSelected ? null : Border.all(color: ZestTokens.line),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: isSelected ? Colors.white : ZestTokens.ink,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
