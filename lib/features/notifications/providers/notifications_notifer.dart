import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:smart_table_app/core/constants/keys_enums.dart';
import 'package:smart_table_app/features/notifications/data/models/notifications_model.dart';
import 'package:smart_table_app/features/notifications/data/repositories/notifications_repo.dart';

import '../../../core/models/models.dart';
import '../../../core/models/pagination_model.dart';
import '../../../core/providers/providers.dart';

class NotificationsNotifer
    extends StateNotifier<AsyncValue<List<NotificationsModel>>> {
  NotificationsNotifer(this._ref) : super(const AsyncData([])) {}
  final Ref _ref;
  final PagingController<int, NotificationParent> pagingController =
      PagingController(firstPageKey: 1);
  Future<void> deleteNotification(
    int id,
  ) async {
    try {
      _ref
          .read(requestResponseProvider.notifier)
          .update((state) => RequestResponseModel.loading());
      await _ref.read(notificationsRepoProvider).deleteNotification(id);
      pagingController.itemList = pagingController.itemList
          ?.where((e) => e.notification.id != id)
          .toList();
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
}

final notificationsMangeProvider = StateNotifierProvider.autoDispose<
    NotificationsNotifer, AsyncValue<List<NotificationsModel>>>((ref) {
  return NotificationsNotifer(ref);
});

final notificationsProvider = FutureProvider.autoDispose
    .family<PaginationModel<NotificationParent>, int>((ref, page) async {
  return ref.read(notificationsRepoProvider).getNotifications(page);
});
