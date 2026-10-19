import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/skeleton_loader.dart';
import '../../../../core/widgets/zest_button.dart';
import '../../../../core/widgets/zest_logo.dart';

// ─────────────────────────────────────────────────────────────────────────────
// StudentProfileTab — Zest Student Profile & Settings
// Spec: Centered 104px lime-gradient avatar ring (6px card-colored ring),
//       name 32sp, 3 stat tiles, colored badges row, academic details card,
//       settings card with switch, About card (ink bg, logo 78px, "zest" 24sp).
// ─────────────────────────────────────────────────────────────────────────────

class StudentProfileTab extends ConsumerStatefulWidget {
  const StudentProfileTab({super.key});

  @override
  ConsumerState<StudentProfileTab> createState() => _StudentProfileTabState();
}

class _StudentProfileTabState extends ConsumerState<StudentProfileTab> {
  Map<String, dynamic>? _profile;
  int _attendedCount = 0;
  bool _isLoading = true;
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

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
        backgroundColor: AppColors.ink,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              SkeletonLoader(width: 104, height: 104, circular: true),
              SizedBox(height: 16),
              SkeletonLoader(width: 160, height: 28),
              SizedBox(height: 8),
              SkeletonLoader(width: 220, height: 16),
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
    final avatarUrl = _profile?['avatar_url']?.toString();
    final points = _profile?['points'] != null
        ? int.tryParse(_profile!['points'].toString()) ?? 140
        : 140;
    final zestLevel = (points ~/ 50) + 1;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: AppColors.ink,
        body: RefreshIndicator(
          color: AppColors.ink,
          backgroundColor: AppColors.lime,
          onRefresh: _load,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              // ── 1. Lime Gradient Header with Centered Avatar (Radius 38) ───
              SliverToBoxAdapter(
                child: Container(
                  padding: EdgeInsets.fromLTRB(
                    18,
                    MediaQuery.of(context).padding.top + 20,
                    18,
                    32,
                  ),
                  decoration: const BoxDecoration(
                    gradient: AppColors.limeGradient,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(AppRadius.limeHeader),
                      bottomRight: Radius.circular(AppRadius.limeHeader),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Centered 104px Avatar with Lime Gradient Ring
                      GestureDetector(
                        onTap: () async {
                          HapticFeedback.lightImpact();
                          await context.push('/student/edit-profile');
                          if (mounted) _load();
                        },
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // 104px outer ring container
                            Container(
                              width: 104,
                              height: 104,
                              padding: const EdgeInsets.all(5),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.ink,
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: AppColors.limeGradient,
                                ),
                                child: CircleAvatar(
                                  radius: 44,
                                  backgroundColor: AppColors.ink2,
                                  backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty)
                                      ? NetworkImage(avatarUrl)
                                      : null,
                                  child: (avatarUrl == null || avatarUrl.isEmpty)
                                      ? Text(
                                          name.isNotEmpty ? name[0].toUpperCase() : 'S',
                                          style: AppTextStyles.title32.copyWith(
                                            color: AppColors.lime,
                                          ),
                                        )
                                      : null,
                                ),
                              ),
                            ),
                            // Camera Edit Badge
                            Positioned(
                              bottom: 0,
                              right: 2,
                              child: Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: AppColors.ink,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.lime, width: 2),
                                ),
                                child: const Icon(
                                  Icons.camera_alt_rounded,
                                  size: 15,
                                  color: AppColors.lime,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Name 32sp Bricolage 800
                      Text(
                        name,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.title32.copyWith(
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // PRN / Roll Pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.ink.withValues(alpha: 0.12),
                          borderRadius: AppRadius.circularPill,
                        ),
                        child: Text(
                          prn.isNotEmpty ? 'PRN: $prn' : (roll.isNotEmpty ? 'Roll: $roll' : 'CAMPUS STUDENT'),
                          style: AppTextStyles.metaLabel.copyWith(
                            color: AppColors.ink,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 20)),

              // ── 2. Stat Tiles Row (3 Bento Cards) ──────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Row(
                    children: [
                      // XP / Points
                      Expanded(
                        child: _buildStatTile(
                          title: '$points',
                          subtitle: 'XP Points',
                          emoji: '⚡',
                          accentColor: AppColors.lime,
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Level
                      Expanded(
                        child: _buildStatTile(
                          title: 'Lvl $zestLevel',
                          subtitle: 'Explorer',
                          emoji: '🚀',
                          accentColor: AppColors.aqua,
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Attended
                      Expanded(
                        child: _buildStatTile(
                          title: '$_attendedCount',
                          subtitle: 'Attended',
                          emoji: '🎟️',
                          accentColor: AppColors.coral,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 20)),

              // ── 3. Colored Badges Row ──────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDark,
                      borderRadius: BorderRadius.circular(AppRadius.card),
                      border: Border.all(color: AppColors.borderDark),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Campus Badges 🏅',
                          style: AppTextStyles.title17.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildBadge('⚡', 'Pioneer', AppColors.lime, AppColors.ink),
                            _buildBadge('🎓', 'Scholar', AppColors.aqua, AppColors.ink),
                            _buildBadge('🔥', '3d Streak', AppColors.mustard, AppColors.ink),
                            _buildBadge('🎨', 'Creative', AppColors.lavender, AppColors.ink),
                            _buildBadge('🎪', 'Campus Fan', AppColors.coral, AppColors.white),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 20)),

              // ── 4. Academic Information Card ───────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDark,
                      borderRadius: BorderRadius.circular(AppRadius.card),
                      border: Border.all(color: AppColors.borderDark),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Academic Details 📚',
                          style: AppTextStyles.title17.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                        const SizedBox(height: 14),
                        _buildInfoRow('Email', email, Icons.email_outlined),
                        if (dept.isNotEmpty) ...[
                          const Divider(color: AppColors.borderDark, height: 20),
                          _buildInfoRow('Department', dept, Icons.school_outlined),
                        ],
                        if (roll.isNotEmpty) ...[
                          const Divider(color: AppColors.borderDark, height: 20),
                          _buildInfoRow('Roll Number', roll, Icons.badge_outlined),
                        ],
                        if (year.isNotEmpty || sem.isNotEmpty) ...[
                          const Divider(color: AppColors.borderDark, height: 20),
                          _buildInfoRow(
                            'Year & Sem',
                            [
                              if (year.isNotEmpty) 'Year $year',
                              if (sem.isNotEmpty) 'Sem $sem',
                            ].join(' • '),
                            Icons.calendar_today_outlined,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 20)),

              // ── 5. Settings Card with Custom Switch ────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDark,
                      borderRadius: BorderRadius.circular(AppRadius.card),
                      border: Border.all(color: AppColors.borderDark),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Preferences ⚙️',
                          style: AppTextStyles.title17.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.notifications_active_outlined, color: AppColors.grey400, size: 20),
                                const SizedBox(width: 12),
                                Text(
                                  'Event Notifications',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            Switch.adaptive(
                              value: _notificationsEnabled,
                              activeThumbColor: AppColors.lime,
                              activeTrackColor: AppColors.lime.withValues(alpha: 0.3),
                              inactiveThumbColor: AppColors.grey400,
                              inactiveTrackColor: AppColors.ink3,
                              onChanged: (val) {
                                HapticFeedback.selectionClick();
                                setState(() => _notificationsEnabled = val);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 20)),

              // ── 6. About Card (Ink bg, Logo 78px, "zest" 24sp) ─────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDark,
                      borderRadius: BorderRadius.circular(AppRadius.card),
                      border: Border.all(color: AppColors.borderDark),
                    ),
                    child: Column(
                      children: [
                        // 78px Zest Logo
                        Container(
                          width: 78,
                          height: 78,
                          decoration: BoxDecoration(
                            color: AppColors.ink,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: AppColors.lime.withValues(alpha: 0.4), width: 1.5),
                          ),
                          alignment: Alignment.center,
                          child: const ZestLogo.markSmall(size: 48),
                        ),
                        const SizedBox(height: 12),

                        // Wordmark 24sp Bricolage 800
                        Text(
                          'zest',
                          style: AppTextStyles.title24.copyWith(
                            color: AppColors.lime,
                            letterSpacing: -1.0,
                          ),
                        ),
                        const SizedBox(height: 4),

                        Text(
                          'v1.0.0 • Campus Edition',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.grey400,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),

                        Text(
                          'Add some zest to your campus life.',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.grey400,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // ── 7. Profile Actions ─────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Column(
                    children: [
                      ZestButton(
                        label: 'Edit Profile Information',
                        icon: Icons.edit_rounded,
                        fullWidth: true,
                        onPressed: () async {
                          HapticFeedback.lightImpact();
                          await context.push('/student/edit-profile');
                          if (mounted) _load();
                        },
                      ),
                      const SizedBox(height: 10),
                      ZestButton(
                        label: 'Sign Out',
                        icon: Icons.logout_rounded,
                        variant: ZestButtonVariant.danger,
                        fullWidth: true,
                        onPressed: () => _confirmSignOut(context),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatTile({
    required String title,
    required String subtitle,
    required String emoji,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 6),
          Text(
            title,
            style: AppTextStyles.title20.copyWith(
              color: accentColor,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.grey400,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String emoji, String title, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppRadius.circularPill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 6),
          Text(
            title,
            style: AppTextStyles.caption.copyWith(
              color: textColor,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.grey400),
        const SizedBox(width: 10),
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.grey400,
            fontSize: 13,
          ),
        ),
        const Spacer(),
        Expanded(
          flex: 2,
          child: Text(
            value,
            textAlign: TextAlign.end,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final router = GoRouter.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Sign Out?',
          style: AppTextStyles.title20.copyWith(color: AppColors.white),
        ),
        content: Text(
          'Are you sure you want to sign out of your Zest student account?',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey400),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Cancel',
              style: AppTextStyles.caption.copyWith(color: AppColors.grey400),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.coral,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(borderRadius: AppRadius.circularPill),
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await Supabase.instance.client.auth.signOut();
      if (mounted) {
        router.go('/login');
      }
    }
  }
}
