import 'package:Aman/app/routing/app_routes_fun.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import '../../../../../../core/shared/theme/colors/app_colors.dart';
import '../../../../../../core/shared/utils/responsive/responsive_utils.dart';
import '../../../../../../app/routing/routes.dart';
import '../../../domain/entities/driver_profile.dart';
import '../../bloc/driver_profile_bloc.dart';
import '../../bloc/driver_profile_event.dart';
import '../../bloc/driver_profile_state.dart';
import '../widgets/waiting_animation.dart';
import '../widgets/waiting_message.dart';
import '../widgets/approval_profile_summary.dart';
import '../widgets/approval_action_buttons.dart';

class WaitingForApprovalScreen extends StatefulWidget {
  final DriverProfile? driverProfile;
  final String? phoneNumber;
  final bool shouldLoadProfile;

  const WaitingForApprovalScreen({
    super.key,
    this.driverProfile,
    this.phoneNumber,
    this.shouldLoadProfile = false,
  });

  @override
  State<WaitingForApprovalScreen> createState() =>
      _WaitingForApprovalScreenState();
}

class _WaitingForApprovalScreenState extends State<WaitingForApprovalScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadDriverProfile();
    _startStatusCheck();
  }

  void _loadDriverProfile() {
    if (widget.shouldLoadProfile && widget.phoneNumber != null) {
      // Load driver profile from storage or backend
      final driverId = 'driver_${widget.phoneNumber}';
      context.read<DriverProfileBloc>().add(LoadDriverProfile(driverId));
    }
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _fadeController.forward();
  }

  void _startStatusCheck() {
    // Periodically check for approval status
    Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) {
        final driverProfile = widget.driverProfile;
        if (driverProfile != null) {
          context.read<DriverProfileBloc>().add(
                RefreshDriverProfile(driverProfile.id),
              );
        } else if (widget.phoneNumber != null) {
          final driverId = 'driver_${widget.phoneNumber}';
          context.read<DriverProfileBloc>().add(
                RefreshDriverProfile(driverId),
              );
        }
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final responsive = context.responsive;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.grey[50],
      body: SafeArea(
        child: BlocConsumer<DriverProfileBloc, DriverProfileState>(
          listener: (context, state) {
            if (state is DriverProfileLoaded && state.profile.isApproved) {
              Navigator.pushReplacementNamed(context, NamedRoutes.i.driverMain);
            } else if (state is DriverProfileLoaded &&
                state.profile.isRejected) {
              _showRejectionDialog(context);
            } else if (state is ContactAdminSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Opening phone dialer...'),
                  backgroundColor: Colors.green,
                ),
              );
            } else if (state is ContactAdminError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            DriverProfile? currentProfile = widget.driverProfile;

            // Handle loaded profile state
            if (state is DriverProfileLoaded) {
              currentProfile = state.profile;
            }

            // Show loading if we're supposed to load profile and haven't gotten it yet
            if (widget.shouldLoadProfile &&
                currentProfile == null &&
                state is DriverProfileLoading) {
              return _buildLoadingScreen(isDarkMode, responsive);
            }

            // Show error if profile couldn't be loaded
            if (widget.shouldLoadProfile && state is DriverProfileError) {
              return _buildErrorScreen(state.message, isDarkMode, responsive);
            }

            // Show not found if profile doesn't exist
            if (widget.shouldLoadProfile && state is DriverProfileNotFound) {
              return _buildNotFoundScreen(isDarkMode, responsive);
            }

            // Show main waiting screen
            return _buildMainContent(currentProfile, isDarkMode, responsive);
          },
        ),
      ),
    );
  }

  Widget _buildLoadingScreen(bool isDarkMode, ResponsiveUtils responsive) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: responsive.fontSize(60),
              height: responsive.fontSize(60),
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 4,
              ),
            ),
            SizedBox(height: responsive.spacing(24)),
            Text(
              'Loading your profile...',
              style: TextStyle(
                fontSize: responsive.fontSize(18),
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen(
      String error, bool isDarkMode, ResponsiveUtils responsive) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: responsive.fontSize(80),
              color: Colors.red,
            ),
            SizedBox(height: responsive.spacing(24)),
            Text(
              'Error loading profile',
              style: TextStyle(
                fontSize: responsive.fontSize(20),
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            SizedBox(height: responsive.spacing(12)),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: responsive.fontSize(16),
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            SizedBox(height: responsive.spacing(32)),
            ElevatedButton(
              onPressed: _retryLoadProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: responsive.padding(16, 20),
              ),
              child: Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotFoundScreen(bool isDarkMode, ResponsiveUtils responsive) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_off,
              size: responsive.fontSize(80),
              color: Colors.orange,
            ),
            SizedBox(height: responsive.spacing(24)),
            Text(
              'Profile Not Found',
              style: TextStyle(
                fontSize: responsive.fontSize(20),
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            SizedBox(height: responsive.spacing(12)),
            Text(
              'Your driver profile could not be found. Please complete your registration.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: responsive.fontSize(16),
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            SizedBox(height: responsive.spacing(32)),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(
                  context,
                  '/driverCompleteProfile',
                  arguments: {'phoneNumber': widget.phoneNumber},
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: responsive.padding(16, 20),
              ),
              child: Text('Complete Registration'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(DriverProfile? currentProfile, bool isDarkMode,
      ResponsiveUtils responsive) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: responsive.padding(20, 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: responsive.spacing(20)),
              WaitingAnimation(pulseAnimation: _pulseAnimation),
              SizedBox(height: responsive.spacing(32)),
              const WaitingMessage(),
              SizedBox(height: responsive.spacing(32)),
              ApprovalProfileSummary(driverProfile: currentProfile),
              SizedBox(height: responsive.spacing(32)),
              ApprovalActionButtons(
                onContactAdmin: _contactAdmin,
                onRefreshStatus: _refreshStatus,
                onSkipToDriverApp: () {
                  replacement(NamedRoutes.i.layout,
                      arguments: {'userType': 'driver'});
                },
              ),
              SizedBox(height: responsive.spacing(40)), // Bottom padding
            ],
          ),
        ),
      ),
    );
  }

  void _contactAdmin() {
    context.read<DriverProfileBloc>().add(
          const ContactAdmin('+96894240578'),
        );
  }

  void _refreshStatus() {
    final driverProfile = widget.driverProfile;
    if (driverProfile != null) {
      context.read<DriverProfileBloc>().add(
            RefreshDriverProfile(driverProfile.id),
          );
    } else if (widget.phoneNumber != null) {
      final driverId = 'driver_${widget.phoneNumber}';
      context.read<DriverProfileBloc>().add(
            RefreshDriverProfile(driverId),
          );
    }
  }

  void _retryLoadProfile() {
    if (widget.phoneNumber != null) {
      final driverId = 'driver_${widget.phoneNumber}';
      context.read<DriverProfileBloc>().add(
            LoadDriverProfile(driverId),
          );
    }
  }

  void _showRejectionDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Application Rejected'),
        content: const Text(
          'Unfortunately, your driver application has been rejected. Please contact admin for more information.',
        ),
        actions: [
          TextButton(
            onPressed: _contactAdmin,
            child: const Text('Contact Admin'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/auth/login',
                (route) => false,
              );
            },
            child: const Text('Back to Login'),
          ),
        ],
      ),
    );
  }
}
