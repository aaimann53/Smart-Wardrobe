class ClothingItem {
  final String id;
  final String name;
  final String category;
  final String subcategory;
  final String color;
  final String season;
  final String imageUrl;
  bool isFavorite;
  final int dressPieces;

  ClothingItem({
    required this.id,
    required this.name,
    required this.category,
    this.subcategory = '',
    required this.color,
    required this.season,
    required this.imageUrl,
    this.isFavorite = false,
    this.dressPieces = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'subcategory': subcategory,
      'color': color,
      'season': season,
      'imageUrl': imageUrl,
      'isFavorite': isFavorite,
      'dressPieces': dressPieces,
    };
  }

  factory ClothingItem.fromMap(Map<String, dynamic> map) {
    return ClothingItem(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      category: map['category'] ?? '',
      subcategory: map['subcategory'] ?? '',
      color: map['color'] ?? '',
      season: map['season'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      isFavorite: map['isFavorite'] ?? false,
      dressPieces: map['dressPieces'] ?? 0,
    );
  }
}
