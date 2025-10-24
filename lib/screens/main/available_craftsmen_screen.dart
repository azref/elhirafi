// lib/screens/main/available_craftsmen_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../models/user_model.dart';
import '../../models/profession_model.dart';
import '../../providers/auth_provider.dart';
import '../../data/cities_data.dart'; // <-- تم تصحيح المسار
import '../chat/chat_detail_screen.dart';

class AvailableCraftsmenScreen extends StatefulWidget {
  const AvailableCraftsmenScreen({super.key});

  @override
  State<AvailableCraftsmenScreen> createState() => _AvailableCraftsmenScreenState();
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

      final newCraftsmen = snapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();

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
  
  String _getUserCountry(UserModel? user) {
    if (user == null || user.workCities.isEmpty) return 'المغرب';
    
    for (var entry in citiesByCountry.entries) {
      if (entry.value.contains(user.workCities.first)) {
        return entry.key;
      }
    }
    return 'المغرب';
  }
  
  String _getDialectCode(String countryName) {
    const countryToDialect = {
      'المغرب': 'MA',
      'الجزائر': 'DZ',
      'تونس': 'TN',
      'المملكة العربية السعودية': 'AR',
    };
    return countryToDialect[countryName] ?? 'AR';
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<AuthProvider>(context).user;
    
    final userCountryName = _getUserCountry(currentUser);
    final userDialect = _getDialectCode(userCountryName);
    final availableCities = citiesByCountry[userCountryName] ?? [];
    final professions = _professionsData.getAllProfessions();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.availableCraftsmen),
        backgroundColor: AppColors.primaryColor,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedProfessionId,
                  decoration: InputDecoration(
                    labelText: 'اختر المهنة',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('جميع المهن'),
                    ),
                    ...professions.map((profession) {
                      return DropdownMenuItem(
                        value: profession.id,
                        child: Text(profession.getNameByDialect(userDialect)),
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
                DropdownButtonFormField<String>(
                  value: _selectedCity,
                  decoration: InputDecoration(
                    labelText: 'اختر المدينة',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('جميع المدن'),
                    ),
                    ...availableCities.map((city) {
                      return DropdownMenuItem(
                        value: city,
                        child: Text(city),
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
              ],
            ),
          ),
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
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primaryColor,
                            backgroundImage: craftsman.profileImageUrl.isNotEmpty
                                ? NetworkImage(craftsman.profileImageUrl)
                                : null,
                            child: craftsman.profileImageUrl.isEmpty
                                ? Text(
                                    craftsman.name.isNotEmpty ? craftsman.name[0].toUpperCase() : '?',
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
                              Text(
                                'المدن: ${craftsman.workCities.join(', ')}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              if (craftsman.yearsOfExperience != null)
                                Text(
                                  'الخبرة: ${craftsman.yearsOfExperience} سنة',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                            ],
                          ),
                          trailing: isClientMode
                              ? IconButton(
                                  icon: const Icon(Icons.message),
                                  color: AppColors.primaryColor,
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ChatDetailScreen(
                                          chatId: '',
                                          otherUserId: craftsman.id,
                                          otherUserName: craftsman.name,
                                        ),
                                      ),
                                    );
                                  },
                                )
                              : Icon(
                                  Icons.lock,
                                  color: Colors.grey[400],
                                ),
                          onTap: isClientMode
                              ? () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChatDetailScreen(
                                        chatId: '',
                                        otherUserId: craftsman.id,
                                        otherUserName: craftsman.name,
                                      ),
                                    ),
                                  );
                                }
                              : null,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
