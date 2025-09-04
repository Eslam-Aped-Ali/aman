// import 'dart:async';

// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:lottie/lottie.dart';
// import 'package:pinput/pinput.dart';

// import '../../../../../../app/routing/app_routes_fun.dart';
// import '../../../../../../app/routing/routes.dart';
// import '../../../../../../core/shared/costants/app_assets.dart';
// import '../../../../../../core/shared/services/storage_service.dart';
// import '../../../../../../core/shared/utils/enums.dart';
// import '../../../../../../generated/locale_keys.g.dart';
// import '../../bloc/auth_cubit.dart';
// import '../../bloc/auth_state.dart';
// import '../../../../../../app/di.dart' as di;

// class OtpScreen extends StatefulWidget {
//   final String phoneNumber;
//   final String? userRole;
//   final bool isAdmin;

//   const OtpScreen({
//     super.key,
//     required this.phoneNumber,
//     this.userRole,
//     this.isAdmin = false,
//   });

//   @override
//   State<OtpScreen> createState() => _OtpScreenState();
// }

// class _OtpScreenState extends State<OtpScreen> with TickerProviderStateMixin {
//   final TextEditingController otpController = TextEditingController();
//   final FocusNode otpFocusNode = FocusNode();

//   bool isLoading = false;
//   bool canResend = false;
//   int resendCounter = 60;
//   Timer? resendTimer;
//   late AuthCubit authCubit;

//   late AnimationController _animationController;
//   late AnimationController _shakeController;
//   late Animation<double> _fadeInAnimation;
//   late Animation<Offset> _slideAnimation;
//   late Animation<double> _shakeAnimation;

//   @override
//   void initState() {
//     super.initState();
//     authCubit = di.sl<AuthCubit>();
//     authCubit.phone.text = widget.phoneNumber;
//     _setupAnimations();
//     _startResendTimer();

//     // Auto-focus on OTP field
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       otpFocusNode.requestFocus();
//     });
//   }

//   void _setupAnimations() {
//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 1200),
//       vsync: this,
//     );

//     _shakeController = AnimationController(
//       duration: const Duration(milliseconds: 500),
//       vsync: this,
//     );

//     _fadeInAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _animationController,
//       curve: const Interval(0.3, 1.0, curve: Curves.easeInOut),
//     ));

//     _slideAnimation = Tween<Offset>(
//       begin: const Offset(0, 0.3),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(
//       parent: _animationController,
//       curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
//     ));

//     _shakeAnimation = Tween<double>(
//       begin: -1.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _shakeController,
//       curve: Curves.elasticIn,
//     ));

//     _animationController.forward();
//   }

//   void _startResendTimer() {
//     resendTimer?.cancel();
//     setState(() {
//       canResend = false;
//       resendCounter = 60;
//     });

//     resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       if (resendCounter > 0) {
//         setState(() => resendCounter--);
//       } else {
//         setState(() => canResend = true);
//         timer.cancel();
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     _shakeController.dispose();
//     resendTimer?.cancel();
//     otpController.dispose();
//     otpFocusNode.dispose();
//     authCubit.close();
//     super.dispose();
//   }

//   Future<void> _verifyOTP() async {
//     final otp = otpController.text;
//     if (otp.length != 6) return;

//     setState(() => isLoading = true);

//     try {
//       // Haptic feedback
//       HapticFeedback.lightImpact();

//       // For admin number with test code, verify directly
//       final isAdmin = _isAdminNumber(widget.phoneNumber);
//       if (isAdmin && otp == '111111') {
//         _handleSuccessfulVerification();

//         return;
//       }

//       // For other test numbers, check test codes
//       final phoneNumber = widget.phoneNumber.replaceAll(' ', '');
//       if ((phoneNumber == '+96892421111' && otp == '111111') ||
//           (phoneNumber == '+96892423333' && otp == '111111')) {
//         _handleSuccessfulVerification();
//         return;
//       }

//       // Update the AuthCubit OTP controller
//       authCubit.otp.text = otp;

