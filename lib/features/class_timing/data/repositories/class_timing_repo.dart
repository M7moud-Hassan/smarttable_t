import 'package:hooks_riverpod/hooks_riverpod.dart' show Ref, Provider;
import 'package:smart_table_app/core/constants/endpoints.dart';
import 'package:smart_table_app/core/providers/api_service_provider.dart';
import 'package:smart_table_app/core/service/api_service.dart';
import 'package:smart_table_app/features/class_timing/data/models/class_timing_model.dart';

import '../../../../core/utils/exceptions.dart';

final classTimingRepoProvider = Provider<ClassTimingRepository>((ref) {
  return ClassTimingRepository(ref);
});

class ClassTimingRepository {
  final Ref<ClassTimingRepository> ref;
  final ApiService _apiService;

  ClassTimingRepository(this.ref) : _apiService = ref.read(apiServiceProvider);
  Future<ClassesTimingSettings> getClassTiming() async {
    final response = await _apiService.get(
      Endpoints.classTiming,
    );
    return ClassesTimingSettings.fromJson(response.data);
  }

  Future<void> updateClassTiming(Map<String, dynamic> data) async {
    final response = await _apiService.put(Endpoints.classTiming, data);
    if (!response.success!) {
      throw ServerException(null);
    }
  }
}
