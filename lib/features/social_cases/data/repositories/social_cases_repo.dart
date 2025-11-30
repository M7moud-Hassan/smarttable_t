import 'package:hooks_riverpod/hooks_riverpod.dart' show Ref, Provider;
import 'package:smart_table_app/core/providers/api_service_provider.dart';
import 'package:smart_table_app/core/service/api_service.dart';
import 'package:smart_table_app/features/social_cases/data/models/social_cases_model.dart';

import '../../../../core/constants/endpoints.dart';
import '../../../../core/models/pagination_model.dart';
import '../models/social_cases_details_model.dart';

final socialCaseRepoProvider = Provider<SocialCasesRepository>((ref) {
  return SocialCasesRepository(ref);
});

class SocialCasesRepository {
  final Ref<SocialCasesRepository> ref;
  final ApiService _apiService;

  SocialCasesRepository(this.ref) : _apiService = ref.read(apiServiceProvider);

  Future<PaginationModel<SocialCaseModel>> getSocialCases(
    int page,
  ) async {
    final response = await _apiService.get(
      Endpoints.socialCases,
      parameters: {
        'page': page,
      },
    );
    final pagination = PaginationModel<SocialCaseModel>();
    pagination.setData(map: response.data, fromJson: SocialCaseModel.fromJson);
    return pagination;
  }

  Future<List<SocialCaseDetailsModel>> getSocialCasesDetails(int id) async {
    final response = await _apiService.get(
      '${Endpoints.socialCases}$id/',
    );
    return List<SocialCaseDetailsModel>.from(response.data['results']
        .map((x) => SocialCaseDetailsModel.fromJson(x)));
  }
}
