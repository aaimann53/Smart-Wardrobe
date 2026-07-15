/// Server-side validation for all input data.
///
/// These match the Firestore security rules validation exactly,
/// providing defense-in-depth: even if security rules are bypassed,
/// the server still validates everything.
class Validators {
  static const validWardrobeTypes = ['male', 'female'];
  static const validStyles = [
    'Casual', 'Formal', 'Streetwear', 'Bohemian', 'Minimalist',
    'Sporty', 'Vintage', 'Preppy', 'Grunge', 'Classic',
  ];
  static const validCategories = [
    'Tops', 'Bottoms', 'Dresses', 'Outerwear', 'Footwear',
    'Accessories', 'Activewear', 'Sleepwear', 'Swimwear', 'Formal Wear',
  ];
  static const validSeasons = ['Spring', 'Summer', 'Fall', 'Winter', 'All Season'];
  static const validColors = [
    'Black', 'White', 'Gray', 'Navy', 'Blue', 'Red', 'Pink',
    'Green', 'Yellow', 'Orange', 'Purple', 'Brown', 'Beige', 'Cream',
    'Teal', 'Maroon', 'Olive', 'Coral', 'Ivory', 'Gold', 'Silver',
  ];

  static const maxNameLength = 50;
  static const maxEmailLength = 255;
  static const maxItemNameLength = 60;
  static const maxClothingItems = 500;

  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required.';
    }
    if (value.length > maxNameLength) {
      return 'Name must be $maxNameLength characters or fewer.';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required.';
    }
    if (value.length > maxEmailLength) {
      return 'Email must be $maxEmailLength characters or fewer.';
    }
    if (!value.contains('@') || !value.contains('.')) {
      return 'A valid email is required.';
    }
    return null;
  }

  static String? validateWardrobeType(String? value) {
    if (value == null || !validWardrobeTypes.contains(value)) {
      return 'wardrobeType must be one of: ${validWardrobeTypes.join(', ')}';
    }
    return null;
  }

  static String? validateStyle(String? value) {
    if (value != null && !validStyles.contains(value)) {
      return 'favoriteStyle must be one of: ${validStyles.join(', ')}';
    }
    return null;
  }

  static String? validateCategory(String? value) {
    if (value == null || !validCategories.contains(value)) {
      return 'Category must be one of: ${validCategories.join(', ')}';
    }
    return null;
  }

  static String? validateColor(String? value) {
    if (value == null || !validColors.contains(value)) {
      return 'Color must be one of: ${validColors.join(', ')}';
    }
    return null;
  }

  static String? validateSeason(String? value) {
    if (value == null || !validSeasons.contains(value)) {
      return 'Season must be one of: ${validSeasons.join(', ')}';
    }
    return null;
  }

  static String? validateItemName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Item name is required.';
    }
    if (value.length > maxItemNameLength) {
      return 'Item name must be $maxItemNameLength characters or fewer.';
    }
    return null;
  }

  static String? validateDressPieces(dynamic value) {
    if (value != null) {
      if (value is! int || value < 0 || value > 10) {
        return 'dressPieces must be an integer between 0 and 10.';
      }
    }
    return null;
  }

  /// Run all profile validations. Returns null if valid, or a list of errors.
  static List<String> validateProfile(Map<String, dynamic> data) {
    final errors = <String>[];

    if (data.containsKey('name')) {
      final e = validateName(data['name'] as String?);
      if (e != null) errors.add(e);
    }
    if (data.containsKey('email')) {
      final e = validateEmail(data['email'] as String?);
      if (e != null) errors.add(e);
    }
    if (data.containsKey('wardrobeType')) {
      final e = validateWardrobeType(data['wardrobeType'] as String?);
      if (e != null) errors.add(e);
    }
    if (data.containsKey('favoriteStyle')) {
      final e = validateStyle(data['favoriteStyle'] as String?);
      if (e != null) errors.add(e);
    }

    return errors;
  }

  /// Run all clothing item validations. Returns null if valid, or a list of errors.
  static List<String> validateClothingItem(Map<String, dynamic> data) {
    final errors = <String>[];

    final nameErr = validateItemName(data['name'] as String?);
    if (nameErr != null) errors.add(nameErr);

    final catErr = validateCategory(data['category'] as String?);
    if (catErr != null) errors.add(catErr);

    final colorErr = validateColor(data['color'] as String?);
    if (colorErr != null) errors.add(colorErr);

    final seasonErr = validateSeason(data['season'] as String?);
    if (seasonErr != null) errors.add(seasonErr);

    final dpErr = validateDressPieces(data['dressPieces']);
    if (dpErr != null) errors.add(dpErr);

    return errors;
  }
}
