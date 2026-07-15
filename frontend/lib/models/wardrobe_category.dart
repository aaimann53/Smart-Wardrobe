class WardrobeCategory {
  final String name;
  final List<String> subcategories;

  const WardrobeCategory({
    required this.name,
    this.subcategories = const [],
  });
}
