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

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();

  String _userType = AppStrings.client;
  String? _selectedProfession;
  List<String> _selectedWorkCities = [];
  File? _image;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
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

  void _showCitySelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _CitySelectionDialog(
          initialSelectedCities: _selectedWorkCities,
          onCitiesSelected: (cities) {
            setState(() {
              _selectedWorkCities = cities;
            });
          },
        );
      },
    );
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_userType == AppStrings.craftsman && (_selectedProfession == null || _selectedWorkCities.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.professionAndCityRequired)),
      );
      return;
    }

    try {
      await Provider.of<AuthProvider>(context, listen: false).register(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        name: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        userType: _userType,
        professionName: _selectedProfession,
        workCities: _selectedWorkCities,
        profileImage: _image,
      );
      if (mounted) {
         Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل التسجيل: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.register),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, auth, child) {
          if (auth.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildImagePicker(),
                  const SizedBox(height: 20),
                  CustomTextField(
                    controller: _nameController,
                    labelText: 'الاسم',
                    validator: (value) => value!.isEmpty ? AppStrings.nameRequired : null,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _emailController,
                    labelText: AppStrings.email,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) => value!.isEmpty ? AppStrings.emailRequired : null,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _passwordController,
                    labelText: AppStrings.password,
                    obscureText: true,
                    validator: (value) => value!.isEmpty ? AppStrings.passwordRequired : null,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _phoneController,
                    labelText: AppStrings.phone,
                    keyboardType: TextInputType.phone,
                    validator: (value) => value!.isEmpty ? AppStrings.phoneRequired : null,
                  ),
                  const SizedBox(height: 20),
                  _buildUserTypeSelector(),
                  const SizedBox(height: 16),
                  if (_userType == AppStrings.craftsman) ...[
                    _buildProfessionDropdown(),
                    const SizedBox(height: 16),
                    _buildWorkCityDropdown(),
                  ],
                  const SizedBox(height: 24),
                  CustomButton(
                    text: AppStrings.register,
                    onPressed: _register,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildImagePicker() {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.grey[300],
            backgroundImage: _image != null ? FileImage(_image!) : null,
            child: _image == null ? const Icon(Icons.person, size: 60, color: Colors.white) : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: InkWell(
              onTap: _pickImage,
              child: const CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primaryColor,
                child: Icon(Icons.camera_alt, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserTypeSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.grey),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _userType,
          isExpanded: true,
          items: const [
            DropdownMenuItem(value: AppStrings.client, child: Text(AppStrings.client)),
            DropdownMenuItem(value: AppStrings.craftsman, child: Text(AppStrings.craftsman)),
            DropdownMenuItem(value: AppStrings.supplier, child: Text(AppStrings.supplier)),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _userType = value;
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildProfessionDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.grey),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedProfession,
          isExpanded: true,
          hint: const Text(AppStrings.selectProfession),
          items: AppStrings.professions.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              _selectedProfession = newValue;
            });
          },
        ),
      ),
    );
  }

  Widget _buildWorkCityDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: _showCitySelectionDialog,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: Colors.grey),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    _selectedWorkCities.isEmpty ? AppStrings.selectWorkCities : _selectedWorkCities.join(', '),
                    style: TextStyle(
                      color: _selectedWorkCities.isEmpty ? Colors.grey[600] : Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.arrow_drop_down, color: Colors.grey),
              ],
            ),
          ),
        ),
        if (_selectedWorkCities.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: _selectedWorkCities
                  .map((city) => Chip(
                        label: Text(city),
                        onDeleted: () {
                          setState(() {
                            _selectedWorkCities.remove(city);
                          });
                        },
                      ))
                  .toList(),
            ),
          ),
      ],
    );
  }
}

class _CitySelectionDialog extends StatefulWidget {
  final List<String> initialSelectedCities;
  final Function(List<String>) onCitiesSelected;

  const _CitySelectionDialog({
    required this.initialSelectedCities,
    required this.onCitiesSelected,
  });

  @override
  State<_CitySelectionDialog> createState() => _CitySelectionDialogState();
}

class _CitySelectionDialogState extends State<_CitySelectionDialog> {
  late List<String> _tempSelectedCities;
  String? _selectedCountry;
  String? _selectedRegion;
  String? _selectedCity;

  List<String> _countries = [];
  List<String> _regions = [];
  List<String> _cities = [];
  List<String> _districts = [];

  @override
  void initState() {
    super.initState();
    _tempSelectedCities = List.from(widget.initialSelectedCities);
    _countries = CitiesData.getCountries();
  }

  void _onCountryChanged(String? newValue) {
    setState(() {
      _selectedCountry = newValue;
      _selectedRegion = null;
      _selectedCity = null;
      _regions = _selectedCountry != null ? CitiesData.getRegions(_selectedCountry!) : [];
      _cities = [];
      _districts = [];
    });
  }

  void _onRegionChanged(String? newValue) {
    setState(() {
      _selectedRegion = newValue;
      _selectedCity = null;
      _cities = (_selectedCountry != null && _selectedRegion != null)
          ? CitiesData.getCities(_selectedCountry!, _selectedRegion!)
          : [];
      _districts = [];
    });
  }

  void _onCityChanged(String? newValue) {
    setState(() {
      _selectedCity = newValue;
      _districts = (_selectedCountry != null && _selectedRegion != null && _selectedCity != null)
          ? CitiesData.getDistricts(_selectedCountry!, _selectedRegion!, _selectedCity!)
          : [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(AppStrings.selectWorkCities),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedCountry,
                hint: const Text('اختر الدولة'),
                isExpanded: true,
                isDense: true,
                style: const TextStyle(fontSize: 14, color: Colors.black, overflow: TextOverflow.ellipsis),
                items: _countries.map((String country) {
                  return DropdownMenuItem<String>(value: country, child: Text(country));
                }).toList(),
                onChanged: _onCountryChanged,
              ),
              if (_selectedCountry != null) const SizedBox(height: 10),
              if (_selectedCountry != null)
                DropdownButtonFormField<String>(
                  value: _selectedRegion,
                  hint: const Text('اختر المنطقة/الجهة'),
                  isExpanded: true,
                  isDense: true,
                  style: const TextStyle(fontSize: 14, color: Colors.black, overflow: TextOverflow.ellipsis),
                  items: _regions.map((String region) {
                    return DropdownMenuItem<String>(value: region, child: Text(region));
                  }).toList(),
                  onChanged: _onRegionChanged,
                ),
              if (_selectedRegion != null) const SizedBox(height: 10),
              if (_selectedRegion != null)
                DropdownButtonFormField<String>(
                  value: _selectedCity,
                  hint: const Text('اختر المحافظة/المدينة'),
                  isExpanded: true,
                  isDense: true,
                  style: const TextStyle(fontSize: 14, color: Colors.black, overflow: TextOverflow.ellipsis),
                  items: _cities.map((String city) {
                    return DropdownMenuItem<String>(value: city, child: Text(city));
                  }).toList(),
                  onChanged: _onCityChanged,
                ),
              const SizedBox(height: 10),
              if (_districts.isNotEmpty)
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _districts.length,
                    itemBuilder: (context, index) {
                      final district = _districts[index];
                      final isSelected = _tempSelectedCities.contains(district);
                      return CheckboxListTile(
                        title: Text(district),
                        value: isSelected,
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              _tempSelectedCities.add(district);
                            } else {
                              _tempSelectedCities.remove(district);
                            }
                          });
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(AppStrings.cancel),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onCitiesSelected(_tempSelectedCities);
            Navigator.of(context).pop();
          },
          child: const Text(AppStrings.save),
        ),
      ],
    );
  }
}
