// import 'dart:io';

// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// import '../../../../../../app/routing/app_routes_fun.dart';
// import '../../../../../../core/shared/services/storage_service.dart';

// class PassengerCompleteProfileScreen extends StatefulWidget {
//   const PassengerCompleteProfileScreen({super.key});

//   @override
//   State<PassengerCompleteProfileScreen> createState() =>
//       _PassengerCompleteProfileScreenState();
// }

// class _PassengerCompleteProfileScreenState
//     extends State<PassengerCompleteProfileScreen>
//     with TickerProviderStateMixin {
//   final GlobalKey<FormState> formKey = GlobalKey<FormState>();

//   // Controllers
//   final TextEditingController firstNameController = TextEditingController();
//   final TextEditingController lastNameController = TextEditingController();
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController emergencyContactController =
//       TextEditingController();

//   // Form state
//   bool isLoading = false;
//   File? profileImage;
//   String selectedGender = 'male';
//   DateTime? selectedBirthDate;

//   // Animation controllers
//   late AnimationController _animationController;
//   late AnimationController _progressController;
//   late Animation<double> _fadeInAnimation;
//   late Animation<Offset> _slideAnimation;
//   late Animation<double> _progressAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _setupAnimations();
//   }

//   void _setupAnimations() {
//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 1200),
//       vsync: this,
//     );

//     _progressController = AnimationController(
//       duration: const Duration(milliseconds: 800),
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

//     _progressAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _progressController,
//       curve: Curves.easeInOut,
//     ));

//     _animationController.forward();
//     _progressController.animateTo(0.7); // 70% complete
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     _progressController.dispose();
//     firstNameController.dispose();
//     lastNameController.dispose();
//     emailController.dispose();
//     emergencyContactController.dispose();
//     super.dispose();
//   }

//   Future<void> _selectBirthDate() async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: selectedBirthDate ?? DateTime(1990),
//       firstDate: DateTime(1900),
//       lastDate: DateTime.now()
//           .subtract(const Duration(days: 365 * 16)), // Min 16 years
//       builder: (context, child) {
//         final theme = Theme.of(context);
//         final isDarkMode = theme.brightness == Brightness.dark;
//         return Theme(
//           data: theme.copyWith(
//             colorScheme: theme.colorScheme.copyWith(
//               primary: theme.colorScheme.primary,
//               surface: isDarkMode ? Colors.grey[800] : Colors.white,
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );

//     if (picked != null && picked != selectedBirthDate) {
//       setState(() {
//         selectedBirthDate = picked;
//       });
//       HapticFeedback.selectionClick();
//     }
//   }

//   Future<void> _selectProfileImage() async {
//     // In a real app, you would use image_picker here
//     HapticFeedback.lightImpact();

//     // Show bottom sheet for image selection
//     showModalBottomSheet(
//       context: context,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
//       ),
//       builder: (context) => _buildImageSelectionSheet(),
//     );
//   }

//   Widget _buildImageSelectionSheet() {
//     final theme = Theme.of(context);
//     final isDarkMode = theme.brightness == Brightness.dark;

//     return Container(
//       padding: EdgeInsets.all(24.w),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(
//             width: 40.w,
//             height: 4.h,
//             decoration: BoxDecoration(
//               color: Colors.grey[400],
//               borderRadius: BorderRadius.circular(2.r),
//             ),
//           ),
//           SizedBox(height: 24.h),
//           Text(
//             'Select Profile Picture',
//             style: TextStyle(
//               fontSize: 20.sp,
//               fontWeight: FontWeight.bold,
//               color: isDarkMode ? Colors.white : Colors.black87,
//             ),
//           ),
//           SizedBox(height: 24.h),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: [
//               _buildImageOption(
//                 icon: Icons.camera_alt,
//                 label: 'Camera',
//                 onTap: () {
//                   Navigator.pop(context);
//                   // Implement camera functionality
//                 },
//               ),
//               _buildImageOption(
//                 icon: Icons.photo_library,
//                 label: 'Gallery',
//                 onTap: () {
//                   Navigator.pop(context);
//                   // Implement gallery functionality
//                 },
//               ),
//               if (profileImage != null)
//                 _buildImageOption(
//                   icon: Icons.delete,
//                   label: 'Remove',
//                   color: Colors.red,
//                   onTap: () {
//                     Navigator.pop(context);
//                     setState(() {
//                       profileImage = null;
//                     });
//                   },
//                 ),
//             ],
//           ),
//           SizedBox(height: 24.h),
//         ],
//       ),
//     );
//   }

