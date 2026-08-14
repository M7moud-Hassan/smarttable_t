import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/core/constants/endpoints.dart';
import 'package:smart_table_app/core/providers/api_service_provider.dart';
import 'package:smart_table_app/core/service/api_service.dart';
import 'package:smart_table_app/core/utils/exceptions.dart';
import 'package:smart_table_app/features/teacher_preferences/data/models/teacher_preference_model.dart';

final teacherPreferencesRepositoryProvider =
    Provider<TeacherPreferencesRepository>((ref) {
  return ApiTeacherPreferencesRepository(ref.read(apiServiceProvider));
});

abstract class TeacherPreferencesRepository {
  Future<List<TeacherPreference>> getWishes();

  Future<List<TeacherClassOption>> getClassrooms({String? search});

  Future<List<WishAvailableCourse>> getClassroomCourses(int classroomId);

  Future<void> createWish(TeacherPreferenceDraft draft);

  Future<void> updateWish(int wishId, TeacherPreferenceDraft draft);

  Future<void> deleteWish(int wishId);
}

class ApiTeacherPreferencesRepository implements TeacherPreferencesRepository {
  ApiTeacherPreferencesRepository(this._apiService);

  final ApiService _apiService;

  @override
  Future<List<TeacherPreference>> getWishes() async {
    final response = await _apiService.get(Endpoints.wishes);
    _ensureSuccess(response.success, response.message);
    return _readList(response.data, const ['wishes'])
        .map(TeacherPreference.fromJson)
        .toList(growable: false);
  }

  @override
  Future<List<TeacherClassOption>> getClassrooms({String? search}) async {
    final response = await _apiService.get(
      Endpoints.wishClassrooms,
      parameters: search == null || search.trim().isEmpty
          ? null
          : {'search': search.trim()},
    );
    _ensureSuccess(response.success, response.message);
    return _readList(response.data, const ['classrooms'])
        .map(TeacherClassOption.fromJson)
        .toList(growable: false);
  }

  @override
  Future<List<WishAvailableCourse>> getClassroomCourses(
    int classroomId,
  ) async {
    final response = await _apiService.get(
      Endpoints.wishClassroomCourses(classroomId),
      parameters: const {'available_only': false},
    );
    _ensureSuccess(response.success, response.message);
    return _readList(response.data, const ['courses'])
        .map(WishAvailableCourse.fromJson)
        .toList(growable: false);
  }

  @override
  Future<void> createWish(TeacherPreferenceDraft draft) async {
    final response = await _apiService.post(Endpoints.wishes, _body(draft));
    _ensureSuccess(response.success, response.message);
  }

  @override
  Future<void> updateWish(
    int wishId,
    TeacherPreferenceDraft draft,
  ) async {
    final response = await _apiService.patch(
      Endpoints.wish(wishId),
      _body(draft),
    );
    _ensureSuccess(response.success, response.message);
  }

  @override
  Future<void> deleteWish(int wishId) async {
    final response = await _apiService.delete(Endpoints.wish(wishId));
    _ensureSuccess(response.success, response.message);
  }

  Map<String, dynamic> _body(TeacherPreferenceDraft draft) {
    return {
      'classroom_id': draft.classroomId,
      'course_ids': draft.courseIds,
      if (draft.note.trim().isNotEmpty) 'note': draft.note.trim(),
    };
  }

  void _ensureSuccess(bool? success, String? message) {
    if (success != true) {
      throw ServerException(message);
    }
  }

  List<Map<String, dynamic>> _readList(
    dynamic data,
    List<String> possibleKeys,
  ) {
    dynamic value = data;
    if (value is Map) {
      for (final key in [...possibleKeys, 'results', 'data']) {
        if (value[key] is List) {
          value = value[key];
          break;
        }
      }
    }
    if (value is! List) return const [];
    return value
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList(growable: false);
  }
}
