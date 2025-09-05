// lib/features/shared_features/splash/presentation/screens/enhanced_splash_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:Aman/app/routing/app_routes_fun.dart';
import 'package:Aman/app/routing/routes.dart';
import 'package:Aman/core/shared/services/storage_service.dart';
import 'package:Aman/core/shared/services/splash_service.dart';
import 'package:Aman/features/shared_fetaures/auth/data/datasource/locale/auth_local_data_source.dart';
import 'package:Aman/features/shared_fetaures/auth/domain/entities/user.dart';

class EnhancedSplashScreen extends StatefulWidget {
  const EnhancedSplashScreen({super.key});

  @override
  State<EnhancedSplashScreen> createState() => _EnhancedSplashScreenState();
}

class _EnhancedSplashScreenState extends State<EnhancedSplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _loadingController;
  late Animation<double> _logoAnimation;
  late Animation<double> _loadingAnimation;

  bool _isNavigating = false;
  String _loadingText = 'Initializing...';

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startInitialization();
  }

  void _initializeAnimations() {
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _logoAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    _loadingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _loadingController,
      curve: Curves.easeInOut,
    ));
  }

  Future<void> _startInitialization() async {
    // Remove native splash immediately when Flutter UI is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SplashService.remove();
    });

    // Start animations
    _logoController.forward();

    // Wait a brief moment for animations to start
    await Future.delayed(const Duration(milliseconds: 300));
    _loadingController.forward();

    await _performInitializationSteps();
  }

  Future<void> _performInitializationSteps() async {
    if (_isNavigating) return;

    try {
      // Step 1: Check initialization status
      setState(() => _loadingText = 'Checking status...');
      await Future.delayed(const Duration(milliseconds: 200));

      // Step 2: Load user preferences
      setState(() => _loadingText = 'Loading preferences...');
      final introCompleted = StorageService.getBool('intro_completed') ?? false;
      await Future.delayed(const Duration(milliseconds: 200));

      if (!introCompleted) {
        setState(() => _loadingText = 'Welcome!');
        await Future.delayed(const Duration(milliseconds: 300));
        _navigateToScreen(NamedRoutes.i.intro);
        return;
      }

      // Step 3: Check authentication
      setState(() => _loadingText = 'Verifying authentication...');
      final token = StorageService.getString('auth_token');
      await Future.delayed(const Duration(milliseconds: 200));

      if (token != null) {
        setState(() => _loadingText = 'Loading user data...');
        final localDataSource = AuthLocalDataSourceImpl();
        final cachedUser = await localDataSource.getCachedUser();

        if (cachedUser != null) {
          String userType = 'passenger';
          switch (cachedUser.role) {
            case UserRole.ADMIN:
              userType = 'admin';
              setState(() => _loadingText = 'Loading admin dashboard...');
              break;
            case UserRole.DRIVER:
              userType = 'driver';
              setState(() => _loadingText = 'Loading driver interface...');
              break;
            case UserRole.PASSENGER:
              userType = 'passenger';
              setState(() => _loadingText = 'Loading passenger app...');
              break;
          }

          await Future.delayed(const Duration(milliseconds: 300));
          _navigateToScreen(NamedRoutes.i.layout,
              arguments: {'userType': userType});
        } else {
          setState(() => _loadingText = 'Authentication required...');
          await Future.delayed(const Duration(milliseconds: 300));
          _navigateToScreen(NamedRoutes.i.selectRole);
        }
      } else {
        setState(() => _loadingText = 'Ready to start...');
        await Future.delayed(const Duration(milliseconds: 300));
        _navigateToScreen(NamedRoutes.i.selectRole);
      }
    } catch (e) {
      setState(() => _loadingText = 'Starting fresh...');
      await Future.delayed(const Duration(milliseconds: 300));
      _navigateToScreen(NamedRoutes.i.intro);
    }
  }

  void _navigateToScreen(String route, {Map<String, dynamic>? arguments}) {
    if (_isNavigating || !mounted) return;

    _isNavigating = true;
    replacement(route, arguments: arguments);
  }

  @override
  void dispose() {
    _logoController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Match native splash colors exactly
    final backgroundColor =
        isDarkMode ? const Color(0xFF000000) : const Color(0xFFFFFFFF);
    final contentColor = isDarkMode ? Colors.white : Colors.black87;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: backgroundColor,
        statusBarIconBrightness:
            isDarkMode ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: backgroundColor,
        systemNavigationBarIconBrightness:
            isDarkMode ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated Logo
              AnimatedBuilder(
                animation: _logoAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _logoAnimation.value,
                    child: Image.asset(
                      'assets/images/app_logo.png',
                      width: 120,
                      height: 120,
                      fit: BoxFit.contain,
                    ),
                  );
                },
              ),

              const SizedBox(height: 48),

              // Loading indicator and text
              AnimatedBuilder(
                animation: _loadingAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _loadingAnimation.value,
                    child: Column(
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              theme.colorScheme.primary.withOpacity(0.8),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _loadingText,
                          style: TextStyle(
                            fontSize: 14,
                            color: contentColor.withOpacity(0.7),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
