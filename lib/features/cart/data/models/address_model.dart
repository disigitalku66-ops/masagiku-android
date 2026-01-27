/// Shipping Address Model
library;

import 'package:equatable/equatable.dart';

/// Shipping/Billing Address
class ShippingAddress extends Equatable {
  final int id;
  final int customerId;
  final String contactPersonName;
  final String phone;
  final String? email;
  final String addressType; // home, office, other
  final String address;
  final String? city;
  final String? zip;
  final String? country;
  final String? state;
  final double? latitude;
  final double? longitude;
  final bool isDefault;
  final bool isBilling;
  final bool isGuest;

  const ShippingAddress({
    required this.id,
    required this.customerId,
    required this.contactPersonName,
    required this.phone,
    this.email,
    this.addressType = 'home',
    required this.address,
    this.city,
    this.zip,
    this.country,
    this.state,
    this.latitude,
    this.longitude,
    this.isDefault = false,
    this.isBilling = false,
    this.isGuest = false,
  });

  /// Full address formatted
  String get fullAddress {
    final parts = <String>[address];
    if (city != null && city!.isNotEmpty) parts.add(city!);
    if (state != null && state!.isNotEmpty) parts.add(state!);
    if (zip != null && zip!.isNotEmpty) parts.add(zip!);
    if (country != null && country!.isNotEmpty) parts.add(country!);
    return parts.join(', ');
  }

  /// Address type label in Indonesian
  String get addressTypeLabel {
    switch (addressType.toLowerCase()) {
      case 'home':
        return 'Rumah';
      case 'office':
        return 'Kantor';
      default:
        return 'Lainnya';
    }
  }

  factory ShippingAddress.fromJson(Map<String, dynamic> json) {
    return ShippingAddress(
      id: json['id'] as int,
      customerId: json['customer_id'] as int? ?? 0,
      contactPersonName:
          json['contact_person_name'] as String? ??
          json['name'] as String? ??
          '',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String?,
      addressType: json['address_type'] as String? ?? 'home',
      address: json['address'] as String? ?? '',
      city: json['city'] as String?,
      zip: json['zip'] as String?,
      country: json['country'] as String?,
      state: json['state'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      isDefault: json['is_default'] == 1 || json['is_default'] == true,
      isBilling: json['is_billing'] == 1 || json['is_billing'] == true,
      isGuest: json['is_guest'] == 1 || json['is_guest'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'contact_person_name': contactPersonName,
      'phone': phone,
      if (email != null) 'email': email,
      'address_type': addressType,
      'address': address,
      if (city != null) 'city': city,
      if (zip != null) 'zip': zip,
      if (country != null) 'country': country,
      if (state != null) 'state': state,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      'is_default': isDefault ? 1 : 0,
      'is_billing': isBilling ? 1 : 0,
    };
  }

  ShippingAddress copyWith({
    int? id,
    int? customerId,
    String? contactPersonName,
    String? phone,
    String? email,
    String? addressType,
    String? address,
    String? city,
    String? zip,
    String? country,
    String? state,
    double? latitude,
    double? longitude,
    bool? isDefault,
    bool? isBilling,
    bool? isGuest,
  }) {
    return ShippingAddress(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      contactPersonName: contactPersonName ?? this.contactPersonName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      addressType: addressType ?? this.addressType,
      address: address ?? this.address,
      city: city ?? this.city,
      zip: zip ?? this.zip,
      country: country ?? this.country,
      state: state ?? this.state,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isDefault: isDefault ?? this.isDefault,
      isBilling: isBilling ?? this.isBilling,
      isGuest: isGuest ?? this.isGuest,
    );
  }

  @override
  List<Object?> get props => [
    id,
    customerId,
    contactPersonName,
    phone,
    email,
    addressType,
    address,
    city,
    zip,
    country,
    state,
    latitude,
    longitude,
    isDefault,
    isBilling,
  ];
}

/// Create/Update address request
class AddressRequest {
  final int? id; // null for create, set for update
  final String contactPersonName;
  final String phone;
  final String? email;
  final String addressType;
  final String address;
  final String? city;
  final String? zip;
  final String? country;
  final String? state;
  final double? latitude;
  final double? longitude;
  final bool isBilling;

  const AddressRequest({
    this.id,
    required this.contactPersonName,
    required this.phone,
    this.email,
    this.addressType = 'home',
    required this.address,
    this.city,
    this.zip,
    this.country,
    this.state,
    this.latitude,
    this.longitude,
    this.isBilling = false,
  });

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'contact_person_name': contactPersonName,
      'phone': phone,
      if (email != null) 'email': email,
      'address_type': addressType,
      'address': address,
      if (city != null) 'city': city,
      if (zip != null) 'zip': zip,
      if (country != null) 'country': country,
      if (state != null) 'state': state,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      'is_billing': isBilling ? 1 : 0,
    };
  }
}
