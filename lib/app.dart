import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_colors.dart';
import 'core/constants/app_strings.dart';
import 'providers/auth_provider.dart';
import 'providers/listings_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/auth/email_verify_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/directory/directory_screen.dart';
import 'screens/map/map_view_screen.dart';
import 'screens/my_listings/my_listings_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';
import 'services/location_service.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            authService: AuthService(),
            firestoreService: FirestoreService(),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => ListingsProvider(
            firestoreService: FirestoreService(),
            locationService: LocationService(),
          )..startListeningToListings(),
        ),
        ChangeNotifierProvider(
          create: (_) => SettingsProvider()..loadPreferences(),
        ),
      ],
      child: MaterialApp(
        title: AppStrings.appTitle,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            brightness: Brightness.light,
            background: AppColors.background,
          ),
          scaffoldBackgroundColor: AppColors.background,
          appBarTheme: const AppBarTheme(
            elevation: 0,
            backgroundColor: AppColors.background,
            foregroundColor: AppColors.textPrimary,
            centerTitle: false,
          ),
          cardTheme: CardThemeData(
            color: AppColors.surface,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            hintStyle: const TextStyle(color: Colors.grey),
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: AppColors.navBackground,
            selectedItemColor: AppColors.navActive,
            unselectedItemColor: AppColors.navInactive,
            type: BottomNavigationBarType.fixed,
          ),
        ),
        home: const _RootRouter(),
      ),
    );
  }
}

class _RootRouter extends StatelessWidget {
  const _RootRouter();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.firebaseUser;

    if (user == null) {
      return const LoginScreen();
    }

    if (!auth.isEmailVerified) {
      return const EmailVerifyScreen();
    }

    return const HomeShell();
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DirectoryScreen(),
    MyListingsScreen(),
    MapViewScreen(),
    SettingsScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.navBackground,
      child: SafeArea(
        top: false,
        child: Scaffold(
          body: _screens[_currentIndex],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _onTabTapped,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_filled),
                label: AppStrings.tabDirectory,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bookmark),
                label: AppStrings.tabMyListings,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.map),
                label: AppStrings.tabMapView,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: AppStrings.tabSettings,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


