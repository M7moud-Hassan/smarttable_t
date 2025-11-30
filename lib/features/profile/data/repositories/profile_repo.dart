
import 'package:hooks_riverpod/hooks_riverpod.dart' show Ref, Provider;
import 'package:smart_table_app/core/providers/api_service_provider.dart';
import 'package:smart_table_app/core/service/api_service.dart';
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

  Future<String> aboutUs() async {
    final response = await _apiService.generalGet(
      Endpoints.aboutUs,
    );
    return response['content'];
  }
}
