class NotificationsModel {
  final int id;
  final String title;
  final String body;
  final String actionId;
  final String clickAction;
  final String priority;
  final String dateCreated;
  final String timeCreated;
  final String fullDate;
  final bool isRead;

  NotificationsModel(
      {required this.id,
      required this.title,
      required this.body,
      required this.actionId,
      required this.clickAction,
      required this.priority,
      required this.dateCreated,
      required this.timeCreated,
      required this.fullDate,
      required this.isRead});

  factory NotificationsModel.fromMap(Map<String, dynamic> map) {
    return NotificationsModel(
      id: map['id']?.toInt() ?? 0,
      title: map['title']?.toString() ?? '',
      body: map['body']?.toString() ?? '',
      actionId: map['action_id']?.toString() ?? '',
      clickAction: map['click_action']?.toString() ?? '',
      priority: map['priority']?.toString() ?? '',
      dateCreated: map['date_created']?.toString() ?? '',
      timeCreated: map['time_created']?.toString() ?? '',
      fullDate: map['full_date']?.toString() ?? '',
      isRead: map['is_read'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'action_id': actionId,
      'click_action': clickAction,
      'priority': priority,
      'date_created': dateCreated,
      'time_created': timeCreated,
      'full_date': fullDate,
      'is_read': isRead,
    };
  }
}

class NotificationParent {
  final NotificationsModel notification;
  NotificationParent({
    required this.notification,
  });

  factory NotificationParent.fromJson(Map<String, dynamic> json) {
    return NotificationParent(
      notification: NotificationsModel.fromMap(json['notification']),
    );
  }
}
