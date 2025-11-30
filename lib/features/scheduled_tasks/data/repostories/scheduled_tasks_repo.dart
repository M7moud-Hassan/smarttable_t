import 'package:hooks_riverpod/hooks_riverpod.dart' show Ref, Provider;
import 'package:smart_table_app/core/constants/keys_enums.dart';
import 'package:smart_table_app/core/models/pagination_model.dart';
import 'package:smart_table_app/core/providers/api_service_provider.dart';
import 'package:smart_table_app/core/service/api_service.dart';
import 'package:smart_table_app/features/scheduled_tasks/data/models/scheduled_tasks_model.dart';

import '../../../../core/constants/endpoints.dart';

final scheduledTasksRepoProvider = Provider<ScheduledTasksRepository>((ref) {
  return ScheduledTasksRepository(ref);
});

class ScheduledTasksRepository {
  final Ref<ScheduledTasksRepository> ref;
  final ApiService _apiService;

  ScheduledTasksRepository(this.ref)
      : _apiService = ref.read(apiServiceProvider);

  Future<PaginationModel<ScheduledTasksModel>> getScheduledTasks(
      ScheduledTasksFilter filter, int page) async {
    final response = await _apiService.get(Endpoints.dailyTasks, parameters: {
      'filter': filter.name,
      'page': page,
    });
    final pagination = PaginationModel<ScheduledTasksModel>();
    pagination.setData(
        map: response.data, fromJson: ScheduledTasksModel.fromJson);
    return pagination;
  }
}
