import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/core/service/class_reminder_service.dart';
import 'package:smart_table_app/core/utils/helpers.dart';
import 'package:smart_table_app/features/class_timing/data/models/class_timing_model.dart';
import 'package:smart_table_app/features/class_timing/data/repositories/class_timing_repo.dart';

import '../../../core/constants/keys_enums.dart';
import '../../../core/models/models.dart';
import '../../../core/providers/providers.dart';
import '../../../core/providers/request_response_provider.dart';

class ClassTimingNotifer extends StateNotifier<bool> {
  ClassTimingNotifer(this._ref) : super(false);
  final Ref _ref;

  Future<void> toggoleClassTiming(
    ClassesTimingSettings model,
  ) async {
    try {
      _ref
          .read(requestResponseProvider.notifier)
          .update((state) => RequestResponseModel.loading());
      await _ref
          .read(classTimingRepoProvider)
          .updateClassTiming(model.toJson());
      _ref.invalidate(classTimingProvider);
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

final classTimingMangeProvider =
    StateNotifierProvider.autoDispose<ClassTimingNotifer, bool>((ref) {
  return ClassTimingNotifer(ref);
});

final classTimingProvider =
    FutureProvider.autoDispose<ClassesTimingSettings>((ref) async {
  final prefs = ref.read(sharedPreferencesProvider);
  final localHashed =
      prefs.getString(SharedPreferenceKeys.classTimingHashed.name);
  final data = await ref.read(classTimingRepoProvider).getClassTiming();
  if (localHashed == null || localHashed != data.hashed) {
    prefs.setString(SharedPreferenceKeys.classTimingHashed.name, data.hashed);
    await ref.read(classScedulingProvider).clearAllReminders();
    for (var i = 0; i < data.classesTiming.length; i++) {
      final element = data.classesTiming[i];
      final int weekday = getWeekdayNumber(element.dayen.toLowerCase())!;
      final TimeOfDay time = parseTimeOfDay(element.startTime);

      ref.read(classScedulingProvider).addClassReminder(
            id: i + 1,
            dayOfWeek: weekday,
            time: time,
            className: element.cellNumberText,
            desc: element.cellText,
            reminderMinutesBefore: data.classesNotificationsMinutesBefore,
          );
    }
  }

  return data;
});
