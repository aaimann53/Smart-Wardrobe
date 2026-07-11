import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/clothing_item.dart';
import 'dummy_data.dart';

class AppState extends ChangeNotifier {
  AppState() {
    clothingItems = List<ClothingItem>.from(DummyData.clothingItems);
    name = 'Alex';
    email = 'alex@example.com';
    favoriteStyle = 'Casual';
    favoriteColor = 'Blue';
  }

  // ── Profile ──────────────────────────────────────
  String name = '';
  String email = '';
  String favoriteStyle = 'Casual';
  String favoriteColor = 'Blue';
  XFile? profileImage;

  void updateProfile({
    required String newName,
    required String newEmail,
    required String newStyle,
    required String newColor,
    XFile? newImage,
  }) {
    name = newName;
    email = newEmail;
    favoriteStyle = newStyle;
    favoriteColor = newColor;
    if (newImage != null) profileImage = newImage;
    notifyListeners();
  }

  // ── Clothing Items ────────────────────────────────
  List<ClothingItem> clothingItems = [];

  void addClothingItem(ClothingItem item) {
    clothingItems.add(item);
    notifyListeners();
  }

  void toggleFavorite(String id) {
    final index = clothingItems.indexWhere((i) => i.id == id);
    if (index != -1) {
      clothingItems[index].isFavorite = !clothingItems[index].isFavorite;
      notifyListeners();
    }
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
