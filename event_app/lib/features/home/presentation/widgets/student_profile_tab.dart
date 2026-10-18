import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/skeleton_loader.dart';
import '../../../../core/widgets/zest_button.dart';

/// Zest Student Profile Tab
/// Displays user info, avatar with edit action, Zest gamification level & badges,
/// college academic details, and account settings.
class StudentProfileTab extends ConsumerStatefulWidget {
  const StudentProfileTab({super.key});

  @override
  ConsumerState<StudentProfileTab> createState() => _StudentProfileTabState();
}

class _StudentProfileTabState extends ConsumerState<StudentProfileTab> {
  Map<String, dynamic>? _profile;
  int _attendedCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    try {
      final results = await Future.wait<dynamic>([
        Supabase.instance.client
            .from('student_profiles')
            .select('*, departments(name)')
            .eq('id', user.id)
            .maybeSingle(),
        Supabase.instance.client
            .from('attendance')
            .select('id')
            .eq('student_id', user.id),
      ]);

      if (mounted) {
        setState(() {
          _profile = results[0] as Map<String, dynamic>?;
          _attendedCount = (results[1] as List).length;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Padding(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          child: Column(
            children: const [
              SizedBox(height: 80),
              SkeletonLoader(width: 88, height: 88, circular: true),
              SizedBox(height: AppSpacing.base),
              SkeletonLoader(width: 160, height: 24),
              SizedBox(height: AppSpacing.xl),
              SkeletonEventCard(),
            ],
          ),
        ),
      );
    }

    final name = _profile?['name']?.toString() ?? 'Student';
    final email = Supabase.instance.client.auth.currentUser?.email ?? '';
    final dept = (_profile?['departments'] != null)
        ? _profile!['departments']['name']?.toString() ?? ''
        : '';
    final prn = _profile?['enrollment_number']?.toString() ?? '';
    final roll = _profile?['roll_number']?.toString() ?? '';
    final year = _profile?['year']?.toString() ?? '';
    final sem = _profile?['semester']?.toString() ?? '';
    final div = _profile?['division']?.toString() ?? '';
    final avatarUrl = _profile?['avatar_url']?.toString();
    final points = _profile?['points'] != null
        ? int.tryParse(_profile!['points'].toString()) ?? 60
        : 60;

    final zestLevel = (points ~/ 50) + 1;
    final pointsIntoLevel = points % 50;
    final levelProgress = pointsIntoLevel / 50.0;

    return RefreshIndicator(
      color: AppColors.coral,
      backgroundColor: AppColors.surface,
      onRefresh: _load,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        slivers: [
          // App Bar with Citrus-Charcoal Gradient
          SliverAppBar(
            expandedHeight: 230,
            pinned: true,
            backgroundColor: AppColors.charcoal,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  Positioned(
                    top: -40,
                    right: -30,
                    child: Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.coral.withValues(alpha: 0.15),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -20,
                    left: -20,
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.mustard.withValues(alpha: 0.15),
                      ),
                    ),
                  ),
                  // Avatar and Name
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () async {
                              await context.push('/student/edit-profile');
                              if (mounted) _load();
                            },
                            child: Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppColors.coral, width: 3),
                                    boxShadow: AppShadows.hero,
                                  ),
                                  child: CircleAvatar(
                                    radius: 46,
                                    backgroundColor: AppColors.mustard,
                                    backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty)
                                        ? NetworkImage(avatarUrl)
                                        : null,
                                    child: (avatarUrl == null || avatarUrl.isEmpty)
                                        ? Text(
                                            name.isNotEmpty ? name[0].toUpperCase() : 'S',
                                            style: GoogleFonts.poppins(
                                              fontSize: 36,
                                              fontWeight: FontWeight.w900,
                                              color: AppColors.white,
                                            ),
                                          )
                                        : null,
                                  ),
                                ),
                                Positioned(
                                  bottom: 2,
                                  right: 2,
                                  child: Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: AppColors.coral,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 2),
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt_rounded,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            name,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          if (prn.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              'PRN: $prn',
                              style: GoogleFonts.poppins(
                                color: Colors.white70,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
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
          ),

          // Content body
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.pagePadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Gamification Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      gradient: AppColors.zestGradient,
                      borderRadius: AppRadius.circularXl2,
                      boxShadow: AppShadows.hero,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Text('🍋', style: TextStyle(fontSize: 24)),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Zest Level $zestLevel Explorer',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    Text(
                                      '$points Total Points',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white.withValues(alpha: 0.85),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.22),
                                borderRadius: AppRadius.circularPill,
                              ),
                              child: Text(
                                '${50 - pointsIntoLevel} pts to L${zestLevel + 1}',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        // Progress bar
                        ClipRRect(
                          borderRadius: AppRadius.circularPill,
                          child: LinearProgressIndicator(
                            value: levelProgress,
                            minHeight: 8,
                            backgroundColor: Colors.white.withValues(alpha: 0.3),
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        const SizedBox(height: 14),
                        // Badges Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _badgeItem('⚡', 'Pioneer'),
                            _badgeItem('🎓', 'Scholar'),
                            _badgeItem('🔥', '3d Streak'),
                            _badgeItem('🎟️', '$_attendedCount Attended'),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Academic Details Section Header
                  Text(
                    'Academic Information 📚',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.charcoal,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  _ZestProfileInfoTile(
                    label: 'Campus Email',
                    value: email,
                    icon: Icons.email_outlined,
                    iconColor: AppColors.coral,
                    iconBg: AppColors.coralLight,
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  if (dept.isNotEmpty) ...[
                    _ZestProfileInfoTile(
                      label: 'Department',
                      value: dept,
                      icon: Icons.school_outlined,
                      iconColor: AppColors.teal,
                      iconBg: AppColors.tealLight,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],

                  if (roll.isNotEmpty) ...[
                    _ZestProfileInfoTile(
                      label: 'Roll Number',
                      value: roll,
                      icon: Icons.badge_outlined,
                      iconColor: AppColors.periwinkle,
                      iconBg: AppColors.periwinkleLight,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],

                  if (year.isNotEmpty || sem.isNotEmpty) ...[
                    _ZestProfileInfoTile(
                      label: 'Year & Semester',
                      value: [
                        if (year.isNotEmpty) '$year${year == '1' ? 'st' : year == '2' ? 'nd' : year == '3' ? 'rd' : 'th'} Year',
                        if (sem.isNotEmpty) 'Semester $sem',
                      ].join(' · '),
                      icon: Icons.calendar_today_outlined,
                      iconColor: AppColors.mustard,
                      iconBg: AppColors.mustardLight,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],

                  if (div.isNotEmpty) ...[
                    _ZestProfileInfoTile(
                      label: 'Division',
                      value: 'Division $div',
                      icon: Icons.group_outlined,
                      iconColor: AppColors.orange,
                      iconBg: const Color(0xFFFFF3E0),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],

                  const SizedBox(height: AppSpacing.lg),

                  // Actions
                  ZestButton(
                    label: 'Edit Profile Information',
                    icon: Icons.edit_rounded,
                    fullWidth: true,
                    onPressed: () async {
                      await context.push('/student/edit-profile');
                      if (mounted) _load();
                    },
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  ZestButton(
                    label: 'Notifications',
                    icon: Icons.notifications_outlined,
                    variant: ZestButtonVariant.secondary,
                    fullWidth: true,
                    onPressed: () => context.push('/notifications'),
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  ZestButton(
                    label: 'Sign Out',
                    icon: Icons.logout_rounded,
                    variant: ZestButtonVariant.danger,
                    fullWidth: true,
                    onPressed: () => _confirmSignOut(context),
                  ),

                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _badgeItem(String emoji, String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: AppRadius.circularPill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            title,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.circularXl2),
        title: Text(
          'Sign Out of Zest?',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        content: Text(
          'You will need to sign back in with your student credentials to view your passes.',
          style: GoogleFonts.poppins(fontSize: 13, color: AppColors.grey600),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: AppColors.grey600, fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: AppRadius.circularPill),
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await Supabase.instance.client.auth.signOut();
              if (context.mounted) context.go('/');
            },
            child: Text(
              'Sign Out',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _ZestProfileInfoTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;

  const _ZestProfileInfoTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.circularLg,
        boxShadow: AppShadows.card,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: AppRadius.circularMd,
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.grey400,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.charcoal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
