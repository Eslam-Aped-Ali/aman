import 'package:flutter/material.dart';
import '../../../../../../core/shared/theme/colors/app_colors.dart';
import '../../../../../../core/shared/utils/responsive/responsive_utils.dart';

class PersonalInfoSection extends StatefulWidget {
  final TextEditingController nameController;
  final String selectedGender;
  final int? selectedBirthYear;
  final bool isEditing;
  final VoidCallback onEditToggle;
  final Function(String) onGenderChanged;
  final VoidCallback onBirthYearTap;

  const PersonalInfoSection({
    super.key,
    required this.nameController,
    required this.selectedGender,
    required this.selectedBirthYear,
    required this.isEditing,
    required this.onEditToggle,
    required this.onGenderChanged,
    required this.onBirthYearTap,
  });

  @override
  State<PersonalInfoSection> createState() => _PersonalInfoSectionState();
}

class _PersonalInfoSectionState extends State<PersonalInfoSection> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final responsive = context.responsive;

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
                onPressed: widget.onEditToggle,
                icon: Icon(
                  widget.isEditing ? Icons.save : Icons.edit,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: responsive.spacing(16)),
          _buildInfoField(
            'Full Name',
            widget.nameController,
            Icons.person,
            widget.isEditing,
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
                      groupValue: widget.selectedGender,
                      onChanged: widget.isEditing
                          ? (value) => widget.onGenderChanged(value!)
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
                      groupValue: widget.selectedGender,
                      onChanged: widget.isEditing
                          ? (value) => widget.onGenderChanged(value!)
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
          onTap: widget.isEditing ? widget.onBirthYearTap : null,
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
                    widget.selectedBirthYear != null
                        ? widget.selectedBirthYear.toString()
                        : 'Select birth year',
                    style: TextStyle(
                      fontSize: responsive.fontSize(16),
                      color: widget.selectedBirthYear != null
                          ? (isDarkMode ? Colors.white : Colors.black87)
                          : (isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                    ),
                  ),
                ),
                if (widget.isEditing)
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
}
