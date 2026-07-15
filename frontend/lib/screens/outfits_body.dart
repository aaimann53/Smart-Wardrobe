import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/outfit.dart';
import '../theme/app_theme.dart';
import '../utils/app_state.dart';
import '../utils/dummy_data.dart';
import '../widgets/outfit_card.dart';

class OutfitSuggestionsBody extends StatefulWidget {
  const OutfitSuggestionsBody({super.key});

  @override
  State<OutfitSuggestionsBody> createState() => _OutfitSuggestionsBodyState();
}

class _OutfitSuggestionsBodyState extends State<OutfitSuggestionsBody> {
  String _selectedOccasion = 'All';

  List<Outfit> _filteredOutfits(AppState state) {
    final gender = state.isMaleWardrobe ? 'male' : 'female';
    final byGender = DummyData.outfits
        .where((o) => o.wardrobeType == gender)
        .toList();
    if (_selectedOccasion == 'All') return byGender;
    return byGender.where((o) => o.occasion == _selectedOccasion).toList();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final filteredOutfits = _filteredOutfits(state);
    final occasions = ['All', 'Office', 'Casual', 'Party', 'Wedding'];
    return Column(
      children: [
        const SizedBox(height: 8),
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: occasions.map((occ) {
              final isSelected = _selectedOccasion == occ;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedOccasion = occ),
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
                      occ,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: filteredOutfits.isEmpty
              ? Center(
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
                        'No outfits found',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.65,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: filteredOutfits.length,
                  itemBuilder: (_, index) {
                    final outfit = filteredOutfits[index];
                    return OutfitCard(
                      outfit: outfit,
                      onLike: () =>
                          setState(() => outfit.isLiked = !outfit.isLiked),
                      onTap: () => _showOutfitDetail(context, outfit),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _showOutfitDetail(BuildContext context, Outfit outfit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        minChildSize: 0.4,
        maxChildSize: 0.85,
        expand: false,
        builder: (_, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.textSecondary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  outfit.imageUrl,
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    height: 250,
                    color: AppTheme.background,
                    child: const Icon(
                      Icons.broken_image,
                      size: 48,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      outfit.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      outfit.isLiked ? Icons.favorite : Icons.favorite_border,
                      color: outfit.isLiked
                          ? AppTheme.error
                          : AppTheme.textSecondary,
                    ),
                    onPressed: () =>
                        setState(() => outfit.isLiked = !outfit.isLiked),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  outfit.occasion,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.accent,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Items in this outfit:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              ...outfit.items.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.check,
                          size: 16,
                          color: AppTheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        item,
                        style: const TextStyle(
                          fontSize: 15,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Outfit added to your planner!'),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.calendar_month_rounded),
                  label: const Text('Plan This Outfit'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
