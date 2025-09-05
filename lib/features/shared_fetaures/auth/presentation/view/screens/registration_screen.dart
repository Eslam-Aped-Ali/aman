// lib/features/shared_features/auth/presentation/screens/registration_screen.dart
import 'package:Aman/app/routing/routes.dart';
import 'package:Aman/core/shared/utils/user_exprience/flash_helper.dart';
import 'package:Aman/features/shared_fetaures/auth/domain/entities/user.dart';
import 'package:Aman/features/shared_fetaures/auth/presentation/bloc/auth_cubit.dart';
import 'package:Aman/features/shared_fetaures/auth/presentation/bloc/auth_state.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Aman/app/routing/app_routes_fun.dart';
import 'package:Aman/core/shared/utils/enums.dart';
import 'package:Aman/generated/locale_keys.g.dart';

class RegistrationScreen extends StatefulWidget {
  final String? userRole;
  final String? phoneNumber;

  const RegistrationScreen({
    super.key,
    this.userRole,
    this.phoneNumber,
  });

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen>
    with TickerProviderStateMixin {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  // Animation controllers
  late AnimationController _animationController;
  late AnimationController _progressController;
  late Animation<double> _fadeInAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _progressAnimation;

  // State
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _setupAnimations();

    // Set phone number if provided
    if (widget.phoneNumber != null) {
      phoneController.text = widget.phoneNumber!;
    }
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 800),
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

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
    _progressController.animateTo(0.5); // 50% complete
  }

  @override
  void dispose() {
    _animationController.dispose();
    _progressController.dispose();
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  // تسجيل المستخدم
  Future<void> _register() async {
    if (!formKey.currentState!.validate()) return;

    final authCubit = context.read<AuthCubit>();

    await authCubit.register(
      fullName: fullNameController.text.trim(),
      email: emailController.text.trim(),
      phone: phoneController.text.trim(),
      password: passwordController.text,
      role: UserRole.fromString(widget.userRole?.toUpperCase() ?? 'PASSENGER'),
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
            // Show success message and navigate to login with pre-filled credentials
            showMessage('Registration successful! Please login to continue.',
                messageType: MessageTypeTost.success);
            pushAndRemoveUntil(NamedRoutes.i.login, arguments: {
              'userRole': widget.userRole,
              'preFilledPhone': phoneController.text.trim(),
              'preFilledPassword': passwordController.text,
            });
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildProgressBar(theme, isTablet),
                                SizedBox(height: 24.h),
                                _buildHeader(isDarkMode, isTablet),
                                SizedBox(height: 32.h),
                                _buildForm(theme, isDarkMode, isTablet),
                                SizedBox(height: 32.h),
                                _buildRegisterButton(theme, isTablet),
                                SizedBox(height: 16.h),
                                _buildLoginLink(theme, isDarkMode),
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
        LocaleKeys.auth_createAccount.tr(),
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

  Widget _buildProgressBar(ThemeData theme, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleKeys.common_stepProgress.tr(args: ['1', '2']),
          style: TextStyle(
            fontSize: isTablet ? 16.sp : 14.sp,
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h),
        AnimatedBuilder(
          animation: _progressAnimation,
          builder: (context, child) {
            return LinearProgressIndicator(
              value: _progressAnimation.value,
              backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
              valueColor:
                  AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
              minHeight: 6.h,
            );
          },
        ),
      ],
    );
  }

  Widget _buildHeader(bool isDarkMode, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleKeys.auth_welcomeToAman.tr(),
          style: TextStyle(
            fontSize: isTablet ? 28.sp : 24.sp,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          LocaleKeys.auth_createAccountSubtitle
              .tr(args: [widget.userRole ?? 'passenger']),
          style: TextStyle(
            fontSize: isTablet ? 18.sp : 16.sp,
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildForm(ThemeData theme, bool isDarkMode, bool isTablet) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          // Full Name Field
          _buildTextField(
            controller: fullNameController,
            label: LocaleKeys.auth_fullName.tr(),
            hint: LocaleKeys.auth_enterFullName.tr(),
            prefixIcon: Icons.person_outline,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return LocaleKeys.auth_fullNameRequired.tr();
              }
              return null;
            },
            theme: theme,
            isDarkMode: isDarkMode,
            isTablet: isTablet,
          ),
          SizedBox(height: 20.h),

          // Email Field
          _buildTextField(
            controller: emailController,
            label: LocaleKeys.auth_emailAddress.tr(),
            hint: LocaleKeys.auth_enterEmail.tr(),
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return LocaleKeys.auth_emailRequired.tr();
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                  .hasMatch(value!)) {
                return LocaleKeys.auth_invalidEmail.tr();
              }
              return null;
            },
            theme: theme,
            isDarkMode: isDarkMode,
            isTablet: isTablet,
          ),
          SizedBox(height: 20.h),

          // Phone Field
          _buildTextField(
            controller: phoneController,
            label: LocaleKeys.auth_phoneNumber.tr(),
            hint: LocaleKeys.auth_enterPhoneNumber.tr(),
            prefixIcon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            readOnly: widget.phoneNumber != null,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return LocaleKeys.auth_phoneNumberRequired.tr();
              }
              return null;
            },
            theme: theme,
            isDarkMode: isDarkMode,
            isTablet: isTablet,
          ),
          SizedBox(height: 20.h),

          // Password Field
          _buildTextField(
            controller: passwordController,
            label: LocaleKeys.auth_password.tr(),
            hint: LocaleKeys.auth_enterPassword.tr(),
            prefixIcon: Icons.lock_outline,
            obscureText: _obscurePassword,
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
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return LocaleKeys.auth_passwordRequired.tr();
              }
              if (value!.length < 6) {
                return LocaleKeys.auth_passwordLength.tr();
              }
              return null;
            },
            theme: theme,
            isDarkMode: isDarkMode,
            isTablet: isTablet,
          ),
          SizedBox(height: 20.h),

          // Confirm Password Field
          _buildTextField(
            controller: confirmPasswordController,
            label: LocaleKeys.auth_confirmPassword.tr(),
            hint: LocaleKeys.auth_confirmPasswordHint.tr(),
            prefixIcon: Icons.lock_outline,
            obscureText: _obscureConfirmPassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword
                    ? Icons.visibility_off
                    : Icons.visibility,
                color: theme.colorScheme.primary,
              ),
              onPressed: () {
                setState(() {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                });
              },
            ),
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return LocaleKeys.auth_confirmPasswordRequired.tr();
              }
              if (value != passwordController.text) {
                return LocaleKeys.auth_passwordsDoNotMatch.tr();
              }
              return null;
            },
            theme: theme,
            isDarkMode: isDarkMode,
            isTablet: isTablet,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData prefixIcon,
    required ThemeData theme,
    required bool isDarkMode,
    required bool isTablet,
    bool obscureText = false,
    bool readOnly = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTablet ? 16.sp : 14.sp,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          readOnly: readOnly,
          keyboardType: keyboardType,
          validator: validator,
          style: TextStyle(
            fontSize: isTablet ? 18.sp : 16.sp,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
            prefixIcon: Icon(
              prefixIcon,
              color: theme.colorScheme.primary,
              size: isTablet ? 24.w : 20.w,
            ),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: isDarkMode ? Colors.grey[800] : Colors.white,
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
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: theme.colorScheme.error,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: isTablet ? 20.h : 16.h,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterButton(ThemeData theme, bool isTablet) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final isLoading = state.requestState == RequestState.loading;

        return SizedBox(
          width: double.infinity,
          height: isTablet ? 56.h : 52.h,
          child: ElevatedButton(
            onPressed: isLoading ? null : _register,
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
                    LocaleKeys.auth_createAccount.tr(),
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

  Widget _buildLoginLink(ThemeData theme, bool isDarkMode) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            LocaleKeys.auth_alreadyHaveAccount.tr(),
            style: TextStyle(
              fontSize: 14.sp,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          TextButton(
            onPressed: () {
              replacement(NamedRoutes.i.login,
                  arguments: {'userRole': widget.userRole});
            },
            child: Text(
              LocaleKeys.auth_login.tr(),
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
