// import 'dart:async';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:intl_phone_number_input/intl_phone_number_input.dart';
// import 'package:lottie/lottie.dart';
// import '../../../../../../app/routing/app_routes_fun.dart';
// import '../../../../../../app/routing/routes.dart';
// import '../../../../../../core/shared/services/storage_service.dart';
// import '../../../../../../core/shared/utils/enums.dart';
// import '../../../../../../generated/locale_keys.g.dart';
// import '../../bloc/auth_cubit.dart';
// import '../../bloc/auth_state.dart';
// import '../../../../../../app/di.dart' as di;

// class LoginWithPhoneScreen extends StatefulWidget {
//   final String? userRole;

//   const LoginWithPhoneScreen({
//     super.key,
//     this.userRole,
//   });

//   @override
//   State<LoginWithPhoneScreen> createState() => _LoginWithPhoneScreenState();
// }

// class _LoginWithPhoneScreenState extends State<LoginWithPhoneScreen>
//     with SingleTickerProviderStateMixin {
//   final TextEditingController phoneController = TextEditingController();
//   final GlobalKey<FormState> formKey = GlobalKey<FormState>();

//   PhoneNumber phoneNumber = PhoneNumber(isoCode: 'OM');
//   bool isLoading = false;
//   bool isPhoneValid = false;
//   late AuthCubit authCubit;

//   late AnimationController _animationController;
//   late Animation<double> _fadeInAnimation;
//   late Animation<Offset> _slideAnimation;

//   @override
//   void initState() {
//     super.initState();
//     authCubit = di.sl<AuthCubit>();
//     _setupAnimations();
//   }

//   void _setupAnimations() {
//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 1200),
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

//     _animationController.forward();
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     phoneController.dispose();
//     authCubit.close();
//     super.dispose();
//   }

//   Future<void> _sendOTP() async {
//     if (!formKey.currentState!.validate() || !isPhoneValid) return;

//     setState(() => isLoading = true);

//     try {
//       // Haptic feedback
//       HapticFeedback.lightImpact();

//       final fullPhoneNumber = phoneNumber.phoneNumber ?? '';

//       // Update the AuthCubit phone controller
//       authCubit.phone.text = fullPhoneNumber;

//       // Store user role for later use
//       await StorageService.setString(
//           'user_role', widget.userRole ?? 'passenger');

//       // Check if user exists first
//       authCubit.checkUserExists();

//       // Create a subscription to listen to auth state changes
//       StreamSubscription<AuthState>? subscription;
//       subscription = authCubit.stream.listen((state) {
//         if (state.requestState == RequestState.done) {
//           subscription?.cancel(); // Cancel subscription on success
//           if (mounted) {
//             // Navigate to OTP screen
//             push(NamedRoutes.i.otp, arguments: {
//               'phoneNumber': fullPhoneNumber,
//               'userRole': widget.userRole,
//               'isAdmin': _isAdminNumber(fullPhoneNumber),
//             });
//           }
//         } else if (state.requestState == RequestState.error) {
//           subscription?.cancel(); // Cancel subscription on error
//           if (mounted) {
//             _showErrorSnackBar(state.msg.isEmpty
//                 ? LocaleKeys.auth_otpSendFailed.tr()
//                 : state.msg);
//           }
//         }

//         if (mounted) {
//           setState(
//               () => isLoading = state.requestState == RequestState.loading);
//         }
//       });

//       // Add timeout to cancel subscription if no response
//       Timer(Duration(seconds: 30), () {
//         subscription?.cancel();
//       });
//     } catch (e) {
//       _showErrorSnackBar(LocaleKeys.auth_invalidOtp.tr());
//       setState(() => isLoading = false);
//     }
//   }

//   bool _isAdminNumber(String phoneNumber) {
//     // Remove spaces and compare with admin number
//     final normalizedNumber = phoneNumber.replaceAll(' ', '');
//     return normalizedNumber == '+96892420578';
//   }

