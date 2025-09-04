import 'package:easy_localization/easy_localization.dart';
import '../../../../../../generated/locale_keys.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../app/routing/app_routes_fun.dart';
import '../../../../../../core/shared/theme/cubit/theme_cubit.dart';
import '../../../../../../core/shared/theme/cubit/theme_state.dart';
import '../../../../../../core/shared/utils/responsive/responsive_utils.dart';
import '../../../../../../core/shared/utils/user_exprience/flash_helper.dart';
import '../../viewModel/language/language_cubit.dart';
import '../../viewModel/language/language_state.dart';
import '../../viewModel/settings/settings_cubit.dart';
import '../../viewModel/settings/settings_state.dart';
import '../widgets/settings_widgets.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadInitialData();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  void _loadInitialData() {
    context.read<SettingsCubit>().loadSettings();
    context.read<LanguageCubit>().loadLanguage();
    context.read<ThemeCubit>().loadTheme();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final responsive = context.responsive;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[50],
      appBar: AppBar(
        title: Text(
          LocaleKeys.settings_title.tr(),
          style: TextStyle(
            fontSize: responsive.fontSize(20),
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarBrightness: isDarkMode ? Brightness.dark : Brightness.light,
          statusBarIconBrightness:
              isDarkMode ? Brightness.light : Brightness.dark,
        ),
      ),
      body: AnimatedBuilder(
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
                      maxWidth: responsive.maxContentWidth,
                    ),
                    child: Padding(
                      padding: responsive.padding(24, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildGeneralSection(),
                          _buildNotificationSection(),
                          _buildPrivacySection(),
                          _buildAccountSection(),
                          SizedBox(height: responsive.spacing(32)),
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
    );
  }

  Widget _buildGeneralSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsSectionHeader(
          title: LocaleKeys.settings_general.tr(),
          icon: Icons.settings_outlined,
        ),
        BlocBuilder<ThemeCubit, ThemeState>(
          builder: (context, themeState) {
            return SettingsCard(
              title: LocaleKeys.settings_theme.tr(),
              subtitle: LocaleKeys.settings_themeDescription.tr(),
              icon: themeState.themeMode.icon,
              onTap: () => _showThemeBottomSheet(),
              trailing: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  (themeState.themeMode.name == 'light'
                          ? LocaleKeys.settings_lightTheme
                          : themeState.themeMode.name == 'dark'
                              ? LocaleKeys.settings_darkTheme
                              : themeState.themeMode.name == 'system'
                                  ? LocaleKeys.settings_systemTheme
                                  : LocaleKeys.settings_theme)
                      .tr(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            );
          },
        ),
        BlocBuilder<LanguageCubit, LanguageState>(
          builder: (context, languageState) {
            return SettingsCard(
              title: LocaleKeys.settings_language.tr(),
              subtitle: LocaleKeys.settings_languageDescription.tr(),
              icon: Icons.language,
              onTap: () => _showLanguageBottomSheet(),
              trailing: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  languageState.selectedLanguage.displayName,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildNotificationSection() {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settingsState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SettingsSectionHeader(
              title: LocaleKeys.settings_notifications.tr(),
              icon: Icons.notifications_outlined,
            ),
            SettingsSwitchCard(
              title: LocaleKeys.settings_pushNotifications.tr(),
              subtitle: LocaleKeys.settings_pushNotificationsDescription.tr(),
              icon: Icons.notifications,
              value: settingsState.pushNotifications,
              onChanged: (value) =>
                  context.read<SettingsCubit>().updatePushNotifications(value),
            ),
            SettingsSwitchCard(
              title: LocaleKeys.settings_tripUpdates.tr(),
              subtitle: LocaleKeys.settings_tripUpdatesDescription.tr(),
              icon: Icons.directions_car,
              value: settingsState.tripUpdates,
              onChanged: (value) =>
                  context.read<SettingsCubit>().updateTripUpdates(value),
            ),
            SettingsSwitchCard(
              title: LocaleKeys.settings_promotionalOffers.tr(),
              subtitle: LocaleKeys.settings_promotionalOffersDescription.tr(),
              icon: Icons.local_offer,
              value: settingsState.promotionalOffers,
              onChanged: (value) =>
                  context.read<SettingsCubit>().updatePromotionalOffers(value),
            ),
            SettingsSwitchCard(
              title: LocaleKeys.settings_newFeatures.tr(),
              subtitle: LocaleKeys.settings_newFeaturesDescription.tr(),
              icon: Icons.new_releases,
              value: settingsState.newFeatures,
              onChanged: (value) =>
                  context.read<SettingsCubit>().updateNewFeatures(value),
            ),
            SettingsSwitchCard(
              title: LocaleKeys.settings_securityAlerts.tr(),
              subtitle: LocaleKeys.settings_securityAlertsDescription.tr(),
              icon: Icons.security,
              value: settingsState.securityAlerts,
              onChanged: (value) =>
                  context.read<SettingsCubit>().updateSecurityAlerts(value),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPrivacySection() {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settingsState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SettingsSectionHeader(
              title: LocaleKeys.settings_privacy.tr(),
              icon: Icons.privacy_tip_outlined,
            ),
            SettingsSwitchCard(
              title: LocaleKeys.settings_dataCollection.tr(),
              subtitle: LocaleKeys.settings_dataCollectionDescription.tr(),
              icon: Icons.data_usage,
              value: settingsState.dataCollection,
              onChanged: (value) =>
                  context.read<SettingsCubit>().updateDataCollection(value),
            ),
            SettingsSwitchCard(
              title: LocaleKeys.settings_locationSharing.tr(),
              subtitle: LocaleKeys.settings_locationSharingDescription.tr(),
              icon: Icons.location_on,
              value: settingsState.locationSharing,
              onChanged: (value) =>
                  context.read<SettingsCubit>().updateLocationSharing(value),
            ),
            SettingsSwitchCard(
              title: LocaleKeys.settings_analytics.tr(),
              subtitle: LocaleKeys.settings_analyticsDescription.tr(),
              icon: Icons.analytics,
              value: settingsState.analytics,
              onChanged: (value) =>
                  context.read<SettingsCubit>().updateAnalytics(value),
            ),
            SettingsSwitchCard(
              title: LocaleKeys.settings_crashReports.tr(),
              subtitle: LocaleKeys.settings_crashReportsDescription.tr(),
              icon: Icons.bug_report,
              value: settingsState.crashReports,
              onChanged: (value) =>
                  context.read<SettingsCubit>().updateCrashReports(value),
            ),
            SettingsSwitchCard(
              title: LocaleKeys.settings_biometrics.tr(),
              subtitle: LocaleKeys.settings_biometricsDescription.tr(),
              icon: Icons.fingerprint,
              value: settingsState.biometrics,
              onChanged: (value) =>
                  context.read<SettingsCubit>().updateBiometrics(value),
            ),
            SettingsSwitchCard(
              title: LocaleKeys.settings_autoLogout.tr(),
              subtitle: LocaleKeys.settings_autoLogoutDescription.tr(),
              icon: Icons.logout,
              value: settingsState.autoLogout,
              onChanged: (value) =>
                  context.read<SettingsCubit>().updateAutoLogout(value),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAccountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsSectionHeader(
          title: LocaleKeys.settings_account.tr(),
          icon: Icons.account_circle_outlined,
        ),
        SettingsCard(
          title: LocaleKeys.help_clearCache.tr(),
          subtitle: LocaleKeys.help_clearCacheDescription.tr(),
          icon: Icons.cached,
          onTap: () => _showClearCacheDialog(),
        ),
        SettingsCard(
          title: LocaleKeys.help_backupData.tr(),
          subtitle: LocaleKeys.help_backupDescription.tr(),
          icon: Icons.backup,
          onTap: () => _showComingSoonMessage(),
        ),
        SettingsCard(
          title: LocaleKeys.help_restoreData.tr(),
          subtitle: LocaleKeys.help_restoreDescription.tr(),
          icon: Icons.restore,
          onTap: () => _showComingSoonMessage(),
        ),
        SettingsCard(
          title: LocaleKeys.settings_deleteAccount.tr(),
          subtitle: LocaleKeys.settings_deleteAccountDescription.tr(),
          icon: Icons.delete_forever,
          isDestructive: true,
          onTap: () => _showDeleteAccountDialog(),
        ),
      ],
    );
  }

  void _showThemeBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => BlocProvider.value(
        value: BlocProvider.of<ThemeCubit>(context),
        child: _ThemeSelectionBottomSheet(),
      ),
    );
  }

  void _showLanguageBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => BlocProvider.value(
        value: BlocProvider.of<LanguageCubit>(context),
        child: _LanguageSelectionBottomSheet(),
      ),
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(LocaleKeys.help_clearCache.tr()),
        content: Text(LocaleKeys.help_clearCacheDescription.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(LocaleKeys.common_cancel.tr()),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<SettingsCubit>().clearCache();
              FlashHelper.showToast(
                'help.cacheCleared'.tr(),
                type: MessageTypeTost.success,
              );
            },
            child: Text(LocaleKeys.common_confirm.tr()),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          LocaleKeys.settings_deleteAccount.tr(),
          style: const TextStyle(color: Colors.red),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(LocaleKeys.settings_deleteAccountWarning.tr()),
            const SizedBox(height: 16),
            Text(
              LocaleKeys.settings_deleteAccountConfirm.tr(),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(LocaleKeys.common_cancel.tr()),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              Navigator.of(context).pop();
              _deleteAccount();
            },
            child: Text(LocaleKeys.common_delete.tr()),
          ),
        ],
      ),
    );
  }

  void _deleteAccount() async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Simulate account deletion process
      await Future.delayed(const Duration(seconds: 2));

      // Account deletion logic - placeholder for future implementation
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(LocaleKeys.settings_deleteAccount.tr()),
          content: Text(LocaleKeys.settings_deleteAccountSoon.tr()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(LocaleKeys.common_cancel.tr()),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(LocaleKeys.common_comingSoon.tr())),
                );
              },
              child: Text(LocaleKeys.common_confirm.tr()),
            ),
          ],
        ),
      );
      // This should include:
      // 1. Delete user data from Firestore
      // 2. Delete Firebase Auth user
      // 3. Clear local storage
      // 4. Log analytics event

      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        FlashHelper.showToast(
          LocaleKeys.settings_accountDeleted.tr(),
          type: MessageTypeTost.success,
        );
        // Navigate to login screen
        pushAndRemoveUntil('/selectRole');
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        FlashHelper.showToast(
          LocaleKeys.settings_deleteAccountFailed.tr(),
          type: MessageTypeTost.fail,
        );
      }
    }
  }

  void _showComingSoonMessage() {
    FlashHelper.showToast(
      LocaleKeys.common_comingSoon.tr(),
      type: MessageTypeTost.warning,
    );
  }
}

