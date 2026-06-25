import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/main_shell.dart';
import 'screens/wardrobe_screen.dart';
import 'screens/add_clothing_screen.dart';
import 'screens/outfit_suggestions_screen.dart';
import 'screens/calendar_planner_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/profile_screen.dart';

void main() {
  runApp(const SmartWardrobeApp());
}

class SmartWardrobeApp extends StatelessWidget {
  const SmartWardrobeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Wardrobe',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        WidgetBuilder builder;
        switch (settings.name) {
          case '/':
            builder = (_) => const SplashScreen();
          case '/login':
            builder = (_) => const LoginScreen();
          case '/register':
            builder = (_) => const RegisterScreen();
          case '/home':
            builder = (_) => const MainShell();
          case '/wardrobe':
            builder = (_) => const WardrobeScreen();
          case '/add-clothing':
            builder = (_) => const AddClothingScreen();
          case '/outfits':
            builder = (_) => const OutfitSuggestionsScreen();
          case '/calendar':
            builder = (_) => const CalendarPlannerScreen();
          case '/notifications':
            builder = (_) => const NotificationsScreen();
          case '/profile':
            builder = (_) => const ProfileScreen();
          default:
            builder = (_) => const SplashScreen();
        }
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => builder(context),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1, 0);
            const end = Offset.zero;
            const curve = Curves.easeInOutCubic;
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
              CurvedAnimation(parent: animation, curve: curve),
            );
            return SlideTransition(
              position: animation.drive(tween),
              child: FadeTransition(
                opacity: fadeAnimation,
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 350),
        );
      },
    );
  }
}
