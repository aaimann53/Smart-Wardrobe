import 'package:flutter/material.dart';
import '../models/clothing_item.dart';
import '../models/wardrobe_category.dart';
import '../theme/app_theme.dart';
import '../utils/dummy_data.dart';
import '../widgets/clothing_card.dart';

class WardrobeBody extends StatefulWidget {
  const WardrobeBody({super.key});

  @override
  State<WardrobeBody> createState() => _WardrobeBodyState();
}

class _WardrobeBodyState extends State<WardrobeBody> {
  final _searchController = TextEditingController();
  String _selectedCategory = 'All';
  String? _selectedSubcategory;
  String _searchQuery = '';

  WardrobeCategory get _currentCategory {
    return DummyData.categories.firstWhere(
      (c) => c.name == _selectedCategory,
      orElse: () => DummyData.categories.first,
    );
  }

  bool get _hasSubcategories => _currentCategory.subcategories.isNotEmpty;

  List<ClothingItem> get _filteredItems {
    var items = DummyData.clothingItems;
    if (_selectedCategory != 'All') {
      items = items.where((i) => i.category == _selectedCategory).toList();
      if (_selectedSubcategory != null && _selectedSubcategory!.isNotEmpty) {
        items = items.where((i) => i.subcategory == _selectedSubcategory).toList();
      }
    }
    if (_searchQuery.isNotEmpty) {
      items = items
          .where((i) => i.name.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }
    return items;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSearchBar(),
        _buildMainCategoryChips(),
        if (_hasSubcategories && _selectedCategory != 'All') _buildSubcategoryChips(),
        const SizedBox(height: 12),
        _buildItemCount(),
        Expanded(child: _buildGrid()),
      ],
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
            prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.textSecondary, size: 22),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded, size: 20, color: AppTheme.textSecondary),
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
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 8 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
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
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
                    boxShadow: isSelected ? AppTheme.softShadow : null,
                  ),
                  child: Text(
                    sub,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildItemCount() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Text(
            '${_filteredItems.length} item${_filteredItems.length != 1 ? 's' : ''}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondary,
            ),
          ),
          if (_selectedSubcategory != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppTheme.accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _selectedSubcategory!,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGrid() {
    if (_filteredItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 64,
              color: AppTheme.textSecondary.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            const Text(
              'No items found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try a different category or search term',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _filteredItems.length,
      itemBuilder: (_, index) {
        final item = _filteredItems[index];
        return ClothingCard(
          item: item,
          onFavoriteTap: () => setState(() => item.isFavorite = !item.isFavorite),
        );
      },
    );
  }
}
