import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/features/attendance_behavior/data/models/attendance_behavior_models.dart';
import 'package:smart_table_app/features/attendance_behavior/presentation/views/attendance_behavior_filter_sheet.dart';
import 'package:smart_table_app/features/attendance_behavior/presentation/views/attendance_panel.dart';
import 'package:smart_table_app/features/attendance_behavior/presentation/views/behavior_panel.dart';
import 'package:smart_table_app/features/attendance_behavior/presentation/views/attendance_behavior_reports_view.dart';
import 'package:smart_table_app/features/attendance_behavior/presentation/widgets/attendance_behavior_state_widgets.dart';
import 'package:smart_table_app/features/attendance_behavior/presentation/widgets/attendance_behavior_widgets.dart';
import 'package:smart_table_app/features/attendance_behavior/providers/attendance_behavior_provider.dart';
import 'package:smart_table_app/features/teacher_tools/data/models/teacher_tools_ui_models.dart';
import 'package:smart_table_app/features/teacher_tools/presentation/views/teacher_tools_view.dart';

export 'attendance_behavior_filter_sheet.dart'
    show AttendanceBehaviorFilterSheet;
export 'attendance_panel.dart' show AttendancePanel;
export 'behavior_panel.dart' show BehaviorPanel;

class AttendanceBehaviorView extends ConsumerStatefulWidget {
  const AttendanceBehaviorView({
    super.key,
    this.initialClassId,
    this.initialClassName,
    this.initialSession,
    this.initialSessionLabel,
    this.showFilterOnOpen = false,
  });

  final int? initialClassId;
  final String? initialClassName;
  final String? initialSession;
  final String? initialSessionLabel;
  final bool showFilterOnOpen;

  @override
  ConsumerState<AttendanceBehaviorView> createState() =>
      _AttendanceBehaviorViewState();
}

