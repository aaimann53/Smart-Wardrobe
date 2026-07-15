class UserModel {
  final String id;
  final String name;
  final String email;
  final String password;
  final String favoriteStyle;
  final String favoriteColor;
  final String profileImage;
  final String wardrobeType;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    this.favoriteStyle = 'Casual',
    this.favoriteColor = 'Blue',
    this.profileImage = '',
    this.wardrobeType = 'female',
  });
}
