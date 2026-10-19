import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/zest_tokens.dart';
import '../../../shared/widgets/zest_floating_nav_bar.dart';
import 'widgets/home_feed_tab.dart';
import 'widgets/explore_tab.dart';
import 'widgets/my_events_tab.dart';
import 'widgets/leaderboard_tab.dart';
import 'widgets/student_profile_tab.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Zest Student Home Shell
// 5-tab navigation: Home, Explore, My Passes, Leaderboard, Profile
// Floating ZestFloatingNavBar with sliding brandGradient circle indicator
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

  @override
  Widget build(BuildContext context) {
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
      // Tab 2: My Events / Passes
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
      value: SystemUiOverlayStyle.dark, // dark status bar icons on light page
      child: Scaffold(
        backgroundColor: ZestTokens.page,
        body: Stack(
          children: [
            // ── Tab content ────────────────────────────────────────────
            IndexedStack(
              index: _selectedIndex,
              children: pages,
            ),

            // ── Floating Pill Nav Bar ──────────────────────────────────
            ZestFloatingNavBar(
              currentIndex: _selectedIndex,
              onTap: _goToTab,
              isVisible: _navVisible,
            ),
          ],
        ),
      ),
    );
  }
}

