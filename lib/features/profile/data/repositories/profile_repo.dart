
import 'dart:io';

import 'package:hooks_riverpod/hooks_riverpod.dart' show Ref, Provider;
import 'package:smart_table_app/core/providers/api_service_provider.dart';
import 'package:smart_table_app/core/service/api_service.dart';
import 'package:smart_table_app/core/models/response_model.dart';
import 'package:smart_table_app/features/profile/data/models/profile_model.dart';

import '../../../../core/constants/endpoints.dart';

final profileRepoProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(ref);
});

class ProfileRepository {
  final Ref<ProfileRepository> ref;
  final ApiService _apiService;

  ProfileRepository(this.ref) : _apiService = ref.read(apiServiceProvider);

  Future<ProfileModel> getProfile() async {
    final response = await _apiService.get(
      Endpoints.profile,
    );
    final Map<String, dynamic> data = response.data;
    final fcmToken = response.fcmToken;
    if (fcmToken != null) {
      data.addAll({'fcm_token': fcmToken});
    }
    return ProfileModel.fromJson(data);
  }

  Future<String?> getSignature() async {
    final response = await _apiService.get(
      Endpoints.getSignature,
    );
    if (response.success ?? false) {
      final data = response.data;
      if (data is Map) {
        final url = data['signature_url'] as String?;
        if (url != null && url.startsWith('http://')) {
          return url.replaceFirst('http://', 'https://');
        }
        return url;
      }
    }
    return null;
  }

  Future<ResponseModel> uploadSignature(File signatureFile) async {
    final response = await _apiService.multipartRequest(
      Endpoints.signature,
      {},
      {'signature': signatureFile},
    );
    return response;
  }

  Future<bool> deleteSignature() async {
    final response = await _apiService.delete(
      Endpoints.deleteSignature,
    );
    return response.success ?? false;
  }

  Future<String> aboutUs() async {
    final response = await _apiService.generalGet(
      Endpoints.aboutUs,
    );
    return response['content'];
  }
}
