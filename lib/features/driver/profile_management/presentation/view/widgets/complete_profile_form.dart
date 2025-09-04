import 'package:flutter/material.dart';
import '../../../../../../core/shared/theme/colors/app_colors.dart';
import '../../../../../../core/shared/utils/responsive/responsive_utils.dart';
import '../../../domain/entities/driver_profile.dart';

class CompleteProfileForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final Gender selectedGender;
  final int selectedBirthYear;
  final Function(Gender) onGenderChanged;
  final Function(int) onBirthYearChanged;
  final Animation<Offset> slideAnimation;

  const CompleteProfileForm({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.selectedGender,
    required this.selectedBirthYear,
    required this.onGenderChanged,
    required this.onBirthYearChanged,
    required this.slideAnimation,
  });

  @override
  State<CompleteProfileForm> createState() => _CompleteProfileFormState();
}

class _CompleteProfileFormState extends State<CompleteProfileForm> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final responsive = context.responsive;

    return SlideTransition(
      position: widget.slideAnimation,
      child: Container(
        padding: responsive.padding(24, 24),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[900] : Colors.white,
          borderRadius: BorderRadius.circular(responsive.spacing(20)),
          boxShadow: [
            BoxShadow(
              color: isDarkMode
                  ? Colors.black.withOpacity(0.3)
                  : Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Form(
          key: widget.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name Field
              _buildFieldLabel('Full Name', responsive, isDarkMode),
              SizedBox(height: responsive.spacing(8)),
              _buildNameField(isDarkMode, responsive),

              SizedBox(height: responsive.spacing(24)),

              // Gender Selection
              _buildFieldLabel('Gender', responsive, isDarkMode),
              SizedBox(height: responsive.spacing(8)),
              _buildGenderSelection(isDarkMode, responsive),

              SizedBox(height: responsive.spacing(24)),

              // Birth Year Selection
              _buildFieldLabel('Birth Year', responsive, isDarkMode),
              SizedBox(height: responsive.spacing(8)),
              _buildBirthYearSelection(isDarkMode, responsive),

              SizedBox(height: responsive.spacing(16)),

              // Age Display
              _buildAgeDisplay(responsive),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(
      String label, ResponsiveUtils responsive, bool isDarkMode) {
    return Text(
      label,
      style: TextStyle(
        fontSize: responsive.fontSize(16),
        fontWeight: FontWeight.w600,
        color: isDarkMode ? Colors.white : Colors.black,
      ),
    );
  }

  Widget _buildNameField(bool isDarkMode, ResponsiveUtils responsive) {
    return TextFormField(
      controller: widget.nameController,
      decoration: InputDecoration(
        hintText: 'Enter your full name',
        prefixIcon: Icon(
          Icons.person,
          color: AppColors.primary,
        ),
        filled: true,
        fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(responsive.spacing(12)),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(responsive.spacing(12)),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      style: TextStyle(
        fontSize: responsive.fontSize(16),
        color: isDarkMode ? Colors.white : Colors.black,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter your full name';
        }
        if (value.trim().length < 2) {
          return 'Name must be at least 2 characters';
        }
        return null;
      },
    );
  }

  Widget _buildGenderSelection(bool isDarkMode, ResponsiveUtils responsive) {
    return Row(
      children: [
        Expanded(
          child: _buildGenderOption(
            Gender.male,
            'Male',
            Icons.male,
            isDarkMode,
            responsive,
          ),
        ),
        SizedBox(width: responsive.spacing(12)),
        Expanded(
          child: _buildGenderOption(
            Gender.female,
            'Female',
            Icons.female,
            isDarkMode,
            responsive,
          ),
        ),
      ],
    );
  }

  Widget _buildGenderOption(
    Gender gender,
    String label,
    IconData icon,
    bool isDarkMode,
    ResponsiveUtils responsive,
  ) {
    final isSelected = widget.selectedGender == gender;

    return GestureDetector(
      onTap: () => widget.onGenderChanged(gender),
      child: Container(
        padding: responsive.padding(16, 16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : (isDarkMode ? Colors.grey[800] : Colors.grey[50]),
          borderRadius: BorderRadius.circular(responsive.spacing(12)),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AppColors.primary
                  : (isDarkMode ? Colors.grey[400] : Colors.grey[600]),
              size: responsive.fontSize(20),
            ),
            SizedBox(width: responsive.spacing(8)),
            Text(
              label,
              style: TextStyle(
                fontSize: responsive.fontSize(14),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? AppColors.primary
                    : (isDarkMode ? Colors.white : Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBirthYearSelection(bool isDarkMode, ResponsiveUtils responsive) {
    return Container(
      padding: responsive.padding(16, 16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.grey[50],
        borderRadius: BorderRadius.circular(responsive.spacing(12)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.calendar_today,
            color: AppColors.primary,
          ),
          SizedBox(width: responsive.spacing(12)),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: widget.selectedBirthYear,
                isExpanded: true,
                items: List.generate(50, (index) {
                  final year = DateTime.now().year - 18 - index;
                  return DropdownMenuItem<int>(
                    value: year,
                    child: Text(
                      year.toString(),
                      style: TextStyle(
                        fontSize: responsive.fontSize(16),
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                  );
                }),
                onChanged: (value) => widget.onBirthYearChanged(value!),
                dropdownColor: isDarkMode ? Colors.grey[800] : Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgeDisplay(ResponsiveUtils responsive) {
    return Container(
      padding: responsive.padding(12, 12),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(responsive.spacing(8)),
      ),
      child: Text(
        'Age: ${DateTime.now().year - widget.selectedBirthYear} years old',
        style: TextStyle(
          fontSize: responsive.fontSize(14),
          color: AppColors.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
