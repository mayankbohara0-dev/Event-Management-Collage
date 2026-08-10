import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../admin_colors.dart';

class UsersScreen extends ConsumerStatefulWidget {
  const UsersScreen({super.key});

  @override
  ConsumerState<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends ConsumerState<UsersScreen> {
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _filtered = [];
  bool _isLoading = true;
  String _search = '';
  String _filterStatus = 'All';
  final _searchController = TextEditingController();

  static const _statusFilters = ['All', 'Active', 'Blocked', 'Banned', 'Reported'];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      final res = await Supabase.instance.client
          .from('student_profiles')
          .select('*, departments(name)')
          .order('created_at', ascending: false);
      if (mounted) {
        setState(() {
          _users = List<Map<String, dynamic>>.from(res);
          _applyFilters();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading users: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    List<Map<String, dynamic>> result = List.from(_users);

    // Status filter
    if (_filterStatus == 'Blocked') {
      result = result.where((u) => u['is_blocked'] == true).toList();
    } else if (_filterStatus == 'Banned') {
      result = result.where((u) => u['is_banned'] == true).toList();
    } else if (_filterStatus == 'Reported') {
      result = result.where((u) => (u['report_count'] ?? 0) > 0).toList();
    } else if (_filterStatus == 'Active') {
      result = result.where((u) => u['is_blocked'] != true && u['is_banned'] != true).toList();
    }

    // Search filter
    if (_search.isNotEmpty) {
      final q = _search.toLowerCase();
      result = result.where((u) {
        final name = (u['name'] ?? '').toString().toLowerCase();
        final roll = (u['roll_number'] ?? '').toString().toLowerCase();
        final enrollment = (u['enrollment_number'] ?? '').toString().toLowerCase();
        return name.contains(q) || roll.contains(q) || enrollment.contains(q);
      }).toList();
    }

    _filtered = result;
  }

  Future<void> _toggleBlock(Map<String, dynamic> user) async {
    final id = user['id'];
    final current = user['is_blocked'] == true;
    final action = current ? 'Unblock' : 'Block';

    final confirm = await _showConfirmDialog(
      title: '$action User',
      message: current
          ? 'This will restore the user\'s access to the app.'
          : 'This will prevent the user from logging in. You can unblock them later.',
      confirmLabel: action,
      confirmColor: current ? AdminColors.success : AdminColors.warning,
    );
    if (confirm != true) return;

    try {
      await Supabase.instance.client
          .from('student_profiles')
          .update({'is_blocked': !current})
          .eq('id', id);
      await _loadUsers();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('User ${current ? 'unblocked' : 'blocked'} successfully'),
          backgroundColor: current ? AdminColors.success : AdminColors.warning,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AdminColors.error,
        ));
      }
    }
  }

