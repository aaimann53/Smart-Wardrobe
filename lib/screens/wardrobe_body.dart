import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/clothing_item.dart';
import '../models/wardrobe_category.dart';
import '../theme/app_theme.dart';
import '../utils/app_state.dart';
import '../utils/dummy_data.dart';
import 'add_clothing_screen.dart';

class WardrobeBody extends StatefulWidget {
  /// If set, the wardrobe opens already filtered to this clothing
  /// category (e.g. "Accessories", "Dresses") instead of "All".
  final String? initialCategory;

  /// If set, the wardrobe opens already filtered to this season
  /// (e.g. "Summer", "Winter") instead of showing every season.
  final String? initialSeason;

  const WardrobeBody({super.key, this.initialCategory, this.initialSeason});

  @override
  State<WardrobeBody> createState() => _WardrobeBodyState();
}

class _WardrobeBodyState extends State<WardrobeBody> {
  final _searchController = TextEditingController();
  late String _selectedCategory;
  String? _selectedSubcategory;
  String _searchQuery = '';
  late String? _selectedSeason;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory ?? 'All';
    _selectedSeason = widget.initialSeason;
  }

  WardrobeCategory get _currentCategory {
    return DummyData.categories.firstWhere(
      (c) => c.name == _selectedCategory,
      orElse: () => DummyData.categories.first,
    );
  }

  bool get _hasSubcategories => _currentCategory.subcategories.isNotEmpty;

  List<ClothingItem> _filteredItems(List<ClothingItem> items) {
    var filtered = items;
    if (_selectedCategory != 'All') {
      filtered = filtered
          .where((i) => i.category == _selectedCategory)
          .toList();
      if (_selectedSubcategory != null && _selectedSubcategory!.isNotEmpty) {
        filtered = filtered
            .where((i) => i.subcategory == _selectedSubcategory)
            .toList();
      }
    }
    if (_selectedSeason != null) {
      filtered = filtered
          .where((i) => i.season == _selectedSeason || i.season == 'All Season')
          .toList();
    }
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (i) => i.name.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }
    return filtered;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = context.watch<AppState>().clothingItems;
    final filtered = _filteredItems(items);

    return Stack(
      children: [
        Column(
          children: [
            _buildSearchBar(),
            if (_selectedSeason != null) _buildSeasonBanner(),
            _buildMainCategoryChips(),
            if (_hasSubcategories && _selectedCategory != 'All')
              _buildSubcategoryChips(),
            const SizedBox(height: 12),
            _buildItemCount(filtered.length),
            Expanded(child: _buildGrid(filtered, context)),
          ],
        ),
        Positioned(
          right: 20,
          bottom: 24,
          child: FloatingActionButton.extended(
            heroTag: 'add_clothing',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddClothingScreen()),
              );
            },
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add Clothing'),
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildSeasonBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.accent.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.filter_alt_rounded,
              size: 18,
              color: AppTheme.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Showing $_selectedSeason items',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primary,
                ),
              ),
            ),
            GestureDetector(
              onTap: () => setState(() => _selectedSeason = null),
              child: const Icon(
                Icons.close_rounded,
                size: 18,
                color: AppTheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppTheme.softShadow,
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (v) => setState(() => _searchQuery = v),
          style: const TextStyle(fontSize: 15, color: AppTheme.textPrimary),
          decoration: InputDecoration(
            hintText: 'Search your wardrobe...',
            hintStyle: TextStyle(
              fontSize: 15,
              color: AppTheme.textSecondary.withValues(alpha: 0.6),
            ),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: AppTheme.textSecondary,
              size: 22,
            ),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(
                      Icons.clear_rounded,
                      size: 20,
                      color: AppTheme.textSecondary,
                    ),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppTheme.primary, width: 2),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainCategoryChips() {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: DummyData.categories.map((cat) {
          final isSelected = _selectedCategory == cat.name;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() {
                _selectedCategory = cat.name;
                _selectedSubcategory = null;
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primary : AppTheme.surface,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.primary
                        : AppTheme.textSecondary.withValues(alpha: 0.15),
                  ),
                  boxShadow: isSelected ? AppTheme.softShadow : null,
                ),
                child: Text(
                  cat.name,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : AppTheme.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSubcategoryChips() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: _currentCategory.subcategories.map((sub) {
          final isSelected = _selectedSubcategory == sub;
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: GestureDetector(
              onTap: () => setState(() {
                _selectedSubcategory = isSelected ? null : sub;
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.accent.withValues(alpha: 0.2)
                      : AppTheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.accent
                        : AppTheme.textSecondary.withValues(alpha: 0.12),
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Text(
                  sub,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? AppTheme.primary
                        : AppTheme.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildItemCount(int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Text(
            '$count item${count != 1 ? 's' : ''}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(List<ClothingItem> items, BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.checkroom_outlined,
              size: 64,
              color: AppTheme.textSecondary.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            const Text(
              'No items yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap + to add your first clothing item',
              style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 110),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: items.length,
      itemBuilder: (_, index) {
        final item = items[index];
        return GestureDetector(
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: AppTheme.softShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        kIsWeb
                            ? Image.network(
                                item.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Container(
                                  color: AppTheme.background,
                                  child: const Icon(
                                    Icons.broken_image,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              )
                            : Image.file(
                                File(item.imageUrl),
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Container(
                                  color: AppTheme.background,
                                  child: const Icon(
                                    Icons.broken_image,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () => context
                                .read<AppState>()
                                .toggleFavorite(item.id),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.9),
                                shape: BoxShape.circle,
                                boxShadow: AppTheme.softShadow,
                              ),
                              child: Icon(
                                item.isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                size: 18,
                                color: item.isFavorite
                                    ? AppTheme.error
                                    : AppTheme.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.category,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
