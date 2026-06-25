import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'home_body.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        title: const Text('Smart Wardrobe'),
      ),
      body: const HomeDashboardBody(),
    );
  }
}