  Future<void> _toggleBan(Map<String, dynamic> user) async {
    final id = user['id'];
    final current = user['is_banned'] == true;
    final action = current ? 'Unban' : 'Ban';

    final confirm = await _showConfirmDialog(
      title: '$action User',
      message: current
          ? 'This will restore the user\'s account. They will be able to log in again.'
          : 'This will permanently ban the user. This is a serious action.',
      confirmLabel: action,
      confirmColor: current ? AdminColors.success : AdminColors.error,
    );
    if (confirm != true) return;

    try {
      await Supabase.instance.client
          .from('student_profiles')
          .update({'is_banned': !current})
          .eq('id', id);
      await _loadUsers();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('User ${current ? 'unbanned' : 'banned'}'),
          backgroundColor: current ? AdminColors.success : AdminColors.error,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AdminColors.error,
        ));
      }
    }
  }

  Future<void> _reportUser(Map<String, dynamic> user) async {
    final id = user['id'];
    final currentCount = (user['report_count'] ?? 0) as int;

    if (currentCount >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('User already has 3 strikes and is auto-blocked.'),
        backgroundColor: AdminColors.warning,
      ));
      return;
    }

    // Pick a reason
    final reason = await _showReportReasonDialog();
    if (reason == null) return;

    final newCount = currentCount + 1;
    final shouldAutoBlock = newCount >= 3;

    try {
      await Supabase.instance.client.from('student_profiles').update({
        'report_count': newCount,
        'report_reasons': [...(user['report_reasons'] ?? []), reason],
        if (shouldAutoBlock) 'is_blocked': true,
      }).eq('id', id);

      await _loadUsers();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            shouldAutoBlock
                ? 'Strike $newCount/3 added — user auto-blocked!'
                : 'Strike $newCount/3 added for: $reason',
          ),
          backgroundColor: shouldAutoBlock ? AdminColors.error : AdminColors.warning,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AdminColors.error,
        ));
      }
    }
  }

  Future<bool?> _showConfirmDialog({
    required String title,
    required String message,
    required String confirmLabel,
    required Color confirmColor,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AdminColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: const TextStyle(color: AdminColors.textPrimary, fontWeight: FontWeight.w700)),
        content: Text(message, style: const TextStyle(color: AdminColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel', style: TextStyle(color: AdminColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
  }

  Future<String?> _showReportReasonDialog() {
    const reasons = [
      'Inappropriate behaviour',
      'Fake / fraudulent profile',
      'Harassment or bullying',
      'Spam or abuse',
      'Academic misconduct',
    ];
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AdminColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Select Report Reason', style: TextStyle(color: AdminColors.textPrimary, fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: reasons.map((r) => ListTile(
            onTap: () => Navigator.of(ctx).pop(r),
            title: Text(r, style: const TextStyle(color: AdminColors.textPrimary, fontSize: 14)),
            leading: const Icon(Icons.warning_amber_rounded, color: AdminColors.warning, size: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          )).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(null),
            child: const Text('Cancel', style: TextStyle(color: AdminColors.textSecondary)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminColors.bg,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          _buildSearchAndFilter(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AdminColors.accent))
                : _filtered.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadUsers,
                        color: AdminColors.accent,
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                          itemCount: _filtered.length,
                          itemBuilder: (_, i) => _UserCard(
                            user: _filtered[i],
                            onBlock: () => _toggleBlock(_filtered[i]),
                            onBan: () => _toggleBan(_filtered[i]),
                            onReport: () => _reportUser(_filtered[i]),
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      decoration: const BoxDecoration(
        color: AdminColors.sidebar,
        border: Border(bottom: BorderSide(color: AdminColors.border)),
      ),
      child: Row(
        children: [
          const Icon(Icons.manage_accounts_rounded, color: AdminColors.accent, size: 28),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('User Management',
                  style: GoogleFonts.inter(color: AdminColors.textPrimary, fontSize: 22, fontWeight: FontWeight.w800)),
              Text('${_users.length} total users',
                  style: GoogleFonts.inter(color: AdminColors.textSecondary, fontSize: 13)),
            ],
          ),
          const Spacer(),
          IconButton(
            onPressed: _loadUsers,
            icon: const Icon(Icons.refresh_rounded, color: AdminColors.textSecondary),
            tooltip: 'Refresh',
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      color: AdminColors.sidebar,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        children: [
          // Search bar
          TextField(
            controller: _searchController,
            onChanged: (q) => setState(() {
              _search = q;
              _applyFilters();
            }),
            style: const TextStyle(color: AdminColors.textPrimary, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Search by name, roll number or enrollment number...',
              hintStyle: const TextStyle(color: AdminColors.textSecondary, fontSize: 13),
              prefixIcon: const Icon(Icons.search_rounded, color: AdminColors.textSecondary, size: 20),
              suffixIcon: _search.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, color: AdminColors.textSecondary, size: 18),
                      onPressed: () => setState(() {
                        _searchController.clear();
                        _search = '';
                        _applyFilters();
                      }),
                    )
                  : null,
              filled: true,
              fillColor: AdminColors.surfaceLight,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AdminColors.border)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AdminColors.border)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AdminColors.accent, width: 1.5)),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
          const SizedBox(height: 10),
          // Filter chips
          SizedBox(
            height: 34,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _statusFilters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final f = _statusFilters[i];
                final selected = _filterStatus == f;
                return GestureDetector(
                  onTap: () => setState(() {
                    _filterStatus = f;
                    _applyFilters();
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: selected ? AdminColors.accent : AdminColors.surfaceLight,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: selected ? AdminColors.accent : AdminColors.border),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      f,
                      style: GoogleFonts.inter(
                        color: selected ? Colors.white : AdminColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.people_outline_rounded, size: 64, color: AdminColors.border),
          const SizedBox(height: 16),
          Text('No users found', style: GoogleFonts.inter(color: AdminColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text('Try adjusting your search or filter', style: GoogleFonts.inter(color: AdminColors.textSecondary, fontSize: 13)),
        ],
      ),
    );
  }
}

// ── USER CARD ─────────────────────────────────────────────────────────────
class _UserCard extends StatelessWidget {
  final Map<String, dynamic> user;
  final VoidCallback onBlock;
  final VoidCallback onBan;
  final VoidCallback onReport;

  const _UserCard({
    required this.user,
    required this.onBlock,
    required this.onBan,
    required this.onReport,
  });

  @override
  Widget build(BuildContext context) {
    final name = user['name']?.toString() ?? 'Unknown';
    final roll = user['roll_number']?.toString() ?? '';
    final enrollment = user['enrollment_number']?.toString() ?? '';
    final dept = user['departments']?['name']?.toString() ?? '';
    final year = user['year']?.toString() ?? '';
    final avatarUrl = user['avatar_url']?.toString();
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    final isBlocked = user['is_blocked'] == true;
    final isBanned = user['is_banned'] == true;
    final reportCount = (user['report_count'] ?? 0) as int;
    final reportReasons = List<String>.from(user['report_reasons'] ?? []);

    final createdAt = user['created_at'] != null
        ? DateTime.tryParse(user['created_at'].toString())
        : null;
    final joined = createdAt != null
        ? '${_month(createdAt.month)} ${createdAt.day}, ${createdAt.year}'
        : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AdminColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isBanned
              ? AdminColors.error.withValues(alpha: 0.5)
              : isBlocked
                  ? AdminColors.warning.withValues(alpha: 0.5)
                  : AdminColors.border,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top row: avatar + info + status badges ──
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AdminColors.accent.withValues(alpha: 0.15),
                  backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                      ? NetworkImage(avatarUrl)
                      : null,
                  child: avatarUrl == null || avatarUrl.isEmpty
                      ? Text(initial, style: const TextStyle(color: AdminColors.accent, fontWeight: FontWeight.w800, fontSize: 18))
                      : null,
                ),
                const SizedBox(width: 12),
                // Name + details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(name,
                                style: GoogleFonts.inter(
                                    color: AdminColors.textPrimary,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700)),
                          ),
                          // Status badges
                          if (isBanned)
                            _Badge(label: 'BANNED', color: AdminColors.error)
                          else if (isBlocked)
                            _Badge(label: 'BLOCKED', color: AdminColors.warning)
                          else
                            _Badge(label: 'ACTIVE', color: AdminColors.success),
                          if (reportCount > 0) ...[
                            const SizedBox(width: 6),
                            _StrikeBadge(count: reportCount),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 12,
                        runSpacing: 2,
                        children: [
                          if (roll.isNotEmpty)
                            _InfoChip(icon: Icons.badge_outlined, text: roll),
                          if (enrollment.isNotEmpty)
                            _InfoChip(icon: Icons.numbers_rounded, text: enrollment),
                          if (dept.isNotEmpty)
                            _InfoChip(icon: Icons.school_outlined, text: dept),
                          if (year.isNotEmpty)
                            _InfoChip(icon: Icons.calendar_today_outlined, text: 'Year $year'),
                          if (joined.isNotEmpty)
                            _InfoChip(icon: Icons.access_time_rounded, text: 'Joined $joined'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // ── Report reasons (if any) ──
            if (reportReasons.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AdminColors.warning.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AdminColors.warning.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: AdminColors.warning, size: 14),
                        const SizedBox(width: 6),
                        Text('$reportCount/3 strikes',
                            style: GoogleFonts.inter(color: AdminColors.warning, fontSize: 12, fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Strike dots
                    Row(
                      children: List.generate(3, (i) => Container(
                        margin: const EdgeInsets.only(right: 6),
                        width: 10, height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i < reportCount ? AdminColors.warning : AdminColors.border,
                        ),
                      )),
                    ),
                    const SizedBox(height: 6),
                    ...reportReasons.map((r) => Text('• $r',
                        style: GoogleFonts.inter(color: AdminColors.textSecondary, fontSize: 12))),
                  ],
                ),
              ),
            ],

            // ── Action buttons ──
            const SizedBox(height: 12),
            Row(
              children: [
                // Block / Unblock
                Expanded(
                  child: _ActionButton(
                    label: isBlocked ? 'Unblock' : 'Block',
                    icon: isBlocked ? Icons.lock_open_rounded : Icons.block_rounded,
                    color: isBlocked ? AdminColors.success : AdminColors.warning,
                    onTap: onBlock,
                  ),
                ),
                const SizedBox(width: 8),
                // Ban / Unban
                Expanded(
                  child: _ActionButton(
                    label: isBanned ? 'Unban' : 'Ban',
                    icon: isBanned ? Icons.check_circle_outline_rounded : Icons.gavel_rounded,
                    color: isBanned ? AdminColors.success : AdminColors.error,
                    onTap: onBan,
                  ),
                ),
                const SizedBox(width: 8),
                // Report / Strike
                Expanded(
                  child: _ActionButton(
                    label: 'Report ($reportCount/3)',
                    icon: Icons.flag_rounded,
                    color: reportCount >= 3 ? AdminColors.textSecondary : AdminColors.accent,
                    onTap: reportCount >= 3 ? null : onReport,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _month(int m) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return months[m - 1];
  }
}

// ── SMALL WIDGETS ──────────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(label, style: GoogleFonts.inter(color: color, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
    );
  }
}

class _StrikeBadge extends StatelessWidget {
  final int count;
  const _StrikeBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    final color = count >= 3 ? AdminColors.error : AdminColors.warning;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.warning_rounded, color: color, size: 11),
          const SizedBox(width: 3),
          Text('$count/3', style: GoogleFonts.inter(color: color, fontSize: 10, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AdminColors.textSecondary),
        const SizedBox(width: 4),
        Text(text, style: GoogleFonts.inter(color: AdminColors.textSecondary, fontSize: 12)),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  const _ActionButton({required this.label, required this.icon, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: disabled ? AdminColors.surfaceLight : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: disabled ? AdminColors.border : color.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: disabled ? AdminColors.textSecondary : color, size: 14),
            const SizedBox(width: 5),
            Text(
              label,
              style: GoogleFonts.inter(
                color: disabled ? AdminColors.textSecondary : color,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
