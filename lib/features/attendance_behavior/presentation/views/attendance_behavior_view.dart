import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/features/attendance_behavior/presentation/views/attendance_behavior_filter_sheet.dart';
import 'package:smart_table_app/features/attendance_behavior/presentation/views/attendance_panel.dart';
import 'package:smart_table_app/features/attendance_behavior/presentation/views/behavior_panel.dart';
import 'package:smart_table_app/features/attendance_behavior/presentation/views/attendance_behavior_reports_view.dart';
import 'package:smart_table_app/features/attendance_behavior/presentation/widgets/attendance_behavior_widgets.dart';
import 'package:smart_table_app/features/attendance_behavior/providers/attendance_behavior_provider.dart';

export 'attendance_behavior_filter_sheet.dart'
    show AttendanceBehaviorFilterSheet;
export 'attendance_panel.dart' show AttendancePanel;
export 'behavior_panel.dart' show BehaviorPanel;

class AttendanceBehaviorView extends ConsumerStatefulWidget {
  const AttendanceBehaviorView({super.key});

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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                      () => _reportIndex = reportType == 'attendance' ? 0 : 1);
                }
              } else {
                showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => const AttendanceBehaviorFilterSheet(),
                );
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
                labels: const ['المواظبة', 'السلوك', 'التقارير والإحصائيات'],
                selectedIndex: _sectionIndex,
                onSelected: (index) {
                  setState(() {
                    if (index == 2 && _sectionIndex != 2) {
                      _reportSession =
                          ref.read(attendanceBehaviorProvider).selectedSession;
                    }
                    _sectionIndex = index;
                    _showSearch = false;
                    _searchController.clear();
                    _searchQuery = '';
                  });
                },
              ),
            ),
            if (_showSearch && _sectionIndex != 2)
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 8),
                child: SearchField(
                  controller: _searchController,
                  onChanged: (value) => setState(
                    () => _searchQuery = value.trim().toLowerCase(),
                  ),
                ),
              ),
            Expanded(child: _buildSection()),
          ],
        ),
        bottomNavigationBar:
            _sectionIndex == 2 ? null : _buildBottomNavigation(),
      ),
    );
  }

  Widget _buildSection() {
    return switch (_sectionIndex) {
      0 => AttendancePanel(
          recording: _attendanceMode == 1,
          searchQuery: _searchQuery,
          onFinishedRecording: () => setState(() => _attendanceMode = 0),
        ),
      1 => BehaviorPanel(
          recording: _behaviorMode == 1,
          searchQuery: _searchQuery,
          onFinishedRecording: () => setState(() => _behaviorMode = 0),
        ),
      _ => AttendanceBehaviorReportsPanel(
          reportIndex: _reportIndex,
          initialSession: _reportSession,
          onReportChanged: (index) => setState(() => _reportIndex = index),
        ),
    };
  }

  Widget _buildBottomNavigation() {
    final isAttendance = _sectionIndex == 0;
    final selected = isAttendance ? _attendanceMode : _behaviorMode;
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
          const SizedBox(width: 12),
          Expanded(
            child: FeatureSegmentedControl(
              labels: isAttendance
                  ? const ['قائمة الطلاب', 'تسجيل الحضور']
                  : const ['سلوك الطلاب', 'تسجيل السلوك'],
              selectedIndex: selected,
              onSelected: (index) {
                setState(() {
                  if (isAttendance) {
                    _attendanceMode = index;
                  } else {
                    _behaviorMode = index;
                  }
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
