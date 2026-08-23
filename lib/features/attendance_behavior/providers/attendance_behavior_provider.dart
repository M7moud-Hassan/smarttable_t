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
    this.selectedAttendanceIds = const {},
    this.selectedBehaviorIds = const {},
    this.selectedAttendanceStatus = AttendanceStatus.present,
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
  final Set<int> selectedAttendanceIds;
  final Set<int> selectedBehaviorIds;
  final AttendanceStatus selectedAttendanceStatus;
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
    Set<int>? selectedAttendanceIds,
    Set<int>? selectedBehaviorIds,
    AttendanceStatus? selectedAttendanceStatus,
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
      selectedAttendanceIds:
          selectedAttendanceIds ?? this.selectedAttendanceIds,
      selectedBehaviorIds: selectedBehaviorIds ?? this.selectedBehaviorIds,
      selectedAttendanceStatus:
          selectedAttendanceStatus ?? this.selectedAttendanceStatus,
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

  Future<void> load() async {
    state = state.copyWith(loading: true, errorMessage: null);
    try {
      final filters = await _repository.getFilters();
      final availableClasses =
          filters.classes.where((item) => item.id != null).toList();
      if (availableClasses.isEmpty || filters.sessions.isEmpty) {
        state = state.copyWith(
          filters: filters,
          students: const [],
          behaviorNotes: await _repository.getBehaviorNotes(),
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
        selectedClassId: classId,
        selectedSession: session,
      );
      await _loadData(classId: classId, session: session);
    } catch (error) {
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
    final previousState = state;
    state = state.copyWith(
      selectedClassId: classId,
      selectedSession: session,
      selectedDate: date,
      selectedAttendanceIds: const {},
      selectedBehaviorIds: const {},
      loading: true,
      errorMessage: null,
    );
    try {
      await _loadData(classId: classId, session: session, date: date);
    } catch (error) {
      state = previousState.copyWith(
        loading: false,
        errorMessage: perseveranceErrorMessage(error),
      );
      rethrow;
    }
  }

  Future<void> _loadData({
    required int classId,
    required String session,
    String? date,
  }) async {
    final results = await Future.wait<dynamic>([
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
    ]);
    final attendance = results[0] as AttendanceRosterData;
    final behavior = results[1] as BehaviorRosterData;
    final notes = results[2] as List<BehaviorNoteModel>;
    state = state.copyWith(
      attendanceRoster: attendance,
      behaviorRoster: behavior,
      students: _mergeStudents(attendance, behavior),
      behaviorNotes: notes,
      selectedDate: attendance.date,
      selectedBehaviorNoteId:
          notes.isEmpty ? null : state.selectedBehaviorNoteId ?? notes.first.id,
      loading: false,
      saving: false,
      errorMessage: null,
    );
  }

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
    if (status == AttendanceStatus.notRecorded) return;
    state = state.copyWith(selectedAttendanceStatus: status);
  }

  Future<void> saveAttendance() async {
    final classId = state.selectedClassId;
    final session = state.selectedSession;
    if (classId == null ||
        session == null ||
        state.selectedAttendanceIds.isEmpty) {
      return;
    }
    state = state.copyWith(saving: true, errorMessage: null);
    try {
      await _repository.saveAttendance(
        classId: classId,
        session: session,
        studentIds: state.selectedAttendanceIds.toList(),
        status: state.selectedAttendanceStatus,
        date: state.selectedDate,
      );
      state = state.copyWith(selectedAttendanceIds: const {});
      await _loadData(
        classId: classId,
        session: session,
        date: state.selectedDate,
      );
    } catch (error) {
      state = state.copyWith(
        saving: false,
        errorMessage: perseveranceErrorMessage(error),
      );
      rethrow;
    }
  }

  void toggleBehaviorStudent(int studentId) {
    final selected = {...state.selectedBehaviorIds};
    selected.contains(studentId)
        ? selected.remove(studentId)
        : selected.add(studentId);
    state = state.copyWith(selectedBehaviorIds: selected);
  }

  void toggleAllBehaviorStudents(bool selected) {
    state = state.copyWith(
      selectedBehaviorIds:
          selected ? state.students.map((student) => student.id).toSet() : {},
    );
  }

  void selectBehaviorNote(int noteId) {
    state = state.copyWith(selectedBehaviorNoteId: noteId);
  }

  Future<void> saveBehaviorAssignment() async {
    final classId = state.selectedClassId;
    final session = state.selectedSession;
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
      assignments[student.id] = {...student.behaviorNoteIds, noteId}.toList();
    }
    state = state.copyWith(saving: true, errorMessage: null);
    try {
      await _repository.saveBehavior(
        classId: classId,
        session: session,
        studentNoteIds: assignments,
        date: state.selectedDate,
      );
      state = state.copyWith(selectedBehaviorIds: const {});
      await _loadData(
        classId: classId,
        session: session,
        date: state.selectedDate,
      );
    } catch (error) {
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

String perseveranceErrorMessage(Object error) {
  if (error is ServerException &&
      error.message != null &&
      error.message!.trim().isNotEmpty) {
    return error.message!;
  }
  return 'تعذر تحميل البيانات، حاول مرة أخرى';
}
