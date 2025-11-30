import 'dart:developer';

import 'package:hooks_riverpod/hooks_riverpod.dart' show Ref, Provider;
import 'package:smart_table_app/core/models/response_model.dart';
import 'package:smart_table_app/core/providers/api_service_provider.dart';
import 'package:smart_table_app/core/service/api_service.dart';
import 'package:smart_table_app/core/service/firebase_messaging_service.dart';

import '../../../../core/constants/endpoints.dart';
import '../../../../core/utils/exceptions.dart';

final authRepoProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref);
});

class AuthRepository {
  final Ref<AuthRepository> ref;
  final ApiService _apiService;

  AuthRepository(this.ref) : _apiService = ref.read(apiServiceProvider);

  Future<ResponseModel> teacherRegisterData(
      String usercode, String username, String password, String email) async {
    final response = await _apiService.post(Endpoints.register, {
      'user_code': usercode,
      'username': username,
      'password': password,
      'email': email
    });
    if (response.success!) {
      return response;
    }
    throw ServerException(response.message);
  }

  Future<ResponseModel> teacherRegisterDataByPhone(
      String phone, String username, String password, String email) async {
    final response = await _apiService.post(Endpoints.registerByPhone, {
      'phone_number': phone,
      'username': username,
      'password': password,
      'email': email
    });
    if (response.success!) {
      // special case for idcode register
      return response;
    }
    throw ServerException(response.message);
  }

  Future<ResponseModel> teacherRegisterIdCode(String usercode) async {
    final response = await _apiService.post(Endpoints.register,
        {'user_code': usercode, "username": "", "password": "", "email": ""});
    if (response.statusCode == 400 || response.success!) {
      // special case for idcode register
      return response;
    }
    throw ServerException(response.message);
  }

  Future<ResponseModel> teacherRegisterPhone(String phone) async {
    final response =
        await _apiService.post(Endpoints.checkPhone, {'phone_number': phone});
    if (response.statusCode == 200) {
      return response;
    }
    throw ServerException(response.message);
  }

  Future<ResponseModel> teacherLogin(
    String username,
    String password,
  ) async {
    final response = await _apiService
        .post(Endpoints.login, {"username": username, "password": password});
    if (response.success!) {
      return response;
    }
    throw ServerException(response.message);
  }

  Future<ResponseModel> forgetPassword(String email) async {
    final response = await _apiService.post(Endpoints.resetPassword, {
      'email': email,
    });

    if (response.success!) {
      return response;
    }
    throw ServerException(response.message);
  }

  Future<void> updateFcm() async {
    try {
      final fcmToken = await FirebaseMessagingService().fetchFCMToken();
      await _apiService.post(Endpoints.updateFcmToken, {
        'fcm_token': fcmToken,
      });
    } catch (_) {}
  }

  Future<void> teacherLogout() async {
    await _apiService.post(Endpoints.logout, {});
  }

  Future<void> deleteMyAccount() async {
    await _apiService.post(Endpoints.deleteMyAccount, {});
  }
}
