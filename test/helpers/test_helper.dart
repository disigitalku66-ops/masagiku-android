import 'package:dio/dio.dart';
import 'package:masagiku_app/core/storage/secure_storage.dart';
import 'package:masagiku_app/features/auth/data/services/auth_api_service.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([AuthApiService, SecureStorageService, Dio])
void main() {}
