import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_radius.dart';
import '../theme/app_shadows.dart';

/// GreetingHeader
/// Displays "Hi, {name} 👋", a date subtitle, a circular avatar,
/// and a notification bell with an optional red badge.
class GreetingHeader extends StatelessWidget {
  const GreetingHeader({
    super.key,
    required this.name,
    this.avatarUrl,
    this.onAvatarTap,
    this.onBellTap,
    this.hasUnreadNotification = false,
    this.subtitle,
  });

  final String name;
  final String? avatarUrl;
  final VoidCallback? onAvatarTap;
  final VoidCallback? onBellTap;
  final bool hasUnreadNotification;
  final String? subtitle;

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String get _dateString {
    final now = DateTime.now();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${days[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$_greeting 👋',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.grey600,
                  ),
                ),
                const SizedBox(height: 2),
                RichText(
                  text: TextSpan(
                    text: 'Hi, ',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.charcoal,
                    ),
                    children: [
                      TextSpan(
                        text: name.split(' ').first,
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppColors.coral,
                        ),
                      ),
                    ],
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.grey400,
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 2),
                  Text(
                    _dateString,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.grey400,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Notification bell
          GestureDetector(
            onTap: onBellTap,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.grey100,
                    borderRadius: AppRadius.circularMd,
                  ),
                  child: const Icon(
                    Icons.notifications_outlined,
                    color: AppColors.charcoal,
                    size: 22,
                  ),
                ),
                if (hasUnreadNotification)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.coral,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          // Avatar
          GestureDetector(
            onTap: onAvatarTap,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: AppShadows.card,
              ),
              child: CircleAvatar(
                radius: 21,
                backgroundColor: AppColors.mustard,
                backgroundImage: (avatarUrl != null && avatarUrl!.isNotEmpty)
                    ? NetworkImage(avatarUrl!)
                    : null,
                child: (avatarUrl == null || avatarUrl!.isEmpty)
                    ? Text(
                        name.isNotEmpty ? name[0].toUpperCase() : '?',
                        style: GoogleFonts.poppins(
                          color: AppColors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      )
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
