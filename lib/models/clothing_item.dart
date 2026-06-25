class ClothingItem {
  final String id;
  final String name;
  final String category;
  final String subcategory;
  final String color;
  final String season;
  final String imageUrl;
  bool isFavorite;

  ClothingItem({
    required this.id,
    required this.name,
    required this.category,
    this.subcategory = '',
    required this.color,
    required this.season,
    required this.imageUrl,
    this.isFavorite = false,
  });
}
