import 'package:hooks_riverpod/hooks_riverpod.dart' show Ref, Provider;
import 'package:smart_table_app/core/providers/api_service_provider.dart';
import 'package:smart_table_app/core/service/api_service.dart';
import 'package:smart_table_app/features/home/data/models/home_data_model.dart';

import '../../../../core/constants/endpoints.dart';

final homeRepoProvider = Provider<HomeRepository>((ref) {
  return HomeRepository(ref);
});

class HomeRepository {
  final Ref<HomeRepository> ref;
  final ApiService _apiService;

  HomeRepository(this.ref) : _apiService = ref.read(apiServiceProvider);

  Future<HomeDataModel> getHomeMenues() async {
    final response = await _apiService.get(
      Endpoints.homeMenus,
    );
    return HomeDataModel.fromJson(response.data);
  }
}
