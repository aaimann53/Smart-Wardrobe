import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'utils/app_state.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/main_shell.dart';
import 'screens/add_clothing_screen.dart';
import 'screens/outfit_suggestions_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/ai_suggest_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // TEMPORARY — remove once you've confirmed Firebase connects successfully.
  print('✅ Firebase connected: ${Firebase.apps.length} app(s) initialized');

  runApp(
    ChangeNotifierProvider(create: (_) => AppState(), child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Wardrobe',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const MainShell(),
        '/add-clothing': (context) => const AddClothingScreen(),
        '/outfits': (context) => const OutfitSuggestionsScreen(),
        '/notifications': (context) => const NotificationsScreen(),
        '/ai-suggest': (context) => const AiSuggestScreen(),
      },
    );
  }
}
