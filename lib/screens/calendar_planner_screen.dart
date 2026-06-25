import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'planner_body.dart';

class CalendarPlannerScreen extends StatelessWidget {
  const CalendarPlannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        title: const Text('Calendar Planner'),
      ),
      body: const CalendarPlannerBody(),
    );
  }
}