//   Widget _buildImageOption({
//     required IconData icon,
//     required String label,
//     required VoidCallback onTap,
//     Color? color,
//   }) {
//     final theme = Theme.of(context);
//     final isDarkMode = theme.brightness == Brightness.dark;

//     return GestureDetector(
//       onTap: onTap,
//       child: Column(
//         children: [
//           Container(
//             width: 60.w,
//             height: 60.w,
//             decoration: BoxDecoration(
//               color: color?.withOpacity(0.1) ??
//                   theme.colorScheme.primary.withOpacity(0.1),
//               shape: BoxShape.circle,
//             ),
//             child: Icon(
//               icon,
//               size: 24.w,
//               color: color ?? theme.colorScheme.primary,
//             ),
//           ),
//           SizedBox(height: 8.h),
//           Text(
//             label,
//             style: TextStyle(
//               fontSize: 14.sp,
//               color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _completeProfile() async {
//     if (!formKey.currentState!.validate()) return;
//     if (selectedBirthDate == null) {
//       _showErrorSnackBar('Please select your birth date');
//       return;
//     }

//     setState(() => isLoading = true);

//     try {
//       // Haptic feedback
//       HapticFeedback.lightImpact();

//       // Simulate API call delay
//       await Future.delayed(const Duration(milliseconds: 1500));

//       final phoneNumber = StorageService.getString('phone_number') ?? '';

//       // Store profile data
//       await StorageService.setString('first_name', firstNameController.text);
//       await StorageService.setString('last_name', lastNameController.text);
//       await StorageService.setString('email', emailController.text);
//       await StorageService.setString(
//           'emergency_contact', emergencyContactController.text);
//       await StorageService.setString('gender', selectedGender);
//       await StorageService.setString(
//           'birth_date', selectedBirthDate!.toIso8601String());

//       // Mark profile as completed for this phone number
//       await StorageService.setBool('profile_completed_$phoneNumber', true);
//       await StorageService.setBool('profile_completed', true);
//       await StorageService.setBool('is_existing_user', true);

//       // Navigate to passenger layout
//       if (mounted) {
//         replacement('/layout', arguments: {'userType': 'passenger'});
//       }
//     } catch (e) {
//       _showErrorSnackBar('Failed to save profile. Please try again.');
//     } finally {
//       if (mounted) setState(() => isLoading = false);
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
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               _buildProgressBar(theme, isTablet),
//                               SizedBox(height: 24.h),
//                               _buildHeader(isDarkMode, isTablet),
//                               SizedBox(height: 32.h),
//                               _buildProfileImageSection(
//                                   theme, isDarkMode, isTablet),
//                               SizedBox(height: 32.h),
//                               _buildForm(theme, isDarkMode, isTablet),
//                               SizedBox(height: 32.h),
//                               _buildCompleteButton(theme, isTablet),
//                               SizedBox(height: 16.h),
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
//         'Complete Profile',
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

//   Widget _buildProgressBar(ThemeData theme, bool isTablet) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Step 2 of 3',
//           style: TextStyle(
//             fontSize: isTablet ? 16.sp : 14.sp,
//             color: theme.colorScheme.primary,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         SizedBox(height: 8.h),
//         AnimatedBuilder(
//           animation: _progressAnimation,
//           builder: (context, child) {
//             return LinearProgressIndicator(
//               value: _progressAnimation.value,
//               backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
//               valueColor:
//                   AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
//               minHeight: 6.h,
//             );
//           },
//         ),
//       ],
//     );
//   }

