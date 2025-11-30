import 'package:hooks_riverpod/hooks_riverpod.dart' show Ref, Provider;
import 'package:smart_table_app/core/providers/api_service_provider.dart';
import 'package:smart_table_app/core/service/api_service.dart';

import '../../../../core/constants/endpoints.dart';
import '../../../../core/utils/exceptions.dart';

final contactUsRepoProvider = Provider<ContactUsRepository>((ref) {
  return ContactUsRepository(ref);
});

class ContactUsRepository {
  final Ref<ContactUsRepository> ref;
  final ApiService _apiService;

  ContactUsRepository(this.ref) : _apiService = ref.read(apiServiceProvider);

  Future<String> contactUs(
      {required String name,
      required String phone,
      required String email,
      required String title,
      required String message}) async {
    final response = await _apiService.post(Endpoints.contactUs, {
      "name": name,
      "phone_number": phone,
      "email": email,
      "title": title,
      "message": message,
    });
    if (response.success!) {
      return response.message ?? '';
    }
    throw ServerException(response.message);
  }
}
