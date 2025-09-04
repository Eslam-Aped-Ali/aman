import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../core/shared/utils/responsive/responsive_utils.dart';
import '../../../../../shared_fetaures/layout/presentation/navigationController/navigation_bloc.dart';
import '../../../../../shared_fetaures/layout/presentation/navigationController/navigation_event.dart';
import '../widgets/passenger_welcome_section.dart';
import '../widgets/passenger_quick_actions.dart';
import '../widgets/passenger_popular_routes_section.dart';
import '../widgets/passenger_recent_activities_section.dart';

class PassengerHomeScreen extends StatefulWidget {
  const PassengerHomeScreen({super.key});

  @override
  State<PassengerHomeScreen> createState() => _PassengerHomeScreenState();
}

class _PassengerHomeScreenState extends State<PassengerHomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _welcomeAnimationController;
  late AnimationController _cardAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _welcomeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _welcomeAnimationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _cardAnimationController,
      curve: Curves.easeOutCubic,
    ));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _welcomeAnimationController.forward();
      Future.delayed(const Duration(milliseconds: 200), () {
        _cardAnimationController.forward();
      });
    });
  }

  @override
  void dispose() {
    _welcomeAnimationController.dispose();
    _cardAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final responsive = context.responsive;
    final isTablet = responsive.isTablet;
    final isArabic = context.locale.languageCode == 'ar';

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PassengerWelcomeSection(
                isDarkMode: isDarkMode,
                responsive: responsive,
                isTablet: isTablet,
                fadeAnimation: _fadeAnimation,
                slideAnimation: _slideAnimation,
              ),
              // PassengerSearchBar(
              //   isDarkMode: isDarkMode,
              //   responsive: responsive,
              //   isTablet: isTablet,
              //   slideAnimation: _slideAnimation,
              //   onSearchTap: _handleSearchTap,
              // ),
              PassengerQuickActions(
                isDarkMode: isDarkMode,
                responsive: responsive,
                isTablet: isTablet,
                fadeAnimation: _fadeAnimation,
                onAvailableTripsPressed: _handleAvailableTripsPressed,
                onMyTripsPressed: _handleMyTripsPressed,
              ),
              PassengerPopularRoutesSection(
                isDarkMode: isDarkMode,
                responsive: responsive,
                isTablet: isTablet,
                isArabic: isArabic,
                fadeAnimation: _fadeAnimation,
                popularRoutes: _getPopularRoutes(),
                onRoutePressed: _handleRoutePressed,
              ),
              PassengerRecentActivitiesSection(
                isDarkMode: isDarkMode,
                responsive: responsive,
                isTablet: isTablet,
                fadeAnimation: _fadeAnimation,
                recentActivities: _getRecentActivities(),
                onActivityPressed: _handleActivityPressed,
              ),
              SizedBox(height: responsive.spacing(20)),
            ],
          ),
        ),
      ),
    );
  }

  // Handler methods
  void _handleSearchTap() {}

  void _handleAvailableTripsPressed() {
    context
        .read<NavigationBloc>()
        .add(NavigateToPage(1)); // Navigate to booking tab
  }

  void _handleMyTripsPressed() {
    context
        .read<NavigationBloc>()
        .add(NavigateToPage(2)); // Navigate to trips tab
  }

  void _handleRoutePressed(PopularRoute route) {
    // Navigate to booking with pre-selected route
  }

  void _handleActivityPressed(RecentActivity activity) {
    // Navigate to activity details
  }

  // Data methods
  List<PopularRoute> _getPopularRoutes() {
    // Return mock data for now - in real app this would come from API/BLoC
    return [
      PopularRoute(
        fromLocation: 'cairo',
        toLocation: 'alexandria',
        fromLocationAr: 'القاهرة',
        toLocationAr: 'الإسكندرية',
        duration: '3h 30m',
        price: 150.0,
        nextDeparture: '2:30 PM',
        isAvailable: true,
      ),
      PopularRoute(
        fromLocation: 'cairo',
        toLocation: 'giza',
        fromLocationAr: 'القاهرة',
        toLocationAr: 'الجيزة',
        duration: '45m',
        price: 25.0,
        nextDeparture: '1:15 PM',
        isAvailable: true,
      ),
    ];
  }

  List<RecentActivity> _getRecentActivities() {
    // Return mock data for now - in real app this would come from API/BLoC
    return [
      RecentActivity(
        id: '1',
        type: ActivityType.booking,
        status: ActivityStatus.completed,
        title: 'Trip to Alexandria',
        subtitle: 'Cairo → Alexandria',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        amount: '150.0 EGP',
      ),
      RecentActivity(
        id: '2',
        type: ActivityType.payment,
        status: ActivityStatus.pending,
        title: 'Payment Processing',
        subtitle: 'Credit card payment',
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        amount: '75.0 EGP',
      ),
    ];
  }
}
