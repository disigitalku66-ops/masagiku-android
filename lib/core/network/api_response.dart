/// API Response wrapper
library;

import 'package:equatable/equatable.dart';

/// Generic API Response wrapper
class ApiResponse<T> extends Equatable {
  final bool success;
  final String? message;
  final T? data;
  final List<String>? errors;
  final int? statusCode;

  const ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.errors,
    this.statusCode,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] ?? json['status'] == true,
      message: json['message'] as String?,
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'] as T?,
      errors: (json['errors'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      statusCode: json['status_code'] as int?,
    );
  }

  bool get hasError => !success || errors != null && errors!.isNotEmpty;

  String get errorMessage {
    if (errors != null && errors!.isNotEmpty) {
      return errors!.join(', ');
    }
    return message ?? 'Terjadi kesalahan. Silakan coba lagi.';
  }

  @override
  List<Object?> get props => [success, message, data, errors, statusCode];
}

/// Paginated response wrapper
class PaginatedResponse<T> extends Equatable {
  final bool success;
  final String? message;
  final List<T>? data;
  final int? totalCount;
  final int currentPage;
  final int perPage;
  final bool hasMorePages;

  const PaginatedResponse({
    this.success = true,
    this.message,
    this.data,
    this.totalCount,
    this.currentPage = 1,
    this.perPage = 20,
    this.hasMorePages = false,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    final dataList = json['data'] as List<dynamic>?;
    final items = dataList
        ?.map((e) => fromJsonT(e as Map<String, dynamic>))
        .toList();

    final currentPage = json['current_page'] as int? ?? 1;
    final lastPage = json['last_page'] as int? ?? 1;

    return PaginatedResponse<T>(
      success: true,
      data: items,
      totalCount: json['total'] as int? ?? json['total_size'] as int?,
      currentPage: currentPage,
      perPage: json['per_page'] as int? ?? 20,
      hasMorePages: currentPage < lastPage,
    );
  }

  @override
  List<Object?> get props => [
    success,
    message,
    data,
    totalCount,
    currentPage,
    perPage,
  ];
}
