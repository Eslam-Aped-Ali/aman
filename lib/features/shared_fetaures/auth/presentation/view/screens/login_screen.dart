// lib/features/shared_features/auth/presentation/screens/login_screen.dart
import 'package:Aman/app/routing/routes.dart';
import 'package:Aman/core/shared/utils/user_exprience/flash_helper.dart';
import 'package:Aman/features/shared_fetaures/auth/presentation/bloc/auth_cubit.dart';
import 'package:Aman/features/shared_fetaures/auth/presentation/bloc/auth_state.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Aman/app/routing/app_routes_fun.dart';
import 'package:Aman/core/shared/utils/enums.dart';
import 'package:Aman/generated/locale_keys.g.dart';

class LoginScreen extends StatefulWidget {
  final String? userRole;

  const LoginScreen({
    super.key,
    this.userRole,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;

  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeInAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeInOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // تسجيل الدخول
  Future<void> _login() async {
    if (!formKey.currentState!.validate()) return;

    final authCubit = context.read<AuthCubit>();

    await authCubit.login(
      phone: phoneController.text.trim(),
      password: passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width >= 600;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[50],
      appBar: _buildAppBar(context, isDarkMode),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state.requestState == RequestState.done) {
            // Navigate based on user role
            pushAndRemoveUntil(NamedRoutes.i.layout,
                arguments: {'userType': widget.userRole ?? 'passenger'});
          } else if (state.requestState == RequestState.error) {
            showMessage(state.msg, messageType: MessageTypeTost.fail);
          }
        },
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _fadeInAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: isTablet ? 48.w : 24.w,
                              vertical: 16.h,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildHeader(isDarkMode, isTablet),
                                SizedBox(height: 40.h),
                                _buildLoginForm(theme, isDarkMode, isTablet),
                                SizedBox(height: 40.h),
                                _buildLoginButton(theme, isTablet),
                                SizedBox(height: 24.h),
                                _buildRegisterLink(theme, isDarkMode),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDarkMode) {
    return AppBar(
      title: Text(
        LocaleKeys.auth_login.tr(),
        style: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.w600,
          color: isDarkMode ? Colors.white : Colors.black87,
        ),
      ),
      centerTitle: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new,
          color: isDarkMode ? Colors.white : Colors.black87,
          size: 20.w,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  Widget _buildHeader(bool isDarkMode, bool isTablet) {
    return Column(
      children: [
        // Logo with animation
        Hero(
          tag: 'app_logo',
          child: Container(
            width: isTablet ? 120.w : 100.w,
            height: isTablet ? 120.w : 100.w,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.lock_outline,
              size: isTablet ? 60.w : 50.w,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        SizedBox(height: 24.h),
        Text(
          LocaleKeys.auth_welcomeBack.tr(),
          style: TextStyle(
            fontSize: isTablet ? 28.sp : 24.sp,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 12.h),
        Text(
          LocaleKeys.auth_loginSubtitle
              .tr(args: [widget.userRole ?? 'account']),
          style: TextStyle(
            fontSize: isTablet ? 18.sp : 16.sp,
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoginForm(ThemeData theme, bool isDarkMode, bool isTablet) {
    return Form(
      key: formKey,
      child: Container(
        padding: EdgeInsets.all(isTablet ? 32.w : 24.w),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[800] : Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Phone Field
            TextFormField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return LocaleKeys.auth_phoneNumberRequired.tr();
                }
                return null;
              },
              style: TextStyle(
                fontSize: isTablet ? 18.sp : 16.sp,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
              decoration: InputDecoration(
                labelText: LocaleKeys.auth_phoneNumber.tr(),
                hintText: LocaleKeys.auth_enterPhoneNumber.tr(),
                prefixIcon: Icon(
                  Icons.phone_outlined,
                  color: theme.colorScheme.primary,
                ),
                filled: true,
                fillColor: isDarkMode ? Colors.grey[700] : Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(
                    color: isDarkMode ? Colors.grey[600]! : Colors.grey[300]!,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 2,
                  ),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: isTablet ? 20.h : 16.h,
                ),
              ),
            ),
            SizedBox(height: 20.h),

            // Password Field
            TextFormField(
              controller: passwordController,
              obscureText: _obscurePassword,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return LocaleKeys.auth_passwordRequired.tr();
                }
                return null;
              },
              style: TextStyle(
                fontSize: isTablet ? 18.sp : 16.sp,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
              decoration: InputDecoration(
                labelText: LocaleKeys.auth_password.tr(),
                hintText: LocaleKeys.auth_enterPassword.tr(),
                prefixIcon: Icon(
                  Icons.lock_outline,
                  color: theme.colorScheme.primary,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: theme.colorScheme.primary,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                filled: true,
                fillColor: isDarkMode ? Colors.grey[700] : Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(
                    color: isDarkMode ? Colors.grey[600]! : Colors.grey[300]!,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 2,
                  ),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: isTablet ? 20.h : 16.h,
                ),
              ),
            ),

            // Forgot Password Link
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  // Navigate to forgot password
                  showMessage(LocaleKeys.common_comingSoon.tr(),
                      messageType: MessageTypeTost.warning);
                },
                child: Text(
                  LocaleKeys.auth_forgotPassword.tr(),
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginButton(ThemeData theme, bool isTablet) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final isLoading = state.requestState == RequestState.loading;

        return SizedBox(
          width: double.infinity,
          height: isTablet ? 56.h : 52.h,
          child: ElevatedButton(
            onPressed: isLoading ? null : _login,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              elevation: isLoading ? 0 : 4,
              shadowColor: theme.colorScheme.primary.withOpacity(0.3),
            ),
            child: isLoading
                ? SizedBox(
                    width: 24.w,
                    height: 24.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.onPrimary,
                      ),
                    ),
                  )
                : Text(
                    LocaleKeys.auth_login.tr(),
                    style: TextStyle(
                      fontSize: isTablet ? 20.sp : 18.sp,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildRegisterLink(ThemeData theme, bool isDarkMode) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          LocaleKeys.auth_noAccount.tr(),
          style: TextStyle(
            fontSize: 14.sp,
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        TextButton(
          onPressed: () {
            push(NamedRoutes.i.register,
                arguments: {'userRole': widget.userRole});
          },
          child: Text(
            LocaleKeys.auth_register.tr(),
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }
}
