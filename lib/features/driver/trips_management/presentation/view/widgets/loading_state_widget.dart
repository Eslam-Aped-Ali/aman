import 'package:flutter/material.dart';
import '../../../../../../core/shared/theme/colors/app_colors.dart';
import '../../../../../../core/shared/utils/responsive/responsive_utils.dart';

class LoadingStateWidget extends StatelessWidget {
  final String message;

  const LoadingStateWidget({
    super.key,
    this.message = 'Loading...',
  });

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: responsive.fontSize(50),
            height: responsive.fontSize(50),
            child: CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 3,
            ),
          ),
          SizedBox(height: responsive.spacing(16)),
          Text(
            message,
            style: TextStyle(
              fontSize: responsive.fontSize(16),
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
