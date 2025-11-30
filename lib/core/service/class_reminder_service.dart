// Class to manage teacher schedule

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/core/service/firebase_messaging_service.dart';

class ClassScheduleManager {
  final FirebaseMessagingService _notificationService;

  ClassScheduleManager(this._notificationService);

  // Add a class reminder
  Future<void> addClassReminder({
    required int id,
    required int dayOfWeek,
    required TimeOfDay time,
    required String className,
    required String desc,
    int reminderMinutesBefore = 15,
  }) async {
    // Schedule the actual notification
    await _notificationService.scheduleClassReminder(
      id: id,
      dayOfWeek: dayOfWeek,
      time: time,
      className: className,
      desc: desc,
      reminderMinutesBefore: reminderMinutesBefore,
    );
  }

  // Clear all reminders
  Future<void> clearAllReminders() async {
    await _notificationService.cancelAllClassReminders();
  }
}

// Class to represent a single class reminder

final classScedulingProvider = Provider<ClassScheduleManager>((ref) {
  final messagingService = ref.read(firebaseMessagingServiceProvider);
  return ClassScheduleManager(messagingService);
});
