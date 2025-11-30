import 'package:hooks_riverpod/hooks_riverpod.dart' show Ref, Provider;
import 'package:smart_table_app/core/models/pagination_model.dart';
import 'package:smart_table_app/core/providers/api_service_provider.dart';
import 'package:smart_table_app/core/service/api_service.dart';
import 'package:smart_table_app/core/utils/exceptions.dart';
import 'package:smart_table_app/features/notifications/data/models/notifications_model.dart';

import '../../../../core/constants/endpoints.dart';

final notificationsRepoProvider = Provider<NotificationsRepository>((ref) {
  return NotificationsRepository(ref);
});

class NotificationsRepository {
  final Ref<NotificationsRepository> ref;
  final ApiService _apiService;

  NotificationsRepository(this.ref)
      : _apiService = ref.read(apiServiceProvider);

  Future<PaginationModel<NotificationParent>> getNotifications(int page) async {
    final response = await _apiService
        .get(Endpoints.notifications, parameters: {'page': page});
    final notification = PaginationModel<NotificationParent>();
    notification.setData(
        map: response.data, fromJson: NotificationParent.fromJson);

    return notification;
  }

  Future<void> deleteNotification(int id) async {
    final response = await _apiService.delete(
      '${Endpoints.notifications}$id/${Endpoints.deleteNotifications}',
    );
    if (!response.success!) {
      throw ServerException(null);
    }
  }
}
