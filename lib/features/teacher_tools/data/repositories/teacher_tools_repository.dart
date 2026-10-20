import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/core/constants/endpoints.dart';
import 'package:smart_table_app/core/providers/api_service_provider.dart';
import 'package:smart_table_app/core/service/api_service.dart';
import 'package:smart_table_app/core/utils/exceptions.dart';
import 'package:smart_table_app/features/teacher_tools/data/models/teacher_tools_api_models.dart';

final teacherToolsRepositoryProvider = Provider<TeacherToolsRepository>((ref) {
  return ApiTeacherToolsRepository(ref.read(apiServiceProvider));
});

abstract class TeacherToolsRepository {
  Future<QuickQuestionGame> getQuickQuestionGame(
      {required int classId, required String session, required String date});
  Future<QuickQuestionGame> startQuickQuestionGame(
      {required int classId,
      required String session,
      required String date,
      required List<int> studentIds});
  Future<QuickQuestionGame> scoreQuickQuestionGame(
      {required int classId,
      required String session,
      required String date,
      required String action,
      int? studentId});
  Future<QuickQuestionGame> finishQuickQuestionGame(
      {required int classId, required String session, required String date});

  Future<PresentStudentsData> getPresentStudents({
    required int classId,
    required String session,
    required String date,
  });

  Future<QuickQuestionData> getQuickQuestion({
    required int classId,
    required String session,
    required String date,
  });

  Future<QuickQuestionData> selectQuickQuestionStudents({
    required int classId,
    required String session,
    required String date,
    required List<int> studentIds,
    String? question,
    String? note,
  });

  Future<QuickQuestionData> rateQuickQuestion({
    required int classId,
    required String session,
    required String date,
    required Map<int, QuickQuestionRating> ratings,
  });

  Future<RandomPickResult> getRandomPick({
    required int classId,
    required String session,
    required String date,
  });

  Future<RandomPickResult> pickRandomStudents({
    required int classId,
    required String session,
    required String date,
    required int count,
  });

  Future<ClassSeatMapData> getSeatMap({required int classId});

  Future<ClassSeatMapData> saveSeatMap({
    required int classId,
    required int rows,
    required int cols,
    required List<SeatAssignment> assignments,
  });

  Future<SessionSummaryData> getSessionSummary({
    required int classId,
    required String session,
    required String date,
  });

  Future<SessionSummaryData> saveSessionSummary({
    required int classId,
    required String session,
    required String date,
    required List<String> selectedElements,
    required int evidenceCategoryId,
  });

  Future<List<TeacherToolEvidenceCategory>> getEvidenceCategories();
}

class ApiTeacherToolsRepository implements TeacherToolsRepository {
  ApiTeacherToolsRepository(this._apiService);

  final ApiService _apiService;

  @override
  Future<QuickQuestionGame> getQuickQuestionGame(
      {required int classId,
      required String session,
      required String date}) async {
    final response = await _apiService.get(
        Endpoints.sessionToolsQuickQuestionGame,
        parameters: _slotParameters(classId, session, date));
    _ensureSuccess(response.success, response.message);
    return QuickQuestionGame.fromJson(_asMap(response.data));
  }

  Future<QuickQuestionGame> _mutateGame(String endpoint, int classId,
      String session, String date, Map<String, dynamic> body) async {
    final response = await _apiService
        .post(endpoint, {..._slotParameters(classId, session, date), ...body});
    _ensureSuccess(response.success, response.message);
    // Fetch the authoritative state even when the mutation only returns an acknowledgement.
    return getQuickQuestionGame(classId: classId, session: session, date: date);
  }

  @override
  Future<QuickQuestionGame> startQuickQuestionGame(
          {required int classId,
          required String session,
          required String date,
          required List<int> studentIds}) =>
      _mutateGame(Endpoints.sessionToolsQuickQuestionGame, classId, session,
          date, {'student_ids': studentIds});

  @override
  Future<QuickQuestionGame> scoreQuickQuestionGame(
      {required int classId,
      required String session,
      required String date,
      required String action,
      int? studentId}) {
    if (!{'award', 'skip', 'undo'}.contains(action) ||
        (action == 'award' && studentId == null)) {
      throw ArgumentError('Invalid quick question action');
    }
    return _mutateGame(
        Endpoints.sessionToolsQuickQuestionScore,
        classId,
        session,
        date,
        {'action': action, if (studentId != null) 'student_id': studentId});
  }

  @override
  Future<QuickQuestionGame> finishQuickQuestionGame(
          {required int classId,
          required String session,
          required String date}) =>
      _mutateGame(Endpoints.sessionToolsQuickQuestionFinish, classId, session,
          date, {});

  @override
  Future<PresentStudentsData> getPresentStudents({
    required int classId,
    required String session,
    required String date,
  }) async {
    final response = await _apiService.get(
      Endpoints.sessionToolsPresentStudents,
      parameters: _slotParameters(classId, session, date),
    );
    _ensureSuccess(response.success, response.message);
    return PresentStudentsData.fromJson(_asMap(response.data));
  }

  @override
  Future<QuickQuestionData> getQuickQuestion({
    required int classId,
    required String session,
    required String date,
  }) async {
    final response = await _apiService.get(
      Endpoints.sessionToolsQuickQuestion,
      parameters: _slotParameters(classId, session, date),
    );
    _ensureSuccess(response.success, response.message);
    return QuickQuestionData.fromJson(_asMap(response.data));
  }

