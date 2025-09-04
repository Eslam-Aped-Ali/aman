import 'package:Aman/core/shared/utils/user_exprience/flash_helper.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../app/routing/app_routes_fun.dart';
import '../../../../../../app/routing/routes.dart';
import '../../../../../../core/shared/services/storage_service.dart';
import '../../../../../../core/shared/utils/enums.dart';
import '../../../../../../core/shared/utils/responsive/responsive_utils.dart';
import '../../../../../../generated/locale_keys.g.dart';
import '../../viewModel/profile_cubit/passenger_profile_cubit.dart';
import '../../viewModel/profile_cubit/passenger_profile_state.dart';
import '../../../../booking/presentation/view/screens/my_bookings_screen.dart';

class PassengerProfileScreen extends StatefulWidget {
  const PassengerProfileScreen({super.key});

  @override
  State<PassengerProfileScreen> createState() => _PassengerProfileScreenState();
}

class _PassengerProfileScreenState extends State<PassengerProfileScreen>
    with TickerProviderStateMixin {
  // Controllers
  late AnimationController _animationController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Form controllers
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emergencyContactController =
      TextEditingController();

  // State variables
  bool isEditing = false;
  bool isLoading = false;
  String selectedGender = 'male';
  DateTime? selectedBirthDate;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadProfileData();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
    _fadeController.forward();
  }

  Future<void> _loadProfileData() async {
    setState(() => isLoading = true);

    try {
      // Load profile data from storage
      firstNameController.text = StorageService.getString('first_name') ?? '';
      lastNameController.text = StorageService.getString('last_name') ?? '';
      emailController.text = StorageService.getString('email') ?? '';
      phoneController.text = StorageService.getString('phone_number') ?? '';
      emergencyContactController.text =
          StorageService.getString('emergency_contact') ?? '';
      selectedGender = StorageService.getString('gender') ?? 'male';

      final birthDateString = StorageService.getString('birth_date');
      if (birthDateString != null) {
        selectedBirthDate = DateTime.parse(birthDateString);
      }
    } catch (e) {
      _showSnackBar(LocaleKeys.profile_profileLoadFailed.tr(), isError: true);
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _selectProfileImage() async {
    // Show image picker options
    _showImagePicker();
  }

  void _showImagePicker() {
    // Image picker functionality - requires image_picker package
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              LocaleKeys.profile_selectProfileImage.tr(),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(LocaleKeys.common_camera.tr()),
              onTap: () {
                Navigator.pop(context);
                _showSnackBar(LocaleKeys.profile_imagePickerSoon.tr());
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(LocaleKeys.common_gallery.tr()),
              onTap: () {
                Navigator.pop(context);
                _showSnackBar(LocaleKeys.profile_imagePickerSoon.tr());
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectBirthDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedBirthDate ?? DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 16)),
      builder: (context, child) {
        final theme = Theme.of(context);
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: theme.colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedBirthDate) {
      setState(() {
        selectedBirthDate = picked;
      });
      HapticFeedback.selectionClick();
    }
  }

  Future<void> _saveProfile() async {
    if (!_validateForm()) return;

    setState(() => isLoading = true);
    HapticFeedback.lightImpact();

    try {
      // Save profile data to storage
      await StorageService.setString(
          'first_name', firstNameController.text.trim());
      await StorageService.setString(
          'last_name', lastNameController.text.trim());
      await StorageService.setString('email', emailController.text.trim());
      await StorageService.setString(
          'emergency_contact', emergencyContactController.text.trim());
      await StorageService.setString('gender', selectedGender);

      if (selectedBirthDate != null) {
        await StorageService.setString(
            'birth_date', selectedBirthDate!.toIso8601String());
      }

      _showSnackBar(LocaleKeys.profile_profileSaved.tr());
      setState(() => isEditing = false);
    } catch (e) {
      _showSnackBar(LocaleKeys.profile_profileSaveFailed.tr(), isError: true);
    } finally {
      setState(() => isLoading = false);
    }
  }

  bool _validateForm() {
    if (firstNameController.text.trim().isEmpty) {
      _showSnackBar(LocaleKeys.profile_firstNameRequired.tr(), isError: true);
      return false;
    }
    if (lastNameController.text.trim().isEmpty) {
      _showSnackBar(LocaleKeys.profile_lastNameRequired.tr(), isError: true);
      return false;
    }
    if (emailController.text.trim().isNotEmpty) {
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(emailController.text.trim())) {
        _showSnackBar(LocaleKeys.profile_invalidEmail.tr(), isError: true);
        return false;
      }
    }
    return true;
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
      ),
    );
  }

  void _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(LocaleKeys.auth_logout.tr()),
        content: Text(LocaleKeys.auth_logoutConfirm.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(LocaleKeys.common_cancel.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              LocaleKeys.auth_logout.tr(),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Call logout through cubit
      context.read<PassengerProfileCubit>().logout();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _fadeController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    emergencyContactController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final responsive = context.responsive;
    final isTablet = responsive.isTablet;

    return BlocListener<PassengerProfileCubit, PassengerProfileState>(
      listener: (context, state) {
        if (state is PassengerProfileLoggedOut) {
          // Navigate to select role screen after successful logout
          pushAndRemoveUntil(NamedRoutes.i.selectRole);
        } else if (state is PassengerProfileError) {
          // Show error message if logout fails
          showMessage(state.message, messageType: MessageTypeTost.fail);
        }
      },
      child: Scaffold(
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[50],
        body: isLoading
            ? Center(
                child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                ),
              )
            : AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                                maxWidth: responsive.maxContentWidth),
                            child: Padding(
                              padding: responsive.padding(24, 24),
                              child: Column(
                                children: [
                                  _buildProfileHeader(
                                      theme, isDarkMode, responsive, isTablet),
                                  SizedBox(height: responsive.spacing(24)),
                                  _buildQuickStatsSection(
                                      theme, isDarkMode, responsive, isTablet),
                                  SizedBox(height: responsive.spacing(24)),
                                  _buildPersonalInfoSection(
                                      theme, isDarkMode, responsive, isTablet),
                                  SizedBox(height: responsive.spacing(24)),
                                  _buildContactInfoSection(
                                      theme, isDarkMode, responsive, isTablet),
                                  SizedBox(height: responsive.spacing(24)),
                                  _buildPreferencesSection(
                                      theme, isDarkMode, responsive, isTablet),
                                  SizedBox(height: responsive.spacing(32)),
                                  _buildActionButtons(
                                      theme, isDarkMode, responsive, isTablet),
                                  SizedBox(height: responsive.spacing(24)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildProfileHeader(ThemeData theme, bool isDarkMode,
      ResponsiveUtils responsive, bool isTablet) {
    return Container(
      padding: responsive.padding(24, 24),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(responsive.spacing(16)),
        boxShadow: [
          BoxShadow(
            color: isDarkMode ? Colors.black26 : Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: isEditing ? _selectProfileImage : null,
            child: Stack(
              children: [
                Container(
                  width: isTablet ? 120.w : 100.w,
                  height: isTablet ? 120.w : 100.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.colorScheme.primary,
                      width: 3,
                    ),
                  ),
                  child: ClipOval(
                    child: Container(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      child: Icon(
                        Icons.person,
                        size: isTablet ? 50.w : 40.w,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                if (isEditing)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(6.w),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDarkMode ? Colors.grey[800]! : Colors.white,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        size: 16.w,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: responsive.spacing(16)),
          Text(
            '${firstNameController.text} ${lastNameController.text}',
            style: TextStyle(
              fontSize: responsive.fontSize(24),
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          SizedBox(height: responsive.spacing(8)),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: responsive.spacing(12),
              vertical: responsive.spacing(6),
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(responsive.spacing(12)),
            ),
            child: Text(
              LocaleKeys.auth_passenger.tr(),
              style: TextStyle(
                fontSize: responsive.fontSize(14),
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatsSection(ThemeData theme, bool isDarkMode,
      ResponsiveUtils responsive, bool isTablet) {
    return Container(
      padding: responsive.padding(20, 20),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(responsive.spacing(16)),
        boxShadow: [
          BoxShadow(
            color: isDarkMode ? Colors.black26 : Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              title: LocaleKeys.profile_stats_totalTrips.tr(),
              value: '0', // This would come from actual data
              icon: Icons.directions_car,
              color: Colors.blue,
              theme: theme,
              isDarkMode: isDarkMode,
              responsive: responsive,
            ),
          ),
          SizedBox(width: responsive.spacing(16)),
          Expanded(
            child: _buildStatItem(
              title: LocaleKeys.profile_stats_savedRoutes.tr(),
              value: '0', // This would come from actual data
              icon: Icons.bookmark,
              color: Colors.green,
              theme: theme,
              isDarkMode: isDarkMode,
              responsive: responsive,
            ),
          ),
          SizedBox(width: responsive.spacing(16)),
          Expanded(
            child: _buildStatItem(
              title: LocaleKeys.profile_stats_rating.tr(),
              value: '5.0', // This would come from actual data
              icon: Icons.star,
              color: Colors.orange,
              theme: theme,
              isDarkMode: isDarkMode,
              responsive: responsive,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required ThemeData theme,
    required bool isDarkMode,
    required ResponsiveUtils responsive,
  }) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(responsive.spacing(12)),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(responsive.spacing(12)),
          ),
          child: Icon(
            icon,
            color: color,
            size: responsive.fontSize(24),
          ),
        ),
        SizedBox(height: responsive.spacing(8)),
        Text(
          value,
          style: TextStyle(
            fontSize: responsive.fontSize(18),
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        SizedBox(height: responsive.spacing(4)),
        Text(
          title,
          style: TextStyle(
            fontSize: responsive.fontSize(12),
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPersonalInfoSection(ThemeData theme, bool isDarkMode,
      ResponsiveUtils responsive, bool isTablet) {
    return _buildSection(
      title: LocaleKeys.profile_personalInformation.tr(),
      icon: Icons.person_outline,
      theme: theme,
      isDarkMode: isDarkMode,
      responsive: responsive,
      isEditable: true,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildInfoField(
                label: LocaleKeys.profile_firstName.tr(),
                controller: firstNameController,
                icon: Icons.person,
                enabled: isEditing,
                theme: theme,
                isDarkMode: isDarkMode,
                responsive: responsive,
                validator: (value) => value?.isEmpty == true
                    ? LocaleKeys.common_required.tr()
                    : null,
              ),
            ),
            SizedBox(width: responsive.spacing(16)),
            Expanded(
              child: _buildInfoField(
                label: LocaleKeys.profile_lastName.tr(),
                controller: lastNameController,
                icon: Icons.person,
                enabled: isEditing,
                theme: theme,
                isDarkMode: isDarkMode,
                responsive: responsive,
                validator: (value) => value?.isEmpty == true
                    ? LocaleKeys.common_required.tr()
                    : null,
              ),
            ),
          ],
        ),
        SizedBox(height: responsive.spacing(16)),
        _buildGenderSelector(theme, isDarkMode, responsive),
        SizedBox(height: responsive.spacing(16)),
        _buildBirthDateSelector(theme, isDarkMode, responsive),
      ],
    );
  }

  Widget _buildContactInfoSection(ThemeData theme, bool isDarkMode,
      ResponsiveUtils responsive, bool isTablet) {
    return _buildSection(
      title: LocaleKeys.profile_contactInformation.tr(),
      icon: Icons.contact_phone_outlined,
      theme: theme,
      isDarkMode: isDarkMode,
      responsive: responsive,
      isEditable: true,
      children: [
        _buildInfoField(
          label: LocaleKeys.profile_phone.tr(),
          controller: phoneController,
          icon: Icons.phone,
          enabled: false, // Phone number should not be editable
          theme: theme,
          isDarkMode: isDarkMode,
          responsive: responsive,
        ),
        SizedBox(height: responsive.spacing(16)),
        _buildInfoField(
          label: LocaleKeys.profile_email.tr(),
          controller: emailController,
          icon: Icons.email,
          enabled: isEditing,
          theme: theme,
          isDarkMode: isDarkMode,
          responsive: responsive,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value?.isNotEmpty == true) {
              final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
              if (!emailRegex.hasMatch(value!)) {
                return LocaleKeys.profile_invalidEmail.tr();
              }
            }
            return null;
          },
        ),
        SizedBox(height: responsive.spacing(16)),
        _buildInfoField(
          label: LocaleKeys.profile_emergencyContact.tr(),
          controller: emergencyContactController,
          icon: Icons.emergency,
          enabled: isEditing,
          theme: theme,
          isDarkMode: isDarkMode,
          responsive: responsive,
          keyboardType: TextInputType.phone,
        ),
      ],
    );
  }

  Widget _buildPreferencesSection(ThemeData theme, bool isDarkMode,
      ResponsiveUtils responsive, bool isTablet) {
    return _buildSection(
      title: LocaleKeys.profile_preferences.tr(),
      icon: Icons.settings_outlined,
      theme: theme,
      isDarkMode: isDarkMode,
      responsive: responsive,
      children: [
        _buildPreferenceItem(
          title: LocaleKeys.profile_notifications.tr(),
          subtitle: LocaleKeys.profile_notificationsDesc.tr(),
          trailing: Switch(
            value: true, // This would come from preferences
            onChanged: isEditing
                ? (value) {
                    // Handle notification preference change
                    HapticFeedback.selectionClick();
                  }
                : null,
            activeThumbColor: theme.colorScheme.primary,
          ),
          theme: theme,
          isDarkMode: isDarkMode,
          responsive: responsive,
        ),
        SizedBox(height: responsive.spacing(12)),
        _buildPreferenceItem(
          title: LocaleKeys.settings_locationSharing.tr(),
          subtitle: LocaleKeys.settings_locationSharingDescription.tr(),
          trailing: Switch(
            value: true, // This would come from preferences
            onChanged: isEditing
                ? (value) {
                    // Handle location preference change
                    HapticFeedback.selectionClick();
                  }
                : null,
            activeThumbColor: theme.colorScheme.primary,
          ),
          theme: theme,
          isDarkMode: isDarkMode,
          responsive: responsive,
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required ThemeData theme,
    required bool isDarkMode,
    required ResponsiveUtils responsive,
    required List<Widget> children,
    bool? isEditable = false,
  }) {
    return Container(
      width: double.infinity,
      padding: responsive.padding(20, 20),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(responsive.spacing(16)),
        boxShadow: [
          BoxShadow(
            color: isDarkMode ? Colors.black26 : Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: theme.colorScheme.primary,
                size: responsive.fontSize(24),
              ),
              SizedBox(width: responsive.spacing(12)),
              Text(
                title,
                style: TextStyle(
                  fontSize: responsive.fontSize(18),
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              if (isEditable == true) const Spacer(),
              IconButton(
                icon: Icon(
                  isEditing ? Icons.save : Icons.edit,
                  color: theme.colorScheme.primary,
                  size: responsive.fontSize(24),
                ),
                onPressed: isEditing
                    ? _saveProfile
                    : () => setState(() => isEditing = true),
              ),
            ],
          ),
          SizedBox(height: responsive.spacing(16)),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required bool enabled,
    required ThemeData theme,
    required bool isDarkMode,
    required ResponsiveUtils responsive,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: responsive.fontSize(14),
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
          ),
        ),
        SizedBox(height: responsive.spacing(8)),
        TextFormField(
          controller: controller,
          enabled: enabled,
          keyboardType: keyboardType,
          validator: validator,
          style: TextStyle(
            fontSize: responsive.fontSize(16),
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(
              icon,
              color: enabled ? theme.colorScheme.primary : Colors.grey,
              size: responsive.fontSize(20),
            ),
            filled: true,
            fillColor: enabled
                ? (isDarkMode ? Colors.grey[700] : Colors.grey[50])
                : (isDarkMode ? Colors.grey[800] : Colors.grey[100]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(responsive.spacing(12)),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(responsive.spacing(12)),
              borderSide:
                  BorderSide(color: theme.colorScheme.primary, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: responsive.spacing(16),
              vertical: responsive.spacing(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderSelector(
      ThemeData theme, bool isDarkMode, ResponsiveUtils responsive) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleKeys.profile_gender.tr(),
          style: TextStyle(
            fontSize: responsive.fontSize(14),
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
          ),
        ),
        SizedBox(height: responsive.spacing(8)),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: responsive.spacing(16),
            vertical: responsive.spacing(4),
          ),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[700] : Colors.grey[50],
            borderRadius: BorderRadius.circular(responsive.spacing(12)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.person_outline,
                color: theme.colorScheme.primary,
                size: responsive.fontSize(20),
              ),
              SizedBox(width: responsive.spacing(12)),
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedGender,
                    isExpanded: true,
                    onChanged: isEditing
                        ? (String? newValue) {
                            if (newValue != null) {
                              setState(() => selectedGender = newValue);
                              HapticFeedback.selectionClick();
                            }
                          }
                        : null,
                    items: ['male', 'female', 'other'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value.substring(0, 1).toUpperCase() +
                              value.substring(1),
                          style: TextStyle(
                            fontSize: responsive.fontSize(16),
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                      );
                    }).toList(),
                    dropdownColor: isDarkMode ? Colors.grey[700] : Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBirthDateSelector(
      ThemeData theme, bool isDarkMode, ResponsiveUtils responsive) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleKeys.profile_birthDate.tr(),
          style: TextStyle(
            fontSize: responsive.fontSize(14),
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
          ),
        ),
        SizedBox(height: responsive.spacing(8)),
        GestureDetector(
          onTap: isEditing ? _selectBirthDate : null,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: responsive.spacing(16),
              vertical: responsive.spacing(16),
            ),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[700] : Colors.grey[50],
              borderRadius: BorderRadius.circular(responsive.spacing(12)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: theme.colorScheme.primary,
                  size: responsive.fontSize(20),
                ),
                SizedBox(width: responsive.spacing(12)),
                Expanded(
                  child: Text(
                    selectedBirthDate != null
                        ? DateFormat('MMM dd, yyyy').format(selectedBirthDate!)
                        : LocaleKeys.profile_selectDate.tr(),
                    style: TextStyle(
                      fontSize: responsive.fontSize(16),
                      color: selectedBirthDate != null
                          ? (isDarkMode ? Colors.white : Colors.black87)
                          : (isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                    ),
                  ),
                ),
                if (isEditing)
                  Icon(
                    Icons.arrow_drop_down,
                    color: theme.colorScheme.primary,
                    size: responsive.fontSize(24),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPreferenceItem({
    required String title,
    required String subtitle,
    required Widget trailing,
    required ThemeData theme,
    required bool isDarkMode,
    required ResponsiveUtils responsive,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: responsive.fontSize(16),
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              SizedBox(height: responsive.spacing(4)),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: responsive.fontSize(14),
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        trailing,
      ],
    );
  }

  Widget _buildActionButtons(ThemeData theme, bool isDarkMode,
      ResponsiveUtils responsive, bool isTablet) {
    return Container(
      padding: responsive.padding(20, 20),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(responsive.spacing(16)),
        boxShadow: [
          BoxShadow(
            color: isDarkMode ? Colors.black26 : Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildActionButton(
            title: LocaleKeys.profile_tripHistory.tr(),
            subtitle: LocaleKeys.profile_tripHistoryDesc.tr(),
            icon: Icons.history,
            onTap: () {
              // Navigate to trip history - placeholder for future implementation
              _showSnackBar(LocaleKeys.profile_tripHistorySoon.tr());
            },
            theme: theme,
            isDarkMode: isDarkMode,
            responsive: responsive,
          ),
          Divider(
            color: isDarkMode ? Colors.grey[600] : Colors.grey[300],
            height: responsive.spacing(24),
          ),
          _buildActionButton(
            title: LocaleKeys.myBookings_title.tr(),
            subtitle: LocaleKeys.home_viewBookingHistory.tr(),
            icon: Icons.book_online,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MyBookingsScreen(),
                ),
              );
            },
            theme: theme,
            isDarkMode: isDarkMode,
            responsive: responsive,
          ),
          Divider(
            color: isDarkMode ? Colors.grey[600] : Colors.grey[300],
            height: responsive.spacing(24),
          ),
          _buildActionButton(
            title: LocaleKeys.profile_favoriteRoutes.tr(),
            subtitle: LocaleKeys.profile_favoriteRoutesDesc.tr(),
            icon: Icons.favorite_outline,
            onTap: () {
              // Navigate to favorite routes - placeholder for future implementation
              _showSnackBar(LocaleKeys.profile_favoriteRoutesSoon.tr());
            },
            theme: theme,
            isDarkMode: isDarkMode,
            responsive: responsive,
          ),
          Divider(
            color: isDarkMode ? Colors.grey[600] : Colors.grey[300],
            height: responsive.spacing(24),
          ),
          _buildActionButton(
            title: LocaleKeys.profile_paymentMethods.tr(),
            subtitle: LocaleKeys.profile_paymentMethodsDesc.tr(),
            icon: Icons.payment,
            onTap: () {
              // Navigate to payment methods - placeholder for future implementation
              _showSnackBar(LocaleKeys.profile_paymentMethodsSoon.tr());
            },
            theme: theme,
            isDarkMode: isDarkMode,
            responsive: responsive,
          ),
          Divider(
            color: isDarkMode ? Colors.grey[600] : Colors.grey[300],
            height: responsive.spacing(24),
          ),
          _buildActionButton(
            title: LocaleKeys.settings_title.tr(),
            subtitle: LocaleKeys.settings_appSettingsDescription.tr(),
            icon: Icons.settings_outlined,
            onTap: () {
              Navigator.pushNamed(context, NamedRoutes.i.settings);
            },
            theme: theme,
            isDarkMode: isDarkMode,
            responsive: responsive,
          ),
          Divider(
            color: isDarkMode ? Colors.grey[600] : Colors.grey[300],
            height: responsive.spacing(24),
          ),
          _buildActionButton(
            title: LocaleKeys.help_title.tr(),
            subtitle: LocaleKeys.help_helpSupportDescription.tr(),
            icon: Icons.help_outline,
            onTap: () {
              Navigator.pushNamed(context, NamedRoutes.i.helpSupport);
            },
            theme: theme,
            isDarkMode: isDarkMode,
            responsive: responsive,
          ),
          Divider(
            color: isDarkMode ? Colors.grey[600] : Colors.grey[300],
            height: responsive.spacing(24),
          ),
          _buildActionButton(
            title: LocaleKeys.auth_logout.tr(),
            subtitle: LocaleKeys.auth_signOutFromAccount.tr(),
            icon: Icons.logout,
            onTap: _logout,
            theme: theme,
            isDarkMode: isDarkMode,
            responsive: responsive,
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    required ThemeData theme,
    required bool isDarkMode,
    required ResponsiveUtils responsive,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(responsive.spacing(12)),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: responsive.spacing(8)),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(responsive.spacing(12)),
              decoration: BoxDecoration(
                color: (isDestructive ? Colors.red : theme.colorScheme.primary)
                    .withOpacity(0.1),
                borderRadius: BorderRadius.circular(responsive.spacing(12)),
              ),
              child: Icon(
                icon,
                color: isDestructive ? Colors.red : theme.colorScheme.primary,
                size: responsive.fontSize(24),
              ),
            ),
            SizedBox(width: responsive.spacing(16)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: responsive.fontSize(16),
                      fontWeight: FontWeight.w600,
                      color: isDestructive
                          ? Colors.red
                          : (isDarkMode ? Colors.white : Colors.black87),
                    ),
                  ),
                  SizedBox(height: responsive.spacing(4)),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: responsive.fontSize(14),
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              size: responsive.fontSize(16),
            ),
          ],
        ),
      ),
    );
  }
}
