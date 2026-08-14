import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/features/teacher_preferences/data/models/teacher_preference_model.dart';
import 'package:smart_table_app/features/teacher_preferences/data/repositories/teacher_preferences_repository.dart';

final teacherPreferencesProvider =
    FutureProvider.autoDispose<List<TeacherPreference>>((ref) {
  return ref.read(teacherPreferencesRepositoryProvider).getWishes();
});

final teacherClassOptionsProvider =
    FutureProvider.autoDispose<List<TeacherClassOption>>((ref) {
  return ref.read(teacherPreferencesRepositoryProvider).getClassrooms();
});

final teacherClassCoursesProvider = FutureProvider.autoDispose
    .family<List<WishAvailableCourse>, int>((ref, classroomId) {
  return ref
      .read(teacherPreferencesRepositoryProvider)
      .getClassroomCourses(classroomId);
});

final teacherPreferencesActionProvider = StateNotifierProvider.autoDispose<
    TeacherPreferencesActionNotifier, AsyncValue<void>>((ref) {
  return TeacherPreferencesActionNotifier(ref);
});

class TeacherPreferencesActionNotifier extends StateNotifier<AsyncValue<void>> {
  TeacherPreferencesActionNotifier(this._ref)
      : super(const AsyncValue.data(null));

  final Ref _ref;

  Future<bool> save({
    required TeacherPreferenceDraft draft,
    int? wishId,
  }) async {
    state = const AsyncValue.loading();
    try {
      final repository = _ref.read(teacherPreferencesRepositoryProvider);
      if (wishId == null) {
        await repository.createWish(draft);
      } else {
        await repository.updateWish(wishId, draft);
      }
      _refresh(draft.classroomId);
      state = const AsyncValue.data(null);
      return true;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return false;
    }
  }

  Future<bool> delete(TeacherPreference preference) async {
    state = const AsyncValue.loading();
    try {
      await _ref
          .read(teacherPreferencesRepositoryProvider)
          .deleteWish(preference.id);
      _refresh(preference.classId);
      state = const AsyncValue.data(null);
      return true;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return false;
    }
  }

  void _refresh(int classroomId) {
    _ref.invalidate(teacherPreferencesProvider);
    _ref.invalidate(teacherClassOptionsProvider);
    _ref.invalidate(teacherClassCoursesProvider(classroomId));
  }
}
