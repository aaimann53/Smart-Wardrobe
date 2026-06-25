class Outfit {
  final String id;
  final String title;
  final String occasion;
  final String imageUrl;
  final List<String> items;
  bool isLiked;

  Outfit({
    required this.id,
    required this.title,
    required this.occasion,
    required this.imageUrl,
    required this.items,
    this.isLiked = false,
  });
}
