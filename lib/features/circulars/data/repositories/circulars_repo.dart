import 'package:hooks_riverpod/hooks_riverpod.dart' show Ref, Provider;
import 'package:smart_table_app/core/providers/api_service_provider.dart';
import 'package:smart_table_app/core/service/api_service.dart';
import 'package:smart_table_app/features/circulars/data/models/circulars_model.dart';

import '../../../../core/constants/endpoints.dart';
import '../../../../core/models/pagination_model.dart';

final circularsRepoProvider = Provider<CircularsRepository>((ref) {
  return CircularsRepository(ref);
});

class CircularsRepository {
  final Ref<CircularsRepository> ref;
  final ApiService _apiService;

  CircularsRepository(this.ref) : _apiService = ref.read(apiServiceProvider);

  Future<PaginationModel<CircularsModel>> getCirculars(
    int page,
  ) async {
    final response = await _apiService.get(
      Endpoints.circulars,
      parameters: {
        'page': page,
      },
    );
    final pagination = PaginationModel<CircularsModel>();
    pagination.setData(map: response.data, fromJson: CircularsModel.fromJson);
    return pagination;
  }
}
