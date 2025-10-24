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
// سنحتاج هذا الملف للانتقال إلى شاشة تعديل الملف الشخصي
import 'profile_screen.dart'; 

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;
  String _selectedLanguage = 'العربية';

  // دالة لتغيير الوضع الليلي (ملاحظة 3)
  void _toggleDarkMode(bool value) {
    setState(() {
      _isDarkMode = value;
    });
    // TODO: هنا يجب أن تضيف الكود الذي يغير السمة فعليًا في التطبيق
    // على سبيل المثال، باستخدام provider لإدارة السمات.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_isDarkMode ? 'تم تفعيل الوضع الليلي' : 'تم إيقاف الوضع الليلي')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    // ملاحظة 4: تغيير اتجاه الشاشة
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(AppStrings.settings),
          backgroundColor: AppColors.primaryColor,
        ),
        body: ListView(
          children: [
            if (user != null && user.userType != 'supplier') ...[
              _buildSectionHeader(AppStrings.currentMode),
              // ملاحظة 1: تحويل الأزرار إلى قائمة منسدلة
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
            // ملاحظة 3: تفعيل الوضع الليلي
            _buildSwitchTile(
              icon: Icons.dark_mode,
              title: AppStrings.darkMode,
              value: _isDarkMode,
              onChanged: _toggleDarkMode, // الربط بالدالة
            ),
            _buildSettingsTile(
              icon: Icons.notifications,
              title: AppStrings.notifications,
              onTap: () { /* Navigate to notifications settings */ },
            ),
            const Divider(height: 32),

            _buildSectionHeader('القانونية والمعلومات'),
            // ... باقي الإعدادات تبقى كما هي
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
            // ...

            if (user != null) ...[
              _buildSectionHeader(AppStrings.accountType),
              // ملاحظة 5: تفعيل زر تعديل الملف الشخصي
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
              // ...
            ],
            const SizedBox(height: 32),
            const Center(child: Text('${AppStrings.version} 1.0.0')),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // الدالة الجديدة للقائمة المنسدلة (ملاحظة 1)
  Widget _buildModeDropdown(UserModel user, AuthProvider authProvider) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: DropdownButtonFormField<String>(
          value: user.userType,
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

  // ... باقي الدوال المساعدة تبقى كما هي
  // _buildSectionHeader, _buildSettingsTile, _buildSwitchTile, _showLanguageDialog, etc.
  
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
                setState(() => _selectedLanguage = value!);
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
}
