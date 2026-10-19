import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/zest_tokens.dart';
import '../../../../shared/widgets/shared_widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// StudentProfileTab — Zest Student Profile & Settings
// Minimal, simple, modern, light UI matching Designjoy aesthetic.
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
        backgroundColor: ZestTokens.page,
        body: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ZestSkeleton(width: 104, height: 104, circular: true),
              SizedBox(height: 16),
              ZestSkeleton(width: 160, height: 28),
              SizedBox(height: 8),
              ZestSkeleton(width: 220, height: 16),
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
    final rawPoints = _profile?['points'] != null
        ? int.tryParse(_profile!['points'].toString()) ?? 0
        : 0;
    // Fix legacy default 60 points if user has never attended an event
    final points = (rawPoints == 60 && _attendedCount == 0) ? 0 : rawPoints;
    final zestLevel = (points ~/ 50) + 1;


    return Scaffold(
      backgroundColor: ZestTokens.page,
      body: RefreshIndicator(
        color: ZestTokens.blue,
        backgroundColor: Colors.white,
        onRefresh: _load,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            // Safe area top
            SliverToBoxAdapter(
              child: SizedBox(
                height: MediaQuery.of(context).padding.top + 20,
              ),
            ),

            // ── 1. Centered Profile Header ─────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: ZestTokens.horizontalPadding,
                ),
                child: Column(
                  children: [
                    // Centered 104px Avatar with Brand Gradient Ring
                    GestureDetector(
                      onTap: () async {
                        HapticFeedback.lightImpact();
                        await context.push('/student/edit-profile');
                        if (mounted) _load();
                      },
                      child: ZestAvatar(
                        imageUrl: avatarUrl,
                        name: name,
                        size: 104,
                        isEditable: true,
                        onCameraTap: () async {
                          HapticFeedback.lightImpact();
                          await context.push('/student/edit-profile');
                          if (mounted) _load();
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Name
                    Text(
                      name,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: ZestTokens.display.copyWith(
                        fontSize: 26,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // PRN / Roll Pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: ZestTokens.borderPill,
                        border: Border.all(color: ZestTokens.line),
                      ),
                      child: Text(
                        prn.isNotEmpty
                            ? 'PRN: $prn'
                            : (roll.isNotEmpty ? 'Roll: $roll' : 'CAMPUS STUDENT'),
                        style: ZestTokens.labelCaps.copyWith(
                          color: ZestTokens.ink2,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // ── 2. Stat Tiles Row (3 Bento Cards) ──────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: ZestTokens.horizontalPadding,
                ),
                child: Row(
                  children: [
                    // XP Points
                    Expanded(
                      child: _buildStatTile(
                        title: '$points',
                        subtitle: 'XP Points',
                        emoji: '⚡',
                        accentColor: ZestTokens.blue,
                        bgTint: const Color(0xFFE8F6FE),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Level
                    Expanded(
                      child: _buildStatTile(
                        title: 'Lvl $zestLevel',
                        subtitle: _getLevelTitle(zestLevel),
                        emoji: _getLevelEmoji(zestLevel),
                        accentColor: const Color(0xFFB45309),
                        bgTint: const Color(0xFFFEF3C7),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Attended
                    Expanded(
                      child: _buildStatTile(
                        title: '$_attendedCount',
                        subtitle: 'Attended',
                        emoji: '🎟️',
                        accentColor: const Color(0xFF047857),
                        bgTint: const Color(0xFFD1FAE5),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: ZestTokens.horizontalPadding,
                ),
                child: ZestCard(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text('🏅', style: TextStyle(fontSize: 18)),
                          const SizedBox(width: 8),
                          Text(
                            'Earned Badges',
                            style: ZestTokens.section.copyWith(fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildBadge('🌱', 'Campus Fresher', const Color(0xFFE8F6FE), ZestTokens.blue),
                          if (_attendedCount >= 1)
                            _buildBadge('🎟️', 'First Check-in', const Color(0xFFD1FAE5), const Color(0xFF047857)),
                          if (points >= 50)
                            _buildBadge('🚀', 'Explorer', const Color(0xFFFEF3C7), const Color(0xFFB45309)),
                          if (points >= 100)
                            _buildBadge('⚡', 'Trailblazer', const Color(0xFFEFF6FF), const Color(0xFF1D4ED8)),
                          if (_attendedCount >= 3)
                            _buildBadge('🎪', 'Campus Fan', const Color(0xFFFFF1F2), const Color(0xFFBE123C)),
                          if (_attendedCount == 0 && points < 50)
                            _buildBadge('🎯', 'Check in at events to earn XP & badges', const Color(0xFFF1F5F9), ZestTokens.ink3),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // ── 4. Academic Information Card ───────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: ZestTokens.horizontalPadding,
                ),
                child: ZestCard(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text('📚', style: TextStyle(fontSize: 18)),
                          const SizedBox(width: 8),
                          Text(
                            'Academic Details',
                            style: ZestTokens.section.copyWith(fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _buildInfoRow('Email', email, LucideIcons.mail),
                      if (dept.isNotEmpty) ...[
                        const Divider(color: ZestTokens.line, height: 20),
                        _buildInfoRow('Department', dept, LucideIcons.graduationCap),
                      ],
                      if (roll.isNotEmpty) ...[
                        const Divider(color: ZestTokens.line, height: 20),
                        _buildInfoRow('Roll Number', roll, LucideIcons.badgeCheck),
                      ],
                      if (year.isNotEmpty || sem.isNotEmpty) ...[
                        const Divider(color: ZestTokens.line, height: 20),
                        _buildInfoRow(
                          'Year & Sem',
                          [
                            if (year.isNotEmpty) 'Year $year',
                            if (sem.isNotEmpty) 'Sem $sem',
                          ].join(' • '),
                          LucideIcons.calendar,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // ── 5. Settings Card ───────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: ZestTokens.horizontalPadding,
                ),
                child: ZestCard(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text('⚙️', style: TextStyle(fontSize: 18)),
                          const SizedBox(width: 8),
                          Text(
                            'Preferences',
                            style: ZestTokens.section.copyWith(fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                LucideIcons.bellRing,
                                color: ZestTokens.ink2,
                                size: 19,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Event Notifications',
                                style: ZestTokens.bodyBold.copyWith(
                                  fontSize: 14.5,
                                ),
                              ),
                            ],
                          ),
                          Switch.adaptive(
                            value: _notificationsEnabled,
                            activeTrackColor: ZestTokens.blue,
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

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // ── 6. About Card ──────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: ZestTokens.horizontalPadding,
                ),
                child: ZestCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const ZestBlobLogo(size: 78),
                      const SizedBox(height: 12),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'zest',
                              style: ZestTokens.accentItalic.copyWith(
                                fontSize: 32,
                                color: ZestTokens.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'v1.0.0 • Campus Edition',
                        style: ZestTokens.caption.copyWith(
                          color: ZestTokens.ink3,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Add some zest to your campus life.',
                        style: ZestTokens.caption.copyWith(
                          color: ZestTokens.ink2,
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
                padding: const EdgeInsets.symmetric(
                  horizontal: ZestTokens.horizontalPadding,
                ),
                child: Column(
                  children: [
                    ZestButton(
                      text: 'Edit Profile Information',
                      variant: ZestButtonVariant.secondary,
                      prefixIcon: LucideIcons.userCheck,
                      fullWidth: true,
                      onPressed: () async {
                        HapticFeedback.lightImpact();
                        await context.push('/student/edit-profile');
                        if (mounted) _load();
                      },
                    ),
                    const SizedBox(height: 10),
                    ZestButton(
                      text: 'Sign Out',
                      variant: ZestButtonVariant.danger,
                      prefixIcon: LucideIcons.logOut,
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
    );
  }

  Widget _buildStatTile({
    required String title,
    required String subtitle,
    required String emoji,
    required Color accentColor,
    required Color bgTint,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: ZestTokens.borderCard,
        border: Border.all(color: ZestTokens.line),
        boxShadow: ZestTokens.cardShadow,
      ),
      child: Column(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: bgTint,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(emoji, style: const TextStyle(fontSize: 18)),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: ZestTokens.title.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: accentColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: ZestTokens.caption.copyWith(
              color: ZestTokens.ink3,
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
        borderRadius: ZestTokens.borderPill,
        border: Border.all(color: textColor.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 5),
          Text(
            title,
            style: ZestTokens.caption.copyWith(
              color: textColor,
              fontWeight: FontWeight.w700,
              fontSize: 11.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: ZestTokens.ink3),
        const SizedBox(width: 10),
        Text(
          label,
          style: ZestTokens.body.copyWith(
            color: ZestTokens.ink2,
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
            style: ZestTokens.bodyBold.copyWith(
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  String _getLevelTitle(int level) {
    if (level <= 1) return 'Fresher';
    if (level == 2) return 'Explorer';
    if (level == 3) return 'Trailblazer';
    if (level == 4) return 'Champion';
    return 'Campus Legend';
  }

  String _getLevelEmoji(int level) {
    if (level <= 1) return '🌱';
    if (level == 2) return '🚀';
    if (level == 3) return '⚡';
    if (level == 4) return '🏆';
    return '👑';
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final router = GoRouter.of(context);
    final confirmed = await ZestDialog.show<bool>(
      context,
      title: 'Sign Out?',
      message: 'Are you sure you want to sign out of your Zest student account?',
      confirmText: 'Sign Out',
      cancelText: 'Cancel',
      isDestructive: true,
      mascotMood: ZestMascotMood.sleepy,
    );

    if (confirmed == true && mounted) {
      await Supabase.instance.client.auth.signOut();
      if (mounted) {
        router.go('/login');
      }
    }
  }
}
