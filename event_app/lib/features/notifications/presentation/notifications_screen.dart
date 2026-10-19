import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/skeleton_loader.dart';
import '../../events/presentation/feedback_dialog.dart';

// ─────────────────────────────────────────────────────────────────────────────
// NotificationsScreen — Zest Campus Alerts & Activity
// Styled to match the dark neo-bold brand with lime accents
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

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: AppColors.ink,
        appBar: AppBar(
          backgroundColor: AppColors.ink,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.white),
            onPressed: () => context.pop(),
          ),
          title: Text(
            'Notifications',
            style: AppTextStyles.title20.copyWith(color: AppColors.white),
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
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.lime,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
          ],
        ),
        body: _isLoading
            ? Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: List.generate(
                    4,
                    (_) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: SkeletonLoader(
                        width: double.infinity,
                        height: 76,
                        radius: AppRadius.listRow,
                      ),
                    ),
                  ),
                ),
              )
            : _notifications.isEmpty
                ? Center(
                    child: EmptyState(
                      emoji: '🔔',
                      title: 'No Notifications Yet',
                      subtitle: 'We will let you know when fresh event updates or passes arrive!',
                      actionLabel: 'Back to Feed',
                      onAction: () => context.pop(),
                    ),
                  )
                : RefreshIndicator(
                    color: AppColors.ink,
                    backgroundColor: AppColors.lime,
                    onRefresh: _loadNotifications,
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(18, 12, 18, 40),
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
        icon = Icons.event_rounded;
        iconColor = AppColors.lime;
        iconBg = AppColors.lime.withValues(alpha: 0.15);
        break;
      case 'feedback_request':
        icon = Icons.star_rounded;
        iconColor = AppColors.mustard;
        iconBg = AppColors.mustard.withValues(alpha: 0.15);
        break;
      case 'registration_update':
        icon = Icons.confirmation_number_rounded;
        iconColor = AppColors.coral;
        iconBg = AppColors.coral.withValues(alpha: 0.15);
        break;
      default:
        icon = Icons.notifications_rounded;
        iconColor = AppColors.aqua;
        iconBg = AppColors.aqua.withValues(alpha: 0.15);
    }

    return Container(
      decoration: BoxDecoration(
        color: isRead ? AppColors.surfaceDark : AppColors.ink2,
        borderRadius: BorderRadius.circular(AppRadius.listRow),
        border: Border.all(
          color: isRead ? AppColors.borderDark : AppColors.lime.withValues(alpha: 0.4),
          width: isRead ? 1 : 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.listRow),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.listRow),
          child: Padding(
            padding: const EdgeInsets.all(14),
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
                              style: AppTextStyles.title17.copyWith(
                                color: AppColors.white,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          Text(
                            _formatDate(date),
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.grey400,
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
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.grey400,
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
                      color: AppColors.lime,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ),
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
    return '${d.day}/${d.month}';
  }
}
