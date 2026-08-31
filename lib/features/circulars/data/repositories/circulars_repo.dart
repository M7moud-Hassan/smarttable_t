import 'package:hooks_riverpod/hooks_riverpod.dart' show Provider;
import 'package:smart_table_app/core/providers/api_service_provider.dart';
import 'package:smart_table_app/core/service/api_service.dart';
import 'package:smart_table_app/core/utils/exceptions.dart';
import 'package:smart_table_app/features/circulars/data/models/circulars_model.dart';

import '../../../../core/constants/endpoints.dart';
import '../../../../core/models/pagination_model.dart';

final circularsRepoProvider = Provider<CircularsRepository>((ref) {
  return ApiCircularsRepository(ref.read(apiServiceProvider));
});

abstract class CircularsRepository {
  Future<PaginationModel<CircularsModel>> getCirculars(int page);

  Future<String?> signCircular(int circularId);
}

class ApiCircularsRepository implements CircularsRepository {
  ApiCircularsRepository(this._apiService);

  final ApiService _apiService;

  @override
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

  @override
  Future<String?> signCircular(int circularId) async {
    final response = await _apiService.post(
      Endpoints.circularSign(circularId),
      {'signed': true},
    );
    if (response.success != true) {
      throw ServerException(response.message);
    }
    return response.message;
  }
}
