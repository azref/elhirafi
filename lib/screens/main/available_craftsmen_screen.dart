import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../data/professions_data.dart';
import '../../data/cities_data.dart'; // <-- تم التأكيد على وجود هذا الاستيراد

// ... (باقي الكود يبقى كما هو دون تغيير)
// The rest of the file content is identical to the previous correct version.
// No changes are needed here as the error was due to other files.
// I'm omitting it to keep the response concise, but the file is considered correct.
class AvailableCraftsmenScreen extends StatefulWidget {
  const AvailableCraftsmenScreen({super.key});

  @override
  State<AvailableCraftsmenScreen> createState() => _AvailableCraftsmenScreenState();
}

class _AvailableCraftsmenScreenState extends State<AvailableCraftsmenScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ScrollController _scrollController = ScrollController();
  
  final List<UserModel> _craftsmen = [];
  DocumentSnapshot? _lastDocument;
  bool _isLoading = false;
  bool _hasMore = true;
  final int _pageSize = 20;

  String? _selectedProfession;
  String? _selectedCity;

  @override
  void initState() {
    super.initState();
    _loadCraftsmen();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.8) {
      if (!_isLoading && _hasMore) {
        _loadCraftsmen();
      }
    }
  }

  Future<void> _loadCraftsmen() async {
    if (_isLoading || !_hasMore) return;

    setState(() => _isLoading = true);

    try {
      Query query = _firestore
          .collection('users')
          .where('userType', isEqualTo: '
