/// User model
library;

import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? image;
  final bool isVerified;
  final String? referralCode;
  final double walletBalance;
  final int loyaltyPoints;
  final DateTime? createdAt;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.image,
    this.isVerified = false,
    this.referralCode,
    this.walletBalance = 0,
    this.loyaltyPoints = 0,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      name: json['f_name'] != null
          ? '${json['f_name']} ${json['l_name'] ?? ''}'.trim()
          : json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      image: json['image'] as String?,
      isVerified:
          json['is_phone_verified'] == 1 || json['is_email_verified'] == 1,
      referralCode: json['referral_code'] as String?,
      walletBalance: (json['wallet_balance'] as num?)?.toDouble() ?? 0,
      loyaltyPoints: json['loyalty_point'] as int? ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'image': image,
      'is_verified': isVerified,
      'referral_code': referralCode,
      'wallet_balance': walletBalance,
      'loyalty_point': loyaltyPoints,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  User copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? image,
    bool? isVerified,
    String? referralCode,
    double? walletBalance,
    int? loyaltyPoints,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      image: image ?? this.image,
      isVerified: isVerified ?? this.isVerified,
      referralCode: referralCode ?? this.referralCode,
      walletBalance: walletBalance ?? this.walletBalance,
      loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    phone,
    image,
    isVerified,
    referralCode,
    walletBalance,
    loyaltyPoints,
    createdAt,
  ];
}
