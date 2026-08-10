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
    final rawData = response.data;
    if (rawData is! Map) {
      throw Exception(
          'Unexpected profile response (${response.statusCode}): ${response.message ?? rawData}');
    }
    final data = Map<String, dynamic>.from(rawData);
    final fcmToken = response.fcmToken;
    if (fcmToken != null) {
      data.addAll({'fcm_token': fcmToken});
    }
    return ProfileModel.fromJson(data);
  }

  Future<String?> getProfilePhoto() async {
    final response = await _apiService.get(
      Endpoints.getProfilePhoto,
    );
    if (!(response.success ?? false)) return null;

    return _extractPhotoUrl(response.data);
  }

  Future<ResponseModel> uploadProfilePhoto(File photoFile) async {
    return _apiService.multipartRequest(
      Endpoints.profilePhoto,
      {},
      {'photo': photoFile},
    );
  }

  Future<bool> deleteProfilePhoto() async {
    final response = await _apiService.delete(
      Endpoints.deleteProfilePhoto,
    );
    return response.success ?? false;
  }

  String? _extractPhotoUrl(dynamic data) {
    if (data is String && data.isNotEmpty) {
      return _normalizeMediaUrl(data);
    }

    if (data is Map) {
      const possibleKeys = [
        'teacher_photo',
        'photo_url',
        'photo',
        'image_url',
        'image',
        'url',
      ];
      for (final key in possibleKeys) {
        final url = _extractPhotoUrl(data[key]);
        if (url != null) return url;
      }
    }

    return null;
  }

  String _normalizeMediaUrl(String url) {
    if (url.startsWith('http://')) {
      return url.replaceFirst('http://', 'https://');
    }
    if (url.startsWith('https://')) return url;

    final relativePath = url.startsWith('/') ? url.substring(1) : url;
    return '${Endpoints.baseUrl}$relativePath';
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
