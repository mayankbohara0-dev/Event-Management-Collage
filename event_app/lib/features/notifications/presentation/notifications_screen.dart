import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/design_system.dart';
import '../../events/presentation/feedback_dialog.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
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

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        leading: const BackButton(color: AppColors.black),
        title: Text(
          'Notifications',
          style: GoogleFonts.inter(
              color: AppColors.black, fontSize: 18, fontWeight: FontWeight.w800),
        ),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: Text(
                'Mark all read',
                style: GoogleFonts.inter(
                    color: AppColors.green, fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.green))
          : _notifications.isEmpty
              ? _buildEmpty()
              : RefreshIndicator(
                  color: AppColors.green,
                  onRefresh: _loadNotifications,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    itemCount: _notifications.length,
                    separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.grey100),
                    itemBuilder: (context, i) {
                      final n = _notifications[i];
                      return _NotificationTile(
                        notification: n,
                        onTap: () {
                          if (n['is_read'] == false) {
                            _markAsRead(n['id']);
                          }
                          if (n['type'] == 'feedback_request' && n['link_id'] != null) {
                            FeedbackDialog.show(context, n['link_id']);
                          }
                        },
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.notifications_off_outlined, size: 64, color: AppColors.grey200),
          const SizedBox(height: 16),
          Text('No notifications yet',
              style: GoogleFonts.inter(
                  color: AppColors.grey800, fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text('We\'ll let you know when something happens',
              style: GoogleFonts.inter(color: AppColors.grey400, fontSize: 14)),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final Map<String, dynamic> notification;
  final VoidCallback onTap;

  const _NotificationTile({required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isRead = notification['is_read'] == true;
    final type = notification['type'] as String? ?? '';
    final title = notification['title'] as String? ?? 'Notification';
    final message = notification['message'] as String? ?? '';
    final date = notification['created_at'] != null 
        ? DateTime.parse(notification['created_at']).toLocal() 
        : DateTime.now();

    IconData icon;
    Color iconColor;
    Color bgColor;

    switch (type) {
      case 'event_update':
        icon = Icons.event_rounded;
        iconColor = AppColors.green;
        bgColor = AppColors.green.withValues(alpha: 0.1);
        break;
      case 'feedback_request':
        icon = Icons.star_rounded;
        iconColor = Colors.amber;
        bgColor = Colors.amber.withValues(alpha: 0.1);
        break;
      case 'registration_update':
        icon = Icons.how_to_reg_rounded;
        iconColor = AppColors.yellow;
        bgColor = AppColors.yellow.withValues(alpha: 0.2);
        break;
      default:
        icon = Icons.notifications_rounded;
        iconColor = AppColors.grey400;
        bgColor = AppColors.grey100;
    }

    return InkWell(
      onTap: onTap,
      child: Container(
        color: isRead ? Colors.transparent : AppColors.green.withValues(alpha: 0.02),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 20),
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
                            color: AppColors.black,
                          ),
                        ),
                      ),
                      Text(
                        _formatDate(date),
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppColors.grey400,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    message,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: isRead ? AppColors.grey400 : AppColors.grey800,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            if (!isRead) ...[
              const SizedBox(width: 12),
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 6),
                decoration: const BoxDecoration(
                  color: AppColors.green,
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
