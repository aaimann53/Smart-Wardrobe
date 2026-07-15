import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';

class DrawerMenu extends StatelessWidget {
  final String userName;
  final String userEmail;
  final String userImage;
  final bool isNetworkImage;
  final VoidCallback? onHome;
  final VoidCallback? onWardrobe;
  final VoidCallback? onOutfits;
  final VoidCallback? onCalendar;
  final VoidCallback? onNotifications;
  final VoidCallback? onAiMatch;
  final VoidCallback? onProfile;
  final VoidCallback? onSettings;
  final VoidCallback? onLogout;
  final String currentRoute;

  const DrawerMenu({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.userImage,
    this.isNetworkImage = false,
    this.onHome,
    this.onWardrobe,
    this.onOutfits,
    this.onCalendar,
    this.onNotifications,
    this.onAiMatch,
    this.onProfile,
    this.onSettings,
    this.onLogout,
    this.currentRoute = '/home',
  });

  Widget _buildProfileImage() {
    if (isNetworkImage) {
      return kIsWeb
          ? Image.network(
              userImage,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) =>
                  const Icon(Icons.person, color: Colors.white),
            )
          : Image.file(
              File(userImage),
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) =>
                  const Icon(Icons.person, color: Colors.white),
            );
    }
    return Image.asset(
      userImage,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => const Icon(Icons.person, color: Colors.white),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppTheme.surface,
      width: MediaQuery.of(context).size.width * 0.78,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primary, AppTheme.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(40),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withValues(alpha: 0.3),
                  blurRadius: 25,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 20,
              bottom: 30,
              left: 24,
              right: 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: _buildProfileImage(),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            userEmail,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 13,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              children: [
                _drawerItem(
                  icon: Icons.home_rounded,
                  label: 'Home',
                  route: '/home',
                  onTap: onHome,
                ),
                _drawerItem(
                  icon: Icons.checkroom_rounded,
                  label: 'My Wardrobe',
                  route: '/wardrobe',
                  onTap: onWardrobe,
                ),
                _drawerItem(
                  icon: Icons.style_rounded,
                  label: 'Outfit Suggestions',
                  route: '/outfits',
                  onTap: onOutfits,
                ),
                _drawerItem(
                  icon: Icons.calendar_month_rounded,
                  label: 'Calendar Planner',
                  route: '/calendar',
                  onTap: onCalendar,
                ),
                _drawerItem(
                  icon: Icons.notifications_rounded,
                  label: 'Notifications',
                  route: '/notifications',
                  onTap: onNotifications,
                ),
                _drawerItem(
                  icon: Icons.camera_alt_rounded,
                  label: 'AI Item Matcher',
                  route: '/ai-match',
                  onTap: onAiMatch,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  child: Divider(
                    color: AppTheme.textSecondary.withValues(alpha: 0.2),
                  ),
                ),
                _drawerItem(
                  icon: Icons.person_rounded,
                  label: 'Profile',
                  route: '/profile',
                  onTap: onProfile,
                ),
                _drawerItem(
                  icon: Icons.settings_rounded,
                  label: 'Settings',
                  route: '/settings',
                  onTap: onSettings,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  child: Divider(
                    color: AppTheme.textSecondary.withValues(alpha: 0.2),
                  ),
                ),
                _drawerItem(
                  icon: Icons.logout_rounded,
                  label: 'Logout',
                  route: '/login',
                  onTap: onLogout,
                  isDestructive: true,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 16, left: 24),
            child: Row(
              children: [
                Text(
                  AppStrings.appName,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.4),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  'v1.0',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerItem({
    required IconData icon,
    required String label,
    required String route,
    VoidCallback? onTap,
    bool isDestructive = false,
  }) {
    final isActive = currentRoute == route;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: isActive ? AppTheme.primary.withValues(alpha: 0.08) : null,
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDestructive
              ? AppTheme.error
              : isActive
              ? AppTheme.primary
              : AppTheme.textSecondary,
          size: 24,
        ),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            color: isDestructive
                ? AppTheme.error
                : isActive
                ? AppTheme.primary
                : AppTheme.textPrimary,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        onTap: onTap,
      ),
    );
  }
}
