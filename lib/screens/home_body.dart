import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/category_carousel.dart';
import '../widgets/section_header.dart';

class HomeDashboardBody extends StatelessWidget {
  final void Function(int page)? onNavigateToPage;
  final void Function(CarouselCategory category)? onNavigateToCategory;

  const HomeDashboardBody({
    super.key,
    this.onNavigateToPage,
    this.onNavigateToCategory,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // NOTE: no horizontal padding wrapper here — the carousel is
          // full-bleed and fills ~90% of the screen height.
          _buildCategoryCarousel(context),
          const SizedBox(height: 24),
          const SectionHeader(title: 'Quick Actions'),
          const SizedBox(height: 12),
          _buildQuickActions(context),
        ],
      ),
    );
  }

  Widget _buildCategoryCarousel(BuildContext context) {
    // No Padding wrapper — CategoryCarousel renders full-width.
    // Height is 90% of the screen height so the carousel acts as a
    // true full-screen hero, with just a sliver of Quick Actions
    // peeking below to hint that there's more to scroll to.
    final screenHeight = MediaQuery.of(context).size.height;
    return CategoryCarousel(
      categories: homeCarouselCategories,
      height: screenHeight * 0.9,
      onCategoryTap: (category) {
        if (onNavigateToCategory != null) {
          onNavigateToCategory!(category);
        }
      },
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      {
        'icon': Icons.checkroom_rounded,
        'label': 'My Wardrobe',
        'color': const Color(0xFF8B6F47),
        'page': 1,
      },
      {
        'icon': Icons.add_circle_outline,
        'label': 'Add Item',
        'color': const Color(0xFFD4A574),
        'route': '/add-clothing',
      },
      {
        'icon': Icons.style_rounded,
        'label': 'Outfits',
        'color': const Color(0xFFA68B6B),
        'page': 4,
      },
      {
        'icon': Icons.calendar_month_rounded,
        'label': 'Planner',
        'color': const Color(0xFFB8956A),
        'page': 2,
      },
      {
        'icon': Icons.notifications_rounded,
        'label': 'Alerts',
        'color': const Color(0xFFC0392B),
        'page': 5,
      },
      {
        'icon': Icons.person_rounded,
        'label': 'Profile',
        'color': const Color(0xFF7B5B3A),
        'page': 3,
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.9,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: actions.length,
        itemBuilder: (_, index) {
          final action = actions[index];
          return GestureDetector(
            onTap: () {
              if (action.containsKey('page')) {
                if (onNavigateToPage != null) {
                  onNavigateToPage!(action['page'] as int);
                }
              } else if (action.containsKey('route')) {
                Navigator.pushNamed(context, action['route'] as String);
              }
            },
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: AppTheme.softShadow,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: (action['color'] as Color).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      action['icon'] as IconData,
                      color: action['color'] as Color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    action['label'] as String,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
