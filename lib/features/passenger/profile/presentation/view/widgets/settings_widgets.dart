import 'package:flutter/material.dart';
import '../../../../../../core/shared/utils/responsive/responsive_utils.dart';

class SettingsCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? cardColor;
  final bool isDestructive;
  final EdgeInsetsGeometry? margin;

  const SettingsCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    this.trailing,
    this.onTap,
    this.iconColor,
    this.cardColor,
    this.isDestructive = false,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final responsive = context.responsive;

    final effectiveIconColor =
        isDestructive ? Colors.red : iconColor ?? theme.colorScheme.primary;

    return Container(
      margin: margin ?? EdgeInsets.only(bottom: responsive.spacing(12)),
      decoration: BoxDecoration(
        color: cardColor ?? (isDarkMode ? Colors.grey[800] : Colors.white),
        borderRadius: BorderRadius.circular(responsive.spacing(16)),
        border: Border.all(
          color: isDarkMode ? Colors.grey[700]! : Colors.grey[200]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDarkMode ? Colors.black12 : Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(responsive.spacing(16)),
          child: Padding(
            padding: EdgeInsets.all(responsive.spacing(16)),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(responsive.spacing(12)),
                  decoration: BoxDecoration(
                    color: effectiveIconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(responsive.spacing(12)),
                  ),
                  child: Icon(
                    icon,
                    color: effectiveIconColor,
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
                      if (subtitle != null) ...[
                        SizedBox(height: responsive.spacing(4)),
                        Text(
                          subtitle!,
                          style: TextStyle(
                            fontSize: responsive.fontSize(14),
                            color: isDarkMode
                                ? Colors.grey[400]
                                : Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) ...[
                  SizedBox(width: responsive.spacing(12)),
                  trailing!,
                ] else if (onTap != null) ...[
                  SizedBox(width: responsive.spacing(12)),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: responsive.fontSize(16),
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SettingsSwitchCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color? iconColor;
  final EdgeInsetsGeometry? margin;

  const SettingsSwitchCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.value,
    this.onChanged,
    this.iconColor,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SettingsCard(
      title: title,
      subtitle: subtitle,
      icon: icon,
      iconColor: iconColor,
      margin: margin,
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeColor: theme.colorScheme.primary,
        activeTrackColor: theme.colorScheme.primary.withOpacity(0.3),
        inactiveThumbColor: Colors.grey[400],
        inactiveTrackColor: Colors.grey[200],
      ),
    );
  }
}

class SettingsSectionHeader extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Widget? trailing;

  const SettingsSectionHeader({
    super.key,
    required this.title,
    this.icon,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: 4,
        right: 4,
        top: 24,
        bottom: 12,
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: theme.colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
          ],
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.primary,
              letterSpacing: 0.5,
            ),
          ),
          if (trailing != null) ...[
            const Spacer(),
            trailing!,
          ],
        ],
      ),
    );
  }
}

class SettingsSliderCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final ValueChanged<double>? onChanged;
  final String Function(double)? labelBuilder;
  final Color? iconColor;

  const SettingsSliderCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.value,
    required this.min,
    required this.max,
    this.divisions,
    this.onChanged,
    this.labelBuilder,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final responsive = context.responsive;

    return Container(
      margin: EdgeInsets.only(bottom: responsive.spacing(12)),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(responsive.spacing(16)),
        border: Border.all(
          color: isDarkMode ? Colors.grey[700]! : Colors.grey[200]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDarkMode ? Colors.black12 : Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(responsive.spacing(16)),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(responsive.spacing(12)),
                  decoration: BoxDecoration(
                    color: (iconColor ?? theme.colorScheme.primary)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(responsive.spacing(12)),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor ?? theme.colorScheme.primary,
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
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                      if (subtitle != null) ...[
                        SizedBox(height: responsive.spacing(4)),
                        Text(
                          subtitle!,
                          style: TextStyle(
                            fontSize: responsive.fontSize(14),
                            color: isDarkMode
                                ? Colors.grey[400]
                                : Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (labelBuilder != null) ...[
                  SizedBox(width: responsive.spacing(8)),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: responsive.spacing(12),
                      vertical: responsive.spacing(6),
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius:
                          BorderRadius.circular(responsive.spacing(8)),
                    ),
                    child: Text(
                      labelBuilder!(value),
                      style: TextStyle(
                        fontSize: responsive.fontSize(14),
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            if (onChanged != null) ...[
              SizedBox(height: responsive.spacing(8)),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: theme.colorScheme.primary,
                  inactiveTrackColor:
                      theme.colorScheme.primary.withOpacity(0.3),
                  thumbColor: theme.colorScheme.primary,
                  overlayColor: theme.colorScheme.primary.withOpacity(0.2),
                  trackHeight: 4.0,
                ),
                child: Slider(
                  value: value,
                  min: min,
                  max: max,
                  divisions: divisions,
                  onChanged: onChanged,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class SettingsRadioCard<T> extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final T value;
  final T groupValue;
  final ValueChanged<T?>? onChanged;
  final Color? iconColor;

  const SettingsRadioCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.value,
    required this.groupValue,
    this.onChanged,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SettingsCard(
      title: title,
      subtitle: subtitle,
      icon: icon,
      iconColor: iconColor,
      onTap: onChanged != null ? () => onChanged!(value) : null,
      trailing: Radio<T>(
        value: value,
        groupValue: groupValue,
        onChanged: onChanged,
        activeColor: theme.colorScheme.primary,
      ),
    );
  }
}
