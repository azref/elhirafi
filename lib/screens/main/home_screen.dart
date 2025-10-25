// lib/screens/main/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alsana_alharfiyin/models/user_model.dart';
import 'package:alsana_alharfiyin/providers/auth_provider.dart';
import 'package:alsana_alharfiyin/constants/app_colors.dart';
import 'package:alsana_alharfiyin/widgets/banner_ad_widget.dart';
import 'package:alsana_alharfiyin/services/store_service.dart';
import 'package:alsana_alharfiyin/models/product_model.dart';
import 'package:share_plus/share_plus.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
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
            child: _buildDashboard(context, user),
          ),
          const BannerAdWidget(),
        ],
      ),
    );
  }

  Widget _buildDashboard(BuildContext context, UserModel user) {
    switch (user.userType) {
      case 'client':
        return const _ClientDashboard();
      case 'craftsman':
        return _CraftsmanDashboard(user: user);
      case 'supplier':
        return _SupplierDashboard(user: user);
      default:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 80, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'نوع المستخدم غير معروف: ${user.userType}',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 16
