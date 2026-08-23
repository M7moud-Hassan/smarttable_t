import 'dart:convert' show jsonDecode, utf8;

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/core/constants/endpoints.dart';
import 'package:smart_table_app/core/providers/api_service_provider.dart';
import 'package:smart_table_app/core/service/api_service.dart';
import 'package:smart_table_app/core/utils/exceptions.dart';
import 'package:smart_table_app/features/attendance_behavior/data/models/attendance_behavior_models.dart';

final perseveranceRepositoryProvider = Provider<PerseveranceRepository>((ref) {
  return ApiPerseveranceRepository(ref.read(apiServiceProvider));
});

abstract class PerseveranceRepository {
  Future<PerseveranceFilters> getFilters();

  Future<AttendanceRosterData> getAttendanceRoster({
    required int classId,
    required String session,
    String? date,
  });

  Future<void> saveAttendance({
    required int classId,
    required String session,
    required List<int> studentIds,
    required AttendanceStatus status,
    String? date,
  });

  Future<BehaviorRosterData> getBehaviorRoster({
    required int classId,
    required String session,
    String? date,
  });

  Future<void> saveBehavior({
    required int classId,
    required String session,
    required Map<int, List<int>> studentNoteIds,
    String? date,
  });

  Future<List<BehaviorNoteModel>> getBehaviorNotes({
    BehaviorNoteType? type,
    String? search,
  });

  Future<BehaviorNoteModel> createBehaviorNote(BehaviorNoteModel note);

  Future<BehaviorNoteModel> updateBehaviorNote(BehaviorNoteModel note);

  Future<void> deleteBehaviorNote(int noteId);

  Future<StudentAttendanceHistory> getStudentAttendance({
    required int studentId,
    String period = 'month',
  });

  Future<StudentBehaviorHistory> getStudentBehavior({
    required int studentId,
    String period = 'month',
  });

  Future<List<StudentProcedureModel>> getProcedures({
    required int studentId,
    String period = 'month',
  });

  Future<List<PerseveranceOption>> getProcedureTypes();

  Future<StudentProcedureModel> createProcedure({
    required int studentId,
    required String procedureType,
    required String source,
    required String reason,
    int? classId,
    String? session,
    String? date,
    int? attendanceRecordId,
    int? behaviorRecordId,
  });

  Future<AttendanceReportData> getAttendanceReport(ReportQuery query);

  Future<BehaviorReportData> getBehaviorReport(ReportQuery query);

  Future<ReportOptions> getReportOptions();

  Future<PerseveranceExportFile> exportReport({
    required String reportType,
    required String fileFormat,
    required ReportQuery query,
  });
}

class ApiPerseveranceRepository implements PerseveranceRepository {
  ApiPerseveranceRepository(this._apiService);

  final ApiService _apiService;

  @override
  Future<PerseveranceFilters> getFilters() async {
    final response = await _apiService.get(Endpoints.perseveranceFilters);
    _ensureSuccess(response.success, response.message);
    return PerseveranceFilters.fromJson(_asMap(response.data));
  }

  @override
  Future<AttendanceRosterData> getAttendanceRoster({
    required int classId,
    required String session,
    String? date,
  }) async {
    final response = await _apiService.get(
      Endpoints.perseveranceAttendance,
      parameters: {
        'class_id': classId,
        'session': session,
        if (date != null && date.isNotEmpty) 'date': date,
      },
    );
    _ensureSuccess(response.success, response.message);
    return AttendanceRosterData.fromJson(_asMap(response.data));
  }

  @override
  Future<void> saveAttendance({
    required int classId,
    required String session,
    required List<int> studentIds,
    required AttendanceStatus status,
    String? date,
  }) async {
    final response = await _apiService.post(
      Endpoints.perseveranceAttendance,
      {
        'class_id': classId,
        'session': session,
        if (date != null && date.isNotEmpty) 'date': date,
        'students': [
          for (final studentId in studentIds)
            {
              'student_id': studentId,
              'attendance': status.apiValue,
            },
        ],
      },
    );
    _ensureSuccess(response.success, response.message);
  }

