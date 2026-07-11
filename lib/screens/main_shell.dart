import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../utils/app_state.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/drawer_widget.dart';
import 'home_body.dart';
import 'wardrobe_body.dart';
import 'planner_body.dart';
import 'profile_body.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentPage = 0;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  // bottom nav has 5 slots: Home, Wardrobe, [empty], Planner, Profile
  // page indices:            0     1          -        2        3
  // internal pages:         Home  Wardrobe  AI(modal) Planner  Profile
  // extra pages via drawer: Outfits=4, Notifications=5

  static const _pageTitles = [
    'Smart Wardrobe',
    'My Wardrobe',
    'Calendar Planner',
    'Profile',
    'Outfit Suggestions',
    'Notifications',
  ];

  bool get _isHome => _currentPage == 0;

  // map bottom nav tap index to page index
  // 0→Home, 1→Wardrobe, 2→empty(AI), 3→Planner, 4→Profile
  void _onBottomNavTap(int navIndex) {
    if (navIndex == 2) {
      // middle slot — open AI screen
      Navigator.pushNamed(context, '/ai-suggest');
      return;
    }
    final pageMap = {0: 0, 1: 1, 3: 2, 4: 3};
    final page = pageMap[navIndex];
    if (page != null) {
      setState(() {
        _currentPage = page;
      });
    }
  }

  void _navigateTo(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  // convert page index back to nav index for highlighting
  int get _navIndex {
    const map = {0: 0, 1: 1, 2: 3, 3: 4};
    return map[_currentPage] ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final hasPickedImage = state.profileImage != null;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppTheme.background,
      appBar: _buildAppBar(state),
      drawer: DrawerMenu(
        userName: state.name,
        userEmail: state.email,
        userImage: hasPickedImage
            ? state.profileImage!.path
            : 'assets/images/profile.jpg',
        isNetworkImage: hasPickedImage,
        currentRoute: '/home',
        onHome: () {
          Navigator.pop(context);
          _navigateTo(0);
        },
        onWardrobe: () {
          Navigator.pop(context);
          _navigateTo(1);
        },
        onOutfits: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/outfits');
        },
        onCalendar: () {
          Navigator.pop(context);
          _navigateTo(2);
        },
        onNotifications: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/notifications');
        },
        onProfile: () {
          Navigator.pop(context);
          _navigateTo(3);
        },
        onSettings: () {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Settings page coming soon!'),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
            ),
          );
        },
        onLogout: () {
          Navigator.pop(context);
          Navigator.pushReplacementNamed(context, '/login');
        },
      ),
      body: IndexedStack(
        index: _currentPage,
        children: [
          HomeDashboardBody(onNavigateToPage: (page) => _navigateTo(page)),
          const WardrobeBody(),
          const CalendarPlannerBody(),
          const ProfileBody(),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _navIndex,
        onTap: _onBottomNavTap,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/ai-suggest'),
        backgroundColor: AppTheme.primary,
        foregroundColor: AppTheme.background,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.auto_awesome, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  PreferredSizeWidget _buildAppBar(AppState state) {
    if (_isHome) return _buildHomeAppBar(state);
    return AppBar(
      backgroundColor: AppTheme.surface,
      elevation: 0,
      title: Text(_pageTitles[_currentPage]),
      leading: IconButton(
        icon: const Icon(Icons.menu_rounded, color: AppTheme.textPrimary),
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
    );
  }

  PreferredSizeWidget _buildHomeAppBar(AppState state) {
    final hasPickedImage = state.profileImage != null;
    return AppBar(
      backgroundColor: AppTheme.surface,
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _getGreeting(),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppTheme.textSecondary,
            ),
          ),
          Text(
            '${state.name}!',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
      leading: IconButton(
        icon: const Icon(Icons.menu_rounded, color: AppTheme.textPrimary),
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: GestureDetector(
            onTap: () => _navigateTo(3),
            child: Stack(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: hasPickedImage
                        ? kIsWeb
                              ? Image.network(
                                  state.profileImage!.path,
                                  fit: BoxFit.cover,
                                )
                              : Image.file(
                                  File(state.profileImage!.path),
                                  fit: BoxFit.cover,
                                )
                        : Image.asset(
                            'assets/images/profile.jpg',
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => const Icon(
                              Icons.person,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppTheme.error,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.surface, width: 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }
}
