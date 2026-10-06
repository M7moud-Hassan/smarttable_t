import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/core/utils/exceptions.dart';
import 'package:smart_table_app/features/attendance_behavior/data/models/attendance_behavior_models.dart';
import 'package:smart_table_app/features/attendance_behavior/data/repositories/perseverance_repository.dart';

final attendanceBehaviorProvider = StateNotifierProvider.autoDispose<
    AttendanceBehaviorNotifier, AttendanceBehaviorState>((ref) {
  final notifier = AttendanceBehaviorNotifier(
    ref.read(perseveranceRepositoryProvider),
  );
  Future.microtask(notifier.load);
  return notifier;
});

class AttendanceBehaviorState {
  const AttendanceBehaviorState({
    this.filters,
    this.attendanceRoster,
    this.behaviorRoster,
    this.students = const [],
    this.behaviorNotes = const [],
    this.attendanceNoteCodes = const [],
    this.attendanceNoteDrafts = const {},
    this.selectedAttendanceIds = const {},
    this.selectedBehaviorIds = const {},
    this.selectedAttendanceStatus,
    this.selectedBehaviorNoteId,
    this.selectedClassId,
    this.selectedSession,
    this.selectedDate,
    this.loading = true,
    this.saving = false,
    this.errorMessage,
  });

  final PerseveranceFilters? filters;
  final AttendanceRosterData? attendanceRoster;
  final BehaviorRosterData? behaviorRoster;
  final List<AttendanceBehaviorStudent> students;
  final List<BehaviorNoteModel> behaviorNotes;
  final List<PerseveranceOption> attendanceNoteCodes;
  final Map<int, AttendanceNoteDraft> attendanceNoteDrafts;
  final Set<int> selectedAttendanceIds;
  final Set<int> selectedBehaviorIds;
  final AttendanceStatus? selectedAttendanceStatus;
  final int? selectedBehaviorNoteId;
  final int? selectedClassId;
  final String? selectedSession;
  final String? selectedDate;
  final bool loading;
  final bool saving;
  final String? errorMessage;

