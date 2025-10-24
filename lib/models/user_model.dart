import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final String userType;
  final String profileImageUrl;
  final String? professionId;
  final String? professionName;
  final List<String> workCities;
  final String? country; // <-- تم إضافة الدولة
  final bool? isAvailable;
  final double rating;
  final int reviewCount;
  final Timestamp createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.userType,
    this.profileImageUrl = '',
    this.professionId,
    this.professionName,
    this.workCities = const [],
    this.country, // <-- تم إضافة الدولة
    this.isAvailable,
    this.rating = 0.0,
    this.reviewCount = 0,
    required this.createdAt,
  });

  // Factory constructor to create a UserModel from a Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      userType: data['userType'] ?? 'client',
      profileImageUrl: data['profileImageUrl'] ?? '',
      professionId: data['professionId'],
      professionName: data['professionName'],
      workCities: List<String>.from(data['workCities'] ?? []),
      country: data['country'], // <-- تم إضافة الدولة
      isAvailable: data['isAvailable'],
      rating: (data['rating'] ?? 0.0).toDouble(),
      reviewCount: data['reviewCount'] ?? 0,
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }

  // Getters for compatibility
  String get uid => id;
  String get displayName => name;
  String get profession => professionName ?? '';
  List<String> get cities => workCities;
  int? get yearsOfExperience => null; // TODO: Add this field to Firestore

  // Method to convert a UserModel instance to a map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'userType': userType,
      'profileImageUrl': profileImageUrl,
      'professionId': professionId,
      'professionName': professionName,
      'workCities': workCities,
      'country': country, // <-- تم إضافة الدولة
      'isAvailable': isAvailable,
      'rating': rating,
      'reviewCount': reviewCount,
      'createdAt': createdAt,
    };
  }
  
  // --- دالة copyWith المضافة لإصلاح الخطأ ---
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phoneNumber,
    String? userType,
    String? profileImageUrl,
    String? professionId,
    String? professionName,
    List<String>? workCities,
    String? country,
    bool? isAvailable,
    double? rating,
    int? reviewCount,
    Timestamp? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      userType: userType ?? this.userType,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      professionId: professionId ?? this.professionId,
      professionName: professionName ?? this.professionName,
      workCities: workCities ?? this.workCities,
      country: country ?? this.country,
      isAvailable: isAvailable ?? this.isAvailable,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
