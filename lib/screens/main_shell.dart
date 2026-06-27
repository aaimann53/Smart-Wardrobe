import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../utils/app_state.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/drawer_widget.dart';
import '../widgets/category_carousel.dart';
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

  // Active filter coming from the home carousel. Null means "show all".
  String? _wardrobeFilterCategory;
  String? _wardrobeFilterSeason;

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
      if (page == 1) {
        // Manual navigation to the Wardrobe tab (drawer/bottom-nav) always
        // shows everything. Filtered navigation goes through
        // _navigateToCategory instead.
        _wardrobeFilterCategory = null;
        _wardrobeFilterSeason = null;
      }
      if (_bottomNavIndices.contains(page)) {
        _lastBottomNavPage = page;
      }
    });
  }

  void _navigateToCategory(CarouselCategory category) {
    setState(() {
      if (category.filterType == CarouselFilterType.category) {
        _wardrobeFilterCategory = category.filterValue;
        _wardrobeFilterSeason = null;
      } else {
        _wardrobeFilterSeason = category.filterValue;
        _wardrobeFilterCategory = null;
      }
      _currentPage = 1; // Wardrobe tab
      _lastBottomNavPage = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final hasPickedImage = state.profileImage != null;

    return Scaffold(
      key: _scaffoldKey,
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
          HomeDashboardBody(
            onNavigateToPage: (page) => _navigateTo(page),
            onNavigateToCategory: _navigateToCategory,
          ),
          WardrobeBody(
            key: ValueKey(
              'wardrobe-$_wardrobeFilterCategory-$_wardrobeFilterSeason',
            ),
            initialCategory: _wardrobeFilterCategory,
            initialSeason: _wardrobeFilterSeason,
          ),
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

  PreferredSizeWidget _buildAppBar(AppState state) {
    if (_isHome) {
      return _buildHomeAppBar(state);
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
                onPressed: () {},
                child: const Text(
                  'Mark all read',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ),
            ]
          : null,
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
                    color: AppTheme.background,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: hasPickedImage
                        ? kIsWeb
                              ? Image.network(
                                  state.profileImage!.path,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => const Icon(
                                    Icons.person,
                                    color: AppTheme.textSecondary,
                                  ),
                                )
                              : Image.file(
                                  File(state.profileImage!.path),
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => const Icon(
                                    Icons.person,
                                    color: AppTheme.textSecondary,
                                  ),
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
