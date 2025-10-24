// lib/screens/main/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';
import '../content/privacy_policy_screen.dart';
import '../content/terms_of_service_screen.dart';
import '../content/about_us_screen.dart';
import '../content/contact_us_screen.dart';
import 'profile_screen.dart'; // للانتقال إلى شاشة تعديل الملف الشخصي

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;
  String _selectedLanguage = 'العربية';

  // دالة لتغيير الوضع الليلي
  void _toggleDarkMode(bool value) {
    setState(() {
      _isDarkMode = value;
    });
    // TODO: هنا يجب أن تضيف الكود الذي يغير السمة فعليًا في التطبيق
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_isDarkMode ? 'تم تفعيل الوضع الليلي' : 'تم إيقاف الوضع الليلي')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    // تغيير اتجاه الشاشة بالكامل
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(AppStrings.settings),
          backgroundColor: AppColors.primaryColor,
        ),
        body: ListView(
          children: [
            // إخفاء قسم التحويل للموردين
            if (user != null && user.userType != 'supplier') ...[
              _buildSectionHeader(AppStrings.currentMode),
              // استخدام القائمة المنسدلة لتبديل الوضع
              _buildModeDropdown(user, authProvider),
              const Divider(height: 32),
            ],

            _buildSectionHeader(AppStrings.settings),
            _buildSettingsTile(
              icon: Icons.language,
              title: AppStrings.changeLanguage,
              subtitle: _selectedLanguage,
              onTap: () => _showLanguageDialog(),
            ),
            // تفعيل مفتاح الوضع الليلي
            _buildSwitchTile(
              icon: Icons.dark_mode,
              title: AppStrings.darkMode,
              value: _isDarkMode,
              onChanged: _toggleDarkMode,
            ),
            _buildSettingsTile(
              icon: Icons.notifications,
              title: AppStrings.notifications,
              onTap: () { /* Navigate to notifications settings */ },
            ),
            const Divider(height: 32),

            _buildSectionHeader('القانونية والمعلومات'),
            _buildSettingsTile(
              icon: Icons.privacy_tip,
              title: AppStrings.privacyPolicy,
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()));
              },
            ),
            _buildSettingsTile(
              icon: Icons.description,
              title: AppStrings.termsOfService,
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const TermsOfServiceScreen()));
              },
            ),
            _buildSettingsTile(
              icon: Icons.info,
              title: AppStrings.aboutUs,
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutUsScreen()));
              },
            ),
            _buildSettingsTile(
              icon: Icons.contact_support,
              title: AppStrings.contactUs,
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ContactUsScreen()));
              },
            ),
            const Divider(height: 32),

            _buildSectionHeader('مشاركة التطبيق'),
            _buildSettingsTile(
              icon: Icons.share,
              title: AppStrings.shareApp,
              onTap: _shareApp,
            ),
            _buildSettingsTile(
              icon: Icons.star,
              title: AppStrings.rateApp,
              onTap: _rateApp,
            ),
            const Divider(height: 32),

            if (user != null) ...[
              _buildSectionHeader(AppStrings.accountType),
              // تفعيل زر تعديل الملف الشخصي
              _buildSettingsTile(
                icon: Icons.edit,
                title: AppStrings.editProfile,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProfileScreen()),
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
                '${AppStrings.version} 1.0.0',
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

  // الدالة الجديدة للقائمة المنسدلة
  Widget _buildModeDropdown(UserModel user, AuthProvider authProvider) {
    // التأكد من أن القيمة الحالية موجودة في القائمة
    String? dropdownValue = (user.userType == AppStrings.client || user.userType == AppStrings.craftsman)
        ? user.userType
        : AppStrings.client;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: DropdownButtonFormField<String>(
          value: dropdownValue,
          decoration: const InputDecoration(
            labelText: 'الوضع الحالي',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          items: const [
            DropdownMenuItem(value: AppStrings.client, child: Text(AppStrings.clientMode)),
            DropdownMenuItem(value: AppStrings.craftsman, child: Text(AppStrings.craftsmanMode)),
          ],
          onChanged: (newValue) {
            if (newValue != null && newValue != user.userType) {
              _switchMode(newValue, authProvider);
            }
          },
        ),
      ),
    );
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
    return SwitchListTile(
      secondary: Icon(icon, color: AppColors.primaryColor),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.primaryColor,
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.changeLanguage),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('العربية'),
              value: 'العربية',
              groupValue: _selectedLanguage,
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedLanguage = value);
                }
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

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
    if (type == AppStrings.client) return AppStrings.clientMode;
    if (type == AppStrings.craftsman) return AppStrings.craftsmanMode;
    return '';
  }

  void _shareApp() {
    Share.share(
      'تطبيق الصانع الحرفي - منصة ربط الحرفيين بأصحاب المشاريع\nhttps://play.google.com/store/apps/details?id=com.elsane3.app',
    );
  }

  void _rateApp() async {
    final url = Uri.parse('https://play.google.com/store/apps/details?id=com.elsane3.app');
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
              Navigator.pop(context);
              await authProvider.signOut();
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
              // TODO: Implement account deletion
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text(AppStrings.accountDeleted)),
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