  @override
  Future<BehaviorRosterData> getBehaviorRoster({
    required int classId,
    required String session,
    String? date,
  }) async {
    final response = await _apiService.get(
      Endpoints.perseveranceBehavior,
      parameters: {
        'class_id': classId,
        'session': session,
        if (date != null && date.isNotEmpty) 'date': date,
      },
    );
    _ensureSuccess(response.success, response.message);
    return BehaviorRosterData.fromJson(_asMap(response.data));
  }

  @override
  Future<void> saveBehavior({
    required int classId,
    required String session,
    required Map<int, List<int>> studentNoteIds,
    String? date,
  }) async {
    final response = await _apiService.post(
      Endpoints.perseveranceBehavior,
      {
        'class_id': classId,
        'session': session,
        if (date != null && date.isNotEmpty) 'date': date,
        'students': [
          for (final entry in studentNoteIds.entries)
            {'student_id': entry.key, 'note_ids': entry.value},
        ],
      },
    );
    _ensureSuccess(response.success, response.message);
  }

  @override
  Future<List<BehaviorNoteModel>> getBehaviorNotes({
    BehaviorNoteType? type,
    String? search,
  }) async {
    final response = await _apiService.get(
      Endpoints.perseveranceBehaviorNotes,
      parameters: {
        if (type != null) 'note_type': type.apiValue,
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      },
    );
    _ensureSuccess(response.success, response.message);
    return _asList(response.data)
        .map(BehaviorNoteModel.fromJson)
        .toList(growable: false);
  }

  @override
  Future<BehaviorNoteModel> createBehaviorNote(BehaviorNoteModel note) async {
    final response = await _apiService.post(
      Endpoints.perseveranceBehaviorNotes,
      note.toWriteJson(),
    );
    _ensureSuccess(response.success, response.message);
    return BehaviorNoteModel.fromJson(_asMap(response.data));
  }

  @override
  Future<BehaviorNoteModel> updateBehaviorNote(BehaviorNoteModel note) async {
    final response = await _apiService.patch(
      Endpoints.perseveranceBehaviorNote(note.id),
      note.toWriteJson(),
    );
    _ensureSuccess(response.success, response.message);
    return BehaviorNoteModel.fromJson(_asMap(response.data));
  }

  @override
  Future<void> deleteBehaviorNote(int noteId) async {
    final response = await _apiService.delete(
      Endpoints.perseveranceBehaviorNote(noteId),
    );
    _ensureSuccess(response.success, response.message);
  }

  @override
  Future<StudentAttendanceHistory> getStudentAttendance({
    required int studentId,
    String period = 'month',
  }) async {
    final response = await _apiService.get(
      Endpoints.perseveranceStudentAttendance(studentId),
      parameters: {'period': period},
    );
    _ensureSuccess(response.success, response.message);
    return StudentAttendanceHistory.fromJson(_asMap(response.data));
  }

  @override
  Future<StudentBehaviorHistory> getStudentBehavior({
    required int studentId,
    String period = 'month',
  }) async {
    final response = await _apiService.get(
      Endpoints.perseveranceStudentBehavior(studentId),
      parameters: {'period': period},
    );
    _ensureSuccess(response.success, response.message);
    return StudentBehaviorHistory.fromJson(_asMap(response.data));
  }

  @override
  Future<List<StudentProcedureModel>> getProcedures({
    required int studentId,
    String period = 'month',
  }) async {
    final response = await _apiService.get(
      Endpoints.perseveranceProcedures,
      parameters: {'student_id': studentId, 'period': period},
    );
    _ensureSuccess(response.success, response.message);
    return _asList(response.data)
        .map(StudentProcedureModel.fromJson)
        .toList(growable: false);
  }

