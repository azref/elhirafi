// lib/screens/main/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart'; // <--- إضافة مهمة
import 'package:permission_handler/permission_handler.dart'; // <--- إضافة مهمة

import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';
import '../content/privacy_policy_screen.dart';
// import '../content/terms_of_service_screen.dart'; // تأكد من وجود الملف أو أبقه معطلاً
import '../content/about_us_screen.dart';
import '../content/contact_us_screen.dart';
import '../auth/register_screen.dart'; // للتعديل على الملف الشخصي

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;
  String _selectedLanguage = 'العربية';
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _getAppVersion();
  }

  Future<void> _getAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = packageInfo.version;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.settings),
        backgroundColor: AppColors.primaryColor,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: ListView(
          children: [
            // User Mode Section
            if (user != null) ...[
              _buildSectionHeader(AppStrings.currentMode),
              _buildModeCard(user, authProvider),
              const Divider(height: 32),
            ],

            // App Settings
            _buildSectionHeader(AppStrings.settings),
            _buildLanguageDropdown(), // <-- تم التعديل هنا
            _buildSwitchTile(
              icon: Icons.dark_mode,
              title: AppStrings.darkMode,
              value: _isDarkMode,
              onChanged: (value) {
                // --- هذا هو التعديل: تعطيل الوظيفة مؤقتًا ---
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('الوضع الليلي غير متاح حاليًا')),
                );
                // setState(() => _isDarkMode = value); // أبقِ هذا معطلاً
                // --- نهاية التعديل ---
              },
            ),
            // --- هذا هو التعديل: تعطيل زر التنبيهات ---
            _buildSettingsTile(
              icon: Icons.notifications,
              title: AppStrings.notifications,
              onTap: () async {
                // فتح إعدادات التنبيهات الخاصة بالتطبيق في نظام التشغيل
                await openAppSettings();
              },
            ),
            // --- نهاية التعديل ---
            const Divider(height: 32),

            // Legal & Info
            _buildSectionHeader('القانونية والمعلومات'),
            _buildSettingsTile(
              icon: Icons.privacy_tip,
              title: AppStrings.privacyPolicy,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PrivacyPolicyScreen(),
                  ),
                );
              },
            ),
            // _buildSettingsTile(
            //   icon: Icons.description,
            //   title: AppStrings.termsOfService,
            //   onTap: () {
            //     Navigator.pushNamed(context, '/terms_of_service');
            //   },
            // ),
            _buildSettingsTile(
              icon: Icons.info,
              title: AppStrings.aboutUs,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AboutUsScreen(),
                  ),
                );
              },
            ),
            _buildSettingsTile(
              icon: Icons.contact_support,
              title: AppStrings.contactUs,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ContactUsScreen(),
                  ),
                );
              },
            ),
            const Divider(height: 32),

            // Share & Rate
            _buildSectionHeader('مشاركة وتقييم التطبيق'),
            _buildSettingsTile(
              icon: Icons.share,
              title: AppStrings.shareApp,
              onTap: () => _shareApp(),
            ),
            _buildSettingsTile(
              icon: Icons.star,
              title: AppStrings.rateApp,
              onTap: () => _rateApp(),
            ),
            const Divider(height: 32),

            // Account
            if (user != null) ...[
              _buildSectionHeader(AppStrings.accountType),
              _buildSettingsTile(
                icon: Icons.edit,
                title: AppStrings.editProfile,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RegisterScreen(
                        isEditing: true,
                        userToEdit: user,
                      ),
                    ),
                  );
                },
              ),
              _buildSettingsTile(
                icon: Icons.logout,
                title: AppStrings.logout,
                textColor: AppColors.errorColor,
                onTap: () => _showLogoutDialog(authProvider),
              ),
              _buildSettingsTile(
                icon: Icons.delete_forever,
                title: AppStrings.deleteAccount,
                textColor: AppColors.errorColor,
                onTap: () => _showDeleteAccountDialog(authProvider),
              ),
            ],

            const SizedBox(height: 32),
            Center(
              child: Text(
                '${AppStrings.version} $_appVersion',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryColor,
        ),
      ),
    );
  }

  Widget _buildModeCard(UserModel user, AuthProvider authProvider) {
    String currentModeText = '';
    IconData currentModeIcon = Icons.person;

    switch (user.userType) {
      case 'client':
        currentModeText = AppStrings.clientMode;
        currentModeIcon = Icons.person;
        break;
      case 'craftsman':
        currentModeText = AppStrings.craftsmanMode;
        currentModeIcon = Icons.construction;
        break;
      case 'supplier':
        currentModeText = AppStrings.supplierMode;
        currentModeIcon = Icons.store;
        break;
    }

    // --- هذا هو التعديل: استخدام قائمة منسدلة للتحويل ---
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(currentModeIcon, color: AppColors.primaryColor, size: 32),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentModeText,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        user.name,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (user.userType != 'supplier') ...[
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: user.userType,
                decoration: const InputDecoration(
                  labelText: 'التحويل إلى',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'client',
                    child: Text(AppStrings.clientMode),
                  ),
                  DropdownMenuItem(
                    value: 'craftsman',
                    child: Text(AppStrings.craftsmanMode),
                  ),
                ],
                onChanged: (newValue) {
                  if (newValue != null && newValue != user.userType) {
                    _switchMode(newValue, authProvider);
                  }
                },
              ),
            ],
          ],
        ),
      ),
    );
    // --- نهاية التعديل ---
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Color? textColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? AppColors.primaryColor),
      title: Text(
        title,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryColor),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primaryColor,
      ),
    );
  }

  // --- هذا هو التعديل: إزالة اللغات الأخرى ---
  Widget _buildLanguageDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: _selectedLanguage,
        decoration: const InputDecoration(
          labelText: AppStrings.language,
          icon: Icon(Icons.language, color: AppColors.primaryColor),
          border: UnderlineInputBorder(),
        ),
        items: const [
          DropdownMenuItem(
            value: 'العربية',
            child: Text('العربية'),
          ),
        ],
        onChanged: (value) {
          if (value != null) {
            setState(() {
              _selectedLanguage = value;
            });
            // يمكنك إضافة منطق تغيير اللغة هنا لاحقًا
          }
        },
      ),
    );
  }
  // --- نهاية التعديل ---

  void _switchMode(String newMode, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.confirm),
        content: Text('هل تريد التحول إلى ${_getModeText(newMode)}؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await authProvider.updateUserType(newMode);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم تغيير الوضع بنجاح')),
              );
            },
            child: const Text(AppStrings.confirm),
          ),
        ],
      ),
    );
  }

  String _getModeText(String type) {
    switch (type) {
      case 'client':
        return AppStrings.clientMode;
      case 'craftsman':
        return AppStrings.craftsmanMode;
      case 'supplier':
        return AppStrings.supplierMode;
      default:
        return '';
    }
  }

  void _shareApp() {
    Share.share(
      'تطبيق الصانع الحرفي - منصة ربط الحرفيين بأصحاب المشاريع\nhttps://play.google.com/store/apps/details?id=com.elsane3.app',
    );
  }

  void _rateApp() async {
    final url = Uri.parse(
        'https://play.google.com/store/apps/details?id=com.elsane3.app');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _showLogoutDialog(AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.logout),
        content: const Text('هل أنت متأكد من تسجيل الخروج؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              await authProvider.signOut();
              if (mounted) {
                Navigator.of(context)
                    .popUntil((route) => route.isFirst);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.errorColor),
            child: const Text(AppStrings.logout),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.deleteAccount),
        content: const Text(AppStrings.confirmDeleteAccount),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              // TODO: Implement account deletion
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('وظيفة حذف الحساب قيد التطوير')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.errorColor),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );
  }
}
