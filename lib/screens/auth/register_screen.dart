// lib/screens/auth/register_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../data/cities_data.dart';
import '../../data/professions_data.dart';
import '../../models/user_model.dart';

class RegisterScreen extends StatefulWidget {
  final bool isEditing;
  final UserModel? userToEdit;

  const RegisterScreen({
    super.key,
    this.isEditing = false,
    this.userToEdit,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();

  String? _selectedCountry;
  String? _selectedRegion;
  String? _selectedCity;
  List<String> _selectedDistricts = [];

  String _userType = 'client';
  String? _selectedProfessionId;
  File? _image;
  String? _networkImageUrl;

  final ImagePicker _picker = ImagePicker();
  final ProfessionsData _professionsData = ProfessionsData();

  @override
  void initState() {
    super.initState();
    if (widget.isEditing && widget.userToEdit != null) {
      final user = widget.userToEdit!;
      _nameController.text = user.name;
      _emailController.text = user.email;
      _phoneController.text = user.phoneNumber;
      _userType = user.userType;
      _selectedProfessionId = user.professionId;
      _networkImageUrl = user.profileImageUrl;
      _selectedCountry = user.country;
      // ملاحظة: لاسترجاع المدن والأحياء، نحتاج إلى منطق أكثر تعقيدًا
      // سنبقيها بسيطة الآن ونسمح للمستخدم بإعادة تحديدها عند التعديل.
      // _selectedDistricts = List.from(user.workCities);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_userType == 'craftsman' &&
        (_selectedProfessionId == null || _selectedDistricts.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يجب اختيار المهنة ومنطقة عمل واحدة على الأقل')),
      );
      return;
    }
    if (_selectedCountry == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء اختيار الدولة')),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      if (widget.isEditing) {
        // --- منطق التحديث ---
        await authProvider.updateUserProfile(
          name: _nameController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
          professionId: _selectedProfessionId,
          workCities: _selectedDistricts,
          country: _selectedCountry!,
          profileImage: _image,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تحديث الملف الشخصي بنجاح')),
        );
      } else {
        // --- منطق التسجيل ---
        await authProvider.register(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          name: _nameController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
          userType: _userType,
          professionId: _selectedProfessionId,
          workCities: _selectedDistricts,
          country: _selectedCountry!,
          profileImage: _image,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم التسجيل بنجاح')),
        );
      }
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ: ${e.toString()}')
