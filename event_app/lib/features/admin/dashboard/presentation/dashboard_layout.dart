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
  // Breakpoint: below this = mobile layout (bottom nav)
  static const double _mobileBreakpoint = 600;

  static const List<_NavItem> _navItems = [
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < _mobileBreakpoint;

    if (isMobile) {
      return _MobileLayout(
        selectedIndex: _selectedIndex,
        navItems: _navItems,
        onNavTap: _onNavTap,
        onLogout: _logout,
        child: widget.child,
      );
    }

    // Desktop / Tablet — sidebar layout
    final sidebarWidth = _isSidebarExpanded ? _expandedWidth : _collapsedWidth;
    return Scaffold(
      backgroundColor: AdminColors.bg,
      body: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            width: sidebarWidth,
            decoration: const BoxDecoration(
              color: AdminColors.sidebar,
              border: Border(right: BorderSide(color: AdminColors.border, width: 1)),
            ),
            child: Column(
              children: [
                // Logo + toggle
                Container(
                  height: 70,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: AdminColors.border, width: 1)),
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
                        child: const Icon(Icons.event_rounded, color: Colors.white, size: 20),
                      ),
                      if (_isSidebarExpanded) ...[
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Event Admin',
                                  style: TextStyle(
                                      color: AdminColors.textPrimary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14)),
                              Text('Management Portal',
                                  style: TextStyle(
                                      color: AdminColors.textSecondary, fontSize: 11)),
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
                const SizedBox(height: 12),
                // Nav items
                ...List.generate(_navItems.length, (i) {
                  final item = _navItems[i];
                  final isActive = _selectedIndex == i;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    child: InkWell(
                      onTap: () => _onNavTap(i),
                      borderRadius: BorderRadius.circular(12),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          color: isActive
                              ? AdminColors.accent.withOpacity(0.18)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: isActive
                              ? Border.all(
                                  color: AdminColors.accent.withOpacity(0.3), width: 1)
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
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: InkWell(
                    onTap: _logout,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(
                        color: AdminColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: _isSidebarExpanded
                            ? MainAxisSize.max
                            : MainAxisSize.min,
                        children: [
                          const Icon(Icons.logout_rounded, color: AdminColors.error, size: 20),
                          if (_isSidebarExpanded) ...[
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text('Sign Out',
                                  style: TextStyle(
                                      color: AdminColors.error,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14)),
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
          // Main content
          Expanded(child: widget.child),
        ],
      ),
    );
  }
}

// ── MOBILE LAYOUT ─────────────────────────────
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
        elevation: 0,
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu_rounded, color: AdminColors.textPrimary),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        title: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                gradient: AdminColors.heroGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.event_rounded, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 10),
            const Text('Event Admin',
                style: TextStyle(
                    color: AdminColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 16)),
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
      drawer: Drawer(
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
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        gradient: AdminColors.heroGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.event_rounded, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Event Admin',
                            style: TextStyle(
                                color: AdminColors.textPrimary,
                                fontWeight: FontWeight.w800,
                                fontSize: 16)),
                        Text('Management Portal',
                            style: TextStyle(
                                color: AdminColors.textSecondary, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              ...List.generate(navItems.length, (i) {
                final item = navItems[i];
                final isActive = selectedIndex == i;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).pop(); // close drawer
                      onNavTap(i);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: isActive
                            ? AdminColors.accent.withOpacity(0.18)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: isActive
                            ? Border.all(
                                color: AdminColors.accent.withOpacity(0.3), width: 1)
                            : null,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isActive ? item.activeIcon : item.icon,
                            color: isActive ? AdminColors.accent : AdminColors.textSecondary,
                            size: 22,
                          ),
                          const SizedBox(width: 16),
                          Text(
                            item.label,
                            style: TextStyle(
                              color: isActive
                                  ? AdminColors.accent
                                  : AdminColors.textSecondary,
                              fontWeight:
                                  isActive ? FontWeight.w700 : FontWeight.w500,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.all(12),
                child: InkWell(
                  onTap: onLogout,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AdminColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.logout_rounded, color: AdminColors.error, size: 20),
                        SizedBox(width: 12),
                        Text('Sign Out',
                            style: TextStyle(
                                color: AdminColors.error,
                                fontWeight: FontWeight.w600,
                                fontSize: 15)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AdminColors.sidebar,
          border: Border(top: BorderSide(color: AdminColors.border, width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: onNavTap,
          backgroundColor: AdminColors.sidebar,
          selectedItemColor: AdminColors.accent,
          unselectedItemColor: AdminColors.textSecondary,
          selectedLabelStyle: const TextStyle(
              fontSize: 11, fontWeight: FontWeight.w700),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
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
