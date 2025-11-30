import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/features/weekly_plan/data/repositories/weekly_plan_repo.dart';

import '../../../core/models/pagination_model.dart';
import '../data/models/week_info_model.dart';

final weekInfoProvider =
    FutureProvider.family<PaginationModel<WeekInfoModel>, int>(
        (ref, page) async {
  return ref.read(weeklyPlanRepoProvider).getWeeksList(page);
});

final selectedWeekProvider = StateProvider<WeekInfoModel?>((ref) {
  return null;
});