class _ThemeSelectionBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final responsive = context.responsive;

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(responsive.spacing(24)),
          topRight: Radius.circular(responsive.spacing(24)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: responsive.spacing(12)),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: responsive.padding(24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'settings.theme'.tr(),
                  style: TextStyle(
                    fontSize: responsive.fontSize(20),
                    fontWeight: FontWeight.w700,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                SizedBox(height: responsive.spacing(8)),
                Text(
                  'settings.themeDescription'.tr(),
                  style: TextStyle(
                    fontSize: responsive.fontSize(14),
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                SizedBox(height: responsive.spacing(24)),
                BlocBuilder<ThemeCubit, ThemeState>(
                  builder: (context, state) {
                    return Column(
                      children: AppThemeMode.values.map((mode) {
                        return SettingsRadioCard<AppThemeMode>(
                          title: 'settings.${mode.name}Theme'.tr(),
                          icon: mode.icon,
                          value: mode,
                          groupValue: state.themeMode,
                          onChanged: (value) {
                            if (value != null) {
                              context.read<ThemeCubit>().setTheme(value);
                              Navigator.of(context).pop();
                              HapticFeedback.selectionClick();
                            }
                          },
                        );
                      }).toList(),
                    );
                  },
                ),
                SizedBox(height: responsive.spacing(16)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageSelectionBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final responsive = context.responsive;

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(responsive.spacing(24)),
          topRight: Radius.circular(responsive.spacing(24)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: responsive.spacing(12)),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: responsive.padding(24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'settings.language'.tr(),
                  style: TextStyle(
                    fontSize: responsive.fontSize(20),
                    fontWeight: FontWeight.w700,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                SizedBox(height: responsive.spacing(8)),
                Text(
                  'settings.languageDescription'.tr(),
                  style: TextStyle(
                    fontSize: responsive.fontSize(14),
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                SizedBox(height: responsive.spacing(24)),
                BlocBuilder<LanguageCubit, LanguageState>(
                  builder: (context, state) {
                    return Column(
                      children: AppLanguage.values.map((language) {
                        return SettingsRadioCard<AppLanguage>(
                          title: language.displayName,
                          icon: language.icon,
                          value: language,
                          groupValue: state.selectedLanguage,
                          onChanged: (value) {
                            if (value != null) {
                              context
                                  .read<LanguageCubit>()
                                  .changeLanguage(value, context);
                              Navigator.of(context).pop();
                              HapticFeedback.selectionClick();
                            }
                          },
                        );
                      }).toList(),
                    );
                  },
                ),
                SizedBox(height: responsive.spacing(16)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
