/// Category model
library;

import 'package:equatable/equatable.dart';

class Category extends Equatable {
  final int id;
  final String name;
  final String? slug;
  final String? icon;
  final String? image;
  final String? bannerImage;
  final int? parentId;
  final int position;
  final int productsCount;
  final List<Category>? children;
  final bool isActive;

  const Category({
    required this.id,
    required this.name,
    this.slug,
    this.icon,
    this.image,
    this.bannerImage,
    this.parentId,
    this.position = 0,
    this.productsCount = 0,
    this.children,
    this.isActive = true,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String?,
      icon: json['icon'] as String?,
      image: json['image'] as String?,
      bannerImage: json['banner_image'] as String?,
      parentId: json['parent_id'] as int?,
      position: json['position'] as int? ?? 0,
      productsCount: json['products_count'] as int? ?? 0,
      children: json['childes'] != null
          ? (json['childes'] as List)
                .map((e) => Category.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
      isActive: json['status'] == 1 || json['is_active'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'icon': icon,
      'image': image,
      'banner_image': bannerImage,
      'parent_id': parentId,
      'position': position,
      'products_count': productsCount,
      'is_active': isActive,
    };
  }

  bool get isParent => parentId == null || parentId == 0;
  bool get hasChildren => children != null && children!.isNotEmpty;

  @override
  List<Object?> get props => [
    id,
    name,
    slug,
    icon,
    image,
    bannerImage,
    parentId,
    position,
    productsCount,
    children,
    isActive,
  ];
}
