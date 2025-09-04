// lib/features/shared_features/splash/presentation/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:Aman/app/routing/app_routes_fun.dart';
import 'package:Aman/app/routing/routes.dart';
import 'package:Aman/core/shared/services/storage_service.dart';

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
    // Wait for splash animation
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    try {
      // Check if intro has been completed
      final introCompleted = StorageService.getBool('intro_completed') ?? false;

      if (!introCompleted) {
        // First time user - show intro
        replacement(NamedRoutes.i.intro);
        return;
      }

      // Check if user is logged in
      final token = StorageService.getString('auth_token');
      final userRole = StorageService.getString('selected_role');

      if (token != null && userRole != null) {
        // User is logged in - go directly to layout
        replacement(NamedRoutes.i.layout, arguments: {'userType': userRole});
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

    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo animation
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutBack,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.directions_bus,
                      size: 80,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            // App name
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeIn,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Text(
                    'Aman',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 48),
            // Loading indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
