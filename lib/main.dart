import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'shared/bookmark_provider.dart';
import 'shared/subscription_provider.dart';
import 'providers/auth_provider.dart';
import 'screens/home_screen.dart';
import 'screens/tender_screen.dart';
import 'screens/favourite_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/notification_screen.dart';
import 'shared/will_pop_scope_state.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Initialize notification service
  await NotificationService().initialize();

  // Create subscription provider and initialize it
  final subscriptionProvider = SubscriptionProvider();
  await subscriptionProvider.initializeSubscription('default_user');

  // Create and initialize auth provider
  final authProvider = AuthProvider();
  await authProvider.initializeAuth();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BookmarkProvider()),
        ChangeNotifierProvider.value(value: subscriptionProvider),
        ChangeNotifierProvider.value(value: authProvider),
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
            return MaterialPageRoute(
              builder: (_) => Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  // If still loading, show splash screen
                  if (authProvider.isLoading) {
                    return const SplashScreen();
                  }

                  // If user is logged in, go to home
                  if (authProvider.isLoggedIn) {
                    return HomeScreen(
                      userEmail: authProvider.userEmail,
                      userName: authProvider.userName,
                      showWelcome: false,
                    );
                  }

                  // If not logged in, show login screen
                  return const LoginScreen();
                },
              ),
            );
          case '/login':
            return MaterialPageRoute(
              builder: (context) {
                return WillPopScope(
                  onWillPop: () async {
                    final now = DateTime.now();
                    if (WillPopScopeState.lastBackPress == null ||
                        now.difference(WillPopScopeState.lastBackPress!) >
                            const Duration(seconds: 2)) {
                      WillPopScopeState.lastBackPress = now;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Press back again to exit'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                      return false;
                    }
                    WillPopScopeState.lastBackPress = null;
                    return true;
                  },
                  child: const LoginScreen(),
                );
              },
            );
          case '/signup':
            return MaterialPageRoute(
              builder: (context) {
                return WillPopScope(
                  onWillPop: () async {
                    final now = DateTime.now();
                    if (WillPopScopeState.lastBackPress == null ||
                        now.difference(WillPopScopeState.lastBackPress!) >
                            const Duration(seconds: 2)) {
                      WillPopScopeState.lastBackPress = now;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Press back again to exit'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                      return false;
                    }
                    return true;
                  },
                  child: SignupScreen(),
                );
              },
            );
          case '/home':
            {
              final args = settings.arguments as Map<String, dynamic>?;
              final userEmail = args != null && args['userEmail'] != null
                  ? args['userEmail'] as String
                  : '';
              return MaterialPageRoute(
                builder: (context) {
                  return WillPopScope(
                    onWillPop: () async {
                      final now = DateTime.now();
                      if (WillPopScopeState.lastBackPress == null ||
                          now.difference(WillPopScopeState.lastBackPress!) >
                              const Duration(seconds: 2)) {
                        WillPopScopeState.lastBackPress = now;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Press back again to exit'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                        return false;
                      }
                      return true;
                    },
                    child: HomeScreen(userEmail: userEmail),
                  );
                },
              );
            }
          case '/tenders':
            return MaterialPageRoute(
              builder: (context) {
                return WillPopScope(
                  onWillPop: () async {
                    final now = DateTime.now();
                    if (WillPopScopeState.lastBackPress == null ||
                        now.difference(WillPopScopeState.lastBackPress!) >
                            const Duration(seconds: 2)) {
                      WillPopScopeState.lastBackPress = now;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Press back again to exit'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                      return false;
                    }
                    return true;
                  },
                  child: TenderScreen(),
                );
              },
            );
          case '/favorites':
            return MaterialPageRoute(
              builder: (context) {
                return WillPopScope(
                  onWillPop: () async {
                    final now = DateTime.now();
                    if (WillPopScopeState.lastBackPress == null ||
                        now.difference(WillPopScopeState.lastBackPress!) >
                            const Duration(seconds: 2)) {
                      WillPopScopeState.lastBackPress = now;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Press back again to exit'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                      return false;
                    }
                    return true;
                  },
                  child: FavoriteScreen(),
                );
              },
            );
          case '/notifications':
            return MaterialPageRoute(
              builder: (context) {
                return WillPopScope(
                  onWillPop: () async {
                    final now = DateTime.now();
                    if (WillPopScopeState.lastBackPress == null ||
                        now.difference(WillPopScopeState.lastBackPress!) >
                            const Duration(seconds: 2)) {
                      WillPopScopeState.lastBackPress = now;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Press back again to exit'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                      return false;
                    }
                    return true;
                  },
                  child: NotificationScreen(),
                );
              },
            );
          case '/profile':
            {
              final args = settings.arguments as Map<String, dynamic>?;
              final userEmail = args != null && args['userEmail'] != null
                  ? args['userEmail'] as String
                  : 'user@example.com';
              // Custom back button logic for ProfileScreen
              return MaterialPageRoute(
                builder: (context) {
                  return WillPopScope(
                    onWillPop: () async {
                      final now = DateTime.now();
                      if (WillPopScopeState.lastBackPress == null ||
                          now.difference(WillPopScopeState.lastBackPress!) >
                              const Duration(seconds: 2)) {
                        WillPopScopeState.lastBackPress = now;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Press back again to exit'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                        return false;
                      }
                      return true;
                    },
                    child: ProfileScreen(userEmail: userEmail),
                  );
                },
              );
            }
          default:
            return MaterialPageRoute(builder: (_) => const SplashScreen());
        }
      },
    );
  }
}
