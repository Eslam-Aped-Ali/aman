import 'package:flutter/material.dart';
import '../../../../../../core/shared/utils/responsive/responsive_utils.dart';

class WaitingMessage extends StatelessWidget {
  const WaitingMessage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final responsive = context.responsive;

    return Column(
      children: [
        Text(
          'Waiting for Approval',
          style: TextStyle(
            fontSize: responsive.fontSize(28),
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: responsive.spacing(12)),
        Text(
          'Your driver profile has been submitted for approval. Our admin team will review your application and get back to you soon.',
          style: TextStyle(
            fontSize: responsive.fontSize(16),
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
