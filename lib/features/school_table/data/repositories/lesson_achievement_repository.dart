import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/core/constants/endpoints.dart';
import 'package:smart_table_app/core/providers/api_service_provider.dart';
import 'package:smart_table_app/core/service/api_service.dart';
import 'package:smart_table_app/core/utils/exceptions.dart';
import 'package:smart_table_app/features/school_table/data/models/lesson_achievement_model.dart';

final lessonAchievementRepositoryProvider =
    Provider<LessonAchievementRepository>((ref) {
  return ApiLessonAchievementRepository(ref.read(apiServiceProvider));
});

abstract class LessonAchievementRepository {
  Future<List<LessonAchievement>> getLessonAchievementsByCell(int cellNumber);

  Future<LessonAchievement> getLessonAchievement(int achievementId);

  Future<void> createLessonAchievement(LessonAchievementDraft draft);

  Future<void> updateLessonAchievement(
    int achievementId,
    LessonAchievementPatch patch,
  );

  Future<void> deleteLessonAchievement(int achievementId);
}

class ApiLessonAchievementRepository implements LessonAchievementRepository {
  ApiLessonAchievementRepository(this._apiService);

  final ApiService _apiService;

  @override
  Future<List<LessonAchievement>> getLessonAchievementsByCell(
    int cellNumber,
  ) async {
    final response = await _apiService.get(
      Endpoints.lessonAchievements,
      parameters: {'cell_number': cellNumber},
    );
    _ensureSuccess(response.success, response.message);
    return _readList(response.data)
        .map(LessonAchievement.fromJson)
        .toList(growable: false);
  }

  @override
  Future<LessonAchievement> getLessonAchievement(int achievementId) async {
    final response = await _apiService.get(
      Endpoints.lessonAchievement(achievementId),
    );
    _ensureSuccess(response.success, response.message);
    return LessonAchievement.fromJson(_readMap(response.data));
  }

  @override
  Future<void> createLessonAchievement(LessonAchievementDraft draft) async {
    final response = await _apiService.post(
      Endpoints.lessonAchievements,
      draft.toJson(),
    );

    if (response.success != true) {
      throw ServerException(response.message);
    }
  }

  @override
  Future<void> updateLessonAchievement(
    int achievementId,
    LessonAchievementPatch patch,
  ) async {
    if (patch.isEmpty) return;
    final response = await _apiService.patch(
      Endpoints.lessonAchievement(achievementId),
      patch.toJson(),
    );
    _ensureSuccess(response.success, response.message);
  }

  @override
  Future<void> deleteLessonAchievement(int achievementId) async {
    final response = await _apiService.delete(
      Endpoints.lessonAchievement(achievementId),
    );
    _ensureSuccess(response.success, response.message);
  }

  void _ensureSuccess(bool? success, String? message) {
    if (success != true) throw ServerException(message);
  }

  List<Map<String, dynamic>> _readList(dynamic data) {
    dynamic value = data;
    if (value is Map) {
      for (final key in const ['results', 'achievements', 'data']) {
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

  Map<String, dynamic> _readMap(dynamic data) {
    dynamic value = data;
    if (value is Map && value['data'] is Map) value = value['data'];
    if (value is Map && value['achievement'] is Map) {
      value = value['achievement'];
    }
    if (value is Map) return Map<String, dynamic>.from(value);
    throw ServerException(null);
  }
}
