import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../admin_colors.dart';

class AdminNotificationsScreen extends ConsumerStatefulWidget {
  const AdminNotificationsScreen({super.key});

  @override
  ConsumerState<AdminNotificationsScreen> createState() => _AdminNotificationsScreenState();
}

class _AdminNotificationsScreenState extends ConsumerState<AdminNotificationsScreen> {
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      final res = await Supabase.instance.client
          .from('notifications')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);
          
      if (mounted) {
        setState(() {
          _notifications = List<Map<String, dynamic>>.from(res);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading notifications: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _markAsRead(String id) async {
    try {
      await Supabase.instance.client
          .from('notifications')
          .update({'is_read': true})
          .eq('id', id);
      
      setState(() {
        final index = _notifications.indexWhere((n) => n['id'] == id);
        if (index != -1) {
          _notifications[index]['is_read'] = true;
        }
      });
    } catch (e) {
      debugPrint('Error marking as read: $e');
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      await Supabase.instance.client
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', user.id)
          .eq('is_read', false);
          
      _loadNotifications();
    } catch (e) {
      debugPrint('Error marking all as read: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifications.where((n) => n['is_read'] == false).length;

    return Container(
      color: AdminColors.bg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top Bar ───────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
            decoration: const BoxDecoration(
              color: AdminColors.sidebar,
              border: Border(
                bottom: BorderSide(color: AdminColors.border, width: 1),
              ),
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notifications',
                      style: GoogleFonts.inter(
                        color: AdminColors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    Text(
                      'Recent activity and system alerts',
                      style: GoogleFonts.inter(
                        color: AdminColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                if (unreadCount > 0)
                  TextButton.icon(
                    onPressed: _markAllAsRead,
                    icon: const Icon(Icons.done_all_rounded, size: 18, color: AdminColors.accent),
                    label: Text(
                      'Mark all as read',
                      style: GoogleFonts.inter(
                        color: AdminColors.accent,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                IconButton(
                  icon: const Icon(Icons.refresh_rounded, color: AdminColors.textSecondary),
                  onPressed: _loadNotifications,
                  tooltip: 'Refresh',
                ),
              ],
            ),
          ),

          // ── List ─────────────────────────────────────────────────
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AdminColors.accent))
                : _notifications.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: const BoxDecoration(
                                color: AdminColors.surfaceLight,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.notifications_off_rounded, size: 48, color: AdminColors.textSecondary),
                            ),
                            const SizedBox(height: 16),
                            Text('No notifications', style: GoogleFonts.inter(color: AdminColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: _notifications.length,
                        itemBuilder: (context, i) {
                          final n = _notifications[i];
                          return _AdminNotificationCard(
                            notification: n,
                            onTap: () {
                              if (n['is_read'] == false) {
                                _markAsRead(n['id']);
                              }
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _AdminNotificationCard extends StatelessWidget {
  final Map<String, dynamic> notification;
  final VoidCallback onTap;

  const _AdminNotificationCard({required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isRead = notification['is_read'] == true;
    final type = notification['type'] as String? ?? '';
    final title = notification['title'] as String? ?? 'Alert';
    final message = notification['message'] as String? ?? '';
    final date = notification['created_at'] != null 
        ? DateTime.parse(notification['created_at']).toLocal() 
        : DateTime.now();

    IconData icon;
    Color color;

    switch (type) {
      case 'admin_alert':
        icon = Icons.warning_rounded;
        color = AdminColors.error;
        break;
      case 'registration_update':
      case 'new_registration':
        icon = Icons.how_to_reg_rounded;
        color = AdminColors.accent;
        break;
      default:
        icon = Icons.notifications_rounded;
        color = AdminColors.textSecondary;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AdminColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isRead ? AdminColors.border : color.withOpacity(0.5)),
          boxShadow: isRead ? [] : [
            BoxShadow(
              color: color.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: isRead ? FontWeight.w600 : FontWeight.w800,
                            color: AdminColors.textPrimary,
                          ),
                        ),
                      ),
                      Text(
                        _formatDate(date),
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AdminColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    message,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AdminColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            if (!isRead) ...[
              const SizedBox(width: 16),
              Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(top: 6),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime d) {
    final now = DateTime.now();
    final diff = now.difference(d);
    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        return diff.inMinutes < 1 ? 'Just now' : '${diff.inMinutes}m ago';
      }
      return '${diff.inHours}h ago';
    }
    if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    }
    return '${d.day}/${d.month}/${d.year}';
  }
}
