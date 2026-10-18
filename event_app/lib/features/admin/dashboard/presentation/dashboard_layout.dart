import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../admin_colors.dart';

// Re-export so other admin screens can still use `import 'dashboard_layout.dart'`
// if they happen to reference it — though they should migrate to admin_colors.dart.
export '../../admin_colors.dart';

class DashboardLayout extends ConsumerWidget {
  final Widget child;
  final String currentLocation;

  const DashboardLayout({
    super.key,
    required this.child,
    required this.currentLocation,
  });

  static const List<_NavItem> _navItems = [
    _NavItem(
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard_rounded,
      label: 'Dashboard',
      route: '/admin/dashboard',
    ),
    _NavItem(
      icon: Icons.event_note_outlined,
      activeIcon: Icons.event_note_rounded,
      label: 'Events',
      route: '/admin/events',
    ),
    _NavItem(
      icon: Icons.people_outline_rounded,
      activeIcon: Icons.people_rounded,
      label: 'Registrations',
      route: '/admin/registrations',
    ),
    _NavItem(
      icon: Icons.manage_accounts_outlined,
      activeIcon: Icons.manage_accounts_rounded,
      label: 'Users',
      route: '/admin/users',
    ),
    _NavItem(
      icon: Icons.notifications_none_outlined,
      activeIcon: Icons.notifications_rounded,
      label: 'Notifications',
      route: '/admin/notifications',
    ),
  ];

  // Derive the selected nav-item index from the actual current location.
  int _selectedIndex() {
    for (int i = 0; i < _navItems.length; i++) {
      if (currentLocation.startsWith(_navItems[i].route)) return i;
    }
    return 0;
  }

  Future<void> _logout(BuildContext context) async {
    await Supabase.instance.client.auth.signOut();
    if (context.mounted) context.go('/admin/login');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final selectedIndex = _selectedIndex();

    if (isMobile) {
      return _MobileLayout(
        selectedIndex: selectedIndex,
        navItems: _navItems,
        onNavTap: (i) => context.go(_navItems[i].route),
        onLogout: () => _logout(context),
        child: child,
      );
    }

    return _DesktopLayout(
      selectedIndex: selectedIndex,
      navItems: _navItems,
      onNavTap: (i) => context.go(_navItems[i].route),
      onLogout: () => _logout(context),
      child: child,
    );
  }
}

// ══════════════════════════════════════════════
// DESKTOP LAYOUT  (collapsible sidebar)
// ══════════════════════════════════════════════
class _DesktopLayout extends StatefulWidget {
  final int selectedIndex;
  final List<_NavItem> navItems;
  final void Function(int) onNavTap;
  final VoidCallback onLogout;
  final Widget child;

  const _DesktopLayout({
    required this.selectedIndex,
    required this.navItems,
    required this.onNavTap,
    required this.onLogout,
    required this.child,
  });

  @override
  State<_DesktopLayout> createState() => _DesktopLayoutState();
}

class _DesktopLayoutState extends State<_DesktopLayout> {
  bool _expanded = true;

  static const double _collapsedWidth = 72;
  static const double _expandedWidth  = 230;

