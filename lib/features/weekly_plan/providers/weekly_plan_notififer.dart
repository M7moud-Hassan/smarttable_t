
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:smart_table_app/core/constants/constants.dart';
import 'package:smart_table_app/core/models/pagination_model.dart';
import 'package:smart_table_app/core/providers/picked_file_provider.dart';
import 'package:smart_table_app/features/weekly_plan/data/models/weekly_plan_model.dart';

import '../../../core/models/models.dart';
import '../../../core/providers/providers.dart';
import '../data/repositories/weekly_plan_repo.dart';

class WeeklyPlanNotififer
    extends StateNotifier<AsyncValue<List<WeeklyPlanModel>>> {
  WeeklyPlanNotififer(this._ref)
      : super(
          const AsyncData([]),
        );
  final Ref _ref;
  final PagingController<int, WeeklyPlanModel> pagingController =
      PagingController(firstPageKey: 1);
  Future<PaginationModel<WeeklyPlanModel>> getWeeklyPlanList() async {
    final response =
        await _ref.read(weeklyPlanRepoProvider).getWeeklyPlanList();
    return response;
  }

  void deleteWeeklyPlan(int id) async {
    try {
      _ref
          .read(requestResponseProvider.notifier)
          .update((state) => RequestResponseModel.loading());
      await _ref.read(weeklyPlanRepoProvider).deleteWeeklyPlan(id);
      pagingController.itemList =
          pagingController.itemList?.where((e) => e.id != id).toList();
      _ref.read(requestResponseProvider.notifier).update((state) =>
          RequestResponseModel.success(
              actionOnDone: ActionOnDone.showSucessMessage));
    } catch (e) {
      _ref
          .read(requestResponseProvider.notifier)
          .update((state) => RequestResponseModel.error());
    } finally {
      _ref
          .read(requestResponseProvider.notifier)
          .update((state) => RequestResponseModel.loading(loading: false));
    }
  }

  uploadFile(int weekId) async {
    try {
      _ref
          .read(requestResponseProvider.notifier)
          .update((state) => RequestResponseModel.loading());
      final file = _ref.read(pickedFileProvider);
      await _ref.read(weeklyPlanRepoProvider).updateWeeklyPlan(file!, weekId);
      pagingController.refresh();
      _ref
          .read(requestResponseProvider.notifier)
          .update((state) => RequestResponseModel.success());
    } catch (e) {
      _ref
          .read(requestResponseProvider.notifier)
          .update((state) => RequestResponseModel.error());
    } finally {
      _ref
          .read(requestResponseProvider.notifier)
          .update((state) => RequestResponseModel.loading(loading: false));
    }
  }
}

final weeklyPlanNotififerProvider = StateNotifierProvider<WeeklyPlanNotififer,
    AsyncValue<List<WeeklyPlanModel>>>((ref) => WeeklyPlanNotififer(ref));
