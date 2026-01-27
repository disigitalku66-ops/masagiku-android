/// Banner model
library;

import 'package:equatable/equatable.dart';

class Banner extends Equatable {
  final int id;
  final String title;
  final String? subtitle;
  final String image;
  final String? resourceType; // 'product', 'category', 'brand', 'url'
  final String? resourceId;
  final String? url;
  final int order;
  final bool isActive;

  const Banner({
    required this.id,
    required this.title,
    this.subtitle,
    required this.image,
    this.resourceType,
    this.resourceId,
    this.url,
    this.order = 0,
    this.isActive = true,
  });

  factory Banner.fromJson(Map<String, dynamic> json) {
    return Banner(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String?,
      image: json['photo'] as String? ?? json['image'] as String? ?? '',
      resourceType: json['resource_type'] as String?,
      resourceId: json['resource_id']?.toString(),
      url: json['url'] as String?,
      order: json['order'] as int? ?? 0,
      isActive: json['status'] == 1 || json['is_active'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'image': image,
      'resource_type': resourceType,
      'resource_id': resourceId,
      'url': url,
      'order': order,
      'is_active': isActive,
    };
  }

  @override
  List<Object?> get props => [
    id,
    title,
    subtitle,
    image,
    resourceType,
    resourceId,
    url,
    order,
    isActive,
  ];
}
