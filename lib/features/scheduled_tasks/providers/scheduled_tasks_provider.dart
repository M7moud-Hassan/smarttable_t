import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/core/models/pagination_model.dart';
import 'package:smart_table_app/features/scheduled_tasks/data/models/scheduled_tasks_model.dart';

import '../../../core/constants/keys_enums.dart';
import '../data/repostories/scheduled_tasks_repo.dart';

final scheduledTasksProvider = FutureProvider.autoDispose
    .family<PaginationModel<ScheduledTasksModel>, int>((ref, page) async {
  final filter = ref.watch(scheduledTaskFilterProvider);
  return ref.read(scheduledTasksRepoProvider).getScheduledTasks(filter, page);
});

final scheduledTaskFilterProvider = StateProvider<ScheduledTasksFilter>((ref) {
  return ScheduledTasksFilter.current;
});
