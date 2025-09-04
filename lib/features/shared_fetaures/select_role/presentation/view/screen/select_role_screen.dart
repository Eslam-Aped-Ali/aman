import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../../../app/routing/app_routes_fun.dart';
import '../../../../../../app/routing/routes.dart';
import '../../../../../../core/shared/services/storage_service.dart';
import '../../../../../../core/shared/utils/responsive/responsive_utils.dart';
import '../../../../../../generated/locale_keys.g.dart';
import '../../../../../../generated/assets.gen.dart';

class SelectRoleScreen extends StatefulWidget {
  const SelectRoleScreen({super.key});

  @override
  State<SelectRoleScreen> createState() => _SelectRoleScreenState();
}

class _SelectRoleScreenState extends State<SelectRoleScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _cardAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late List<Animation<double>> _cardAnimations;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    // Create staggered animations for cards with safer curves
    _cardAnimations = List.generate(3, (index) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _cardAnimationController,
        curve: Interval(
          index * 0.15,
          0.5 + (index * 0.15),
          curve: Curves.easeOutCubic,
        ),
      ));
    });

    // Start animations
    _animationController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _cardAnimationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _cardAnimationController.dispose();
    super.dispose();
  }

  Future<void> _selectRole(String role) async {
    // Add haptic feedback
    if (Theme.of(context).platform == TargetPlatform.iOS ||
        Theme.of(context).platform == TargetPlatform.android) {
      // We'll add HapticFeedback.lightImpact() if needed
    }

    // Show loading state with animation
    setState(() {
      // You could add a loading state here if needed
    });

    try {
      await StorageService.setString('selected_role', role);

      if (mounted) {
        // Add a small delay for better UX
        await Future.delayed(const Duration(milliseconds: 200));

        push(NamedRoutes.i.login, arguments: {'userRole': role});
      }
    } catch (e) {
      // Handle error gracefully
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(LocaleKeys.common_error.tr()),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final responsive = context.responsive;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.surface.withOpacity(0.8),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            // Main content
            SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: responsive.maxContentWidth,
                      ),
                      child: Padding(
                        padding: responsive.padding(24, 0),
                        child: Column(
                          children: [
                            SizedBox(height: responsive.spacing(40)),

                            // App Logo
                            Hero(
                              tag: 'app_logo',
                              child: TweenAnimationBuilder<double>(
                                tween: Tween<double>(begin: 0.8, end: 1.0),
                                duration: const Duration(milliseconds: 800),
                                curve: Curves.easeOutBack,
                                builder: (context, scale, child) {
                                  final clampedScale = scale.clamp(0.0, 2.0);
                                  final logoSize = responsive.spacing(100);
                                  return Transform.scale(
                                    scale: clampedScale,
                                    child: Container(
                                      width: logoSize,
                                      height: logoSize,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                            responsive.spacing(20)),
                                        boxShadow: [
                                          BoxShadow(
                                            color: theme.colorScheme.primary
                                                .withOpacity(0.3),
                                            blurRadius: responsive.spacing(20),
                                            offset: Offset(
                                                0, responsive.spacing(8)),
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                            responsive.spacing(20)),
                                        child: Assets.images.appLogo.image(
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),

                            SizedBox(height: responsive.spacing(32)),

                            // Title with typewriter effect
                            TweenAnimationBuilder<int>(
                              tween: IntTween(
                                  begin: 0,
                                  end: LocaleKeys.roles_select_role_title
                                      .tr()
                                      .length),
                              duration: const Duration(milliseconds: 1200),
                              builder: (context, value, child) {
                                return Text(
                                  LocaleKeys.roles_select_role_title
                                      .tr()
                                      .substring(0, value),
                                  style:
                                      theme.textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onSurface,
                                    fontSize: responsive.isMobile ? 24 : 28,
                                  ),
                                  textAlign: TextAlign.center,
                                );
                              },
                            ),

                            SizedBox(height: responsive.spacing(12)),

                            Text(
                              LocaleKeys.roles_select_role_subtitle.tr(),
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.7),
                                fontSize: responsive.isMobile ? 16 : 18,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            SizedBox(height: responsive.spacing(48)),

                            // Role options
                            Expanded(
                              child: SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                child: _buildResponsiveRoleCards(
                                    context, responsive, theme),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResponsiveRoleCards(
      BuildContext context, ResponsiveUtils responsive, ThemeData theme) {
    // For larger screens, use a grid layout
    if (responsive.isDesktop || responsive.isLargeTablet) {
      return Column(
        children: [
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: responsive.isDesktop ? 3 : 2,
            mainAxisSpacing: responsive.spacing(24),
            crossAxisSpacing: responsive.spacing(24),
            childAspectRatio: responsive.isDesktop ? 1.2 : 1.0,
            children: [
              _buildResponsiveRoleCard(
                context,
                responsive,
                title: LocaleKeys.roles_passenger_role.tr(),
                description: LocaleKeys.roles_passenger_description.tr(),
                assetPath: Assets.images.passenger.path,
                gradientColors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withOpacity(0.8),
                ],
                onTap: () => _selectRole('passenger'),
              ),
              _buildResponsiveRoleCard(
                context,
                responsive,
                title: LocaleKeys.roles_driver_role.tr(),
                description: LocaleKeys.roles_driver_description.tr(),
                assetPath: Assets.images.driver.path,
                gradientColors: [
                  const Color(0xFF4CAF50),
                  const Color(0xFF43A047),
                ],
                onTap: () => _selectRole('driver'),
              ),
              _buildResponsiveRoleCard(
                context,
                responsive,
                title: LocaleKeys.roles_admin_role.tr(),
                description: LocaleKeys.roles_admin_description.tr(),
                assetPath: Assets.images.admin.path,
                gradientColors: [
                  const Color(0xFF9C27B0),
                  const Color(0xFF8E24AA),
                ],
                onTap: () => _selectRole('admin'),
              ),
            ],
          ),
          SizedBox(height: responsive.spacing(40)),
          _buildSecurityFooter(context, responsive, theme),
        ],
      );
    }

    // For mobile and small tablets, use vertical list
    return Column(
      children: [
        AnimatedBuilder(
          animation: _cardAnimations[0],
          builder: (context, child) {
            final animValue = _cardAnimations[0].value.clamp(0.0, 1.0);
            return Transform.scale(
              scale: animValue,
              child: Opacity(
                opacity: animValue,
                child: Semantics(
                  label:
                      '${LocaleKeys.roles_passenger_role.tr()}: ${LocaleKeys.roles_passenger_description.tr()}',
                  button: true,
                  child: _buildResponsiveRoleCard(
                    context,
                    responsive,
                    title: LocaleKeys.roles_passenger_role.tr(),
                    description: LocaleKeys.roles_passenger_description.tr(),
                    assetPath: Assets.images.passenger.path,
                    gradientColors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withOpacity(0.8),
                    ],
                    onTap: () => _selectRole('passenger'),
                  ),
                ),
              ),
            );
          },
        ),
        SizedBox(height: responsive.spacing(24)),
        AnimatedBuilder(
          animation: _cardAnimations[1],
          builder: (context, child) {
            final animValue = _cardAnimations[1].value.clamp(0.0, 1.0);
            return Transform.scale(
              scale: animValue,
              child: Opacity(
                opacity: animValue,
                child: Semantics(
                  label:
                      '${LocaleKeys.roles_driver_role.tr()}: ${LocaleKeys.roles_driver_description.tr()}',
                  button: true,
                  child: _buildResponsiveRoleCard(
                    context,
                    responsive,
                    title: LocaleKeys.roles_driver_role.tr(),
                    description: LocaleKeys.roles_driver_description.tr(),
                    assetPath: Assets.images.driver.path,
                    gradientColors: [
                      const Color(0xFF4CAF50),
                      const Color(0xFF43A047),
                    ],
                    onTap: () => _selectRole('driver'),
                  ),
                ),
              ),
            );
          },
        ),
        SizedBox(height: responsive.spacing(24)),
        AnimatedBuilder(
          animation: _cardAnimations[2],
          builder: (context, child) {
            final animValue = _cardAnimations[2].value.clamp(0.0, 1.0);
            return Transform.scale(
              scale: animValue,
              child: Opacity(
                opacity: animValue,
                child: Semantics(
                  label:
                      '${LocaleKeys.roles_admin_role.tr()}: ${LocaleKeys.roles_admin_description.tr()}',
                  button: true,
                  child: _buildResponsiveRoleCard(
                    context,
                    responsive,
                    title: LocaleKeys.roles_admin_role.tr(),
                    description: LocaleKeys.roles_admin_description.tr(),
                    assetPath: Assets.images.admin.path,
                    gradientColors: [
                      const Color(0xFF9C27B0),
                      const Color(0xFF8E24AA),
                    ],
                    onTap: () => _selectRole('admin'),
                  ),
                ),
              ),
            );
          },
        ),
        SizedBox(height: responsive.spacing(40)),
        _buildSecurityFooter(context, responsive, theme),
      ],
    );
  }

  Widget _buildSecurityFooter(
      BuildContext context, ResponsiveUtils responsive, ThemeData theme) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: responsive.spacing(16),
          vertical: responsive.spacing(12),
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withOpacity(0.8),
          borderRadius: BorderRadius.circular(responsive.spacing(12)),
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.1),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.security,
              size: responsive.fontSize(16),
              color: theme.colorScheme.primary.withOpacity(0.7),
            ),
            SizedBox(width: responsive.spacing(8)),
            Text(
              'Secure • Private • Trusted',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
                fontWeight: FontWeight.w500,
                fontSize: responsive.isMobile ? 12 : 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResponsiveRoleCard(
    BuildContext context,
    ResponsiveUtils responsive, {
    required String title,
    required String description,
    required String assetPath,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, child) {
        final clampedValue = value.clamp(0.0, 1.0);
        return Transform.translate(
          offset: Offset(0, (1 - clampedValue) * 20),
          child: Opacity(
            opacity: clampedValue,
            child: Container(
              width: double.infinity,
              height:
                  responsive.isMobile ? 140 : (responsive.isTablet ? 150 : 160),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(responsive.spacing(20)),
                boxShadow: [
                  BoxShadow(
                    color: gradientColors.first.withOpacity(0.3 * clampedValue),
                    blurRadius: 15 * clampedValue,
                    offset: Offset(0, 5 * clampedValue),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Material(
                borderRadius: BorderRadius.circular(responsive.spacing(20)),
                child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(responsive.spacing(20)),
                  splashColor: Colors.white.withOpacity(0.2),
                  highlightColor: Colors.white.withOpacity(0.1),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: gradientColors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius:
                          BorderRadius.circular(responsive.spacing(20)),
                    ),
                    child: Stack(
                      children: [
                        // Background pattern
                        Positioned(
                          right: -20,
                          top: -20,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.05),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 20,
                          bottom: -10,
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.08),
                            ),
                          ),
                        ),

                        // Main content
                        Padding(
                          padding: EdgeInsets.all(responsive.isMobile
                              ? responsive.spacing(16)
                              : responsive.spacing(20)),
                          child: Row(
                            children: [
                              // Role Image/Icon
                              Hero(
                                tag: 'role_${title.toLowerCase()}',
                                child: Container(
                                  width: responsive.isMobile ? 80 : 100,
                                  height: responsive.isMobile ? 80 : 100,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(
                                        responsive.spacing(16)),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.3),
                                      width: 2,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                        responsive.spacing(14)),
                                    child: Image.asset(
                                      assetPath,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        // Fallback to icon if image not found
                                        return Icon(
                                          _getIconForRole(title),
                                          size: responsive.isMobile ? 36 : 42,
                                          color: Colors.white,
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),

                              SizedBox(width: responsive.spacing(20)),

                              // Text Content
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      title,
                                      style:
                                          theme.textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: 0.5,
                                        fontSize: responsive.isMobile ? 18 : 20,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: responsive.spacing(6)),
                                    Flexible(
                                      child: Text(
                                        description,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                          color: Colors.white.withOpacity(0.9),
                                          height: 1.2,
                                          fontSize:
                                              responsive.isMobile ? 12 : 14,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Arrow Icon with bounce animation
                              TweenAnimationBuilder<double>(
                                tween: Tween<double>(begin: 0.0, end: 1.0),
                                duration: const Duration(milliseconds: 800),
                                curve: Curves.easeOutBack,
                                builder: (context, animValue, child) {
                                  final clampedValue =
                                      animValue.clamp(0.0, 1.0);
                                  return Transform.scale(
                                    scale: clampedValue,
                                    child: Container(
                                      padding:
                                          EdgeInsets.all(responsive.spacing(8)),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(
                                            responsive.spacing(12)),
                                      ),
                                      child: Icon(
                                        Icons.arrow_forward_ios,
                                        size: responsive.isMobile ? 18 : 20,
                                        color: Colors.white,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  IconData _getIconForRole(String role) {
    switch (role.toLowerCase()) {
      case 'passenger':
      case 'راكب':
        return Icons.person_outline;
      case 'driver':
      case 'سائق':
        return Icons.drive_eta_outlined;
      case 'admin':
      case 'مدير':
        return Icons.admin_panel_settings_outlined;
      default:
        return Icons.person_outline;
    }
  }
}
