import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';

/// One slide in the home-page carousel.
///
/// [filterType] tells the wardrobe screen whether to filter by
/// clothing `category` (e.g. "Accessories") or by `season`
/// (e.g. "Summer"). [filterValue] is the actual value to match.
class CarouselCategory {
  final String title;
  final String subtitle;
  final String imageAsset;
  final CarouselFilterType filterType;
  final String filterValue;

  const CarouselCategory({
    required this.title,
    required this.subtitle,
    required this.imageAsset,
    required this.filterType,
    required this.filterValue,
  });
}

enum CarouselFilterType { category, season }

/// Dummy slides for the home page. Edit/add entries here — everything
/// else wires itself up automatically. Uses your existing local assets
/// from ImageConstants, no network images.
final List<CarouselCategory> homeCarouselCategories = [
  CarouselCategory(
    title: 'Summer Clothes',
    subtitle: 'Light & breezy picks',
    imageAsset: ImageConstants.casual1,
    filterType: CarouselFilterType.season,
    filterValue: 'Summer',
  ),
  CarouselCategory(
    title: 'Winter Clothes',
    subtitle: 'Cozy & warm layers',
    imageAsset: ImageConstants.jacket1,
    filterType: CarouselFilterType.season,
    filterValue: 'Winter',
  ),
  CarouselCategory(
    title: 'Accessories',
    subtitle: 'Bags, jewelry & more',
    imageAsset: ImageConstants.accessory1,
    filterType: CarouselFilterType.category,
    filterValue: 'Accessories',
  ),
  CarouselCategory(
    title: 'Dresses',
    subtitle: 'For every occasion',
    imageAsset: ImageConstants.dress1,
    filterType: CarouselFilterType.category,
    filterValue: 'Dresses',
  ),
];

/// Swipeable, full-bleed carousel banner. Spans the entire screen width
/// with no side padding — drop this where the black banner placeholder
/// currently sits at the top of the home page.
class CategoryCarousel extends StatefulWidget {
  final List<CarouselCategory> categories;
  final void Function(CarouselCategory category) onCategoryTap;
  final double height;

  const CategoryCarousel({
    super.key,
    required this.categories,
    required this.onCategoryTap,
    this.height = 320,
  });

  @override
  State<CategoryCarousel> createState() => _CategoryCarouselState();
}

class _CategoryCarouselState extends State<CategoryCarousel> {
  late final PageController _controller;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 1.0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: widget.height,
          width: double.infinity,
          child: ClipRRect(
            borderRadius: BorderRadius.zero,
            child: PageView.builder(
              controller: _controller,
              physics: const BouncingScrollPhysics(),
              itemCount: widget.categories.length,
              onPageChanged: (i) => setState(() => _currentPage = i),
              itemBuilder: (context, index) {
                final category = widget.categories[index];
                return _CarouselCard(
                  category: category,
                  onTap: () => widget.onCategoryTap(category),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.categories.length, (index) {
            final isActive = index == _currentPage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: isActive ? 18 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: isActive
                    ? AppTheme.primary
                    : AppTheme.textSecondary.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _CarouselCard extends StatelessWidget {
  final CarouselCategory category;
  final VoidCallback onTap;

  const _CarouselCard({required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // No horizontal padding here — full-bleed, edge to edge.
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Image.asset(
              category.imageAsset,
              // Fill the whole slide, edge to edge — no gray bars.
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                color: AppTheme.background,
                child: const Icon(
                  Icons.image_not_supported_outlined,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 22,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    category.subtitle,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
          // Moved from top-right to top-left.
          Positioned(
            top: 16,
            left: 16,
            child: CircleAvatar(
              radius: 15,
              backgroundColor: Colors.white24,
              child: const Icon(
                Icons.arrow_forward,
                color: Colors.white,
                size: 17,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
