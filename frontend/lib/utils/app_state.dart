import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/clothing_item.dart';
import 'backend_service.dart';

class AppState extends ChangeNotifier {
  final BackendService _backend = BackendService();

  // ── Profile ──────────────────────────────────────
  String _uid = '';
  String name = '';
  String email = '';
  String favoriteStyle = 'Casual';
  String favoriteColor = 'Blue';
  String _wardrobeType = 'female';
  XFile? profileImage;

  String get wardrobeType => _wardrobeType;
  bool get isMaleWardrobe => _wardrobeType == 'male';
  String get uid => _uid;

  /// Load the user profile from the backend after login / registration.
  Future<void> loadProfileFromFirestore(String uid) async {
    _uid = uid;
    try {
      final data = await _backend.getUserProfile();
      name = data['name'] ?? '';
      email = data['email'] ?? '';
      favoriteStyle = data['favoriteStyle'] ?? 'Casual';
      favoriteColor = data['favoriteColor'] ?? 'Blue';
      _wardrobeType = data['wardrobeType'] ?? 'female';
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading profile: $e');
    }
  }

  /// Create a new profile via the backend (registration).
  Future<void> createProfile({
    required String newName,
    required String newEmail,
    required String newStyle,
    required String newColor,
    required String newWardrobeType,
  }) async {
    name = newName;
    email = newEmail;
    favoriteStyle = newStyle;
    favoriteColor = newColor;
    _wardrobeType = newWardrobeType;
    notifyListeners();

    await _backend.createUserProfile(
      name: newName,
      email: newEmail,
      favoriteStyle: newStyle,
      favoriteColor: newColor,
      wardrobeType: newWardrobeType,
    );
  }

  /// Update profile fields via the backend.
  Future<void> updateProfile({
    String? newUid,
    String? newName,
    String? newEmail,
    String? newStyle,
    String? newColor,
    XFile? newImage,
    String? newWardrobeType,
  }) async {
    if (newUid != null) _uid = newUid;
    if (newName != null) name = newName;
    if (newEmail != null) email = newEmail;
    if (newStyle != null) favoriteStyle = newStyle;
    if (newColor != null) favoriteColor = newColor;
    if (newImage != null) profileImage = newImage;
    if (newWardrobeType != null) _wardrobeType = newWardrobeType;
    notifyListeners();

    await _backend.updateUserProfile(
      name: newName,
      email: newEmail,
      favoriteStyle: newStyle,
      favoriteColor: newColor,
      wardrobeType: newWardrobeType,
    );
  }

  // ── Clothing Items ────────────────────────────────
  List<ClothingItem> clothingItems = [];

  /// Load all clothing items from the backend.
  Future<void> loadClothingItemsFromFirestore() async {
    try {
      clothingItems = await _backend.getClothingItems();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading clothing items: $e');
    }
  }

  /// Add a new clothing item via the backend.
  Future<void> addClothingItem(ClothingItem item) async {
    clothingItems.insert(0, item);
    notifyListeners();

    try {
      await _backend.addClothingItem(item);
    } catch (e) {
      debugPrint('Error saving clothing item: $e');
      // Rollback local state on failure
      clothingItems.removeWhere((i) => i.id == item.id);
      notifyListeners();
    }
  }

  /// Delete a clothing item via the backend.
  Future<void> deleteClothingItem(String itemId) async {
    final index = clothingItems.indexWhere((i) => i.id == itemId);
    if (index == -1) return;

    final removed = clothingItems.removeAt(index);
    notifyListeners();

    try {
      await _backend.deleteClothingItem(itemId);
    } catch (e) {
      debugPrint('Error deleting clothing item: $e');
      // Rollback on failure
      clothingItems.insert(index, removed);
      notifyListeners();
    }
  }

  /// Toggle favorite and persist via the backend.
  Future<void> toggleFavorite(String id) async {
    final index = clothingItems.indexWhere((i) => i.id == id);
    if (index == -1) return;

    clothingItems[index].isFavorite = !clothingItems[index].isFavorite;
    notifyListeners();

    try {
      final serverFavorite = await _backend.toggleFavorite(id);
      clothingItems[index].isFavorite = serverFavorite;
      notifyListeners();
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
      // Rollback on failure
      clothingItems[index].isFavorite = !clothingItems[index].isFavorite;
      notifyListeners();
    }
  }

  /// Reset all profile data on logout to prevent data leakage between accounts.
  void clearProfile() {
    _uid = '';
    name = '';
    email = '';
    favoriteStyle = 'Casual';
    favoriteColor = 'Blue';
    _wardrobeType = 'female';
    profileImage = null;
    clothingItems = [];
    plannedOutfits = {};
    notifyListeners();
  }

  // ── Planned Outfits ───────────────────────────────
  Map<DateTime, List<Map<String, String>>> plannedOutfits = {};

  void addPlannedOutfit(DateTime date, Map<String, String> outfit) {
    final key = DateTime(date.year, date.month, date.day);
    if (plannedOutfits[key] == null) {
      plannedOutfits[key] = [];
    }
    plannedOutfits[key]!.add(outfit);
    notifyListeners();
  }

  void removePlannedOutfit(DateTime date, int index) {
    final key = DateTime(date.year, date.month, date.day);
    final outfitsForDate = plannedOutfits[key];

    if (outfitsForDate == null) return;
    if (index < 0 || index >= outfitsForDate.length) return;

    outfitsForDate.removeAt(index);
    if (outfitsForDate.isEmpty) {
      plannedOutfits.remove(key);
    }
    notifyListeners();
  }

  List<Map<String, String>> getOutfitsForDate(DateTime date) {
    return plannedOutfits[DateTime(date.year, date.month, date.day)] ?? [];
  }
}
