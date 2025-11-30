import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/core/extensions/context_extensions.dart';
import 'package:smart_table_app/core/providers/request_response_provider.dart';
import 'package:smart_table_app/core/widgets/pagination_list_view.dart';
import 'package:smart_table_app/features/notifications/providers/notifications_notifer.dart';

import '../widgets/notification_card.dart';

class NotificationsView extends ConsumerWidget {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
        body: PaginationListView(
      controller:
          ref.watch(notificationsMangeProvider.notifier).pagingController,
      getList: (page) => ref.read(notificationsProvider(page).future),
      itemBuilder: (notification, index) => NotificationCard(
        notfificaionModel: notification.notification,
      ),
      noItemWidget: Center(
        child: Text(context.locale.noNotifications),
      ),
    )
        //  notificationAsync.when(
        //     data: (notifications) => ListView.separated(
        //         separatorBuilder: (context, index) => const Divider(
        //               height: 0,
        //             ),
        //         itemCount: notifications.length,
        //         itemBuilder: (_, index) => NotificationCard(
        //               notfificaionModel: notifications[index],
        //             )),
        //     error: (_, __) => CustomErrorWidget(
        //           onTap: () {
        //             ref.invalidate(notificationsProvider);
        //           },
        //         ),
        //     loading: () => const Center(
        //           child: LoadingWidget(),
        //         )),
        );
  }
}
