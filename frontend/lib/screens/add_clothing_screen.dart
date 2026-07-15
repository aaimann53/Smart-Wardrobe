import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/clothing_item.dart';
import '../theme/app_theme.dart';
import '../utils/app_state.dart';
import '../utils/dummy_data.dart';

class AddClothingScreen extends StatefulWidget {
  const AddClothingScreen({super.key});

  @override
  State<AddClothingScreen> createState() => _AddClothingScreenState();
}

class _AddClothingScreenState extends State<AddClothingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _selectedCategory = '';
  String _selectedColor = 'Blue';
  String _selectedSeason = 'All Season';
  String _selectedPieces = '1 Piece';
  final List<XFile?> _pickedImages = [];
  final ImagePicker _picker = ImagePicker();

  int get _pieceCount {
    return int.tryParse(_selectedPieces.replaceAll(RegExp(r'[^0-9]'), '')) ?? 1;
  }

  @override
  void initState() {
    super.initState();
    final appState = context.read<AppState>();
    final cats = appState.isMaleWardrobe
        ? DummyData.maleCategories
        : DummyData.categories;
    final firstCategory = cats.length > 1 ? cats[1].name : 'Tops';
    _selectedCategory = firstCategory;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(int index, ImageSource source) async {
    final XFile? image = await _picker.pickImage(
      source: source,
      imageQuality: 80,
    );
    if (image != null) {
      setState(() {
        while (_pickedImages.length <= index) {
          _pickedImages.add(null);
        }
        _pickedImages[index] = image;
      });
    }
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      final hasImages = _pickedImages.any((img) => img != null);
      if (!hasImages) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please add an image of your clothing item'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: AppTheme.error,
          ),
        );
        return;
      }

      final primaryImage = _pickedImages
          .firstWhere((img) => img != null, orElse: () => null)!
          .path;

      final newItem = ClothingItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        category: _selectedCategory,
        subcategory: '',
        color: _selectedColor,
        season: _selectedSeason,
        imageUrl: primaryImage,
        isFavorite: false,
        dressPieces: _pieceCount,
      );

      context.read<AppState>().addClothingItem(newItem);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 22),
              SizedBox(width: 12),
              Text('Clothing item added to your wardrobe!'),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: AppTheme.primary,
          duration: const Duration(seconds: 2),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final categoryList = appState.isMaleWardrobe
        ? DummyData.maleCategories.skip(1).map((c) => c.name).toList()
        : DummyData.categories.skip(1).map((c) => c.name).toList();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        title: const Text('Add Clothing Item'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Image upload area ──
              _buildImageArea(),
              const SizedBox(height: 24),

              // ── Clothing Name ──
              _buildLabel('Clothing Name'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppTheme.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'e.g., White Linen Shirt',
                  hintStyle: TextStyle(
                    fontSize: 15,
                    color: AppTheme.textSecondary.withValues(alpha: 0.6),
                  ),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Please enter a name' : null,
              ),
              const SizedBox(height: 20),

              // ── Category + Color row ──
              Row(
                children: [
                  Expanded(
                    child: _buildDropdown(
                      'Category',
                      _selectedCategory,
                      categoryList,
                      (v) => setState(() => _selectedCategory = v!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDropdown(
                      'Color',
                      _selectedColor,
                      DummyData.colors,
                      (v) => setState(() => _selectedColor = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Season + Pieces row ──
              Row(
                children: [
                  Expanded(
                    child: _buildDropdown(
                      'Season',
                      _selectedSeason,
                      DummyData.seasons,
                      (v) => setState(() => _selectedSeason = v!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDropdown(
                      'Dress Pieces',
                      _selectedPieces,
                      DummyData.dressPiecesOptions,
                      (v) => setState(() {
                        _selectedPieces = v!;
                        _pickedImages.clear();
                      }),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── Dynamic image upload slots ──
              _buildLabel('Upload Images ($_pieceCount piece${_pieceCount > 1 ? 's' : ''})'),
              const SizedBox(height: 8),
              ...List.generate(_pieceCount, (i) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildImageSlot(i),
                );
              }),

              const SizedBox(height: 32),

              // ── Save button ──
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    'Save to Wardrobe',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageArea() {
    // Show the first picked image as main preview if available
    final firstImage = _pickedImages.isNotEmpty ? _pickedImages.first : null;
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.softShadow,
      ),
      child: firstImage != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  kIsWeb
                      ? Image.network(firstImage.path, fit: BoxFit.cover)
                      : Image.file(File(firstImage.path), fit: BoxFit.cover),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: GestureDetector(
                      onTap: () => setState(() {
                        _pickedImages.clear();
                      }),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _imageButton(
                    icon: Icons.camera_alt_rounded,
                    label: 'Camera',
                    onTap: () => _pickImage(0, ImageSource.camera),
                  ),
                  const SizedBox(width: 20),
                  _imageButton(
                    icon: Icons.photo_library_rounded,
                    label: 'Gallery',
                    onTap: () => _pickImage(0, ImageSource.gallery),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildImageSlot(int index) {
    while (_pickedImages.length <= index) {
      _pickedImages.add(null);
    }
    final picked = _pickedImages[index];
    final labels = ['Image ${index + 1}'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labels.first,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 140,
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: AppTheme.softShadow,
          ),
          child: picked != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      kIsWeb
                          ? Image.network(picked.path, fit: BoxFit.cover)
                          : Image.file(
                              File(picked.path),
                              fit: BoxFit.cover,
                            ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () =>
                              setState(() => _pickedImages[index] = null),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.5),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _imageButton(
                        icon: Icons.camera_alt_rounded,
                        label: 'Camera',
                        onTap: () => _pickImage(index, ImageSource.camera),
                      ),
                      const SizedBox(width: 16),
                      _imageButton(
                        icon: Icons.photo_library_rounded,
                        label: 'Gallery',
                        onTap: () => _pickImage(index, ImageSource.gallery),
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  Widget _imageButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          color: AppTheme.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.textSecondary.withValues(alpha: 0.15),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppTheme.primary, size: 30),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppTheme.textPrimary,
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppTheme.softShadow,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              items: items
                  .map(
                    (item) => DropdownMenuItem(value: item, child: Text(item)),
                  )
                  .toList(),
              onChanged: onChanged,
              style: const TextStyle(
                fontSize: 15,
                color: AppTheme.textPrimary,
              ),
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