  @override
  Future<QuickQuestionData> selectQuickQuestionStudents({
    required int classId,
    required String session,
    required String date,
    required List<int> studentIds,
    String? question,
    String? note,
  }) async {
    final response = await _apiService.post(
      Endpoints.sessionToolsQuickQuestion,
      {
        ..._slotParameters(classId, session, date),
        'student_ids': studentIds,
        if (question?.trim().isNotEmpty == true) 'question': question!.trim(),
        if (note?.trim().isNotEmpty == true) 'note': note!.trim(),
      },
    );
    _ensureSuccess(response.success, response.message);
    return QuickQuestionData.fromJson(_asMap(response.data));
  }

  @override
  Future<QuickQuestionData> rateQuickQuestion({
    required int classId,
    required String session,
    required String date,
    required Map<int, QuickQuestionRating> ratings,
  }) async {
    final response = await _apiService.post(
      Endpoints.sessionToolsQuickQuestionRate,
      {
        ..._slotParameters(classId, session, date),
        'answers': [
          for (final entry in ratings.entries)
            {'student_id': entry.key, 'rating': entry.value.apiValue},
        ],
      },
    );
    _ensureSuccess(response.success, response.message);
    return QuickQuestionData.fromJson(_asMap(response.data));
  }

  @override
  Future<RandomPickResult> getRandomPick({
    required int classId,
    required String session,
    required String date,
  }) async {
    final response = await _apiService.get(
      Endpoints.sessionToolsRandomPick,
      parameters: _slotParameters(classId, session, date),
    );
    _ensureSuccess(response.success, response.message);
    return RandomPickResult.fromJson(_asMap(response.data));
  }

  @override
  Future<RandomPickResult> pickRandomStudents({
    required int classId,
    required String session,
    required String date,
    required int count,
  }) async {
    final response = await _apiService.post(
      Endpoints.sessionToolsRandomPick,
      {..._slotParameters(classId, session, date), 'count': count},
    );
    _ensureSuccess(response.success, response.message);
    return RandomPickResult.fromJson(_asMap(response.data));
  }

  @override
  Future<ClassSeatMapData> getSeatMap({required int classId}) async {
    final response = await _apiService.get(
      Endpoints.sessionToolsSeats,
      parameters: {'class_id': classId},
    );
    _ensureSuccess(response.success, response.message);
    return ClassSeatMapData.fromJson(_asMap(response.data));
  }

  @override
  Future<ClassSeatMapData> saveSeatMap({
    required int classId,
    required int rows,
    required int cols,
    required List<SeatAssignment> assignments,
  }) async {
    final response = await _apiService.post(
      Endpoints.sessionToolsSeats,
      {
        'class_id': classId,
        'rows': rows,
        'cols': cols,
        'assignments': [
          for (final assignment in assignments)
            {
              'student_id': assignment.student.id,
              'row': assignment.row,
              'col': assignment.col,
            },
        ],
      },
    );
    _ensureSuccess(response.success, response.message);
    return ClassSeatMapData.fromJson(_asMap(response.data));
  }

  @override
  Future<SessionSummaryData> getSessionSummary({
    required int classId,
    required String session,
    required String date,
  }) async {
    final response = await _apiService.get(
      Endpoints.sessionToolsSummary,
      parameters: _slotParameters(classId, session, date),
    );
    _ensureSuccess(response.success, response.message);
    return SessionSummaryData.fromJson(_asMap(response.data));
  }

  @override
  Future<SessionSummaryData> saveSessionSummary({
    required int classId,
    required String session,
    required String date,
    required List<String> selectedElements,
    required int evidenceCategoryId,
  }) async {
    final response = await _apiService.post(
      Endpoints.sessionToolsSummary,
      {
        ..._slotParameters(classId, session, date),
        'selected_elements': selectedElements,
        'evidence_category_id': evidenceCategoryId,
      },
    );
    _ensureSuccess(response.success, response.message);
    return SessionSummaryData.fromJson(_asMap(response.data));
  }

  @override
  Future<List<TeacherToolEvidenceCategory>> getEvidenceCategories() async {
    final response =
        await _apiService.get(Endpoints.performanceEvidenceCategories);
    _ensureSuccess(response.success, response.message);
    return _flattenEvidenceCategories(_asList(response.data));
  }

  Map<String, dynamic> _slotParameters(
    int classId,
    String session,
    String date,
  ) =>
      {'class_id': classId, 'session': session, 'date': date};

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map) return Map<String, dynamic>.from(value);
    throw ServerException(null);
  }

  List<Map<String, dynamic>> _asList(dynamic value) {
    dynamic items = value;
    if (value is Map) items = value['results'] ?? value['data'];
    if (items is! List) throw ServerException(null);
    return items
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList(growable: false);
  }

  List<TeacherToolEvidenceCategory> _flattenEvidenceCategories(
    List<Map<String, dynamic>> items, [
    String parentName = '',
  ]) {
    final categories = <TeacherToolEvidenceCategory>[];
    for (final item in items) {
      final category = TeacherToolEvidenceCategory.fromJson(item);
      if (category.id <= 0 || category.name.isEmpty) continue;
      final children = readMapList(item['subcategories']);
      final label =
          parentName.isEmpty ? category.name : '$parentName — ${category.name}';
      if (children.isEmpty) {
        categories.add(
          TeacherToolEvidenceCategory(id: category.id, name: label),
        );
      } else {
        categories.addAll(_flattenEvidenceCategories(children, label));
      }
    }
    return categories;
  }

  void _ensureSuccess(bool? success, String? message) {
    if (success != true) throw ServerException(message);
  }
}
