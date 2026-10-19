import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/zest_tokens.dart';
import '../../../shared/widgets/shared_widgets.dart';
import '../../events/presentation/feedback_dialog.dart';

// ─────────────────────────────────────────────────────────────────────────────
// NotificationsScreen — Zest Campus Alerts & Activity
// Minimal, simple, modern, light UI matching Designjoy aesthetic.
// ─────────────────────────────────────────────────────────────────────────────

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
      backgroundColor: ZestTokens.page,
      appBar: AppBar(
        backgroundColor: ZestTokens.page,
        elevation: 0,
        foregroundColor: ZestTokens.ink,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
        title: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Notifi',
                style: ZestTokens.title.copyWith(fontSize: 20),
              ),
              TextSpan(
                text: 'cations',
                style: ZestTokens.accentItalic.copyWith(
                  fontSize: 24,
                  color: ZestTokens.blue,
                ),
              ),
            ],
          ),
        ),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                _markAllAsRead();
              },
              child: Text(
                'Mark all read',
                style: ZestTokens.caption.copyWith(
                  color: ZestTokens.blue,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? Padding(
              padding: const EdgeInsets.all(ZestTokens.horizontalPadding),
              child: Column(
                children: List.generate(
                  4,
                  (_) => const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: ZestSkeleton(
                      width: double.infinity,
                      height: 78,
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                  ),
                ),
              ),
            )
          : _notifications.isEmpty
              ? Center(
                  child: ZestEmptyState(
                    mascotMood: ZestMascotMood.idle,
                    title: 'No Notifications Yet',
                    subtitle: 'We will let you know when fresh event updates or passes arrive!',
                    actionLabel: 'Back to Feed',
                    onAction: () => context.pop(),
                  ),
                )
              : RefreshIndicator(
                  color: ZestTokens.blue,
                  backgroundColor: Colors.white,
                  onRefresh: _loadNotifications,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                      ZestTokens.horizontalPadding,
                      12,
                      ZestTokens.horizontalPadding,
                      40,
                    ),
                    itemCount: _notifications.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final n = _notifications[i];
                      return _NotificationCard(
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
}

class _NotificationCard extends StatelessWidget {
  final Map<String, dynamic> notification;
  final VoidCallback onTap;

  const _NotificationCard({required this.notification, required this.onTap});

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
    Color iconBg;

    switch (type) {
      case 'event_update':
        icon = LucideIcons.calendar;
        iconColor = ZestTokens.blue;
        iconBg = const Color(0xFFE8F6FE);
        break;
      case 'feedback_request':
        icon = LucideIcons.star;
        iconColor = const Color(0xFFD97706);
        iconBg = const Color(0xFFFEF3C7);
        break;
      case 'registration_update':
        icon = LucideIcons.ticket;
        iconColor = ZestTokens.coral;
        iconBg = const Color(0xFFFFF1F2);
        break;
      default:
        icon = LucideIcons.bell;
        iconColor = const Color(0xFF047857);
        iconBg = const Color(0xFFD1FAE5);
    }

    return ZestCard(
      padding: const EdgeInsets.all(14),
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: ZestTokens.bodyBold.copyWith(
                          fontSize: 14.5,
                          fontWeight: isRead ? FontWeight.w600 : FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      _formatDate(date),
                      style: ZestTokens.caption.copyWith(
                        color: ZestTokens.ink3,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: ZestTokens.body.copyWith(
                    color: ZestTokens.ink2,
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          if (!isRead) ...[
            const SizedBox(width: 8),
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(top: 4),
              decoration: const BoxDecoration(
                color: ZestTokens.blue,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
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
    return '${d.day}/${d.month}';
  }
}
