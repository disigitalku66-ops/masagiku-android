/// Address API Service
library;

import 'package:dio/dio.dart';
import '../models/address_model.dart';
import '../../../../core/network/api_response.dart';

class AddressApiService {
  final Dio _dio;
  static const String _basePath = '/customer/address';

  AddressApiService(this._dio);

  /// Get all addresses
  Future<ApiResponse<List<ShippingAddress>>> getAddresses() async {
    try {
      final response = await _dio.get('$_basePath/list');
      final data = response.data;

      if (data is List) {
        final addresses = data
            .map((e) => ShippingAddress.fromJson(e as Map<String, dynamic>))
            .toList();
        return ApiResponse<List<ShippingAddress>>(
          success: true,
          data: addresses,
        );
      }

      if (data['data'] is List) {
        final addresses = (data['data'] as List)
            .map((e) => ShippingAddress.fromJson(e as Map<String, dynamic>))
            .toList();
        return ApiResponse<List<ShippingAddress>>(
          success: true,
          data: addresses,
        );
      }

      return ApiResponse<List<ShippingAddress>>(success: true, data: []);
    } on DioException catch (e) {
      return ApiResponse<List<ShippingAddress>>(
        success: false,
        message:
            e.response?.data?['message'] as String? ??
            e.message ??
            'Gagal memuat alamat',
      );
    }
  }

  /// Get single address by ID
  Future<ApiResponse<ShippingAddress>> getAddress(int id) async {
    try {
      final response = await _dio.get('$_basePath/get/$id');
      final data = response.data;

      if (data is Map<String, dynamic>) {
        return ApiResponse<ShippingAddress>(
          success: true,
          data: ShippingAddress.fromJson(data),
        );
      }

      return ApiResponse<ShippingAddress>(
        success: false,
        message: 'Alamat tidak ditemukan',
      );
    } on DioException catch (e) {
      return ApiResponse<ShippingAddress>(
        success: false,
        message:
            e.response?.data?['message'] as String? ??
            e.message ??
            'Gagal memuat alamat',
      );
    }
  }

  /// Add new address
  Future<ApiResponse<ShippingAddress>> addAddress(
    AddressRequest request,
  ) async {
    try {
      final response = await _dio.post(
        '$_basePath/add',
        data: request.toJson(),
      );
      final data = response.data;

      if (data['errors'] != null) {
        final errors = data['errors'] as List;
        final message = errors.isNotEmpty
            ? errors.first['message'] as String? ?? 'Gagal menambahkan alamat'
            : 'Gagal menambahkan alamat';
        return ApiResponse<ShippingAddress>(success: false, message: message);
      }

      // Parse the created address
      if (data['address'] != null) {
        return ApiResponse<ShippingAddress>(
          success: true,
          data: ShippingAddress.fromJson(
            data['address'] as Map<String, dynamic>,
          ),
          message: 'Alamat berhasil ditambahkan',
        );
      }

      return ApiResponse<ShippingAddress>(
        success: true,
        message: data['message'] as String? ?? 'Alamat berhasil ditambahkan',
      );
    } on DioException catch (e) {
      return ApiResponse<ShippingAddress>(
        success: false,
        message:
            e.response?.data?['message'] as String? ??
            e.message ??
            'Gagal menambahkan alamat',
      );
    }
  }

  /// Update existing address
  Future<ApiResponse<ShippingAddress>> updateAddress(
    AddressRequest request,
  ) async {
    try {
      final response = await _dio.put(
        '$_basePath/update',
        data: request.toJson(),
      );
      final data = response.data;

      if (data['errors'] != null) {
        final errors = data['errors'] as List;
        final message = errors.isNotEmpty
            ? errors.first['message'] as String? ?? 'Gagal mengupdate alamat'
            : 'Gagal mengupdate alamat';
        return ApiResponse<ShippingAddress>(success: false, message: message);
      }

      return ApiResponse<ShippingAddress>(
        success: true,
        message: data['message'] as String? ?? 'Alamat berhasil diupdate',
      );
    } on DioException catch (e) {
      return ApiResponse<ShippingAddress>(
        success: false,
        message:
            e.response?.data?['message'] as String? ??
            e.message ??
            'Gagal mengupdate alamat',
      );
    }
  }

  /// Delete address
  Future<ApiResponse<void>> deleteAddress(int id) async {
    try {
      await _dio.delete(_basePath, data: {'id': id});
      return ApiResponse<void>(
        success: true,
        message: 'Alamat berhasil dihapus',
      );
    } on DioException catch (e) {
      return ApiResponse<void>(
        success: false,
        message:
            e.response?.data?['message'] as String? ??
            e.message ??
            'Gagal menghapus alamat',
      );
    }
  }

  /// Get restricted countries
  Future<ApiResponse<List<String>>> getRestrictedCountries() async {
    try {
      final response = await _dio.get('/customer/get-restricted-country-list');
      final data = response.data;

      if (data is List) {
        return ApiResponse<List<String>>(
          success: true,
          data: data.map((e) => e.toString()).toList(),
        );
      }

      return ApiResponse<List<String>>(success: true, data: []);
    } on DioException catch (e) {
      return ApiResponse<List<String>>(
        success: false,
        message: e.message ?? 'Gagal memuat daftar negara',
      );
    }
  }

  /// Get restricted zip codes
  Future<ApiResponse<List<String>>> getRestrictedZipCodes() async {
    try {
      final response = await _dio.get('/customer/get-restricted-zip-list');
      final data = response.data;

      if (data is List) {
        return ApiResponse<List<String>>(
          success: true,
          data: data.map((e) => e.toString()).toList(),
        );
      }

      return ApiResponse<List<String>>(success: true, data: []);
    } on DioException catch (e) {
      return ApiResponse<List<String>>(
        success: false,
        message: e.message ?? 'Gagal memuat daftar kode pos',
      );
    }
  }
}
