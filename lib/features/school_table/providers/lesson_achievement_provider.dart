import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/features/school_table/data/models/lesson_achievement_model.dart';
import 'package:smart_table_app/features/school_table/data/repositories/lesson_achievement_repository.dart';

final lessonAchievementForCellProvider = FutureProvider.autoDispose
    .family<LessonAchievement?, LessonAchievementLookup>((ref, lookup) async {
  final repository = ref.read(lessonAchievementRepositoryProvider);
  final achievements =
      await repository.getLessonAchievementsByCell(lookup.cellNumber);

  LessonAchievement? match;
  for (final achievement in achievements) {
    if (achievement.isForDate(lookup.date)) {
      match = achievement;
      break;
    }
  }
  if (match == null) return null;
  return repository.getLessonAchievement(match.id);
});

final lessonAchievementSubmitProvider = StateNotifierProvider.autoDispose<
    LessonAchievementSubmitNotifier, AsyncValue<void>>((ref) {
  return LessonAchievementSubmitNotifier(ref);
});

class LessonAchievementLookup {
  const LessonAchievementLookup({
    required this.cellNumber,
    required this.date,
  });

  final int cellNumber;
  final DateTime date;

  @override
  bool operator ==(Object other) {
    return other is LessonAchievementLookup &&
        other.cellNumber == cellNumber &&
        formatLessonAchievementDate(other.date) ==
            formatLessonAchievementDate(date);
  }

  @override
  int get hashCode => Object.hash(
        cellNumber,
        formatLessonAchievementDate(date),
      );
}

class LessonAchievementSubmitNotifier extends StateNotifier<AsyncValue<void>> {
  LessonAchievementSubmitNotifier(this._ref)
      : super(const AsyncValue.data(null));

  final Ref _ref;

  Future<bool> submit(LessonAchievementDraft draft) async {
    return save(draft: draft);
  }

  Future<bool> save({
    required LessonAchievementDraft draft,
    LessonAchievement? existing,
  }) async {
    state = const AsyncValue.loading();
    try {
      final repository = _ref.read(lessonAchievementRepositoryProvider);
      if (existing == null) {
        await repository.createLessonAchievement(draft);
      } else {
        await repository.updateLessonAchievement(
          existing.id,
          LessonAchievementPatch(
            achievement: _changed(draft.achievement, existing.achievement),
            homework: _changed(draft.homework, existing.homework),
            notes: _changed(draft.notes, existing.notes),
          ),
        );
      }
      _ref.invalidate(lessonAchievementForCellProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return false;
    }
  }

  Future<bool> delete(int achievementId) async {
    state = const AsyncValue.loading();
    try {
      await _ref
          .read(lessonAchievementRepositoryProvider)
          .deleteLessonAchievement(achievementId);
      _ref.invalidate(lessonAchievementForCellProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return false;
    }
  }

  String? _changed(String value, String original) {
    final normalized = value.trim();
    return normalized == original.trim() ? null : normalized;
  }
}