  @override
  Widget build(BuildContext context) {
    final w = _expanded ? _expandedWidth : _collapsedWidth;

    return Scaffold(
      backgroundColor: AdminColors.bg,
      body: Row(
        children: [
          // ── Sidebar ──────────────────────────────────────────────────
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            width: w,
            decoration: const BoxDecoration(
              color: AdminColors.sidebar,
              border: Border(
                right: BorderSide(color: AdminColors.border),
              ),
            ),
            child: Column(
              children: [
                // Logo + toggle
                _SidebarHeader(
                  expanded: _expanded,
                  onToggle: () => setState(() => _expanded = !_expanded),
                ),
                const SizedBox(height: 8),
                // Nav items
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    children: [
                      ...List.generate(widget.navItems.length, (i) {
                        final item = widget.navItems[i];
                        final isActive = widget.selectedIndex == i;
                        return _NavTile(
                          item: item,
                          isActive: isActive,
                          expanded: _expanded,
                          onTap: () => widget.onNavTap(i),
                        );
                      }),
                    ],
                  ),
                ),
                // Logout
                _LogoutTile(
                  expanded: _expanded,
                  onTap: widget.onLogout,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),

          // ── Main content ─────────────────────────────────────────────
          Expanded(child: widget.child),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════
// MOBILE LAYOUT  (bottom nav + drawer)
// ══════════════════════════════════════════════
class _MobileLayout extends StatelessWidget {
  final int selectedIndex;
  final List<_NavItem> navItems;
  final void Function(int) onNavTap;
  final VoidCallback onLogout;
  final Widget child;

  const _MobileLayout({
    required this.selectedIndex,
    required this.navItems,
    required this.onNavTap,
    required this.onLogout,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminColors.bg,
      appBar: AppBar(
        backgroundColor: AdminColors.sidebar,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu_rounded, color: AdminColors.textPrimary),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/logo.png',
                width: 30,
                height: 30,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Zest Admin',
              style: GoogleFonts.inter(
                color: AdminColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AdminColors.error, size: 22),
            tooltip: 'Sign Out',
            onPressed: onLogout,
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AdminColors.border),
        ),
      ),
      drawer: _MobileDrawer(
        selectedIndex: selectedIndex,
        navItems: navItems,
        onNavTap: onNavTap,
        onLogout: onLogout,
      ),
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AdminColors.sidebar,
          border: Border(top: BorderSide(color: AdminColors.border)),
        ),
        child: BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: onNavTap,
          backgroundColor: AdminColors.sidebar,
          selectedItemColor: AdminColors.accent,
          unselectedItemColor: AdminColors.textSecondary,
          selectedLabelStyle: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
          unselectedLabelStyle: GoogleFonts.inter(fontSize: 11),
          elevation: 0,
          items: navItems
              .map((item) => BottomNavigationBarItem(
                    icon: Icon(item.icon),
                    activeIcon: Icon(item.activeIcon),
                    label: item.label,
                  ))
              .toList(),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════
// MOBILE DRAWER
// ══════════════════════════════════════════════
class _MobileDrawer extends StatelessWidget {
  final int selectedIndex;
  final List<_NavItem> navItems;
  final void Function(int) onNavTap;
  final VoidCallback onLogout;

  const _MobileDrawer({
    required this.selectedIndex,
    required this.navItems,
    required this.onNavTap,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AdminColors.sidebar,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AdminColors.border)),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/logo.png',
                      width: 42,
                      height: 42,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Zest Admin',
                        style: GoogleFonts.inter(
                          color: AdminColors.textPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Admin Portal',
                        style: GoogleFonts.inter(
                          color: AdminColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                children: List.generate(navItems.length, (i) {
                  final item = navItems[i];
                  final isActive = selectedIndex == i;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                        onNavTap(i);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: isActive
                              ? AdminColors.accent.withValues(alpha: 0.12)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: isActive
                              ? Border.all(
                                  color: AdminColors.accent.withValues(alpha: 0.3),
                                )
                              : null,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isActive ? item.activeIcon : item.icon,
                              color: isActive
                                  ? AdminColors.accent
                                  : AdminColors.textSecondary,
                              size: 22,
                            ),
                            const SizedBox(width: 16),
                            Text(
                              item.label,
                              style: GoogleFonts.inter(
                                color: isActive
                                    ? AdminColors.accent
                                    : AdminColors.textSecondary,
                                fontWeight: isActive
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: InkWell(
                onTap: onLogout,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AdminColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.logout_rounded,
                        color: AdminColors.error,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Sign Out',
                        style: GoogleFonts.inter(
                          color: AdminColors.error,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════
// SIDEBAR SUB-WIDGETS
// ══════════════════════════════════════════════
class _SidebarHeader extends StatelessWidget {
  final bool expanded;
  final VoidCallback onToggle;

  const _SidebarHeader({required this.expanded, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AdminColors.border)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              'assets/logo.png',
              width: 36,
              height: 36,
              fit: BoxFit.cover,
            ),
          ),
          if (expanded) ...[
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Zest Admin',
                    style: GoogleFonts.inter(
                      color: AdminColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    'Admin Portal',
                    style: GoogleFonts.inter(
                      color: AdminColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
          IconButton(
            icon: Icon(
              expanded
                  ? Icons.chevron_left_rounded
                  : Icons.chevron_right_rounded,
              color: AdminColors.textSecondary,
              size: 20,
            ),
            onPressed: onToggle,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  final _NavItem item;
  final bool isActive;
  final bool expanded;
  final VoidCallback onTap;

  const _NavTile({
    required this.item,
    required this.isActive,
    required this.expanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Tooltip(
        message: expanded ? '' : item.label,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: isActive
                  ? AdminColors.accent.withValues(alpha: 0.12)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: isActive
                  ? Border.all(
                      color: AdminColors.accent.withValues(alpha: 0.3),
                    )
                  : null,
            ),
            child: Row(
              mainAxisSize:
                  expanded ? MainAxisSize.max : MainAxisSize.min,
              children: [
                Icon(
                  isActive ? item.activeIcon : item.icon,
                  color:
                      isActive ? AdminColors.accent : AdminColors.textSecondary,
                  size: 22,
                ),
                if (expanded) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item.label,
                      style: GoogleFonts.inter(
                        color: isActive
                            ? AdminColors.accent
                            : AdminColors.textSecondary,
                        fontWeight:
                            isActive ? FontWeight.w700 : FontWeight.w500,
                        fontSize: 14,
                      ),
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
}

class _LogoutTile extends StatelessWidget {
  final bool expanded;
  final VoidCallback onTap;

  const _LogoutTile({required this.expanded, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Tooltip(
        message: expanded ? '' : 'Sign Out',
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: AdminColors.error.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
              children: [
                const Icon(
                  Icons.logout_rounded,
                  color: AdminColors.error,
                  size: 20,
                ),
                if (expanded) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Sign Out',
                      style: GoogleFonts.inter(
                        color: AdminColors.error,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
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
}

// ══════════════════════════════════════════════
// NAV ITEM MODEL
// ══════════════════════════════════════════════
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
