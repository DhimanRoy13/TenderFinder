import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'shared/bookmark_provider.dart';
import 'screens/home_screen.dart';
import 'screens/tender_screen.dart';
import 'screens/favourite_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => BookmarkProvider())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tender Finder',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1C989C)),
        primaryColor: const Color(0xFF1C989C),
        useMaterial3: true,
        fontFamily: 'Poppins',
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignupScreen(),
        '/home': (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?;
          final userEmail = args != null && args['userEmail'] != null
              ? args['userEmail'] as String
              : '';
          return HomeScreen(userEmail: userEmail);
        },
        '/tenders': (context) => TenderScreen(),
        '/notifications': (context) => FavoriteScreen(),
        '/profile': (context) => ProfileScreen(userEmail: 'user@example.com'),
      },
    );
  }
}