//       // Create a simple subscription to listen for changes
//       StreamSubscription<AuthState>? subscription;
//       subscription = authCubit.stream.listen((state) {
//         print('AuthCubit state: ${state.requestState}, msg: ${state.msg}');

//         if (state.requestState == RequestState.done) {
//           subscription?.cancel();
//           if (mounted) {
//             setState(() => isLoading = false);
//             _handleSuccessfulVerification();
//           }
//         } else if (state.requestState == RequestState.error) {
//           subscription?.cancel();
//           if (mounted) {
//             setState(() => isLoading = false);
//             _shakeController.forward().then((_) => _shakeController.reverse());
//             _showErrorSnackBar(state.msg.isEmpty
//                 ? LocaleKeys.auth_invalidOtp.tr()
//                 : state.msg);
//           }
//         } else if (state.requestState == RequestState.loading) {
//           if (mounted) {
//             setState(() => isLoading = true);
//           }
//         }
//       });

//       // Add timeout for the operation
//       Timer(Duration(seconds: 30), () {
//         subscription?.cancel();
//         if (mounted && isLoading) {
//           setState(() => isLoading = false);
//           _showErrorSnackBar('OTP verification timeout. Please try again.');
//         }
//       });

//       // Trigger OTP verification
//       authCubit.login();
//     } catch (e) {
//       print('OTP verification error: $e');
//       _shakeController.forward().then((_) => _shakeController.reverse());
//       _showErrorSnackBar('OTP verification failed: ${e.toString()}');
//       setState(() => isLoading = false);
//     }
//   }

//   Future<void> _handleSuccessfulVerification() async {
//     // Store verification status
//     await StorageService.setBool('is_verified', true);
//     await StorageService.setString(
//         'verification_time', DateTime.now().toIso8601String());
//     await StorageService.setString('phone_number', widget.phoneNumber);
//     await StorageService.setString('user_role', widget.userRole ?? 'passenger');

//     if (mounted) {
//       final isAdmin = _isAdminNumber(widget.phoneNumber);

//       // Check if this is the first time for this phone number
//       final profileCompleted =
//           StorageService.getBool('profile_completed_${widget.phoneNumber}');
//       final isFirstTime = profileCompleted == null || !profileCompleted;

//       if (isAdmin) {
//         // Admin always goes to dashboard
//         await StorageService.setBool(
//             'profile_completed_${widget.phoneNumber}', true);
//         replacement(NamedRoutes.i.layout, arguments: {'userType': 'admin'});
//       } else if (isFirstTime) {
//         // First time user - navigate to complete profile
//         if (widget.userRole == 'driver') {
//           replacement(NamedRoutes.i.driverCompleteProfile,
//               arguments: {'phoneNumber': widget.phoneNumber});
//         } else {
//           replacement(NamedRoutes.i.passengerCompleteProfile);
//         }
//       } else {
//         // Existing user - check driver approval status
//         if (widget.userRole == 'driver') {
//           final isApproved =
//               StorageService.getBool('driver_approved_${widget.phoneNumber}') ??
//                   false;
//           if (isApproved) {
//             replacement(NamedRoutes.i.layout,
//                 arguments: {'userType': 'driver'});
//           } else {
//             // Driver exists but not approved - show waiting screen
//             replacement(NamedRoutes.i.driverApprovalScreen, arguments: {
//               'phoneNumber': widget.phoneNumber,
//               'shouldLoadProfile': true,
//             });
//           }
//         } else {
//           replacement(NamedRoutes.i.layout,
//               arguments: {'userType': 'passenger'});
//         }
//       }
//     }
//   }

//   bool _isAdminNumber(String phoneNumber) {
//     // Remove spaces and compare with admin number
//     final normalizedNumber = phoneNumber.replaceAll(' ', '');
//     return normalizedNumber == '+96892420578';
//   }

//   Future<void> _resendOTP() async {
//     if (!canResend) return;

//     setState(() => isLoading = true);

//     try {
//       // Haptic feedback
//       HapticFeedback.lightImpact();

