import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../../../generated/locale_keys.g.dart';
import '../../../../../../core/shared/utils/responsive/responsive_utils.dart';

class EmptyStateWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRefresh;
  final IconData icon;

  const EmptyStateWidget({
    super.key,
    required this.message,
    required this.onRefresh,
    this.icon = Icons.assignment_outlined,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: responsive.fontSize(80),
            color: Colors.grey[400],
          ),
          SizedBox(height: responsive.spacing(16)),
          Text(
            message,
            style: TextStyle(
              fontSize: responsive.fontSize(16),
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: responsive.spacing(16)),
          TextButton(
            onPressed: onRefresh,
            child: Text(LocaleKeys.common_refresh.tr()),
          ),
        ],
      ),
    );
  }
}
