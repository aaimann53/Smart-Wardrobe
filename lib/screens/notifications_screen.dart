import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'notifications_body.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        title: const Text('Notifications'),
      ),
      body: const NotificationsBody(),
    );
  }
}
