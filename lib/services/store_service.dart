import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import '../models/product_model.dart';
import '../models/store_model.dart';

class StoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<StoreModel?> getStoreBySupplier(String supplierId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('stores')
          .where('supplierId', isEqualTo: supplierId)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;
      return StoreModel.fromFirestore(snapshot.docs.first);
    } catch (e) {
      print('Error getting store: $e');
      return null;
    }
  }

  Future<String?> createStore(StoreModel store) async {
    try {
      DocumentReference docRef =
          await _firestore.collection('stores').add(store.toFirestore());
      return docRef.id;
    } catch (e) {
      print('Error creating store: $e');
      return null;
    }
  }

  Future<bool> updateStore(String storeId, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection('stores').doc(storeId
