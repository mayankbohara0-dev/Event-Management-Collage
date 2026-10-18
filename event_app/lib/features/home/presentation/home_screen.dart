import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/floating_pill_nav_bar.dart';
import 'widgets/home_feed_tab.dart';
import 'widgets/my_events_tab.dart';
import 'widgets/student_profile_tab.dart';

/// Zest Student Home Shell
/// Houses HomeFeedTab, MyEventsTab, and StudentProfileTab
/// connected via FloatingPillNavBar.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;
  bool _navVisible = true;

  void _goToTab(int index) {
    setState(() => _selectedIndex = index);
  }

  void setNavVisible(bool visible) {
    if (_navVisible != visible) {
      setState(() => _navVisible = visible);
    }
  }

  static const _navItems = [
    ZestNavItem(
      icon: Icons.explore_outlined,
      activeIcon: Icons.explore_rounded,
      label: 'Explore',
    ),
    ZestNavItem(
      icon: Icons.confirmation_number_outlined,
      activeIcon: Icons.confirmation_number_rounded,
      label: 'My Passes',
    ),
    ZestNavItem(
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: 'Profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeFeedTab(
        onProfileTap: () => _goToTab(2),
        onMyEventsTap: () => _goToTab(1),
        onScrollDirectionChange: setNavVisible,
      ),
      MyEventsTab(
        onProfileTap: () => _goToTab(2),
        onExploreTap: () => _goToTab(0),
      ),
      const StudentProfileTab(),
    ];

    return Scaffold(
      backgroundColor: AppColors.ink,
      body: Stack(
        children: [
          // Current tab content
          IndexedStack(
            index: _selectedIndex,
            children: pages,
          ),

          // Floating Pill Nav Bar
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
    );
  }
}
