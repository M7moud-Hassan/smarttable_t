import 'package:hooks_riverpod/hooks_riverpod.dart' show Ref, Provider;
import 'package:smart_table_app/core/providers/api_service_provider.dart';
import 'package:smart_table_app/core/service/api_service.dart';

import '../../../../core/constants/endpoints.dart';
import '../../../school_table/data/models/lesson_model.dart';

final waitingClasessRepoProvider = Provider<WaitingClasessRepository>((ref) {
  return WaitingClasessRepository(ref);
});

class WaitingClasessRepository {
  final Ref<WaitingClasessRepository> ref;
  final ApiService _apiService;

  WaitingClasessRepository(this.ref)
      : _apiService = ref.read(apiServiceProvider);

  Future<List<LessonModel>> getWaitingClasess() async {
    final response = await _apiService.get(
      Endpoints.waitingClasses,
    );
    return List<LessonModel>.from(
        response.data.map((x) => LessonModel.fromJson(x)));
  }
}
