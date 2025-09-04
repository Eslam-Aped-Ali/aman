import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../core/shared/theme/colors/app_colors.dart';
import '../../../../../../core/shared/utils/responsive/responsive_utils.dart';
import '../../bloc/driver_profile_bloc.dart';
import '../../bloc/driver_profile_state.dart';

class CompleteProfileSubmitButton extends StatelessWidget {
  final VoidCallback onSubmit;
  final Animation<Offset> slideAnimation;

  const CompleteProfileSubmitButton({
    super.key,
    required this.onSubmit,
    required this.slideAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    return BlocBuilder<DriverProfileBloc, DriverProfileState>(
      builder: (context, state) {
        final isLoading = state is DriverProfileLoading;

        return SlideTransition(
          position: slideAnimation,
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isLoading ? null : onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: responsive.padding(18, 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(responsive.spacing(16)),
                ),
                elevation: 0,
              ),
              child: isLoading
                  ? SizedBox(
                      height: responsive.fontSize(20),
                      width: responsive.fontSize(20),
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'Complete Profile',
                      style: TextStyle(
                        fontSize: responsive.fontSize(16),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }
}
