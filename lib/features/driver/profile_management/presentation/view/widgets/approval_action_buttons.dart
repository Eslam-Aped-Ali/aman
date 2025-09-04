import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../core/shared/theme/colors/app_colors.dart';
import '../../../../../../core/shared/utils/responsive/responsive_utils.dart';
import '../../bloc/driver_profile_bloc.dart';
import '../../bloc/driver_profile_state.dart';

class ApprovalActionButtons extends StatelessWidget {
  final VoidCallback onContactAdmin;
  final VoidCallback onRefreshStatus;
  final VoidCallback onSkipToDriverApp;

  const ApprovalActionButtons({
    super.key,
    required this.onContactAdmin,
    required this.onRefreshStatus,
    required this.onSkipToDriverApp,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    return Column(
      children: [
        _buildContactAdminButton(responsive),
        SizedBox(height: responsive.spacing(20)),
        _buildRefreshButton(responsive),
        SizedBox(height: responsive.spacing(20)),
        _buildSkipButton(responsive),
      ],
    );
  }

  Widget _buildContactAdminButton(ResponsiveUtils responsive) {
    return BlocBuilder<DriverProfileBloc, DriverProfileState>(
      builder: (context, state) {
        final isLoading = state is ContactingAdmin;

        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: isLoading ? null : onContactAdmin,
            icon: isLoading
                ? SizedBox(
                    width: responsive.fontSize(16),
                    height: responsive.fontSize(16),
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.phone),
            label: Text(
              isLoading ? 'Contacting...' : 'Contact Admin',
              style: TextStyle(
                fontSize: responsive.fontSize(16),
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: responsive.padding(16, 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(responsive.spacing(12)),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRefreshButton(ResponsiveUtils responsive) {
    return BlocBuilder<DriverProfileBloc, DriverProfileState>(
      builder: (context, state) {
        final isLoading = state is DriverProfileLoading;

        return TextButton.icon(
          onPressed: isLoading ? null : onRefreshStatus,
          icon: isLoading
              ? SizedBox(
                  width: responsive.fontSize(16),
                  height: responsive.fontSize(16),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                )
              : const Icon(Icons.refresh),
          label: Text(
            isLoading ? 'Checking...' : 'Check Status',
            style: TextStyle(
              fontSize: responsive.fontSize(14),
              fontWeight: FontWeight.w500,
            ),
          ),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
          ),
        );
      },
    );
  }

  Widget _buildSkipButton(ResponsiveUtils responsive) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onSkipToDriverApp,
        icon: Icon(
          Icons.skip_next,
          size: responsive.fontSize(20),
        ),
        label: Text(
          'Skip to Driver App (Dev Mode)',
          style: TextStyle(
            fontSize: responsive.fontSize(16),
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(
            vertical: responsive.spacing(16),
            horizontal: responsive.spacing(24),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(responsive.spacing(12)),
          ),
        ),
      ),
    );
  }
}