//       // Use Firebase to resend OTP
//       authCubit.checkUserExists(); // This will trigger OTP sending

//       _startResendTimer();
//       _showSuccessSnackBar('OTP resent successfully!');
//     } catch (e) {
//       _showErrorSnackBar('Failed to resend OTP. Please try again.');
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }

//   void _showErrorSnackBar(String message) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Theme.of(context).colorScheme.error,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       ),
//     );
//   }

//   void _showSuccessSnackBar(String message) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.green,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final isDarkMode = theme.brightness == Brightness.dark;
//     final screenSize = MediaQuery.of(context).size;
//     final isTablet = screenSize.width >= 600;

//     return Scaffold(
//       backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[50],
//       appBar: _buildAppBar(context, isDarkMode),
//       body: SafeArea(
//         child: LayoutBuilder(
//           builder: (context, constraints) {
//             return SingleChildScrollView(
//               physics: const BouncingScrollPhysics(),
//               child: ConstrainedBox(
//                 constraints: BoxConstraints(
//                   minHeight: constraints.maxHeight,
//                 ),
//                 child: AnimatedBuilder(
//                   animation: _animationController,
//                   builder: (context, child) {
//                     return FadeTransition(
//                       opacity: _fadeInAnimation,
//                       child: SlideTransition(
//                         position: _slideAnimation,
//                         child: AnimatedBuilder(
//                           animation: _shakeAnimation,
//                           builder: (context, child) {
//                             return Transform.translate(
//                               offset: Offset(_shakeAnimation.value * 10, 0),
//                               child: Padding(
//                                 padding: EdgeInsets.symmetric(
//                                   horizontal: isTablet ? 48.w : 24.w,
//                                   vertical: 16.h,
//                                 ),
//                                 child: Column(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     _buildHeader(isDarkMode, isTablet),
//                                     SizedBox(height: 40.h),
//                                     _buildOTPInput(theme, isDarkMode, isTablet),
//                                     SizedBox(height: 32.h),
//                                     _buildVerifyButton(theme, isTablet),
//                                     SizedBox(height: 24.h),
//                                     _buildResendSection(
//                                         theme, isDarkMode, isTablet),
//                                     SizedBox(height: 24.h),
//                                     _buildHelpSection(
//                                         theme, isDarkMode, isTablet),
//                                   ],
//                                 ),
//                               ),
//                             );
//                           },
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   PreferredSizeWidget _buildAppBar(BuildContext context, bool isDarkMode) {
//     return AppBar(
//       title: Text(
//         LocaleKeys.auth_vereifyOtp.tr(),
//         style: TextStyle(
//           fontSize: 20.sp,
//           fontWeight: FontWeight.w600,
//           color: isDarkMode ? Colors.white : Colors.black87,
//         ),
//       ),
//       centerTitle: true,
//       backgroundColor: Colors.transparent,
//       elevation: 0,
//       leading: IconButton(
//         icon: Icon(
//           Icons.arrow_back_ios_new,
//           color: isDarkMode ? Colors.white : Colors.black87,
//           size: 20.w,
//         ),
//         onPressed: () => Navigator.of(context).pop(),
//       ),
//     );
//   }

//   Widget _buildHeader(bool isDarkMode, bool isTablet) {
//     return Column(
//       children: [
//         Hero(
//           tag: 'otp_icon',
//           child: Container(
//             width: isTablet ? 220.w : 180.w,
//             height: isTablet ? 220.h : 180.h,
//             decoration: BoxDecoration(
//               color: Colors.transparent,
//               shape: BoxShape.circle,
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.transparent,
//                   blurRadius: 20,
//                   offset: const Offset(0, 10),
//                 ),
//               ],
//             ),
//             child: otpController.text.isEmpty
//                 ? Lottie.asset(
//                     "assets/animations/otp.json",
//                     width: isTablet ? 200.w : 160.w,
//                     height: isTablet ? 200.h : 160.h,
//                     fit: BoxFit.contain,
//                     repeat: true,
//                   )
//                 : Lottie.asset(
//                     "assets/animations/otp.json",
//                     width: isTablet ? 200.w : 160.w,
//                     height: isTablet ? 200.h : 160.h,
//                     fit: BoxFit.contain,
//                     repeat: true,
//                   ),
//           ),
//         ),
//         SizedBox(height: 32.h),
//         AnimatedDefaultTextStyle(
//           duration: const Duration(milliseconds: 300),
//           style: TextStyle(
//             fontSize: isTablet ? 32.sp : 28.sp,
//             fontWeight: FontWeight.bold,
//             color: isDarkMode ? Colors.white : Colors.black87,
//             letterSpacing: -0.5,
//           ),
//           child: Text(
//             LocaleKeys.auth_enterOtp.tr(),
//             textAlign: TextAlign.center,
//           ),
//         ),
//         SizedBox(height: 16.h),
//         Padding(
//           padding: EdgeInsets.symmetric(horizontal: isTablet ? 40.w : 20.w),
//           child: RichText(
//             textAlign: TextAlign.center,
//             text: TextSpan(
//               style: TextStyle(
//                 fontSize: isTablet ? 18.sp : 16.sp,
//                 color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
//                 height: 1.6,
//               ),
//               children: [
//                 TextSpan(text: LocaleKeys.auth_otpSentMessage.tr()),
//                 TextSpan(
//                   text: ' ${widget.phoneNumber}',
//                   style: TextStyle(
//                     fontWeight: FontWeight.w700,
//                     color: Theme.of(context).colorScheme.primary,
//                     fontSize: isTablet ? 19.sp : 17.sp,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildOTPInput(ThemeData theme, bool isDarkMode, bool isTablet) {
//     final defaultPinTheme = PinTheme(
//       width: isTablet ? 68.w : 60.w,
//       height: isTablet ? 68.h : 60.h,
//       textStyle: TextStyle(
//         fontSize: isTablet ? 28.sp : 24.sp,
//         fontWeight: FontWeight.w700,
//         color: isDarkMode ? Colors.white : Colors.black87,
//         letterSpacing: 2,
//       ),
//       decoration: BoxDecoration(
//         color: isDarkMode ? Colors.grey[800] : Colors.white,
//         borderRadius: BorderRadius.circular(16.r),
//         border: Border.all(
//           color: isDarkMode ? Colors.grey[600]! : Colors.grey[300]!,
//           width: 2,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: theme.colorScheme.primary.withOpacity(0.08),
//             blurRadius: 15,
//             offset: const Offset(0, 4),
//             spreadRadius: 0,
//           ),
//           BoxShadow(
//             color: isDarkMode
//                 ? Colors.black.withOpacity(0.1)
//                 : Colors.grey.withOpacity(0.05),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//     );

//     final focusedPinTheme = defaultPinTheme.copyWith(
//       decoration: BoxDecoration(
//         color: isDarkMode ? Colors.grey[750] : Colors.white,
//         borderRadius: BorderRadius.circular(16.r),
//         border: Border.all(
//           color: theme.colorScheme.primary,
//           width: 3,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: theme.colorScheme.primary.withOpacity(0.25),
//             blurRadius: 20,
//             offset: const Offset(0, 8),
//             spreadRadius: 0,
//           ),
//           BoxShadow(
//             color: theme.colorScheme.primary.withOpacity(0.1),
//             blurRadius: 40,
//             offset: const Offset(0, 0),
//             spreadRadius: 8,
//           ),
//         ],
//       ),
//     );

//     final submittedPinTheme = defaultPinTheme.copyWith(
//       decoration: BoxDecoration(
//         color: theme.colorScheme.primary.withOpacity(0.08),
//         borderRadius: BorderRadius.circular(16.r),
//         border: Border.all(
//           color: theme.colorScheme.primary,
//           width: 2,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: theme.colorScheme.primary.withOpacity(0.15),
//             blurRadius: 15,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//     );

//     final errorPinTheme = defaultPinTheme.copyWith(
//       decoration: BoxDecoration(
//         color: isDarkMode ? Colors.red[900]?.withOpacity(0.2) : Colors.red[50],
//         borderRadius: BorderRadius.circular(16.r),
//         border: Border.all(
//           color: theme.colorScheme.error,
//           width: 2,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: theme.colorScheme.error.withOpacity(0.2),
//             blurRadius: 15,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//     );

//     return Container(
//       padding: EdgeInsets.all(isTablet ? 40.w : 32.w),
//       decoration: BoxDecoration(
//         color: isDarkMode
//             ? Colors.grey[850]?.withOpacity(0.3)
//             : Colors.white.withOpacity(0.9),
//         borderRadius: BorderRadius.circular(24.r),
//         border: Border.all(
//           color: theme.colorScheme.primary.withOpacity(0.1),
//           width: 1,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: isDarkMode
//                 ? Colors.black.withOpacity(0.2)
//                 : Colors.grey.withOpacity(0.1),
//             blurRadius: 30,
//             offset: const Offset(0, 15),
//             spreadRadius: 0,
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           AnimatedContainer(
//             duration: const Duration(milliseconds: 300),
//             curve: Curves.easeInOut,
//             child: Pinput(
//               controller: otpController,
//               focusNode: otpFocusNode,
//               length: 6,
//               defaultPinTheme: defaultPinTheme,
//               focusedPinTheme: focusedPinTheme,
//               submittedPinTheme: submittedPinTheme,
//               errorPinTheme: errorPinTheme,
//               showCursor: true,
//               cursor: Container(
//                 width: 3,
//                 height: 28.h,
//                 decoration: BoxDecoration(
//                   color: theme.colorScheme.primary,
//                   borderRadius: BorderRadius.circular(2.r),
//                 ),
//               ),
//               onCompleted: (pin) {
//                 HapticFeedback.selectionClick();
//                 _verifyOTP();
//               },
//               onChanged: (value) {
//                 setState(() {
//                   // Trigger rebuild to update header animation
//                 });
//               },
//               hapticFeedbackType: HapticFeedbackType.lightImpact,
//               pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
//               animationDuration: const Duration(milliseconds: 300),
//               animationCurve: Curves.easeInOut,
//               enableSuggestions: false,
//               obscureText: false,
//               keyboardType: TextInputType.number,
//               autofocus: true,
//             ),
//           ),
//           if (otpController.text.isNotEmpty && otpController.text.length < 6)
//             Padding(
//               padding: EdgeInsets.only(top: 16.h),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(
//                     Icons.info_outline_rounded,
//                     color: theme.colorScheme.primary,
//                     size: isTablet ? 20.w : 18.w,
//                   ),
//                   SizedBox(width: 8.w),
//                   Text(
//                     'Enter ${6 - otpController.text.length} more digits',
//                     style: TextStyle(
//                       fontSize: isTablet ? 15.sp : 13.sp,
//                       color: theme.colorScheme.primary,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildVerifyButton(ThemeData theme, bool isTablet) {
//     final isOTPComplete = otpController.text.length == 6;

//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 300),
//       width: double.infinity,
//       height: isTablet ? 60.h : 56.h,
//       child: ElevatedButton(
//         onPressed: isLoading || !isOTPComplete ? null : _verifyOTP,
//         style: ElevatedButton.styleFrom(
//           backgroundColor: isOTPComplete
//               ? theme.colorScheme.primary
//               : theme.colorScheme.primary.withOpacity(0.6),
//           foregroundColor: theme.colorScheme.onPrimary,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16.r),
//           ),
//           elevation: isOTPComplete ? 8 : 2,
//           shadowColor: theme.colorScheme.primary.withOpacity(0.4),
//           splashFactory: InkRipple.splashFactory,
//         ).copyWith(
//           animationDuration: const Duration(milliseconds: 200),
//         ),
//         child: AnimatedSwitcher(
//           duration: const Duration(milliseconds: 300),
//           transitionBuilder: (child, animation) {
//             return ScaleTransition(
//               scale: animation,
//               child: FadeTransition(
//                 opacity: animation,
//                 child: child,
//               ),
//             );
//           },
//           child: isLoading
//               ? SizedBox(
//                   key: const ValueKey('loading'),
//                   width: 28.w,
//                   height: 28.w,
//                   child: CircularProgressIndicator(
//                     strokeWidth: 3,
//                     valueColor: AlwaysStoppedAnimation<Color>(
//                       theme.colorScheme.onPrimary,
//                     ),
//                   ),
//                 )
//               : Row(
//                   key: const ValueKey('verify'),
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     if (isOTPComplete) ...[
//                       Icon(
//                         Icons.verified_user_rounded,
//                         size: isTablet ? 24.w : 22.w,
//                         color: theme.colorScheme.onPrimary,
//                       ),
//                       SizedBox(width: 12.w),
//                     ],
//                     Text(
//                       LocaleKeys.auth_verify.tr(),
//                       style: TextStyle(
//                         fontSize: isTablet ? 20.sp : 18.sp,
//                         fontWeight: FontWeight.w700,
//                         letterSpacing: 0.5,
//                         color: theme.colorScheme.onPrimary,
//                       ),
//                     ),
//                     if (isOTPComplete) ...[
//                       SizedBox(width: 12.w),
//                       Icon(
//                         Icons.arrow_forward_rounded,
//                         size: isTablet ? 22.w : 20.w,
//                         color: theme.colorScheme.onPrimary,
//                       ),
//                     ],
//                   ],
//                 ),
//         ),
//       ),
//     );
//   }

//   Widget _buildResendSection(ThemeData theme, bool isDarkMode, bool isTablet) {
//     return Container(
//       padding: EdgeInsets.symmetric(
//         horizontal: isTablet ? 24.w : 20.w,
//         vertical: isTablet ? 20.h : 16.h,
//       ),
//       decoration: BoxDecoration(
//         color:
//             isDarkMode ? Colors.grey[800]?.withOpacity(0.3) : Colors.grey[50],
//         borderRadius: BorderRadius.circular(16.r),
//         border: Border.all(
//           color: isDarkMode ? Colors.grey[700]! : Colors.grey[200]!,
//           width: 1,
//         ),
//       ),
//       child: Column(
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(
//                 canResend ? Icons.refresh_rounded : Icons.access_time_rounded,
//                 color: canResend
//                     ? theme.colorScheme.primary
//                     : isDarkMode
//                         ? Colors.grey[500]
//                         : Colors.grey[600],
//                 size: isTablet ? 20.w : 18.w,
//               ),
//               SizedBox(width: 8.w),
//               Text(
//                 LocaleKeys.auth_didntReceiveCode.tr(),
//                 style: TextStyle(
//                   fontSize: isTablet ? 16.sp : 14.sp,
//                   color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 12.h),
//           AnimatedContainer(
//             duration: const Duration(milliseconds: 300),
//             child: TextButton.icon(
//               onPressed: canResend ? _resendOTP : null,
//               icon: canResend
//                   ? Icon(
//                       Icons.send_rounded,
//                       size: isTablet ? 20.w : 18.w,
//                       color: theme.colorScheme.primary,
//                     )
//                   : SizedBox.shrink(),
//               label: AnimatedSwitcher(
//                 duration: const Duration(milliseconds: 300),
//                 child: Text(
//                   key: ValueKey(canResend),
//                   canResend
//                       ? LocaleKeys.auth_resendOtp.tr()
//                       : '${LocaleKeys.auth_resend.tr()} in ${resendCounter}s',
//                   style: TextStyle(
//                     fontSize: isTablet ? 18.sp : 16.sp,
//                     fontWeight: FontWeight.w700,
//                     color: canResend
//                         ? theme.colorScheme.primary
//                         : isDarkMode
//                             ? Colors.grey[500]
//                             : Colors.grey[500],
//                   ),
//                 ),
//               ),
//               style: TextButton.styleFrom(
//                 padding: EdgeInsets.symmetric(
//                   horizontal: isTablet ? 20.w : 16.w,
//                   vertical: isTablet ? 12.h : 10.h,
//                 ),
//                 backgroundColor: canResend
//                     ? theme.colorScheme.primary.withOpacity(0.1)
//                     : Colors.transparent,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12.r),
//                   side: canResend
//                       ? BorderSide(
//                           color: theme.colorScheme.primary.withOpacity(0.2),
//                           width: 1,
//                         )
//                       : BorderSide.none,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildHelpSection(ThemeData theme, bool isDarkMode, bool isTablet) {
//     return Container(
//       padding: EdgeInsets.all(isTablet ? 20.w : 16.w),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             theme.colorScheme.primary.withOpacity(0.05),
//             theme.colorScheme.secondary.withOpacity(0.03),
//           ],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(16.r),
//         border: Border.all(
//           color: theme.colorScheme.primary.withOpacity(0.15),
//           width: 1,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: theme.colorScheme.primary.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           Row(
//             children: [
//               Container(
//                 padding: EdgeInsets.all(8.w),
//                 decoration: BoxDecoration(
//                   color: theme.colorScheme.primary.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(12.r),
//                 ),
//                 child: Icon(
//                   Icons.help_outline_rounded,
//                   color: theme.colorScheme.primary,
//                   size: isTablet ? 24.w : 20.w,
//                 ),
//               ),
//               SizedBox(width: 16.w),
//               Expanded(
//                 child: Text(
//                   LocaleKeys.auth_needHelp.tr(),
//                   style: TextStyle(
//                     fontSize: isTablet ? 18.sp : 16.sp,
//                     color: isDarkMode ? Colors.white : Colors.black87,
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 12.h),
//           Container(
//             width: double.infinity,
//             height: 1,
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [
//                   Colors.transparent,
//                   theme.colorScheme.primary.withOpacity(0.2),
//                   Colors.transparent,
//                 ],
//               ),
//             ),
//           ),
//           SizedBox(height: 12.h),
//           Text(
//             LocaleKeys.auth_didntReceiveCodeDescription.tr(),
//             style: TextStyle(
//               fontSize: isTablet ? 15.sp : 13.sp,
//               color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
//               height: 1.5,
//               fontWeight: FontWeight.w500,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           SizedBox(height: 16.h),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: [
//               _buildHelpAction(
//                 icon: Icons.phone_rounded,
//                 label: 'Call Support',
//                 onTap: () {
//                   // Handle call support
//                 },
//                 theme: theme,
//                 isDarkMode: isDarkMode,
//                 isTablet: isTablet,
//               ),
//               Container(
//                 width: 1,
//                 height: 30.h,
//                 color: theme.colorScheme.primary.withOpacity(0.2),
//               ),
//               _buildHelpAction(
//                 icon: Icons.chat_rounded,
//                 label: 'Live Chat',
//                 onTap: () {
//                   // Handle live chat
//                 },
//                 theme: theme,
//                 isDarkMode: isDarkMode,
//                 isTablet: isTablet,
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildHelpAction({
//     required IconData icon,
//     required String label,
//     required VoidCallback onTap,
//     required ThemeData theme,
//     required bool isDarkMode,
//     required bool isTablet,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: EdgeInsets.symmetric(
//           horizontal: isTablet ? 16.w : 12.w,
//           vertical: isTablet ? 10.h : 8.h,
//         ),
//         decoration: BoxDecoration(
//           color: theme.colorScheme.primary.withOpacity(0.1),
//           borderRadius: BorderRadius.circular(12.r),
//           border: Border.all(
//             color: theme.colorScheme.primary.withOpacity(0.2),
//             width: 1,
//           ),
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(
//               icon,
//               color: theme.colorScheme.primary,
//               size: isTablet ? 18.w : 16.w,
//             ),
//             SizedBox(width: 8.w),
//             Text(
//               label,
//               style: TextStyle(
//                 fontSize: isTablet ? 14.sp : 12.sp,
//                 color: theme.colorScheme.primary,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
