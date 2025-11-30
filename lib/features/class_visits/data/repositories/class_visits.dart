import 'package:hooks_riverpod/hooks_riverpod.dart' show Ref, Provider;
import 'package:smart_table_app/core/providers/api_service_provider.dart';
import 'package:smart_table_app/core/service/api_service.dart';
import 'package:smart_table_app/features/class_visits/data/models/class_visits_model.dart';

import '../../../../core/constants/endpoints.dart';
import '../../../../core/models/pagination_model.dart';

final classVisitsRepoProvider = Provider<ClassVisitsRepository>((ref) {
  return ClassVisitsRepository(ref);
});

class ClassVisitsRepository {
  final Ref<ClassVisitsRepository> ref;
  final ApiService _apiService;

  ClassVisitsRepository(this.ref) : _apiService = ref.read(apiServiceProvider);

  Future<PaginationModel<ClassVisitsModel>> getClassVisits(int page) async {
    final response = await _apiService.get(
      Endpoints.classVisits,
      parameters: {
        'page': page,
      },
    );
    final pagination = PaginationModel<ClassVisitsModel>();
    pagination.setData(map: response.data, fromJson: ClassVisitsModel.fromJson);
    return pagination;
  }
}