//   Widget _buildHeader(bool isDarkMode, bool isTablet) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Tell us about yourself',
//           style: TextStyle(
//             fontSize: isTablet ? 28.sp : 24.sp,
//             fontWeight: FontWeight.bold,
//             color: isDarkMode ? Colors.white : Colors.black87,
//           ),
//         ),
//         SizedBox(height: 8.h),
//         Text(
//           'Help us personalize your experience',
//           style: TextStyle(
//             fontSize: isTablet ? 18.sp : 16.sp,
//             color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
//             height: 1.5,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildProfileImageSection(
//       ThemeData theme, bool isDarkMode, bool isTablet) {
//     return Center(
//       child: Column(
//         children: [
//           Hero(
//             tag: 'profile_image',
//             child: GestureDetector(
//               onTap: _selectProfileImage,
//               child: Container(
//                 width: isTablet ? 120.w : 100.w,
//                 height: isTablet ? 120.w : 100.w,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   border: Border.all(
//                     color: theme.colorScheme.primary,
//                     width: 3,
//                   ),
//                   boxShadow: [
//                     BoxShadow(
//                       color: theme.colorScheme.primary.withOpacity(0.3),
//                       blurRadius: 20,
//                       offset: const Offset(0, 4),
//                     ),
//                   ],
//                 ),
//                 child: ClipOval(
//                   child: profileImage != null
//                       ? Image.file(
//                           profileImage!,
//                           width: isTablet ? 120.w : 100.w,
//                           height: isTablet ? 120.w : 100.w,
//                           fit: BoxFit.cover,
//                         )
//                       : Container(
//                           color:
//                               isDarkMode ? Colors.grey[800] : Colors.grey[200],
//                           child: Icon(
//                             Icons.person_add_alt_1,
//                             size: isTablet ? 40.w : 32.w,
//                             color: theme.colorScheme.primary,
//                           ),
//                         ),
//                 ),
//               ),
//             ),
//           ),
//           SizedBox(height: 12.h),
//           TextButton(
//             onPressed: _selectProfileImage,
//             child: Text(
//               profileImage != null ? 'Change Photo' : 'Add Photo',
//               style: TextStyle(
//                 fontSize: isTablet ? 16.sp : 14.sp,
//                 color: theme.colorScheme.primary,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildForm(ThemeData theme, bool isDarkMode, bool isTablet) {
//     return Form(
//       key: formKey,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Expanded(
//                 child: _buildTextField(
//                   controller: firstNameController,
//                   label: 'First Name',
//                   hint: 'Enter your first name',
//                   prefixIcon: Icons.person_outline,
//                   validator: (value) {
//                     if (value?.isEmpty ?? true) {
//                       return 'First name is required';
//                     }
//                     return null;
//                   },
//                   theme: theme,
//                   isDarkMode: isDarkMode,
//                   isTablet: isTablet,
//                 ),
//               ),
//               SizedBox(width: 16.w),
//               Expanded(
//                 child: _buildTextField(
//                   controller: lastNameController,
//                   label: 'Last Name',
//                   hint: 'Enter your last name',
//                   prefixIcon: Icons.person_outline,
//                   validator: (value) {
//                     if (value?.isEmpty ?? true) {
//                       return 'Last name is required';
//                     }
//                     return null;
//                   },
//                   theme: theme,
//                   isDarkMode: isDarkMode,
//                   isTablet: isTablet,
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 20.h),
//           _buildTextField(
//             controller: emailController,
//             label: 'Email Address',
//             hint: 'Enter your email address',
//             prefixIcon: Icons.email_outlined,
//             keyboardType: TextInputType.emailAddress,
//             validator: (value) {
//               if (value?.isEmpty ?? true) {
//                 return 'Email is required';
//               }
//               if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
//                   .hasMatch(value!)) {
//                 return 'Enter a valid email';
//               }
//               return null;
//             },
//             theme: theme,
//             isDarkMode: isDarkMode,
//             isTablet: isTablet,
//           ),
//           SizedBox(height: 20.h),
//           _buildGenderSelection(theme, isDarkMode, isTablet),
//           SizedBox(height: 20.h),
//           _buildBirthDateField(theme, isDarkMode, isTablet),
//           SizedBox(height: 20.h),
//           _buildTextField(
//             controller: emergencyContactController,
//             label: 'Emergency Contact',
//             hint: 'Enter emergency contact number',
//             prefixIcon: Icons.phone_outlined,
//             keyboardType: TextInputType.phone,
//             validator: (value) {
//               if (value?.isEmpty ?? true) {
//                 return 'Emergency contact is required';
//               }
//               return null;
//             },
//             theme: theme,
//             isDarkMode: isDarkMode,
//             isTablet: isTablet,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTextField({
//     required TextEditingController controller,
//     required String label,
//     required String hint,
//     required IconData prefixIcon,
//     required ThemeData theme,
//     required bool isDarkMode,
//     required bool isTablet,
//     TextInputType? keyboardType,
//     String? Function(String?)? validator,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: isTablet ? 16.sp : 14.sp,
//             fontWeight: FontWeight.w600,
//             color: isDarkMode ? Colors.white : Colors.black87,
//           ),
//         ),
//         SizedBox(height: 8.h),
//         TextFormField(
//           controller: controller,
//           keyboardType: keyboardType,
//           validator: validator,
//           style: TextStyle(
//             fontSize: isTablet ? 18.sp : 16.sp,
//             color: isDarkMode ? Colors.white : Colors.black87,
//           ),
//           decoration: InputDecoration(
//             hintText: hint,
//             hintStyle: TextStyle(
//               color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
//             ),
//             prefixIcon: Icon(
//               prefixIcon,
//               color: theme.colorScheme.primary,
//               size: isTablet ? 24.w : 20.w,
//             ),
//             filled: true,
//             fillColor: isDarkMode ? Colors.grey[800] : Colors.white,
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12.r),
//               borderSide: BorderSide.none,
//             ),
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12.r),
//               borderSide: BorderSide(
//                 color: isDarkMode ? Colors.grey[600]! : Colors.grey[300]!,
//               ),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12.r),
//               borderSide: BorderSide(
//                 color: theme.colorScheme.primary,
//                 width: 2,
//               ),
//             ),
//             errorBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12.r),
//               borderSide: BorderSide(
//                 color: theme.colorScheme.error,
//               ),
//             ),
//             contentPadding: EdgeInsets.symmetric(
//               horizontal: 16.w,
//               vertical: isTablet ? 20.h : 16.h,
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildGenderSelection(
//       ThemeData theme, bool isDarkMode, bool isTablet) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Gender',
//           style: TextStyle(
//             fontSize: isTablet ? 16.sp : 14.sp,
//             fontWeight: FontWeight.w600,
//             color: isDarkMode ? Colors.white : Colors.black87,
//           ),
//         ),
//         SizedBox(height: 8.h),
//         Row(
//           children: [
//             Expanded(
//               child: _buildGenderOption(
//                   'male', 'Male', Icons.male, theme, isDarkMode, isTablet),
//             ),
//             SizedBox(width: 12.w),
//             Expanded(
//               child: _buildGenderOption('female', 'Female', Icons.female, theme,
//                   isDarkMode, isTablet),
//             ),
//             SizedBox(width: 12.w),
//             Expanded(
//               child: _buildGenderOption(
//                   'other', 'Other', Icons.person, theme, isDarkMode, isTablet),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildGenderOption(
//     String value,
//     String label,
//     IconData icon,
//     ThemeData theme,
//     bool isDarkMode,
//     bool isTablet,
//   ) {
//     final isSelected = selectedGender == value;

//     return GestureDetector(
//       onTap: () {
//         setState(() {
//           selectedGender = value;
//         });
//         HapticFeedback.selectionClick();
//       },
//       child: Container(
//         padding: EdgeInsets.symmetric(
//           vertical: isTablet ? 16.h : 12.h,
//         ),
//         decoration: BoxDecoration(
//           color: isSelected
//               ? theme.colorScheme.primary.withOpacity(0.1)
//               : (isDarkMode ? Colors.grey[800] : Colors.white),
//           borderRadius: BorderRadius.circular(12.r),
//           border: Border.all(
//             color: isSelected
//                 ? theme.colorScheme.primary
//                 : (isDarkMode ? Colors.grey[600]! : Colors.grey[300]!),
//             width: isSelected ? 2 : 1,
//           ),
//         ),
//         child: Column(
//           children: [
//             Icon(
//               icon,
//               size: isTablet ? 24.w : 20.w,
//               color: isSelected
//                   ? theme.colorScheme.primary
//                   : (isDarkMode ? Colors.grey[400] : Colors.grey[600]),
//             ),
//             SizedBox(height: 4.h),
//             Text(
//               label,
//               style: TextStyle(
//                 fontSize: isTablet ? 14.sp : 12.sp,
//                 fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
//                 color: isSelected
//                     ? theme.colorScheme.primary
//                     : (isDarkMode ? Colors.grey[400] : Colors.grey[600]),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildBirthDateField(ThemeData theme, bool isDarkMode, bool isTablet) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Birth Date',
//           style: TextStyle(
//             fontSize: isTablet ? 16.sp : 14.sp,
//             fontWeight: FontWeight.w600,
//             color: isDarkMode ? Colors.white : Colors.black87,
//           ),
//         ),
//         SizedBox(height: 8.h),
//         GestureDetector(
//           onTap: _selectBirthDate,
//           child: Container(
//             width: double.infinity,
//             padding: EdgeInsets.symmetric(
//               horizontal: 16.w,
//               vertical: isTablet ? 20.h : 16.h,
//             ),
//             decoration: BoxDecoration(
//               color: isDarkMode ? Colors.grey[800] : Colors.white,
//               borderRadius: BorderRadius.circular(12.r),
//               border: Border.all(
//                 color: isDarkMode ? Colors.grey[600]! : Colors.grey[300]!,
//               ),
//             ),
//             child: Row(
//               children: [
//                 Icon(
//                   Icons.calendar_today_outlined,
//                   color: theme.colorScheme.primary,
//                   size: isTablet ? 24.w : 20.w,
//                 ),
//                 SizedBox(width: 12.w),
//                 Expanded(
//                   child: Text(
//                     selectedBirthDate != null
//                         ? DateFormat('dd/MM/yyyy').format(selectedBirthDate!)
//                         : 'Select your birth date',
//                     style: TextStyle(
//                       fontSize: isTablet ? 18.sp : 16.sp,
//                       color: selectedBirthDate != null
//                           ? (isDarkMode ? Colors.white : Colors.black87)
//                           : (isDarkMode ? Colors.grey[400] : Colors.grey[600]),
//                     ),
//                   ),
//                 ),
//                 Icon(
//                   Icons.arrow_forward_ios,
//                   color: theme.colorScheme.primary,
//                   size: 16.w,
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildCompleteButton(ThemeData theme, bool isTablet) {
//     return SizedBox(
//       width: double.infinity,
//       height: isTablet ? 56.h : 52.h,
//       child: ElevatedButton(
//         onPressed: isLoading ? null : _completeProfile,
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
//                 'Complete Profile',
//                 style: TextStyle(
//                   fontSize: isTablet ? 20.sp : 18.sp,
//                   fontWeight: FontWeight.w600,
//                   letterSpacing: 0.5,
//                 ),
//               ),
//       ),
//     );
//   }
// }