  AttendanceBehaviorState copyWith({
    PerseveranceFilters? filters,
    AttendanceRosterData? attendanceRoster,
    BehaviorRosterData? behaviorRoster,
    List<AttendanceBehaviorStudent>? students,
    List<BehaviorNoteModel>? behaviorNotes,
    List<PerseveranceOption>? attendanceNoteCodes,
    Map<int, AttendanceNoteDraft>? attendanceNoteDrafts,
    Set<int>? selectedAttendanceIds,
    Set<int>? selectedBehaviorIds,
    Object? selectedAttendanceStatus = _unchanged,
    Object? selectedBehaviorNoteId = _unchanged,
    int? selectedClassId,
    String? selectedSession,
    Object? selectedDate = _unchanged,
    bool? loading,
    bool? saving,
    Object? errorMessage = _unchanged,
  }) {
    return AttendanceBehaviorState(
      filters: filters ?? this.filters,
      attendanceRoster: attendanceRoster ?? this.attendanceRoster,
      behaviorRoster: behaviorRoster ?? this.behaviorRoster,
      students: students ?? this.students,
      behaviorNotes: behaviorNotes ?? this.behaviorNotes,
      attendanceNoteCodes: attendanceNoteCodes ?? this.attendanceNoteCodes,
      attendanceNoteDrafts: attendanceNoteDrafts ?? this.attendanceNoteDrafts,
      selectedAttendanceIds:
          selectedAttendanceIds ?? this.selectedAttendanceIds,
      selectedBehaviorIds: selectedBehaviorIds ?? this.selectedBehaviorIds,
      selectedAttendanceStatus: identical(selectedAttendanceStatus, _unchanged)
          ? this.selectedAttendanceStatus
          : selectedAttendanceStatus as AttendanceStatus?,
      selectedBehaviorNoteId: identical(selectedBehaviorNoteId, _unchanged)
          ? this.selectedBehaviorNoteId
          : selectedBehaviorNoteId as int?,
      selectedClassId: selectedClassId ?? this.selectedClassId,
      selectedSession: selectedSession ?? this.selectedSession,
      selectedDate: identical(selectedDate, _unchanged)
          ? this.selectedDate
          : selectedDate as String?,
      loading: loading ?? this.loading,
      saving: saving ?? this.saving,
      errorMessage: identical(errorMessage, _unchanged)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}

const _unchanged = Object();

class AttendanceBehaviorNotifier
    extends StateNotifier<AttendanceBehaviorState> {
  AttendanceBehaviorNotifier(this._repository)
      : super(const AttendanceBehaviorState());

  final PerseveranceRepository _repository;
  int _contextRevision = 0;
  int _latestLoadRequest = 0;

  Future<void> load() async {
    final contextRevision = ++_contextRevision;
    state = state.copyWith(loading: true, saving: false, errorMessage: null);
    try {
      final filters = await _repository.getFilters();
      if (contextRevision != _contextRevision) return;

      final availableClasses =
          filters.classes.where((item) => item.id != null).toList();
      if (availableClasses.isEmpty || filters.sessions.isEmpty) {
        final behaviorNotes = await _repository.getBehaviorNotes();
        if (contextRevision != _contextRevision) return;
        state = state.copyWith(
          filters: filters,
          selectedAttendanceStatus: _initialAttendanceStatus(filters),
          students: const [],
          behaviorNotes: behaviorNotes,
          loading: false,
        );
        return;
      }

      final classId = availableClasses.any(
        (item) => item.id == state.selectedClassId,
      )
          ? state.selectedClassId!
          : availableClasses.first.id!;
      final session = filters.sessions.any(
        (item) => item.value == state.selectedSession,
      )
          ? state.selectedSession!
          : filters.sessions.first.value;
      state = state.copyWith(
        filters: filters,
        selectedAttendanceStatus: _initialAttendanceStatus(filters),
        selectedClassId: classId,
        selectedSession: session,
      );
      await _loadData(
        classId: classId,
        session: session,
        date: state.selectedDate,
        contextRevision: contextRevision,
      );
    } catch (error) {
      if (contextRevision != _contextRevision) return;
      state = state.copyWith(
        loading: false,
        errorMessage: perseveranceErrorMessage(error),
      );
    }
  }

  Future<void> changeContext({
    required int classId,
    required String session,
    String? date,
  }) async {
    final contextRevision = ++_contextRevision;
    final previousState = state;
    state = state.copyWith(
      selectedClassId: classId,
      selectedSession: session,
      selectedDate: date,
      selectedAttendanceIds: const {},
      selectedBehaviorIds: const {},
      attendanceNoteDrafts: const {},
      loading: true,
      saving: false,
      errorMessage: null,
    );
    try {
      await _loadData(
        classId: classId,
        session: session,
        date: date,
        contextRevision: contextRevision,
      );
    } catch (error) {
      if (contextRevision != _contextRevision) return;
      state = previousState.copyWith(
        loading: false,
        saving: false,
        errorMessage: perseveranceErrorMessage(error),
      );
      rethrow;
    }
  }

  Future<void> _loadData({
    required int classId,
    required String session,
    String? date,
    required int contextRevision,
  }) async {
    if (!_isCurrentContext(classId, session, contextRevision)) return;
    final loadRequest = ++_latestLoadRequest;
    late final List<dynamic> results;
    try {
      results = await Future.wait<dynamic>([
        _repository.getAttendanceRoster(
          classId: classId,
          session: session,
          date: date,
        ),
        _repository.getBehaviorRoster(
          classId: classId,
          session: session,
          date: date,
        ),
        _repository.getBehaviorNotes(),
        _repository
            .getAttendanceNoteCodes()
            .catchError((Object _) => <PerseveranceOption>[]),
      ]);
    } catch (_) {
      if (loadRequest != _latestLoadRequest ||
          !_isCurrentContext(classId, session, contextRevision)) {
        return;
      }
      rethrow;
    }
    final attendance = results[0] as AttendanceRosterData;
    final behavior = results[1] as BehaviorRosterData;
    final notes = results[2] as List<BehaviorNoteModel>;
    final attendanceNoteCodes = results[3] as List<PerseveranceOption>;
    if (loadRequest != _latestLoadRequest ||
        !_isCurrentContext(classId, session, contextRevision)) {
      return;
    }
    state = state.copyWith(
      attendanceRoster: attendance,
      behaviorRoster: behavior,
      students: _mergeStudents(attendance, behavior),
      behaviorNotes: notes,
      attendanceNoteCodes: attendanceNoteCodes,
      selectedDate: attendance.date,
      selectedBehaviorNoteId:
          notes.isEmpty ? null : state.selectedBehaviorNoteId ?? notes.first.id,
      loading: false,
      saving: false,
      errorMessage: null,
    );
  }

  bool _isCurrentContext(int classId, String session, int contextRevision) =>
      contextRevision == _contextRevision &&
      classId == state.selectedClassId &&
      session == state.selectedSession;

  List<AttendanceBehaviorStudent> _mergeStudents(
    AttendanceRosterData attendance,
    BehaviorRosterData behavior,
  ) {
    final behaviorStudents = {
      for (final student in behavior.students) student.studentId: student,
    };
    return attendance.students.map((student) {
      final behaviorStudent = behaviorStudents[student.id];
      return AttendanceBehaviorStudent(
        id: student.id,
        name: student.name,
        numberStudent: student.numberStudent,
        classId: attendance.classId,
        className: attendance.className,
        attendanceStatus: student.attendanceStatus,
        attendanceRecordId: student.attendanceRecordId,
        attendanceNote: student.attendanceNote,
        behaviorRecordId: behaviorStudent?.recordId,
        teacherCanModifyBehavior: behaviorStudent?.teacherCanModify ?? false,
        behaviorNoteIds:
            behaviorStudent?.notes.map((note) => note.id).toList() ?? const [],
        additionalBehaviorNotes: behaviorStudent?.additionalNotes ?? '',
        totalBehaviorPoints: behaviorStudent?.totalPoints ?? 0,
        proceduresCount: behaviorStudent == null
            ? student.proceduresCount
            : behaviorStudent.proceduresCount,
      );
    }).toList(growable: false);
  }

  void toggleAttendanceStudent(int studentId) {
    final selected = {...state.selectedAttendanceIds};
    selected.contains(studentId)
        ? selected.remove(studentId)
        : selected.add(studentId);
    state = state.copyWith(selectedAttendanceIds: selected);
  }

  void toggleAllAttendanceStudents(bool selected) {
    state = state.copyWith(
      selectedAttendanceIds:
          selected ? state.students.map((student) => student.id).toSet() : {},
    );
  }

  void setAttendanceStatus(AttendanceStatus status) {
    if (!_isAttendanceStatusAllowed(status)) return;
    state = state.copyWith(selectedAttendanceStatus: status);
  }

  void setAttendanceNoteCode({
    required int studentId,
    required String? noteCode,
    String note = '',
    bool isCustom = false,
  }) {
    final drafts = {...state.attendanceNoteDrafts};
    if (noteCode == null && !isCustom && note.isEmpty) {
      drafts.remove(studentId);
    } else {
      drafts[studentId] = AttendanceNoteDraft(
        note: note,
        noteCode: noteCode,
        isCustom: isCustom,
      );
    }
    state = state.copyWith(attendanceNoteDrafts: drafts);
  }

  void setAttendanceNoteText({
    required int studentId,
    required String note,
  }) {
    setAttendanceNoteCode(
      studentId: studentId,
      noteCode: null,
      note: note,
      isCustom: true,
    );
  }

  Future<void> saveAttendance() async {
    final classId = state.selectedClassId;
    final session = state.selectedSession;
    final date = state.selectedDate;
    final contextRevision = _contextRevision;
    final studentIds = state.selectedAttendanceIds.toList(growable: false);
    final status = state.selectedAttendanceStatus;
    final attendanceNoteDrafts = state.attendanceNoteDrafts;
    if (classId == null ||
        session == null ||
        status == null ||
        !_isAttendanceStatusAllowed(status) ||
        studentIds.isEmpty) {
      return;
    }
    state = state.copyWith(saving: true, errorMessage: null);
    try {
      await _repository.saveAttendance(
        classId: classId,
        session: session,
        studentIds: studentIds,
        status: status,
        notes: {
          for (final studentId in studentIds)
            if (attendanceNoteDrafts[studentId] != null)
              studentId: attendanceNoteDrafts[studentId]!,
        },
        date: date,
      );
      if (contextRevision != _contextRevision) return;
      state = state.copyWith(
        selectedAttendanceIds: const {},
        attendanceNoteDrafts: {
          for (final entry in attendanceNoteDrafts.entries)
            if (!studentIds.contains(entry.key)) entry.key: entry.value,
        },
      );
      await _loadData(
        classId: classId,
        session: session,
        date: date,
        contextRevision: contextRevision,
      );
    } catch (error) {
      if (contextRevision != _contextRevision) rethrow;
      state = state.copyWith(
        saving: false,
        errorMessage: perseveranceErrorMessage(error),
      );
      rethrow;
    }
  }

  Future<void> updateStudentAttendance({
    required int studentId,
    required AttendanceStatus status,
  }) async {
    final classId = state.selectedClassId;
    final session = state.selectedSession;
    final date = state.selectedDate;
    final contextRevision = _contextRevision;
    if (classId == null ||
        session == null ||
        !_isAttendanceStatusAllowed(status)) {
      return;
    }
    state = state.copyWith(saving: true, errorMessage: null);
    try {
      await _repository.saveAttendance(
        classId: classId,
        session: session,
        studentIds: [studentId],
        status: status,
        date: date,
      );
      if (contextRevision != _contextRevision) return;
      await _loadData(
        classId: classId,
        session: session,
        date: date,
        contextRevision: contextRevision,
      );
    } catch (error) {
      if (contextRevision != _contextRevision) rethrow;
      state = state.copyWith(
        saving: false,
        errorMessage: perseveranceErrorMessage(error),
      );
      rethrow;
    }
  }

  void toggleBehaviorStudent(int studentId) {
    final student = _studentById(studentId);
    if (student == null || !_canChangeBehavior(student)) return;
    final selected = {...state.selectedBehaviorIds};
    selected.contains(studentId)
        ? selected.remove(studentId)
        : selected.add(studentId);
    state = state.copyWith(selectedBehaviorIds: selected);
  }

  void toggleAllBehaviorStudents(bool selected) {
    final assignableStudentIds = state.students
        .where(_canChangeBehavior)
        .map((student) => student.id)
        .toSet();
    state = state.copyWith(
      selectedBehaviorIds: selected ? assignableStudentIds : {},
    );
  }

  void selectBehaviorNote(int noteId) {
    state = state.copyWith(selectedBehaviorNoteId: noteId);
  }

  Future<void> saveBehaviorAssignment() async {
    final classId = state.selectedClassId;
    final session = state.selectedSession;
    final date = state.selectedDate;
    final contextRevision = _contextRevision;
    final noteId = state.selectedBehaviorNoteId;
    if (classId == null ||
        session == null ||
        noteId == null ||
        state.selectedBehaviorIds.isEmpty) {
      return;
    }
    final assignments = <int, List<int>>{};
    for (final student in state.students) {
      if (!state.selectedBehaviorIds.contains(student.id)) continue;
      if (!_canChangeBehavior(student)) continue;
      assignments[student.id] = {...student.behaviorNoteIds, noteId}.toList();
    }
    if (assignments.isEmpty) return;
    state = state.copyWith(saving: true, errorMessage: null);
    try {
      await _repository.saveBehavior(
        classId: classId,
        session: session,
        studentNoteIds: assignments,
        date: date,
      );
      if (contextRevision != _contextRevision) return;
      state = state.copyWith(selectedBehaviorIds: const {});
      await _loadData(
        classId: classId,
        session: session,
        date: date,
        contextRevision: contextRevision,
      );
    } catch (error) {
      if (contextRevision != _contextRevision) rethrow;
      state = state.copyWith(
        saving: false,
        errorMessage: perseveranceErrorMessage(error),
      );
      rethrow;
    }
  }

  Future<void> updateStudentBehavior({
    required int studentId,
    required List<int> noteIds,
  }) async {
    final student = _studentById(studentId);
    if (student == null ||
        student.behaviorRecordId == null ||
        !student.teacherCanModifyBehavior) {
      throw ServerException('لا يمكنك تعديل هذه الملاحظة');
    }
    if (noteIds.isEmpty) return;
    await _changeBehaviorRecord(
      studentId: studentId,
      noteIds: noteIds,
    );
  }

  Future<void> deleteStudentBehaviorRecord(int studentId) async {
    final student = _studentById(studentId);
    final recordId = student?.behaviorRecordId;
    final classId = state.selectedClassId;
    final session = state.selectedSession;
    final date = state.selectedDate;
    final contextRevision = _contextRevision;
    if (student == null ||
        recordId == null ||
        !student.teacherCanModifyBehavior ||
        classId == null ||
        session == null) {
      throw ServerException('لا يمكنك حذف هذه الملاحظة');
    }
    state = state.copyWith(saving: true, errorMessage: null);
    try {
      await _repository.deleteBehaviorRecord(recordId);
      if (contextRevision != _contextRevision) return;
      await _loadData(
        classId: classId,
        session: session,
        date: date,
        contextRevision: contextRevision,
      );
    } catch (error) {
      if (contextRevision != _contextRevision) rethrow;
      state = state.copyWith(
        saving: false,
        errorMessage: perseveranceErrorMessage(error),
      );
      rethrow;
    }
  }

  AttendanceBehaviorStudent? _studentById(int studentId) {
    for (final student in state.students) {
      if (student.id == studentId) return student;
    }
    return null;
  }

  AttendanceStatus? _initialAttendanceStatus(PerseveranceFilters filters) {
    final allowedStatuses = filters.allowedAttendanceStates
        .map((option) => AttendanceStatus.tryFromApi(option.value)!)
        .toList(growable: false);
    final selectedStatus = state.selectedAttendanceStatus;
    if (selectedStatus != null && allowedStatuses.contains(selectedStatus)) {
      return selectedStatus;
    }
    return allowedStatuses.isEmpty ? null : allowedStatuses.first;
  }

  bool _isAttendanceStatusAllowed(AttendanceStatus status) {
    if (status == AttendanceStatus.notRecorded) return false;
    return state.filters?.allowedAttendanceStates.any(
          (option) => AttendanceStatus.tryFromApi(option.value) == status,
        ) ??
        false;
  }

  bool _canChangeBehavior(AttendanceBehaviorStudent student) =>
      student.behaviorRecordId == null || student.teacherCanModifyBehavior;

  Future<void> _changeBehaviorRecord({
    required int studentId,
    required List<int> noteIds,
  }) async {
    final classId = state.selectedClassId;
    final session = state.selectedSession;
    if (classId == null || session == null) return;
    final date = state.selectedDate;
    final contextRevision = _contextRevision;
    state = state.copyWith(saving: true, errorMessage: null);
    try {
      await _repository.saveBehavior(
        classId: classId,
        session: session,
        studentNoteIds: {studentId: noteIds},
        date: date,
      );
      if (contextRevision != _contextRevision) return;
      await _loadData(
        classId: classId,
        session: session,
        date: date,
        contextRevision: contextRevision,
      );
    } catch (error) {
      if (contextRevision != _contextRevision) rethrow;
      state = state.copyWith(
        saving: false,
        errorMessage: perseveranceErrorMessage(error),
      );
      rethrow;
    }
  }

  Future<void> createBehaviorNote(BehaviorNoteModel note) async {
    await _repository.createBehaviorNote(note);
    await refreshBehaviorNotes();
  }

  Future<void> updateBehaviorNote(BehaviorNoteModel note) async {
    await _repository.updateBehaviorNote(note);
    await refreshBehaviorNotes();
  }

  Future<void> deleteBehaviorNote(int noteId) async {
    await _repository.deleteBehaviorNote(noteId);
    await refreshBehaviorNotes();
  }

  Future<void> refreshBehaviorNotes() async {
    final notes = await _repository.getBehaviorNotes();
    state = state.copyWith(
      behaviorNotes: notes,
      selectedBehaviorNoteId: notes.any(
        (note) => note.id == state.selectedBehaviorNoteId,
      )
          ? state.selectedBehaviorNoteId
          : notes.isEmpty
              ? null
              : notes.first.id,
    );
  }
}

class StudentPeriodQuery {
  const StudentPeriodQuery(this.studentId, this.period);

  final int studentId;
  final String period;

  @override
  bool operator ==(Object other) =>
      other is StudentPeriodQuery &&
      studentId == other.studentId &&
      period == other.period;

  @override
  int get hashCode => Object.hash(studentId, period);
}

final studentAttendanceHistoryProvider = FutureProvider.autoDispose
    .family<StudentAttendanceHistory, StudentPeriodQuery>((ref, query) {
  return ref.read(perseveranceRepositoryProvider).getStudentAttendance(
        studentId: query.studentId,
        period: query.period,
      );
});

final studentBehaviorHistoryProvider = FutureProvider.autoDispose
    .family<StudentBehaviorHistory, StudentPeriodQuery>((ref, query) {
  return ref.read(perseveranceRepositoryProvider).getStudentBehavior(
        studentId: query.studentId,
        period: query.period,
      );
});

final studentProceduresProvider = FutureProvider.autoDispose
    .family<List<StudentProcedureModel>, StudentPeriodQuery>((ref, query) {
  return ref.read(perseveranceRepositoryProvider).getProcedures(
        studentId: query.studentId,
        period: query.period,
      );
});

final procedureTypesProvider =
    FutureProvider.autoDispose<List<PerseveranceOption>>((ref) {
  return ref.read(perseveranceRepositoryProvider).getProcedureTypes();
});

final attendanceReportQueryProvider =
    StateProvider.autoDispose<ReportQuery>((ref) => const ReportQuery());

final behaviorReportQueryProvider =
    StateProvider.autoDispose<ReportQuery>((ref) => const ReportQuery());

final attendanceReportProvider =
    FutureProvider.autoDispose<AttendanceReportData>((ref) {
  final query = ref.watch(attendanceReportQueryProvider);
  return ref.read(perseveranceRepositoryProvider).getAttendanceReport(query);
});

final behaviorReportProvider =
    FutureProvider.autoDispose<BehaviorReportData>((ref) {
  final query = ref.watch(behaviorReportQueryProvider);
  return ref.read(perseveranceRepositoryProvider).getBehaviorReport(query);
});

final reportOptionsProvider = FutureProvider.autoDispose<ReportOptions>((ref) {
  return ref.read(perseveranceRepositoryProvider).getReportOptions();
});

typedef ReportStudentsQuery = ({int classId, String? session});

final reportStudentsProvider = FutureProvider.autoDispose
    .family<List<AttendanceBehaviorStudent>, ReportStudentsQuery>(
        (ref, query) async {
  final repository = ref.read(perseveranceRepositoryProvider);
  final filters = await repository.getFilters();
  if (filters.sessions.isEmpty) {
    throw ServerException('لا توجد حصص متاحة لتحميل الطلاب');
  }
  final session = filters.sessions.any((item) => item.value == query.session)
      ? query.session!
      : filters.sessions.first.value;
  final roster = await repository.getAttendanceRoster(
    classId: query.classId,
    session: session,
  );
  return roster.students;
});

String perseveranceErrorMessage(Object error) {
  if (error is ServerException &&
      error.message != null &&
      error.message!.trim().isNotEmpty) {
    return error.message!;
  }
  return 'تعذر تحميل البيانات، حاول مرة أخرى';
}
