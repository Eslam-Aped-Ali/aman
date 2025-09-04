import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../../core/shared/utils/responsive/responsive_utils.dart';
import '../../../../../../core/shared/utils/user_exprience/flash_helper.dart';
import '../widgets/settings_widgets.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  PackageInfo? packageInfo;
  String deviceInfo = '';

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadAppInfo();
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

  Future<void> _loadAppInfo() async {
    try {
      packageInfo = await PackageInfo.fromPlatform();

      final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
      if (Theme.of(context).platform == TargetPlatform.android) {
        final androidInfo = await deviceInfoPlugin.androidInfo;
        deviceInfo = '${androidInfo.brand} ${androidInfo.model}';
      } else if (Theme.of(context).platform == TargetPlatform.iOS) {
        final iosInfo = await deviceInfoPlugin.iosInfo;
        deviceInfo = '${iosInfo.name} ${iosInfo.model}';
      }

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      // Handle error silently
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsSectionHeader(
          title: 'help.quickActions'.tr(),
          icon: Icons.flash_on,
        ),
        SettingsCard(
          title: 'help.faq'.tr(),
          subtitle: 'Find answers to common questions',
          icon: Icons.help_outline,
          onTap: () => _showFAQBottomSheet(),
        ),
        SettingsCard(
          title: 'help.contactUs'.tr(),
          subtitle: 'Get in touch with our support team',
          icon: Icons.support_agent,
          onTap: () => _showContactBottomSheet(),
        ),
        SettingsCard(
          title: 'help.reportIssue'.tr(),
          subtitle: 'Report a bug or technical issue',
          icon: Icons.bug_report,
          onTap: () => _openEmailSupport(subject: 'Bug Report'),
        ),
        SettingsCard(
          title: 'help.feedback'.tr(),
          subtitle: 'Share your thoughts and suggestions',
          icon: Icons.feedback,
          onTap: () => _openEmailSupport(subject: 'App Feedback'),
        ),
      ],
    );
  }

  Widget _buildSupportSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsSectionHeader(
          title: 'help.getInTouch'.tr(),
          icon: Icons.support,
        ),
        SettingsCard(
          title: 'help.userGuide'.tr(),
          subtitle: 'Learn how to use the app effectively',
          icon: Icons.book,
          onTap: () => _showComingSoonMessage(),
        ),
        SettingsCard(
          title: 'help.rateApp'.tr(),
          subtitle: 'Rate and review on app store',
          icon: Icons.star_rate,
          onTap: () => _rateApp(),
        ),
        SettingsCard(
          title: 'help.shareApp'.tr(),
          subtitle: 'Recommend to friends and family',
          icon: Icons.share,
          onTap: () => _shareApp(),
        ),
      ],
    );
  }

  Widget _buildLegalSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsSectionHeader(
          title: 'help.legal'.tr(),
          icon: Icons.gavel,
        ),
        SettingsCard(
          title: 'help.privacyPolicy'.tr(),
          subtitle: 'How we protect and use your data',
          icon: Icons.privacy_tip,
          onTap: () => _openUrl('${'help.websiteUrl'.tr()}/privacy'),
        ),
        SettingsCard(
          title: 'help.termsOfService'.tr(),
          subtitle: 'Terms and conditions of use',
          icon: Icons.description,
          onTap: () => _openUrl('${'help.websiteUrl'.tr()}/terms'),
        ),
        SettingsCard(
          title: 'help.aboutUs'.tr(),
          subtitle: 'Learn more about our company',
          icon: Icons.info,
          onTap: () => _showAboutBottomSheet(),
        ),
      ],
    );
  }

  Widget _buildSocialMediaSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsSectionHeader(
          title: 'help.followUs'.tr(),
          icon: Icons.public,
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[800]
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[700]!
                  : Colors.grey[200]!,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSocialButton(
                icon: Icons.facebook,
                color: const Color(0xFF1877F2),
                onTap: () => _openUrl('help.facebookUrl'.tr()),
              ),
              _buildSocialButton(
                icon: Icons.language,
                color: const Color(0xFF1DA1F2),
                onTap: () => _openUrl('help.twitterUrl'.tr()),
              ),
              _buildSocialButton(
                icon: Icons.camera_alt,
                color: const Color(0xFFE4405F),
                onTap: () => _openUrl('help.instagramUrl'.tr()),
              ),
              _buildSocialButton(
                icon: Icons.business,
                color: const Color(0xFF0A66C2),
                onTap: () => _openUrl('help.linkedinUrl'.tr()),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: color,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildAppInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsSectionHeader(
          title: 'App Information',
          icon: Icons.info_outline,
        ),
        SettingsCard(
          title: 'help.version'.tr(),
          subtitle: packageInfo?.version ?? 'Unknown',
          icon: Icons.update,
          onTap: () =>
              _copyToClipboard('Version: ${packageInfo?.version ?? 'Unknown'}'),
        ),
        SettingsCard(
          title: 'help.buildNumber'.tr(),
          subtitle: packageInfo?.buildNumber ?? 'Unknown',
          icon: Icons.build,
          onTap: () => _copyToClipboard(
              'Build: ${packageInfo?.buildNumber ?? 'Unknown'}'),
        ),
        SettingsCard(
          title: 'help.deviceInfo'.tr(),
          subtitle: deviceInfo.isNotEmpty ? deviceInfo : 'Unknown Device',
          icon: Icons.phone_android,
          onTap: () => _copyToClipboard('Device: $deviceInfo'),
        ),
      ],
    );
  }

  void _showFAQBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FAQBottomSheet(),
    );
  }

  void _showContactBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ContactBottomSheet(),
    );
  }

  void _showAboutBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AboutBottomSheet(),
    );
  }

  Future<void> _openEmailSupport({String? subject}) async {
    final email = 'help.supportEmail'.tr();
    final deviceDetails = '''

--- Device Information ---
App Version: ${packageInfo?.version ?? 'Unknown'}
Build Number: ${packageInfo?.buildNumber ?? 'Unknown'}
Device: $deviceInfo
Platform: ${Theme.of(context).platform.name}
Locale: ${context.locale.toString()}
''';

    try {
      FlashHelper.showToast('help.openingEmail'.tr());
      // Implement email opening logic using url_launcher
      final Uri emailUri = Uri(
        scheme: 'mailto',
        path: email,
        queryParameters: {
          'subject': subject ?? 'Support Request',
          'body': deviceDetails,
        },
      );
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        _copyToClipboard(
            '$email\nSubject: ${subject ?? 'Support Request'}\n$deviceDetails');
        FlashHelper.showToast('help.noEmailApp'.tr(),
            type: MessageTypeTost.warning);
      }
    } catch (e) {
      FlashHelper.showToast('help.errorOpeningUrl'.tr(),
          type: MessageTypeTost.fail);
    }
  }

  Future<void> _openUrl(String url) async {
    try {
      FlashHelper.showToast('help.openingWebsite'.tr());
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _copyToClipboard(url);
        FlashHelper.showToast('help.errorOpeningUrl'.tr(),
            type: MessageTypeTost.fail);
      }
    } catch (e) {
      FlashHelper.showToast('help.errorOpeningUrl'.tr(),
          type: MessageTypeTost.fail);
    }
  }

  Future<void> _rateApp() async {
    // App store URLs for rating the app
    final String storeUrl;
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      storeUrl =
          'https://apps.apple.com/app/id1234567890'; // Replace with actual App Store ID
    } else {
      storeUrl =
          'https://play.google.com/store/apps/details?id=com.aman.transportation';
    }

    await _openUrl(storeUrl);
  }

  Future<void> _shareApp() async {
    try {
      FlashHelper.showToast('help.sharingApp'.tr());

      final String shareText = '''
Check out Aman - Your trusted transportation companion!

${Theme.of(context).platform == TargetPlatform.iOS ? 'Download on App Store: https://apps.apple.com/app/idYOUR_APP_ID' : 'Download on Google Play: https://play.google.com/store/apps/details?id=com.Aman.app'}
''';

      _copyToClipboard(shareText);
    } catch (e) {
      FlashHelper.showToast('Failed to share app', type: MessageTypeTost.fail);
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    FlashHelper.showToast('help.copyingToClipboard'.tr());
    HapticFeedback.selectionClick();
  }

  void _showComingSoonMessage() {
    FlashHelper.showToast(
      'common.comingSoon'.tr(),
      type: MessageTypeTost.warning,
    );
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
          'help.title'.tr(),
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
                          _buildQuickActionsSection(),
                          _buildSupportSection(),
                          _buildLegalSection(),
                          _buildSocialMediaSection(),
                          _buildAppInfoSection(),
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
}

class _FAQBottomSheet extends StatelessWidget {
  final List<Map<String, String>> faqData = [
    {
      'question': 'How do I book a ride?',
      'answer':
          'Open the app, enter your destination, select your preferred vehicle type, and confirm your booking.'
    },
    {
      'question': 'How do I track my ride?',
      'answer':
          'Once your ride is confirmed, you can track the driver\'s location in real-time on the map.'
    },
    {
      'question': 'How do I cancel a ride?',
      'answer':
          'You can cancel your ride from the trip details screen. Cancellation fees may apply.'
    },
    {
      'question': 'How do I change my payment method?',
      'answer':
          'Go to Profile > Payment Methods to add, remove, or change your preferred payment method.'
    },
    {
      'question': 'How do I contact customer support?',
      'answer':
          'You can reach us through the Contact Us section in Help & Support, or email us directly.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final responsive = context.responsive;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[850] : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(responsive.spacing(24)),
              topRight: Radius.circular(responsive.spacing(24)),
            ),
          ),
          child: Column(
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
                child: Row(
                  children: [
                    Icon(
                      Icons.help_outline,
                      color: theme.colorScheme.primary,
                      size: responsive.fontSize(24),
                    ),
                    SizedBox(width: responsive.spacing(12)),
                    Text(
                      'help.faq'.tr(),
                      style: TextStyle(
                        fontSize: responsive.fontSize(20),
                        fontWeight: FontWeight.w700,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding:
                      EdgeInsets.symmetric(horizontal: responsive.spacing(24)),
                  itemCount: faqData.length,
                  itemBuilder: (context, index) {
                    final faq = faqData[index];
                    return _FAQItem(
                      question: faq['question']!,
                      answer: faq['answer']!,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FAQItem extends StatefulWidget {
  final String question;
  final String answer;

  const _FAQItem({
    required this.question,
    required this.answer,
  });

  @override
  State<_FAQItem> createState() => _FAQItemState();
}

class _FAQItemState extends State<_FAQItem>
    with SingleTickerProviderStateMixin {
  bool isExpanded = false;
  late AnimationController _controller;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      isExpanded = !isExpanded;
      if (isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
    HapticFeedback.selectionClick();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final responsive = context.responsive;

    return Container(
      margin: EdgeInsets.only(bottom: responsive.spacing(12)),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.grey[50],
        borderRadius: BorderRadius.circular(responsive.spacing(12)),
        border: Border.all(
          color: isDarkMode ? Colors.grey[700]! : Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: _toggleExpanded,
            borderRadius: BorderRadius.circular(responsive.spacing(12)),
            child: Padding(
              padding: EdgeInsets.all(responsive.spacing(16)),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.question,
                      style: TextStyle(
                        fontSize: responsive.fontSize(16),
                        fontWeight: FontWeight.w600,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                  RotationTransition(
                    turns: _expandAnimation,
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: theme.colorScheme.primary,
                      size: responsive.fontSize(24),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizeTransition(
            sizeFactor: _expandAnimation,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                responsive.spacing(16),
                0,
                responsive.spacing(16),
                responsive.spacing(16),
              ),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(responsive.spacing(16)),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(responsive.spacing(8)),
                ),
                child: Text(
                  widget.answer,
                  style: TextStyle(
                    fontSize: responsive.fontSize(14),
                    color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactBottomSheet extends StatelessWidget {
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
                Row(
                  children: [
                    Icon(
                      Icons.support_agent,
                      color: theme.colorScheme.primary,
                      size: responsive.fontSize(24),
                    ),
                    SizedBox(width: responsive.spacing(12)),
                    Text(
                      'help.contactUs'.tr(),
                      style: TextStyle(
                        fontSize: responsive.fontSize(20),
                        fontWeight: FontWeight.w700,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: responsive.spacing(24)),
                _ContactOption(
                  icon: Icons.email,
                  title: 'Email Support',
                  subtitle: 'help.supportEmail'.tr(),
                  onTap: () => _openEmail(context),
                ),
                SizedBox(height: responsive.spacing(16)),
                _ContactOption(
                  icon: Icons.phone,
                  title: 'Phone Support',
                  subtitle: 'help.supportPhone'.tr(),
                  onTap: () => _openPhone(context),
                ),
                SizedBox(height: responsive.spacing(16)),
                _ContactOption(
                  icon: Icons.schedule,
                  title: 'Support Hours',
                  subtitle: 'help.supportHours'.tr(),
                  onTap: null,
                ),
                SizedBox(height: responsive.spacing(24)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openEmail(BuildContext context) async {
    try {
      FlashHelper.showToast('help.openingEmail'.tr());
      Navigator.of(context).pop();
      // Implement email launching using url_launcher
      final Uri emailUri = Uri(
        scheme: 'mailto',
        path: 'help.supportEmail'.tr(),
      );
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        _copyToClipboard('help.supportEmail'.tr());
        FlashHelper.showToast('help.noEmailApp'.tr(),
            type: MessageTypeTost.warning);
      }
    } catch (e) {
      FlashHelper.showToast('help.errorOpeningUrl'.tr(),
          type: MessageTypeTost.fail);
    }
  }

  void _openPhone(BuildContext context) async {
    try {
      FlashHelper.showToast('Opening phone app...');
      Navigator.of(context).pop();
      // Implement phone launching using url_launcher
      final Uri phoneUri = Uri(
        scheme: 'tel',
        path: 'help.supportPhone'.tr(),
      );
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        _copyToClipboard('help.supportPhone'.tr());
        FlashHelper.showToast('help.errorOpeningUrl'.tr(),
            type: MessageTypeTost.warning);
      }
    } catch (e) {
      FlashHelper.showToast('help.errorOpeningUrl'.tr(),
          type: MessageTypeTost.fail);
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    FlashHelper.showToast('help.copyingToClipboard'.tr());
  }
}

class _ContactOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _ContactOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final responsive = context.responsive;

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.grey[50],
        borderRadius: BorderRadius.circular(responsive.spacing(12)),
        border: Border.all(
          color: isDarkMode ? Colors.grey[700]! : Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(responsive.spacing(12)),
          child: Padding(
            padding: EdgeInsets.all(responsive.spacing(16)),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(responsive.spacing(12)),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(responsive.spacing(8)),
                  ),
                  child: Icon(
                    icon,
                    color: theme.colorScheme.primary,
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
                      SizedBox(height: responsive.spacing(4)),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: responsive.fontSize(14),
                          color:
                              isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (onTap != null)
                  Icon(
                    Icons.arrow_forward_ios,
                    size: responsive.fontSize(16),
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AboutBottomSheet extends StatelessWidget {
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
              children: [
                // App logo and name
                Container(
                  padding: EdgeInsets.all(responsive.spacing(20)),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(responsive.spacing(20)),
                  ),
                  child: Icon(
                    Icons.directions_car,
                    color: theme.colorScheme.primary,
                    size: responsive.fontSize(48),
                  ),
                ),
                SizedBox(height: responsive.spacing(16)),
                Text(
                  'Aman',
                  style: TextStyle(
                    fontSize: responsive.fontSize(24),
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                SizedBox(height: responsive.spacing(8)),
                Text(
                  'help.appDescription'.tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: responsive.fontSize(16),
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    height: 1.5,
                  ),
                ),
                SizedBox(height: responsive.spacing(24)),
                Container(
                  padding: EdgeInsets.all(responsive.spacing(16)),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[800] : Colors.grey[50],
                    borderRadius: BorderRadius.circular(responsive.spacing(12)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'help.companyInfo'.tr(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: responsive.fontSize(14),
                          color:
                              isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: responsive.spacing(12)),
                      GestureDetector(
                        onTap: () => _openWebsite(context),
                        child: Text(
                          'help.websiteUrl'.tr(),
                          style: TextStyle(
                            fontSize: responsive.fontSize(14),
                            color: theme.colorScheme.primary,
                            decoration: TextDecoration.underline,
                            decorationColor: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: responsive.spacing(24)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openWebsite(BuildContext context) async {
    try {
      FlashHelper.showToast('help.openingWebsite'.tr());
      Navigator.of(context).pop();
      // Implement website opening using url_launcher
      final String url = 'help.websiteUrl'.tr();
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        Clipboard.setData(ClipboardData(text: url));
        FlashHelper.showToast('help.copyingToClipboard'.tr());
      }
    } catch (e) {
      FlashHelper.showToast('help.errorOpeningUrl'.tr(),
          type: MessageTypeTost.fail);
    }
  }
}
