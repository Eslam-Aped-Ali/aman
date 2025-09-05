// lib/features/shared_features/splash/presentation/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:Aman/app/routing/app_routes_fun.dart';
import 'package:Aman/app/routing/routes.dart';
import 'package:Aman/core/shared/services/storage_service.dart';
import 'package:Aman/core/shared/services/splash_service.dart';
import 'package:Aman/features/shared_fetaures/auth/data/datasource/locale/auth_local_data_source.dart';
import 'package:Aman/features/shared_fetaures/auth/domain/entities/user.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    // Remove native splash after Flutter UI is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SplashService.remove();
    });

    // Reduced delay for smoother transition
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    try {
      // Check if intro has been completed
      final introCompleted = StorageService.getBool('intro_completed') ?? false;

      if (!introCompleted) {
        // First time user - show intro
        replacement(NamedRoutes.i.intro);
        return;
      }

      // Check if user is logged in by checking for auth token
      final token = StorageService.getString('auth_token');

      if (token != null) {
        // User has token, now get their actual role from cached user data
        final localDataSource = AuthLocalDataSourceImpl();
        final cachedUser = await localDataSource.getCachedUser();

        if (cachedUser != null) {
          // Convert UserRole enum to string for navigation
          String userType = 'passenger'; // default fallback
          switch (cachedUser.role) {
            case UserRole.ADMIN:
              userType = 'admin';
              break;
            case UserRole.DRIVER:
              userType = 'driver';
              break;
            case UserRole.PASSENGER:
              userType = 'passenger';
              break;
          }

          // User is logged in with valid cached data - go to layout with actual role
          replacement(NamedRoutes.i.layout, arguments: {'userType': userType});
        } else {
          // Token exists but no cached user data - user needs to login again
          replacement(NamedRoutes.i.selectRole);
        }
      } else {
        // User not logged in - go to role selection
        replacement(NamedRoutes.i.selectRole);
      }
    } catch (e) {
      // On any error, default to intro
      replacement(NamedRoutes.i.intro);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Match the native splash screen colors exactly
    final backgroundColor =
        isDarkMode ? const Color(0xFF000000) : const Color(0xFFFFFFFF);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo - exactly matching native splash
            Image.asset(
              'assets/images/app_logo.png',
              width: 120,
              height: 120,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 24),
            // Optional: Add a subtle loading indicator after a delay
            FutureBuilder(
              future: Future.delayed(const Duration(milliseconds: 500)),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.primary.withOpacity(0.7),
                      ),
                    ),
                  );
                }
                return const SizedBox(height: 24);
              },
            ),
          ],
        ),
      ),
    );
  }
}
