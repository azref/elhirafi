// lib/screens/main/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Kept for _CraftsmanDashboard
import 'package:share_plus/share_plus.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/banner_ad_widget.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('مرحباً ${user.name}'),
        backgroundColor: AppColors.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              Share.share(
                'تطبيق الصانع الحرفي - منصة ربط الحرفيين بأصحاب المشاريع\nhttps://play.google.com/store/apps/details?id=com.elsane3.app',
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildDashboard(context, user.userType),
          ),
          // Assuming BannerAdWidget is defined correctly elsewhere
          // For now, let's use a placeholder to avoid breaking the build if it's not found.
          const BannerAdWidget(),
        ],
      ),
    );
  }

  Widget _buildDashboard(BuildContext context, String userType) {
    // --- هذا هو التعديل الرئيسي ---
    switch (userType) {
      case AppStrings.client: // "أبحث عن حرفي"
        return const _ClientDashboard();
      case AppStrings.craftsman: // "أنا حرفي"
        return const _CraftsmanDashboard();
      case AppStrings.supplier: // "أنا مورد"
        return const _SupplierDashboard();
      default:
        // This is the part that is currently showing
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 80,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'نوع المستخدم غير معروف: $userType',
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Provider.of<AuthProvider>(context, listen: false).signOut();
                },
                child: const Text('تسجيل الخروج'),
              ),
            ],
          ),
        );
    }
  }
}

class _ClientDashboard extends StatelessWidget {
  const _ClientDashboard();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.build_circle,
              size: 100,
              color: AppColors.primaryColor,
            ),
            const SizedBox(height: 24),
            const Text(
              'لوحة تحكم العميل',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'ابحث عن الحرفيين المتاحين أو أنشئ طلب جديد',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                // This navigation needs a named route setup in main.dart
                // For now, it will do nothing if '/create_request' is not defined.
                // Navigator.pushNamed(context, '/create_request');
                 ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('شاشة إنشاء الطلب قيد التطوير')),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('إنشاء طلب جديد'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CraftsmanDashboard extends StatelessWidget {
  const _CraftsmanDashboard();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.handyman,
              size: 100,
              color: AppColors.primaryColor,
            ),
            const SizedBox(height: 24),
            const Text(
              'لوحة تحكم الحرفي',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'المهنة: ${user?.professionName ?? 'غير محدد'}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('جاهز للعمل'),
                const SizedBox(width: 16),
                Switch(
                  value: user?.isAvailable ?? false,
                  onChanged: (value) {
                    authProvider.updateAvailability(value);
                  },
                  activeColor: AppColors.primaryColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SupplierDashboard extends StatelessWidget {
  const _SupplierDashboard();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.store,
              size: 100,
              color: AppColors.primaryColor,
            ),
            const SizedBox(height: 24),
            const Text(
              'لوحة تحكم المورد',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/store_management');
              },
              icon: const Icon(Icons.edit),
              label: const Text('إدارة المتجر'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
