import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/dummy_data.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/drawer_widget.dart';
import 'home_body.dart';
import 'wardrobe_body.dart';
import 'planner_body.dart';
import 'profile_body.dart';
import 'outfits_body.dart';
import 'notifications_body.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentPage = 0;
  int _lastBottomNavPage = 0;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  static const _pageTitles = [
    'Smart Wardrobe',
    'My Wardrobe',
    'Calendar Planner',
    'Profile',
    'Outfit Suggestions',
    'Notifications',
  ];

  static const _bottomNavIndices = [0, 1, 2, 3];

  bool get _isHome => _currentPage == 0;
  bool get _showFAB => _currentPage == 1 || _currentPage == 2;

  void _navigateTo(int page) {
    setState(() {
      _currentPage = page;
      if (_bottomNavIndices.contains(page)) {
        _lastBottomNavPage = page;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: _buildAppBar(),
      drawer: DrawerMenu(
        userName: DummyData.currentUser.name,
        userEmail: DummyData.currentUser.email,
        userImage: DummyData.currentUser.profileImage,
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
          _navigateTo(4);
        },
        onCalendar: () {
          Navigator.pop(context);
          _navigateTo(2);
        },
        onNotifications: () {
          Navigator.pop(context);
          _navigateTo(5);
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
          const OutfitSuggestionsBody(),
          const NotificationsBody(),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _lastBottomNavPage,
        onTap: (i) => _navigateTo(i),
      ),
      floatingActionButton: _showFAB
          ? FloatingActionButton(
              onPressed: () {
                if (_currentPage == 1) {
                  Navigator.pushNamed(context, '/add-clothing');
                } else {
                  Navigator.pushNamed(context, '/outfits');
                }
              },
              backgroundColor: AppTheme.primary,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    if (_isHome) {
      return _buildHomeAppBar();
    }
    return AppBar(
      backgroundColor: AppTheme.surface,
      elevation: 0,
      title: Text(_pageTitles[_currentPage]),
      leading: IconButton(
        icon: const Icon(Icons.menu_rounded, color: AppTheme.textPrimary),
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      actions: _currentPage == 5
          ? [
              TextButton(
                onPressed: () {
                  // Mark all read will be handled by body widget via callback
                },
                child: const Text(
                  'Mark all read',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ),
            ]
          : null,
    );
  }

  PreferredSizeWidget _buildHomeAppBar() {
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
            '${DummyData.currentUser.name}!',
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
            onTap: () => _navigateTo(5),
            child: Stack(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.background,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: CachedNetworkImage(
                      imageUrl: DummyData.currentUser.profileImage,
                      fit: BoxFit.cover,
                      placeholder: (_, _) => const Icon(Icons.person, color: AppTheme.textSecondary),
                      errorWidget: (_, _, _) => const Icon(Icons.person, color: AppTheme.textSecondary),
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
                      border: Border.all(color: Colors.white, width: 2),
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
