import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

// ─────────────────────────────────────────────
// Admin Design Tokens
// ─────────────────────────────────────────────
class AdminColors {
  static const Color bg = Color(0xFF0F0F1A);
  static const Color sidebar = Color(0xFF14142B);
  static const Color surface = Color(0xFF1A1A2E);
  static const Color surfaceLight = Color(0xFF242440);
  static const Color accent = Color(0xFF7C3AED);
  static const Color gold = Color(0xFFFFB800);
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color textPrimary = Color(0xFFF1F1F8);
  static const Color textSecondary = Color(0xFF8B8BA8);
  static const Color border = Color(0xFF2A2A4A);

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF1A1A2E), Color(0xFF7C3AED)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class DashboardLayout extends ConsumerStatefulWidget {
  final Widget child;
  const DashboardLayout({super.key, required this.child});

  @override
  ConsumerState<DashboardLayout> createState() => _DashboardLayoutState();
}

class _DashboardLayoutState extends ConsumerState<DashboardLayout> {
  bool _isSidebarExpanded = true;
  int _selectedIndex = 0;

  static const double _collapsedWidth = 72;
  static const double _expandedWidth = 220;
  final List<_NavItem> _navItems = const [
    _NavItem(
        icon: Icons.dashboard_outlined,
        activeIcon: Icons.dashboard_rounded,
        label: 'Dashboard',
        route: '/admin/dashboard'),
    _NavItem(
        icon: Icons.event_note_outlined,
        activeIcon: Icons.event_note_rounded,
        label: 'Events',
        route: '/admin/events'),
    _NavItem(
        icon: Icons.people_outline_rounded,
        activeIcon: Icons.people_rounded,
        label: 'Registrations',
        route: '/admin/registrations'),
  ];

  void _onNavTap(int index) {
    setState(() => _selectedIndex = index);
    context.go(_navItems[index].route);
  }

  Future<void> _logout() async {
    await Supabase.instance.client.auth.signOut();
    if (mounted) context.go('/admin/login');
  }

  @override
  Widget build(BuildContext context) {
    final sidebarWidth =
        _isSidebarExpanded ? _expandedWidth : _collapsedWidth;

    return Scaffold(
      backgroundColor: AdminColors.bg,
      body: Row(
        children: [
          // ── Sidebar ──────────────────────────────────────────────
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            width: sidebarWidth,
            decoration: const BoxDecoration(
              color: AdminColors.sidebar,
              border: Border(
                right: BorderSide(color: AdminColors.border, width: 1),
              ),
            ),
            child: Column(
              children: [
                // Logo + toggle
                Container(
                  height: 70,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: const BoxDecoration(
                    border: Border(
                        bottom:
                            BorderSide(color: AdminColors.border, width: 1)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          gradient: AdminColors.heroGradient,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.event_rounded,
                            color: Colors.white, size: 20),
                      ),
                      if (_isSidebarExpanded) ...[
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Event Admin',
                                style: TextStyle(
                                  color: AdminColors.textPrimary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                'Management Portal',
                                style: TextStyle(
                                    color: AdminColors.textSecondary,
                                    fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      ],
                      IconButton(
                        icon: Icon(
                          _isSidebarExpanded
                              ? Icons.chevron_left_rounded
                              : Icons.chevron_right_rounded,
                          color: AdminColors.textSecondary,
                          size: 20,
                        ),
                        onPressed: () =>
                            setState(() => _isSidebarExpanded = !_isSidebarExpanded),
                      ),
                    ],
                  ),
                ),

                // Nav items
                const SizedBox(height: 12),
                ...List.generate(_navItems.length, (i) {
                  final item = _navItems[i];
                  final isActive = _selectedIndex == i;
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    child: InkWell(
                      onTap: () => _onNavTap(i),
                      borderRadius: BorderRadius.circular(12),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          color: isActive
                              ? AdminColors.accent.withOpacity(0.18)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: isActive
                              ? Border.all(
                                  color:
                                      AdminColors.accent.withOpacity(0.3),
                                  width: 1)
                              : null,
                        ),
                        child: Row(
                          mainAxisSize: _isSidebarExpanded
                              ? MainAxisSize.max
                              : MainAxisSize.min,
                          children: [
                            Icon(
                              isActive ? item.activeIcon : item.icon,
                              color: isActive
                                  ? AdminColors.accent
                                  : AdminColors.textSecondary,
                              size: 22,
                            ),
                            if (_isSidebarExpanded) ...[
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  item.label,
                                  style: TextStyle(
                                    color: isActive
                                        ? AdminColors.accent
                                        : AdminColors.textSecondary,
                                    fontWeight: isActive
                                        ? FontWeight.w700
                                        : FontWeight.w400,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                }),

                const Spacer(),

                // Bottom: Logout
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: InkWell(
                    onTap: _logout,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(
                        color: AdminColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: _isSidebarExpanded
                            ? MainAxisSize.max
                            : MainAxisSize.min,
                        children: [
                          const Icon(Icons.logout_rounded,
                              color: AdminColors.error, size: 20),
                          if (_isSidebarExpanded) ...[
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Sign Out',
                                style: TextStyle(
                                    color: AdminColors.error,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),

          // ── Main Content ─────────────────────────────────────────
          Expanded(
            child: widget.child,
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
  });
}
