// lib/screens/main/available_craftsmen_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../models/user_model.dart';
import '../../models/profession_model.dart';
import '../../providers/auth_provider.dart';
import '../../data/cities_data.dart';
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
    return 'المغرب'; // Default country
  }

  String _getDialectCode(String countryName) {
    const countryToDialect = {
      'المغرب': 'MA',
      'الجزائر': 'DZ',
      'تونس': 'TN',
      'المملكة العربية السعودية': 'AR',
      // Add other countries
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
        children:
