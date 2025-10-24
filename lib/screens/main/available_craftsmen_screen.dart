// lib/screens/main/available_craftsmen_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../models/user_model.dart';
import '../../models/profession_model.dart';
import '../../providers/auth_provider.dart';
import '../../data/professions_data.dart';
import '../../data/cities_data.dart';
import '../chat/chat_detail_screen.dart';
import 'package:url_launcher/url_launcher.dart'; // <--- إضافة مهمة

class AvailableCraftsmenScreen extends StatefulWidget {
  const AvailableCraftsmenScreen({super.key});

  @override
  State<AvailableCraftsmenScreen> createState() =>
      _AvailableCraftsmenScreenState();
}

class _AvailableCraftsmenScreenState extends State<AvailableCraftsmenScreen> {
  String? _selectedProfessionId;
  String? _selectedCity;
  final ScrollController _scrollController = ScrollController();
  final List<UserModel> _craftsmen = [];
  bool _isLoading = false;
  bool _hasMore = true;
  DocumentSnapshot? _lastDocument;
  static const int _pageSize = 20;

  final ProfessionsData _professionsData = ProfessionsData();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadCraftsmen();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      _loadCraftsmen();
    }
  }

  Future<void> _loadCraftsmen() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    try {
      Query query = FirebaseFirestore.instance
          .collection('users')
          .where('userType', isEqualTo: 'craftsman')
          .where('isAvailable', isEqualTo: true);

      if (_selectedProfessionId != null) {
        query = query.where('professionId', isEqualTo: _selectedProfessionId);
      }

      if (_selectedCity != null) {
        query = query.where('workCities', arrayContains: _selectedCity);
      }

      if (_lastDocument != null) {
        query = query.startAfterDocument(_lastDocument!);
      }

      query = query.limit(_pageSize);

      final snapshot = await query.get();

      if (snapshot.docs.isEmpty) {
        setState(() {
          _hasMore = false;
          _isLoading = false;
        });
        return;
      }

      _lastDocument = snapshot.docs.last;

      final newCraftsmen =
          snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();

      setState(() {
        _craftsmen.addAll(newCraftsmen);
        _isLoading = false;
        if (snapshot.docs.length < _pageSize) {
          _hasMore = false;
        }
      });
    } catch (e) {
      print('Error loading craftsmen: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _resetAndReload() {
    setState(() {
      _craftsmen.clear();
      _lastDocument = null;
      _hasMore = true;
    });
    _loadCraftsmen();
  }

  // --- دالة مساعدة للاتصال ---
  void _callCraftsman(String phoneNumber) async {
    final url = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا يمكن إجراء الاتصال')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<AuthProvider>(context).user;
    
    // --- هذا هو التعديل الأول: تحديد الدولة والمدن تلقائيًا ---
    final String userCountryName = currentUser?.country ?? 'المغرب';
    final String userDialect = _getDialectCode(userCountryName);
    final List<String> availableCities = CitiesData.getAllCitiesForCountry(userCountryName);
    final professions = _professionsData.getAllProfessions();
    // --- نهاية التعديل الأول ---

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.availableCraftsmen),
        backgroundColor: AppColors.primaryColor,
      ),
      body: Column(
        children: [
          // Filters
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              children: [
                // Profession Filter
                DropdownButtonFormField<String>(
                  value: _selectedProfessionId,
                  decoration: InputDecoration(
                    labelText: 'اختر المهنة',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                  ),
                  isExpanded: true,
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('جميع المهن'),
                    ),
                    ...professions.map((profession) {
                      return DropdownMenuItem(
                        value: profession.id,
                        child: Text(
                          profession.getNameByDialect(userDialect),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedProfessionId = value;
                    });
                    _resetAndReload();
                  },
                ),
                const SizedBox(height: 12),

                // --- هذا هو التعديل الثاني: عرض المدن فقط بدون الدولة ---
                // City Filter
                DropdownButtonFormField<String>(
                  value: _selectedCity,
                  decoration: InputDecoration(
                    labelText: 'اختر مدينتك', // تم تغيير النص
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                  ),
                  isExpanded: true,
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('جميع المدن'),
                    ),
                    ...availableCities.map((city) {
                      return DropdownMenuItem(
                        value: city,
                        child: Text(
                          city,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14), // تصغير حجم الخط
                        ),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedCity = value;
                    });
                    _resetAndReload();
                  },
                ),
                // --- نهاية التعديل الثاني ---
              ],
            ),
          ),

          // Craftsmen List
          Expanded(
            child: _craftsmen.isEmpty && !_isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_search,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'لا يوجد حرفيون متاحون',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: _craftsmen.length + (_hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _craftsmen.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      final craftsman = _craftsmen[index];
                      final isClientMode = currentUser?.userType == 'client';

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ListTile(
                            leading: CircleAvatar(
                              radius: 25,
                              backgroundColor: AppColors.primaryColor,
                              backgroundImage: craftsman.profileImageUrl.isNotEmpty
                                  ? NetworkImage(craftsman.profileImageUrl)
                                  : null,
                              child: craftsman.profileImageUrl.isEmpty
                                  ? Text(
                                      craftsman.name.isNotEmpty ? craftsman.name[0].toUpperCase() : 'U',
                                      style: const TextStyle(color: Colors.white),
                                    )
                                  : null,
                            ),
                            title: Text(
                              craftsman.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  craftsman.professionName ?? 'حرفي',
                                  style: TextStyle(
                                    color: AppColors.primaryColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                if (craftsman.workCities.isNotEmpty)
                                  Text(
                                    'المدن: ${craftsman.workCities.join(', ')}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isClientMode)
                                  IconButton(
                                    icon: const Icon(Icons.phone),
                                    color: Colors.green,
                                    onPressed: () => _callCraftsman(craftsman.phoneNumber),
                                  ),
                                if (isClientMode)
                                  IconButton(
                                    icon: const Icon(Icons.message),
                                    color: AppColors.primaryColor,
                                    onPressed: () {
                                      // TODO: Implement getOrCreateChat
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('جاري فتح المحادثة...'))
                                      );
                                    },
                                  ),
                                if (!isClientMode)
                                  Icon(
                                    Icons.lock,
                                    color: Colors.grey[400],
                                  ),
                              ],
                            ),
                            onTap: isClientMode
                                ? () {
                                    // TODO: Navigate to craftsman profile
                                  }
                                : null,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
  
  String _getDialectCode(String countryName) {
    const map = {
      'المغرب': 'MA',
      'الجزائر': 'DZ',
      'تونس': 'TN',
    };
    return map[countryName] ?? 'AR'; // AR as default
  }
}
