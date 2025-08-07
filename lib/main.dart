import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'shared/bookmark_provider.dart';
import 'shared/subscription_provider.dart';
import 'screens/home_screen.dart';
import 'screens/tender_screen.dart';
import 'screens/favourite_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Create subscription provider and initialize it
  final subscriptionProvider = SubscriptionProvider();
  await subscriptionProvider.initializeSubscription('default_user');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BookmarkProvider()),
        ChangeNotifierProvider.value(value: subscriptionProvider),
      ],
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
        fontFamily: 'Montserrat',
      ),
      initialRoute: '/splash',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/splash':
            return MaterialPageRoute(builder: (_) => const SplashScreen());
          case '/login':
            return MaterialPageRoute(builder: (_) => LoginScreen());
          case '/signup':
            return MaterialPageRoute(builder: (_) => SignupScreen());
          case '/home':
            {
              final args = settings.arguments as Map<String, dynamic>?;
              final userEmail = args != null && args['userEmail'] != null
                  ? args['userEmail'] as String
                  : '';
              return MaterialPageRoute(
                builder: (_) => HomeScreen(userEmail: userEmail),
              );
            }
          case '/tenders':
            return MaterialPageRoute(builder: (_) => TenderScreen());
          case '/notifications':
            return MaterialPageRoute(builder: (_) => FavoriteScreen());
          case '/profile':
            {
              final args = settings.arguments as Map<String, dynamic>?;
              final userEmail = args != null && args['userEmail'] != null
                  ? args['userEmail'] as String
                  : 'user@example.com';
              return MaterialPageRoute(
                builder: (_) => ProfileScreen(userEmail: userEmail),
              );
            }
          default:
            return MaterialPageRoute(builder: (_) => const SplashScreen());
        }
      },
    );
  }
}
