import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:introduction_screen/introduction_screen.dart';

import '../../../../../../app/routing/app_routes_fun.dart';
import '../../../../../../app/routing/routes.dart';
import '../../../../../../core/shared/services/storage_service.dart';
import '../../../../../../generated/locale_keys.g.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
  }

  List<Map<String, dynamic>> _getIntroPages(BuildContext context) {
    final theme = Theme.of(context);

    return [
      {
        'title': LocaleKeys.onboarding_title1.tr(),
        'description': LocaleKeys.onboarding_desc1.tr(),
        'svgAsset': "assets/icons/bus_tracking.svg",
        'primaryColor': theme.colorScheme.primary,
        'backgroundColor': theme.colorScheme.primary.withOpacity(0.1),
      },
      {
        'title': LocaleKeys.onboarding_title2.tr(),
        'description': LocaleKeys.onboarding_desc2.tr(),
        'svgAsset': "assets/icons/smart_ticketing.svg",
        'primaryColor': const Color(0xFF4CAF50),
        'backgroundColor': const Color(0xFF4CAF50).withOpacity(0.1),
      },
      {
        'title': LocaleKeys.onboarding_title3.tr(),
        'description': LocaleKeys.onboarding_desc3.tr(),
        'svgAsset': "assets/icons/stay_updated.svg",
        'primaryColor': const Color(0xFF9C27B0),
        'backgroundColor': const Color(0xFF9C27B0).withOpacity(0.1),
      },
    ];
  }

  List<PageViewModel> getPages(BuildContext context, bool isDarkMode) {
    final introPages = _getIntroPages(context);

    return introPages
        .map(
          (page) => PageViewModel(
            title: page['title'] as String,
            body: page['description'] as String,
            image: _buildEnhancedImage(
              page['svgAsset'] as String,
              page['primaryColor'] as Color,
              page['backgroundColor'] as Color,
              isDarkMode,
            ),
            decoration: _pageDecoration(
              isDarkMode,
              page['primaryColor'] as Color,
            ),
          ),
        )
        .toList();
  }

  PageDecoration _pageDecoration(bool isDarkMode, Color primaryColor) {
    return PageDecoration(
      titleTextStyle: TextStyle(
        fontSize: 26.sp,
        fontWeight: FontWeight.bold,
        color: isDarkMode ? Colors.white : primaryColor,
        letterSpacing: -0.5,
      ),
      bodyTextStyle: TextStyle(
        fontSize: 16.sp,
        color: isDarkMode ? Colors.white70 : Colors.grey[600],
        height: 1.6,
        letterSpacing: 0.2,
      ),
      imagePadding: EdgeInsets.only(top: 30.h),
      contentMargin: EdgeInsets.symmetric(horizontal: 24.w),
      pageColor: Colors.transparent,
    );
  }

  Widget _buildEnhancedImage(
    String svgAsset,
    // String animationAsset,
    Color primaryColor,
    Color backgroundColor,
    bool isDarkMode,
  ) {
    return Container(
      height: 350.h,
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      child: Stack(
        children: [
          // Background circle with gradient
          Center(
            child: Container(
              width: 280.w,
              height: 280.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: isDarkMode
                      ? [
                          backgroundColor.withOpacity(0.1),
                          backgroundColor.withOpacity(0.05),
                        ]
                      : [
                          backgroundColor.withOpacity(0.6),
                          backgroundColor.withOpacity(0.2),
                        ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.2),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
            ),
          ),

          // SVG Icon
          Center(
            child: Container(
              width: 180.w,
              height: 180.h,
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Colors.white.withOpacity(0.1)
                    : Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
                border: Border.all(
                  color: primaryColor.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: _buildSvgIcon(svgAsset),
            ),
          ),

          // Floating animation dots
          Positioned(
            top: 50.h,
            left: 30.w,
            child: _buildFloatingDot(primaryColor, 8.w, 0),
          ),
          Positioned(
            top: 80.h,
            right: 40.w,
            child: _buildFloatingDot(primaryColor, 6.w, 1),
          ),
          Positioned(
            bottom: 60.h,
            left: 50.w,
            child: _buildFloatingDot(primaryColor, 10.w, 2),
          ),
          Positioned(
            bottom: 90.h,
            right: 30.w,
            child: _buildFloatingDot(primaryColor, 7.w, 3),
          ),

          // Small Lottie animation overlay
        ],
      ),
    );
  }

  Widget _buildSvgIcon(String svgAsset) {
    return FutureBuilder<String>(
      future: _loadSvgAsset(svgAsset),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          // Fallback icon if SVG fails to load
          return Icon(
            Icons.image_not_supported,
            size: 60.w,
            color: Theme.of(context).primaryColor.withOpacity(0.5),
          );
        }

        if (!snapshot.hasData) {
          return SizedBox(
            width: 60.w,
            height: 60.h,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
          );
        }

        return SvgPicture.asset(
          svgAsset,
          width: 140.w,
          height: 140.h,
          fit: BoxFit.contain,
          placeholderBuilder: (context) => Icon(
            Icons.image,
            size: 60.w,
            color: Theme.of(context).primaryColor.withOpacity(0.5),
          ),
        );
      },
    );
  }

  Future<String> _loadSvgAsset(String assetPath) async {
    try {
      final String svgString = await rootBundle.loadString(assetPath);
      // Basic SVG validation
      if (svgString.trim().isEmpty || !svgString.contains('<svg')) {
        throw Exception('Invalid SVG data');
      }
      return svgString;
    } catch (e) {
      throw Exception('Failed to load SVG: $e');
    }
  }

  Widget _buildFloatingDot(Color color, double size, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 1500 + (index * 300)),
      curve: Curves.easeInOut,
      onEnd: () {
        // This will cause the animation to restart
        if (mounted) {
          setState(() {});
        }
      },
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(
            8 * (index.isOdd ? value : (1 - value)),
            10 * (index.isEven ? value : (1 - value)),
          ),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 200 + (index * 100)),
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: color.withOpacity(0.4 + (0.4 * value)),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3 * value),
                  blurRadius: 4 * value,
                  offset: Offset(0, 2 * value),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final isArabic = context.locale.languageCode == 'ar';
    final introPages = _getIntroPages(context);
    final currentPageData = introPages[currentPage];
    final currentPrimaryColor = currentPageData['primaryColor'] as Color;
    final currentBackgroundColor = currentPageData['backgroundColor'] as Color;

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDarkMode
                ? [Colors.grey[900]!, Colors.grey[800]!]
                : [
                    currentBackgroundColor.withOpacity(0.3),
                    currentBackgroundColor.withOpacity(0.1),
                    Colors.white,
                  ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: isDarkMode ? null : [0.0, 0.3, 1.0],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Progress indicator at the top
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 4.h,
                  margin: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
                  child: Row(
                    children: List.generate(
                      introPages.length,
                      (index) => Expanded(
                        child: Container(
                          height: 4.h,
                          margin: EdgeInsets.symmetric(horizontal: 2.w),
                          decoration: BoxDecoration(
                            color: index <= currentPage
                                ? currentPrimaryColor
                                : currentPrimaryColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(2.r),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Introduction Screen
              IntroductionScreen(
                pages: getPages(context, isDarkMode),
                onDone: () async {
                  await StorageService.setBool('intro_completed', true);
                  if (mounted) replacement(NamedRoutes.i.selectRole);
                },
                onChange: (page) {
                  setState(() {
                    currentPage = page;
                  });
                },
                showSkipButton: true,
                skip: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? Colors.white.withOpacity(0.15)
                        : currentPrimaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(30.r),
                    border: Border.all(
                      color: isDarkMode ? Colors.white : currentPrimaryColor,
                      width: 1.5,
                    ),
                  ),
                  padding:
                      EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                  child: Text(
                    LocaleKeys.onboarding_skip.tr(),
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : currentPrimaryColor,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                next: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    color: currentPrimaryColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: currentPrimaryColor.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    isArabic
                        ? Icons.arrow_forward_rounded
                        : Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 20.w,
                  ),
                ),
                done: Container(
                  constraints: BoxConstraints(
                    maxWidth: 200.w, // Add explicit max width
                    maxHeight: 50.h, // Add explicit max height
                  ),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      color: currentPrimaryColor,
                      borderRadius: BorderRadius.circular(30.r),
                      boxShadow: [
                        BoxShadow(
                          color: currentPrimaryColor.withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    padding:
                        EdgeInsets.symmetric(horizontal: 28.w, vertical: 14.h),
                    child: Text(
                      LocaleKeys.onboarding_getStart.tr(),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontSize: 14.sp,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                dotsDecorator: DotsDecorator(
                  activeColor: currentPrimaryColor,
                  size: Size(8.w, 8.w),
                  color: isDarkMode
                      ? Colors.white.withOpacity(0.3)
                      : currentPrimaryColor.withOpacity(0.3),
                  activeSize: Size(24.w, 8.h),
                  activeShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.r),
                  ),
                  spacing: EdgeInsets.symmetric(horizontal: 4.w),
                ),
                globalBackgroundColor: Colors.transparent,
                skipOrBackFlex: 0,
                nextFlex: 0,
                showNextButton: true,
                animationDuration: 400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
