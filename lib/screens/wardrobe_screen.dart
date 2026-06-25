import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'wardrobe_body.dart';

class WardrobeScreen extends StatelessWidget {
  const WardrobeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        title: const Text('My Wardrobe'),
      ),
      body: const WardrobeBody(),
    );
  }
}