  @override
  Future<List<PerseveranceOption>> getProcedureTypes() async {
    final response =
        await _apiService.get(Endpoints.perseveranceProcedureTypes);
    _ensureSuccess(response.success, response.message);
    return _asList(response.data)
        .map(PerseveranceOption.fromJson)
        .toList(growable: false);
  }

  @override
  Future<StudentProcedureModel> createProcedure({
    required int studentId,
    required String procedureType,
    required String source,
    required String reason,
    int? classId,
    String? session,
    String? date,
    int? attendanceRecordId,
    int? behaviorRecordId,
  }) async {
    final response = await _apiService.post(
      Endpoints.perseveranceProcedures,
      {
        'student_id': studentId,
        'procedure_type': procedureType,
        'source': source,
        if (reason.trim().isNotEmpty) 'reason': reason.trim(),
        if (classId != null) 'class_id': classId,
        if (session != null && session.isNotEmpty) 'session': session,
        if (date != null && date.isNotEmpty) 'date': date,
        if (attendanceRecordId != null)
          'attendance_record_id': attendanceRecordId,
        if (behaviorRecordId != null) 'behavior_record_id': behaviorRecordId,
      },
    );
    _ensureSuccess(response.success, response.message);
    return StudentProcedureModel.fromJson(_asMap(response.data));
  }

  @override
  Future<AttendanceReportData> getAttendanceReport(ReportQuery query) async {
    final response = await _apiService.get(
      Endpoints.perseveranceAttendanceReport,
      parameters: query.toParameters(),
    );
    _ensureSuccess(response.success, response.message);
    return AttendanceReportData.fromJson(_asMap(response.data));
  }

  @override
  Future<BehaviorReportData> getBehaviorReport(ReportQuery query) async {
    final response = await _apiService.get(
      Endpoints.perseveranceBehaviorReport,
      parameters: query.toParameters(),
    );
    _ensureSuccess(response.success, response.message);
    return BehaviorReportData.fromJson(_asMap(response.data));
  }

  @override
  Future<ReportOptions> getReportOptions() async {
    final response = await _apiService.get(Endpoints.perseveranceReportOptions);
    _ensureSuccess(response.success, response.message);
    return ReportOptions.fromJson(_asMap(response.data));
  }

  @override
  Future<PerseveranceExportFile> exportReport({
    required String reportType,
    required String fileFormat,
    required ReportQuery query,
  }) async {
    final response = await _apiService.getRaw(
      Endpoints.perseveranceReportExport,
      parameters: {
        'report_type': reportType,
        'file_format': fileFormat,
        ...query.toParameters(),
      },
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      String? message;
      try {
        final decoded = jsonDecode(utf8.decode(response.bodyBytes));
        if (decoded is Map) {
          message =
              (decoded['message'] ?? decoded['detail'] ?? decoded['error'])
                  ?.toString();
        }
      } catch (_) {}
      throw ServerException(message);
    }

    final disposition = response.headers['content-disposition'] ?? '';
    final match = RegExp(r'''filename\*?=(?:UTF-8''|["'])?([^"';]+)''')
        .firstMatch(disposition);
    final extension = fileFormat == 'excel' ? 'xlsx' : 'pdf';
    final responseFileName = match?.group(1)?.trim() ??
        'perseverance_${reportType}_${DateTime.now().millisecondsSinceEpoch}.$extension';
    String decodedFileName;
    try {
      decodedFileName = Uri.decodeComponent(responseFileName);
    } catch (_) {
      decodedFileName = responseFileName;
    }
    final fileName = decodedFileName
        .replaceAll('/', '_')
        .replaceAll('\\', '_')
        .replaceAll('\u0000', '');
    return PerseveranceExportFile(
      bytes: response.bodyBytes,
      fileName: fileName,
    );
  }

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

  void _ensureSuccess(bool? success, String? message) {
    if (success != true) throw ServerException(message);
  }
}
