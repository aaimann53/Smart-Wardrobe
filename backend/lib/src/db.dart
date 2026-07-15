/// Wrapper around Firestore for all database operations.
///
/// In production, swap these methods for real Firestore REST API calls
/// using the `http` package and the service account credentials.
class Database {
  final _profiles = <String, Map<String, dynamic>>{};
  final _clothingItems = <String, Map<String, dynamic>>{};

  // ── Profile Operations ────────────────────────────────────────────

  Map<String, dynamic>? getProfile(String uid) => _profiles[uid];

  void createProfile(String uid, Map<String, dynamic> profile) {
    _profiles[uid] = profile;
  }

  void updateProfile(String uid, Map<String, dynamic> updates) {
    final existing = _profiles[uid];
    if (existing == null) return;
    existing.addAll(updates);
    existing['updatedAt'] = DateTime.now().toUtc().toIso8601String();
  }

  void deleteProfile(String uid) {
    // Delete all clothing items for this user
    _clothingItems.removeWhere((key, value) => value['uid'] == uid);
    _profiles.remove(uid);
  }

  // ── Clothing Item Operations ──────────────────────────────────────

  List<Map<String, dynamic>> getClothingItems(String uid) {
    final items = _clothingItems.values
        .where((item) => item['uid'] == uid)
        .toList();
    items.sort((a, b) => (b['id'] ?? '').compareTo(a['id'] ?? ''));
    return items;
  }

  Map<String, dynamic>? getClothingItem(String uid, String itemId) {
    final key = '$uid/$itemId';
    final item = _clothingItems[key];
    if (item != null && item['uid'] == uid) return item;
    return null;
  }

  int getClothingItemCount(String uid) {
    return _clothingItems.values.where((item) => item['uid'] == uid).length;
  }

  void addClothingItem(String uid, Map<String, dynamic> item) {
    final key = '$uid/${item['id']}';
    item['uid'] = uid;
    _clothingItems[key] = item;
  }

  void updateClothingItem(String uid, String itemId, Map<String, dynamic> updates) {
    final key = '$uid/$itemId';
    final existing = _clothingItems[key];
    if (existing == null || existing['uid'] != uid) return;
    existing.addAll(updates);
    existing['updatedAt'] = DateTime.now().toUtc().toIso8601String();
  }

  bool deleteClothingItem(String uid, String itemId) {
    final key = '$uid/$itemId';
    final existing = _clothingItems[key];
    if (existing == null || existing['uid'] != uid) return false;
    _clothingItems.remove(key);
    return true;
  }

  bool toggleFavorite(String uid, String itemId) {
    final key = '$uid/$itemId';
    final existing = _clothingItems[key];
    if (existing == null || existing['uid'] != uid) return false;
    final current = existing['isFavorite'] as bool? ?? false;
    existing['isFavorite'] = !current;
    existing['updatedAt'] = DateTime.now().toUtc().toIso8601String();
    return !current;
  }
}

/// Singleton database instance.
final db = Database();