class _AttendanceBehaviorViewState
    extends ConsumerState<AttendanceBehaviorView> {
  final _searchController = TextEditingController();
  int _sectionIndex = 0;
  int _attendanceMode = 0;
  int _behaviorMode = 0;
  int _reportIndex = 0;
  String? _reportSession;
  String _searchQuery = '';
  bool _showSearch = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(_initialize);
  }

  Future<void> _initialize() async {
    await ref.read(attendanceBehaviorProvider.notifier).load(
          initialClassId: widget.initialClassId,
          initialClassName: widget.initialClassName,
          initialSession: widget.initialSession,
          initialSessionLabel: widget.initialSessionLabel,
        );
    if (!mounted || !widget.showFilterOnOpen) return;
    final state = ref.read(attendanceBehaviorProvider);
    if (state.filters == null || state.errorMessage != null) return;
    await _showFilterSheet();
  }

  Future<void> _showFilterSheet() => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (_) => const AttendanceBehaviorFilterSheet(),
      );

  TeacherToolsContext? _teacherToolsContext(AttendanceBehaviorState state) {
    final attendance = state.attendanceRoster;
    final behavior = state.behaviorRoster;
    final classId = state.selectedClassId;
    final session = state.selectedSession;
    if (classId == null || session == null) return null;

    final selectedClass =
        state.filters?.classes.where((item) => item.id == classId).firstOrNull;
    final selectedSession = state.filters?.sessions
        .where((item) => item.value == session)
        .firstOrNull;
    final rawDate = attendance?.date ?? behavior?.date ?? state.selectedDate;
    final hasRecordedAttendance = state.students.any(
      (student) => student.attendanceStatus != AttendanceStatus.notRecorded,
    );
    final availableStudents = hasRecordedAttendance
        ? state.students.where(
            (student) => student.attendanceStatus == AttendanceStatus.present,
          )
        : state.students;

    return TeacherToolsContext(
      classId: classId,
      className: attendance?.className ??
          behavior?.className ??
          selectedClass?.name ??
          '',
      session: session,
      sessionLabel: attendance?.sessionLabel ??
          behavior?.sessionLabel ??
          selectedSession?.label ??
          session,
      subject: '',
      date: DateTime.tryParse(rawDate ?? '') ?? DateTime.now(),
      fallbackToPreviewStudents: false,
      students: availableStudents
          .map(
            (student) => TeacherToolStudent(
              id: student.id,
              name: student.name,
              number: student.numberStudent,
            ),
          )
          .toList(growable: false),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(attendanceBehaviorProvider);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: FeatureTitleAppBar(
          title: 'المواظبة والسلوك',
          action: IconButton.filled(
            tooltip: 'فلترة',
            onPressed: () async {
              if (_sectionIndex == 2) {
                final reportType = await Navigator.of(context).push<String>(
                  MaterialPageRoute<String>(
                    builder: (_) => ReportFilterView(
                      initialReportIndex: _reportIndex,
                      initialSession: _reportSession,
                    ),
                  ),
                );
                if (!mounted) return;
                if (reportType == 'attendance' || reportType == 'behavior') {
                  setState(
                    () => _reportIndex = reportType == 'attendance' ? 0 : 1,
                  );
                }
              } else {
                await _showFilterSheet();
              }
            },
            icon: const Icon(Icons.tune_rounded, color: Colors.white),
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 10),
              child: FeatureSegmentedControl(
                      labels: const [
                        'المواظبة',
                        'السلوك',
                        'التقارير',
                        'أدوات الحصة',
                      ],
                      selectedIndex: _sectionIndex,
                      onSelected: (index) {
                        setState(() {
                          if (index == 2 && _sectionIndex != 2) {
                            _reportSession = ref
                                .read(attendanceBehaviorProvider)
                                .selectedSession;
                          }
                          _sectionIndex = index;
                          _showSearch = false;
                          _searchController.clear();
                          _searchQuery = '';
                        });
                      },
                    ),
            ),
            if (_showSearch && _sectionIndex < 2)
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 8),
                child: SearchField(
                  controller: _searchController,
                  onChanged: (value) => setState(
                    () => _searchQuery = value.trim().toLowerCase(),
                  ),
                ),
              ),
            Expanded(child: _buildSection(state)),
          ],
        ),
        bottomNavigationBar:
            _sectionIndex >= 2 ? null : _buildBottomNavigation(),
      ),
    );
  }

  Widget _buildSection(AttendanceBehaviorState state) {
    return switch (_sectionIndex) {
      0 => AttendancePanel(
          recording: _attendanceMode == 1,
          searchQuery: _searchQuery,
          onFinishedRecording: () => setState(() => _attendanceMode = 0),
        ),
      1 => BehaviorPanel(
          onSelectionStarted: () => setState(() => _behaviorMode = 1),
          recording: _behaviorMode == 1,
          searchQuery: _searchQuery,
          onFinishedRecording: () => setState(() => _behaviorMode = 0),
        ),
      2 => AttendanceBehaviorReportsPanel(
          reportIndex: _reportIndex,
          initialSession: _reportSession,
          onReportChanged: (index) => setState(() => _reportIndex = index),
        ),
      _ => _buildTeacherToolsSection(state),
    };
  }

  Widget _buildTeacherToolsSection(AttendanceBehaviorState state) {
    final lessonContext = _teacherToolsContext(state);
    if (lessonContext == null) {
      if (state.loading) {
        return const Center(child: CircularProgressIndicator());
      }
      return const FeatureEmptyState(
        message: 'اختر الفصل والحصة لعرض أدوات الحصة',
      );
    }
    return TeacherToolsView.withContext(
      lessonContext: lessonContext,
      embedded: true,
    );
  }

  Widget _buildBottomNavigation() {
    final isAttendance = _sectionIndex == 0;
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(18, 8, 18, 12),
      child: Row(
        children: [
          SizedBox(
            width: 52,
            height: 52,
            child: FloatingActionButton(
              heroTag: 'attendance-behavior-search',
              elevation: 0,
              onPressed: () => setState(() => _showSearch = !_showSearch),
              child: const Icon(Icons.search_rounded, color: Colors.white),
            ),
          ),
          if (isAttendance) ...[
            const SizedBox(width: 12),
            Expanded(
              child: FeatureSegmentedControl(
                labels: const ['قائمة الطلاب', 'تسجيل الحضور'],
                selectedIndex: _attendanceMode,
                onSelected: (index) => setState(() => _attendanceMode = index),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
