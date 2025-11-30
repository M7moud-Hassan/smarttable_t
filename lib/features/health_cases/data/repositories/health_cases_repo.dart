import 'package:hooks_riverpod/hooks_riverpod.dart' show Ref, Provider;
import 'package:smart_table_app/core/providers/api_service_provider.dart';
import 'package:smart_table_app/core/service/api_service.dart';
import 'package:smart_table_app/features/health_cases/data/models/health_case_model.dart';

import '../../../../core/constants/endpoints.dart';
import '../../../../core/models/pagination_model.dart';
import '../models/health_case_details_model.dart';

final healthCasesRepoProvider = Provider<HealthCasesRepository>((ref) {
  return HealthCasesRepository(ref);
});

class HealthCasesRepository {
  final Ref<HealthCasesRepository> ref;
  final ApiService _apiService;

  HealthCasesRepository(this.ref) : _apiService = ref.read(apiServiceProvider);

  Future<PaginationModel<HealthCaseModel>> getHealthCases(
    int page,
  ) async {
    final response = await _apiService.get(
      Endpoints.healthCases,
      parameters: {
        'page': page,
      },
    );
    final pagination = PaginationModel<HealthCaseModel>();
    pagination.setData(map: response.data, fromJson: HealthCaseModel.fromJson);
    return pagination;
  }

  Future<List<HealthCaseDetailsModel>> getHealthCasesDetails(int id) async {
    final response = await _apiService.get(
      '${Endpoints.healthCases}$id/',
    );
    return List<HealthCaseDetailsModel>.from(response.data['results']
        .map((x) => HealthCaseDetailsModel.fromJson(x)));
  }
}
