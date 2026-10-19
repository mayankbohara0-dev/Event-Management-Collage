import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/floating_pill_nav_bar.dart';
import 'widgets/home_feed_tab.dart';
import 'widgets/explore_tab.dart';
import 'widgets/my_events_tab.dart';
import 'widgets/leaderboard_tab.dart';
import 'widgets/student_profile_tab.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Zest Student Home Shell
// 5-tab navigation per spec: Home, Explore, My Events, Leaderboard, Profile
// FloatingPillNavBar with sliding lime circle indicator
// ─────────────────────────────────────────────────────────────────────────────

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;
  bool _navVisible = true;

  void _goToTab(int index) {
    if (_selectedIndex != index) {
      setState(() => _selectedIndex = index);
    }
  }

  void setNavVisible(bool visible) {
    if (_navVisible != visible) {
      setState(() => _navVisible = visible);
    }
  }

  // ── 5-tab nav items per spec:
  //    0: Home (house icon)
  //    1: Explore (compass)
  //    2: My Events (ticket)
  //    3: Leaderboard (trophy)
  //    4: Profile (person)
  static const _navItems = [
    ZestNavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Home',
    ),
    ZestNavItem(
      icon: Icons.explore_outlined,
      activeIcon: Icons.explore_rounded,
      label: 'Explore',
    ),
    ZestNavItem(
      icon: Icons.confirmation_number_outlined,
      activeIcon: Icons.confirmation_number_rounded,
      label: 'My Events',
    ),
    ZestNavItem(
      icon: Icons.emoji_events_outlined,
      activeIcon: Icons.emoji_events_rounded,
      label: 'Leaderboard',
    ),
    ZestNavItem(
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: 'Profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // Each tab builds lazily — IndexedStack preserves state
    final pages = [
      // Tab 0: Home Feed
      HomeFeedTab(
        onProfileTap: () => _goToTab(4),
        onMyEventsTap: () => _goToTab(2),
        onExploreTap: () => _goToTab(1),
        onScrollDirectionChange: setNavVisible,
      ),
      // Tab 1: Explore
      ExploreTab(
        onScrollDirectionChange: setNavVisible,
      ),
      // Tab 2: My Events / Tickets
      MyEventsTab(
        onProfileTap: () => _goToTab(4),
        onExploreTap: () => _goToTab(1),
      ),
      // Tab 3: Leaderboard
      const LeaderboardTab(),
      // Tab 4: Profile
      const StudentProfileTab(),
    ];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light, // light status bar icons on dark bg
      child: Scaffold(
        backgroundColor: AppColors.ink,
        body: Stack(
          children: [
            // ── Tab content ────────────────────────────────────────────
            IndexedStack(
              index: _selectedIndex,
              children: pages,
            ),

            // ── Floating Pill Nav Bar ──────────────────────────────────
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: FloatingPillNavBar(
                items: _navItems,
                selectedIndex: _selectedIndex,
                onTap: _goToTab,
                isVisible: _navVisible,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
