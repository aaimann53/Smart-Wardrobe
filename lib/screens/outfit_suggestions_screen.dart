import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'outfits_body.dart';

class OutfitSuggestionsScreen extends StatelessWidget {
  const OutfitSuggestionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        title: const Text('Outfit Suggestions'),
      ),
      body: const OutfitSuggestionsBody(),
    );
  }
}
