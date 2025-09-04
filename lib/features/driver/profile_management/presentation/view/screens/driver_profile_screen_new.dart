import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../core/shared/theme/colors/app_colors.dart';
import '../../../../../../core/shared/utils/responsive/responsive_utils.dart';
import '../../../../../../core/shared/services/storage_service.dart';
import '../../../../../../app/routing/routes.dart';
import '../../bloc/driver_profile_bloc.dart';
import '../../bloc/driver_profile_event.dart';
import '../../bloc/driver_profile_state.dart';

class DriverProfileScreen extends StatefulWidget {
  const DriverProfileScreen({super.key});

  @override
  State<DriverProfileScreen> createState() => _DriverProfileScreenState();
}

class _DriverProfileScreenState extends State<DriverProfileScreen>
    with TickerProviderStateMixin {
  // Controllers
  late AnimationController _animationController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Form controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  // State variables
  bool isEditing = false;
  bool isLoading = false;
  String selectedGender = 'male';
  int? selectedBirthYear;

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

    _fadeController.forward();
    _animationController.forward();
  }

  Future<void> _loadProfileData() async {
    // Mock data loading - replace with actual BLoC call
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      nameController.text = 'Ahmed Al-Rashid';
      phoneController.text = '+968 9123 4567';
      selectedGender = 'male';
      selectedBirthYear = 1990;
    });
  }

  Future<void> _selectProfileImage() async {
    _showImagePicker();
  }

  void _showImagePicker() {
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
              'Choose Profile Picture',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _showSnackBar('Camera feature coming soon');
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _showSnackBar('Gallery feature coming soon');
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectBirthYear() async {
    final int? picked = await showDialog<int>(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          height: 300,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Text('Select Birth Year', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: 50,
                  itemBuilder: (context, index) {
                    final year = DateTime.now().year - 18 - index;
                    return ListTile(
                      title: Text(year.toString()),
                      onTap: () => Navigator.of(context).pop(year),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (picked != null) {
      setState(() {
        selectedBirthYear = picked;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_validateForm()) return;

    setState(() => isLoading = true);
    try {
      await Future.delayed(const Duration(seconds: 1)); // Mock API call
      _showSnackBar('Profile updated successfully!');
      setState(() => isEditing = false);
    } catch (e) {
      _showSnackBar('Failed to update profile', isError: true);
    } finally {
      setState(() => isLoading = false);
    }
  }

  bool _validateForm() {
    if (nameController.text.trim().isEmpty) {
      _showSnackBar('Please enter your name', isError: true);
      return false;
    }
    if (phoneController.text.trim().isEmpty) {
      _showSnackBar('Please enter your phone number', isError: true);
      return false;
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
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      context.read<DriverProfileBloc>().add(const LogoutDriver());
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _fadeController.dispose();
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final responsive = context.responsive;
    final isTablet = responsive.isTablet;

    return BlocListener<DriverProfileBloc, DriverProfileState>(
      listener: (context, state) {
        if (state is DriverLoggedOut) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            NamedRoutes.i.selectRole,
            (route) => false,
          );
        } else if (state is DriverProfileError) {
          _showSnackBar(state.message, isError: true);
        }
      },
      child: Scaffold(
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[50],
        body: isLoading
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
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
                                  _buildDriverStatsSection(
                                      theme, isDarkMode, responsive, isTablet),
                                  SizedBox(height: responsive.spacing(24)),
                                  _buildPersonalInfoSection(
                                      theme, isDarkMode, responsive, isTablet),
                                  SizedBox(height: responsive.spacing(24)),
                                  _buildContactInfoSection(
                                      theme, isDarkMode, responsive, isTablet),
                                  SizedBox(height: responsive.spacing(24)),
                                  _buildDriverPreferencesSection(
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
                      color: AppColors.primary,
                      width: 3,
                    ),
                  ),
                  child: ClipOval(
                    child: Container(
                      color: AppColors.primary.withOpacity(0.1),
                      child: Icon(
                        Icons.person,
                        size: isTablet ? 50.w : 40.w,
                        color: AppColors.primary,
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
                        color: AppColors.primary,
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
            nameController.text.isNotEmpty
                ? nameController.text
                : 'Driver Name',
            style: TextStyle(
              fontSize: responsive.fontSize(24),
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: responsive.spacing(8)),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: responsive.spacing(12),
              vertical: responsive.spacing(6),
            ),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(responsive.spacing(20)),
            ),
            child: Text(
              'Active Driver',
              style: TextStyle(
                fontSize: responsive.fontSize(12),
                color: Colors.green[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(height: responsive.spacing(16)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Text(
                    '4.8',
                    style: TextStyle(
                      fontSize: responsive.fontSize(20),
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    'Rating',
                    style: TextStyle(
                      fontSize: responsive.fontSize(12),
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
              Container(
                height: 30,
                width: 1,
                color: isDarkMode ? Colors.grey[600] : Colors.grey[300],
              ),
              Column(
                children: [
                  Text(
                    '127',
                    style: TextStyle(
                      fontSize: responsive.fontSize(20),
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    'Trips',
                    style: TextStyle(
                      fontSize: responsive.fontSize(12),
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
              Container(
                height: 30,
                width: 1,
                color: isDarkMode ? Colors.grey[600] : Colors.grey[300],
              ),
              Column(
                children: [
                  Text(
                    '3.2K',
                    style: TextStyle(
                      fontSize: responsive.fontSize(20),
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    'KMs',
                    style: TextStyle(
                      fontSize: responsive.fontSize(12),
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDriverStatsSection(ThemeData theme, bool isDarkMode,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.local_shipping,
                color: AppColors.primary,
                size: responsive.fontSize(20),
              ),
              SizedBox(width: responsive.spacing(8)),
              Text(
                'Driver Statistics',
                style: TextStyle(
                  fontSize: responsive.fontSize(18),
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: responsive.spacing(16)),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'This Month',
                  '23',
                  'Completed Trips',
                  Icons.check_circle,
                  Colors.green,
                  isDarkMode,
                  responsive,
                ),
              ),
              SizedBox(width: responsive.spacing(12)),
              Expanded(
                child: _buildStatCard(
                  'This Week',
                  '6',
                  'Trips',
                  Icons.directions_bus,
                  Colors.blue,
                  isDarkMode,
                  responsive,
                ),
              ),
            ],
          ),
          SizedBox(height: responsive.spacing(12)),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Revenue',
                  '2,450',
                  'OMR',
                  Icons.attach_money,
                  Colors.orange,
                  isDarkMode,
                  responsive,
                ),
              ),
              SizedBox(width: responsive.spacing(12)),
              Expanded(
                child: _buildStatCard(
                  'Avg Rating',
                  '4.8',
                  'Stars',
                  Icons.star,
                  Colors.amber,
                  isDarkMode,
                  responsive,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    String unit,
    IconData icon,
    Color color,
    bool isDarkMode,
    ResponsiveUtils responsive,
  ) {
    return Container(
      padding: responsive.padding(12, 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(responsive.spacing(8)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: responsive.fontSize(20)),
          SizedBox(height: responsive.spacing(4)),
          Text(
            value,
            style: TextStyle(
              fontSize: responsive.fontSize(18),
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            unit,
            style: TextStyle(
              fontSize: responsive.fontSize(10),
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: responsive.fontSize(10),
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection(ThemeData theme, bool isDarkMode,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    color: AppColors.primary,
                    size: responsive.fontSize(20),
                  ),
                  SizedBox(width: responsive.spacing(8)),
                  Text(
                    'Personal Information',
                    style: TextStyle(
                      fontSize: responsive.fontSize(18),
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    isEditing = !isEditing;
                    if (!isEditing) {
                      // Save changes
                      _saveProfile();
                    }
                  });
                },
                icon: Icon(
                  isEditing ? Icons.save : Icons.edit,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: responsive.spacing(16)),
          _buildInfoField(
            'Full Name',
            nameController,
            Icons.person,
            isEditing,
            isDarkMode,
            responsive,
          ),
          SizedBox(height: responsive.spacing(16)),
          _buildGenderField(isDarkMode, responsive),
          SizedBox(height: responsive.spacing(16)),
          _buildBirthYearField(isDarkMode, responsive),
        ],
      ),
    );
  }

  Widget _buildContactInfoSection(ThemeData theme, bool isDarkMode,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.contact_phone,
                color: AppColors.primary,
                size: responsive.fontSize(20),
              ),
              SizedBox(width: responsive.spacing(8)),
              Text(
                'Contact Information',
                style: TextStyle(
                  fontSize: responsive.fontSize(18),
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: responsive.spacing(16)),
          _buildInfoField(
            'Phone Number',
            phoneController,
            Icons.phone,
            false, // Phone number should not be editable
            isDarkMode,
            responsive,
          ),
        ],
      ),
    );
  }

  Widget _buildDriverPreferencesSection(ThemeData theme, bool isDarkMode,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.settings,
                color: AppColors.primary,
                size: responsive.fontSize(20),
              ),
              SizedBox(width: responsive.spacing(8)),
              Text(
                'Driver Preferences',
                style: TextStyle(
                  fontSize: responsive.fontSize(18),
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: responsive.spacing(16)),
          _buildPreferenceItem(
            'Notifications',
            'Receive trip notifications',
            true,
            Icons.notifications,
            isDarkMode,
            responsive,
          ),
          SizedBox(height: responsive.spacing(12)),
          _buildPreferenceItem(
            'Auto Accept',
            'Automatically accept assigned trips',
            false,
            Icons.auto_awesome,
            isDarkMode,
            responsive,
          ),
        ],
      ),
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
            title: 'Trip History',
            subtitle: 'View your completed trips',
            icon: Icons.history,
            onTap: () {
              _showSnackBar('Trip History feature coming soon!');
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
            title: 'Earnings Report',
            subtitle: 'View your earnings details',
            icon: Icons.account_balance_wallet,
            onTap: () {
              _showSnackBar('Earnings Report feature coming soon!');
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
            title: 'Settings',
            subtitle: 'App settings and preferences',
            icon: Icons.settings_outlined,
            onTap: () {
              _showSnackBar('Settings feature coming soon!');
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
            title: 'Help & Support',
            subtitle: 'Get help or contact support',
            icon: Icons.help_outline,
            onTap: () {
              _showSnackBar('Help & Support feature coming soon!');
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
            title: 'Logout',
            subtitle: 'Sign out of your account',
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

  Widget _buildInfoField(
    String label,
    TextEditingController controller,
    IconData icon,
    bool enabled,
    bool isDarkMode,
    ResponsiveUtils responsive,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: responsive.fontSize(14),
            fontWeight: FontWeight.w500,
            color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
          ),
        ),
        SizedBox(height: responsive.spacing(8)),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: responsive.spacing(16),
            vertical: responsive.spacing(16),
          ),
          decoration: BoxDecoration(
            color: enabled
                ? (isDarkMode ? Colors.grey[700] : Colors.grey[50])
                : (isDarkMode ? Colors.grey[800] : Colors.grey[100]),
            borderRadius: BorderRadius.circular(responsive.spacing(12)),
            border: enabled
                ? Border.all(
                    color: isDarkMode ? Colors.grey[600]! : Colors.grey[300]!)
                : null,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: AppColors.primary,
                size: responsive.fontSize(20),
              ),
              SizedBox(width: responsive.spacing(12)),
              Expanded(
                child: TextFormField(
                  controller: controller,
                  enabled: enabled,
                  style: TextStyle(
                    fontSize: responsive.fontSize(16),
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGenderField(bool isDarkMode, ResponsiveUtils responsive) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gender',
          style: TextStyle(
            fontSize: responsive.fontSize(14),
            fontWeight: FontWeight.w500,
            color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
          ),
        ),
        SizedBox(height: responsive.spacing(8)),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: responsive.spacing(16),
            vertical: responsive.spacing(8),
          ),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[700] : Colors.grey[50],
            borderRadius: BorderRadius.circular(responsive.spacing(12)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.person,
                color: AppColors.primary,
                size: responsive.fontSize(20),
              ),
              SizedBox(width: responsive.spacing(12)),
              Expanded(
                child: Row(
                  children: [
                    Radio<String>(
                      value: 'male',
                      groupValue: selectedGender,
                      onChanged: isEditing
                          ? (value) => setState(() => selectedGender = value!)
                          : null,
                      activeColor: AppColors.primary,
                    ),
                    Text(
                      'Male',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    SizedBox(width: responsive.spacing(20)),
                    Radio<String>(
                      value: 'female',
                      groupValue: selectedGender,
                      onChanged: isEditing
                          ? (value) => setState(() => selectedGender = value!)
                          : null,
                      activeColor: AppColors.primary,
                    ),
                    Text(
                      'Female',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBirthYearField(bool isDarkMode, ResponsiveUtils responsive) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Birth Year',
          style: TextStyle(
            fontSize: responsive.fontSize(14),
            fontWeight: FontWeight.w500,
            color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
          ),
        ),
        SizedBox(height: responsive.spacing(8)),
        GestureDetector(
          onTap: isEditing ? _selectBirthYear : null,
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
                  color: AppColors.primary,
                  size: responsive.fontSize(20),
                ),
                SizedBox(width: responsive.spacing(12)),
                Expanded(
                  child: Text(
                    selectedBirthYear != null
                        ? selectedBirthYear.toString()
                        : 'Select birth year',
                    style: TextStyle(
                      fontSize: responsive.fontSize(16),
                      color: selectedBirthYear != null
                          ? (isDarkMode ? Colors.white : Colors.black87)
                          : (isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                    ),
                  ),
                ),
                if (isEditing)
                  Icon(
                    Icons.arrow_drop_down,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPreferenceItem(
    String title,
    String subtitle,
    bool value,
    IconData icon,
    bool isDarkMode,
    ResponsiveUtils responsive,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppColors.primary,
          size: responsive.fontSize(20),
        ),
        SizedBox(width: responsive.spacing(12)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: responsive.fontSize(16),
                  fontWeight: FontWeight.w500,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: responsive.fontSize(12),
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: (newValue) {
            // Handle preference change
            _showSnackBar('Preference updated');
          },
          activeThumbColor: AppColors.primary,
        ),
      ],
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
              padding: responsive.padding(12, 12),
              decoration: BoxDecoration(
                color: isDestructive
                    ? Colors.red.withOpacity(0.1)
                    : AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(responsive.spacing(10)),
              ),
              child: Icon(
                icon,
                color: isDestructive ? Colors.red : AppColors.primary,
                size: responsive.fontSize(20),
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
                      fontWeight: FontWeight.w500,
                      color: isDestructive
                          ? Colors.red
                          : (isDarkMode ? Colors.white : Colors.black87),
                    ),
                  ),
                  SizedBox(height: responsive.spacing(2)),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: responsive.fontSize(12),
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: responsive.fontSize(16),
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ],
        ),
      ),
    );
  }
}