//   void _showErrorSnackBar(String message) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Theme.of(context).colorScheme.error,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//         action: SnackBarAction(
//           label: LocaleKeys.common_dismiss.tr(),
//           textColor: Colors.white,
//           onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
//         ),
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
//                         child: Padding(
//                           padding: EdgeInsets.symmetric(
//                             horizontal: isTablet ? 48.w : 24.w,
//                             vertical: 16.h,
//                           ),
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               _buildHeader(isDarkMode, isTablet),
//                               SizedBox(height: 40.h),
//                               _buildPhoneForm(theme, isDarkMode, isTablet),
//                               SizedBox(height: 40.h),
//                               _buildContinueButton(theme, isTablet),
//                               SizedBox(height: 24.h),
//                               _buildPrivacyNotice(theme, isDarkMode, isTablet),
//                             ],
//                           ),
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
//         LocaleKeys.auth_phoneVerificationMessage.tr(),
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
//           tag: 'phone_icon',
//           child: Container(
//             width: isTablet ? 280.w : 200.w,
//             height: isTablet ? 280.h : 200.h,
//             decoration: BoxDecoration(
//               color: Colors.transparent,
//               shape: BoxShape.circle,
//             ),
//             child: Lottie.asset(
//               'assets/animations/welcome.json',
//               width: isTablet ? 280.w : 200.w,
//               height: isTablet ? 280.h : 200.h,
//               fit: BoxFit.contain,
//               // errorBuilder: (context, error, stackTrace) {
//               //   // Fallback to an icon if Lottie fails to load
//               //   return Icon(
//               //     Icons.phone_android,
//               //     size: isTablet ? 80.w : 60.w,
//               //     color: Theme.of(context).colorScheme.primary,
//               //   );
//               // },
//             ),
//           ),
//         ),
//         SizedBox(height: 24.h),
//         Text(
//           LocaleKeys.auth_enterPhoneNumber.tr(),
//           style: TextStyle(
//             fontSize: isTablet ? 28.sp : 24.sp,
//             fontWeight: FontWeight.bold,
//             color: isDarkMode ? Colors.white : Colors.black87,
//           ),
//           textAlign: TextAlign.center,
//         ),
//         SizedBox(height: 12.h),
//         Padding(
//           padding: EdgeInsets.symmetric(horizontal: isTablet ? 40.w : 20.w),
//           child: Text(
//             LocaleKeys.auth_phoneVerificationMessage.tr(),
//             style: TextStyle(
//               fontSize: isTablet ? 18.sp : 16.sp,
//               color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
//               height: 1.5,
//             ),
//             textAlign: TextAlign.center,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildPhoneForm(ThemeData theme, bool isDarkMode, bool isTablet) {
//     return Form(
//       key: formKey,
//       child: Container(
//         padding: EdgeInsets.all(isTablet ? 32.w : 24.w),
//         decoration: BoxDecoration(
//           color: isDarkMode ? Colors.grey[800] : Colors.white,
//           borderRadius: BorderRadius.circular(20.r),
//           boxShadow: [
//             BoxShadow(
//               color: theme.colorScheme.primary.withOpacity(0.1),
//               blurRadius: 20,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               LocaleKeys.auth_phoneNumber.tr(),
//               style: TextStyle(
//                 fontSize: isTablet ? 18.sp : 16.sp,
//                 fontWeight: FontWeight.w600,
//                 color: isDarkMode ? Colors.white : Colors.black87,
//               ),
//             ),
//             SizedBox(height: 12.h),
//             InternationalPhoneNumberInput(
//               onInputChanged: (PhoneNumber number) {
//                 phoneNumber = number;
//                 setState(() {
//                   isPhoneValid = number.phoneNumber?.isNotEmpty == true;
//                 });
//               },
//               onInputValidated: (bool value) {
//                 setState(() {
//                   isPhoneValid = value && phoneController.text.isNotEmpty;
//                 });
//               },
//               validator: (value) {
//                 if (phoneController.text.isEmpty) {
//                   return LocaleKeys.auth_phoneNumberRequired.tr();
//                 }
//                 if (!isPhoneValid) {
//                   return LocaleKeys.auth_invalidPhoneNumber.tr();
//                 }
//                 return null;
//               },
//               selectorConfig: SelectorConfig(
//                 selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
//                 showFlags: true,
//                 useEmoji: false,
//                 setSelectorButtonAsPrefixIcon: true,
//                 leadingPadding: 16.w,
//               ),
//               ignoreBlank: false,
//               autoValidateMode: AutovalidateMode.onUserInteraction,
//               selectorTextStyle: TextStyle(
//                 color: isDarkMode ? Colors.white : Colors.black87,
//                 fontSize: isTablet ? 18.sp : 16.sp,
//               ),
//               initialValue: phoneNumber,
//               textFieldController: phoneController,
//               formatInput: true,
//               keyboardType: const TextInputType.numberWithOptions(
//                 signed: true,
//                 decimal: true,
//               ),
//               inputDecoration: InputDecoration(
//                 hintText: LocaleKeys.auth_enterPhoneNumber.tr(),
//                 hintStyle: TextStyle(
//                   color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
//                   fontSize: isTablet ? 18.sp : 16.sp,
//                 ),
//                 filled: true,
//                 fillColor: isDarkMode ? Colors.grey[700] : Colors.grey[100],
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12.r),
//                   borderSide: BorderSide.none,
//                 ),
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12.r),
//                   borderSide: BorderSide(
//                     color: isDarkMode ? Colors.grey[600]! : Colors.grey[300]!,
//                   ),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12.r),
//                   borderSide: BorderSide(
//                     color: theme.colorScheme.primary,
//                     width: 2,
//                   ),
//                 ),
//                 contentPadding: EdgeInsets.symmetric(
//                   horizontal: 16.w,
//                   vertical: isTablet ? 20.h : 16.h,
//                 ),
//               ),
//               textStyle: TextStyle(
//                 fontSize: isTablet ? 18.sp : 16.sp,
//                 color: isDarkMode ? Colors.white : Colors.black87,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildContinueButton(ThemeData theme, bool isTablet) {
//     return SizedBox(
//       width: double.infinity,
//       height: isTablet ? 56.h : 52.h,
//       child: ElevatedButton(
//         onPressed: isLoading || !isPhoneValid ? null : _sendOTP,
//         style: ElevatedButton.styleFrom(
//           backgroundColor: theme.colorScheme.primary,
//           foregroundColor: theme.colorScheme.onPrimary,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12.r),
//           ),
//           elevation: isLoading ? 0 : 4,
//           shadowColor: theme.colorScheme.primary.withOpacity(0.3),
//         ),
//         child: isLoading
//             ? SizedBox(
//                 width: 24.w,
//                 height: 24.w,
//                 child: CircularProgressIndicator(
//                   strokeWidth: 2.5,
//                   valueColor: AlwaysStoppedAnimation<Color>(
//                     theme.colorScheme.onPrimary,
//                   ),
//                 ),
//               )
//             : Text(
//                 LocaleKeys.auth_sendOtp.tr(),
//                 style: TextStyle(
//                   fontSize: isTablet ? 20.sp : 18.sp,
//                   fontWeight: FontWeight.w600,
//                   letterSpacing: 0.5,
//                 ),
//               ),
//       ),
//     );
//   }

//   Widget _buildPrivacyNotice(ThemeData theme, bool isDarkMode, bool isTablet) {
//     return Container(
//       padding: EdgeInsets.all(16.w),
//       decoration: BoxDecoration(
//         color: theme.colorScheme.primary.withOpacity(0.05),
//         borderRadius: BorderRadius.circular(12.r),
//         border: Border.all(
//           color: theme.colorScheme.primary.withOpacity(0.2),
//         ),
//       ),
//       child: Row(
//         children: [
//           Icon(
//             Icons.info_outline,
//             color: theme.colorScheme.primary,
//             size: isTablet ? 24.w : 20.w,
//           ),
//           SizedBox(width: 12.w),
//           Expanded(
//             child: Text(
//               LocaleKeys.auth_privacyNotice.tr(),
//               style: TextStyle(
//                 fontSize: isTablet ? 16.sp : 14.sp,
//                 color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
//                 height: 1.4,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
