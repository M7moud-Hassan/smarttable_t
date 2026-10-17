import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/core/constants/constants.dart';
import 'package:smart_table_app/core/extensions/context_extensions.dart';
import 'package:smart_table_app/core/utils/student_name_formatter.dart';
import 'package:smart_table_app/features/attendance_behavior/providers/attendance_behavior_provider.dart';
import 'package:smart_table_app/features/teacher_tools/data/models/teacher_tools_api_models.dart';
import 'package:smart_table_app/features/teacher_tools/data/models/teacher_tools_ui_models.dart';
import 'package:smart_table_app/features/teacher_tools/data/repositories/teacher_tools_repository.dart';
import 'package:smart_table_app/features/teacher_tools/presentation/widgets/teacher_tools_widgets.dart';

class SeatMapView extends ConsumerStatefulWidget {
  const SeatMapView({
    super.key,
    required this.lessonContext,
  });

  final TeacherToolsContext lessonContext;

  @override
  ConsumerState<SeatMapView> createState() => _SeatMapViewState();
}

class _SeatMapViewState extends ConsumerState<SeatMapView> {
  int _rows = 4;
  int _cols = 4;
  final Map<int, int> _assignments = {};
  List<TeacherToolStudent> _students = const [];
  bool _loading = true;
  bool _saving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _students = widget.lessonContext.availableStudents;
    const previewSeats = [0, 1, 3, 4, 5, 7, 8, 10];
    for (var index = 0;
        index < _students.length && index < previewSeats.length;
        index++) {
      _assignments[previewSeats[index]] = _students[index].id;
    }
    Future.microtask(_load);
  }

  Future<void> _load() async {
    final classId = widget.lessonContext.classId;
    if (classId == null) {
      setState(() {
        _loading = false;
        _errorMessage = 'تعذر تحديد الفصل لهذه الحصة';
      });
      return;
    }
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      final seatMap = await ref
          .read(teacherToolsRepositoryProvider)
          .getSeatMap(classId: classId);
      if (!mounted) return;
      setState(() {
        _rows = seatMap.rows > 0 ? seatMap.rows : 4;
        _cols = seatMap.cols > 0 ? seatMap.cols : 4;
        _students = seatMap.students;
        _assignments
          ..clear()
          ..addEntries(
            seatMap.assignments
                .where(
                  (assignment) => assignment.row > 0 && assignment.col > 0,
                )
                .map(
                  (assignment) => MapEntry(
                    (assignment.row - 1) * _cols + assignment.col - 1,
                    assignment.student.id,
                  ),
                ),
          );
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorMessage = perseveranceErrorMessage(error);
      });
    }
  }

  Future<void> _save() async {
    final classId = widget.lessonContext.classId;
    if (classId == null || _saving) return;
    setState(() => _saving = true);
    try {
      final assignments = <SeatAssignment>[];
      for (final entry in _assignments.entries) {
        final student = _studentById(entry.value);
        if (student == null) continue;
        assignments.add(
          SeatAssignment(
            student: student,
            row: entry.key ~/ _cols + 1,
            col: entry.key % _cols + 1,
          ),
        );
      }
      final saved = await ref.read(teacherToolsRepositoryProvider).saveSeatMap(
            classId: classId,
            rows: _rows,
            cols: _cols,
            assignments: assignments,
          );
      if (!mounted) return;
      setState(() {
        _students = saved.students;
        _saving = false;
      });
      context.showSnackbarSuccess('تم حفظ مخطط المقاعد بنجاح');
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(perseveranceErrorMessage(error))),
      );
    }
  }

  TeacherToolStudent? _studentById(int? id) {
    if (id == null) return null;
    for (final student in _students) {
      if (student.id == id) return student;
    }
    return null;
  }

  List<TeacherToolStudent> get _unassignedStudents {
    final assignedIds = _assignments.values.toSet();
    return _students
        .where((student) => !assignedIds.contains(student.id))
        .toList(growable: false);
  }

  void _changeGrid({int? rows, int? cols}) {
    final nextRows = rows ?? _rows;
    final nextCols = cols ?? _cols;
    final seatCount = nextRows * nextCols;
    setState(() {
      _rows = nextRows;
      _cols = nextCols;
      _assignments.removeWhere((seat, _) => seat >= seatCount);
    });
  }

  Future<void> _openStudentPicker(int seatIndex) async {
    final occupant = _studentById(_assignments[seatIndex]);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (sheetContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              18,
              12,
              18,
              16 + MediaQuery.viewInsetsOf(sheetContext).bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD8D8D8),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  occupant == null ? 'إسناد طالب للمقعد' : 'تعديل المقعد',
                  style: const TextStyle(
                    color: AppColors.secondryColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (occupant != null) ...[
                  const SizedBox(height: 10),
                  _StudentPickerTile(
                    student: occupant,
                    trailing: const Icon(
                      Icons.remove_circle_outline_rounded,
                      color: teacherToolsRed,
                    ),
                    onTap: () {
                      setState(() => _assignments.remove(seatIndex));
                      Navigator.pop(sheetContext);
                    },
                  ),
                  const Divider(height: 22),
                ],
                Flexible(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.sizeOf(sheetContext).height * .55,
                    ),
                    child: _unassignedStudents.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(24),
                            child: Text('تم إسناد جميع الطلاب إلى مقاعد'),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            itemCount: _unassignedStudents.length,
                            itemBuilder: (_, index) {
                              final student = _unassignedStudents[index];
                              return _StudentPickerTile(
                                student: student,
                                trailing: const Icon(
                                  Icons.add_circle_outline_rounded,
                                  color: AppColors.primaryColor,
                                ),
                                onTap: () {
                                  setState(
                                    () => _assignments[seatIndex] = student.id,
                                  );
                                  Navigator.pop(sheetContext);
                                },
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: const TeacherToolsAppBar(title: 'مخطط المقاعد'),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? TeacherToolsLoadError(
                    message: _errorMessage!,
                    onRetry: _load,
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(18, 8, 18, 20),
                    children: [
                      TeacherToolsContextCard(
                        lessonContext: widget.lessonContext,
                        compact: true,
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          const Expanded(
                            child: TeacherToolSectionTitle(
                              title: 'شكل الفصل',
                              subtitle:
                                  'اضغط على أي مقعد لإسناد طالب أو تغييره',
                            ),
                          ),
                          _GridSizeControl(
                            label: 'صفوف',
                            value: _rows,
                            onDecrease: _rows > 2
                                ? () => _changeGrid(rows: _rows - 1)
                                : null,
                            onIncrease: _rows < 6
                                ? () => _changeGrid(rows: _rows + 1)
                                : null,
                          ),
                          const SizedBox(width: 7),
                          _GridSizeControl(
                            label: 'أعمدة',
                            value: _cols,
                            onDecrease: _cols > 2
                                ? () => _changeGrid(cols: _cols - 1)
                                : null,
                            onIncrease: _cols < 6
                                ? () => _changeGrid(cols: _cols + 1)
                                : null,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const _TeacherDesk(),
                      const SizedBox(height: 17),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: teacherToolsSurface,
                          borderRadius: BorderRadius.circular(19),
                          border: Border.all(color: const Color(0xFFE3EEEE)),
                        ),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _rows * _cols,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: _cols,
                            crossAxisSpacing: 7,
                            mainAxisSpacing: 7,
                            childAspectRatio: .9,
                          ),
                          itemBuilder: (_, index) {
                            final student = _studentById(_assignments[index]);
                            return _SeatCell(
                              seatNumber: index + 1,
                              student: student,
                              onTap: () => _openStudentPicker(index),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: _SeatMapStat(
                              icon: Icons.event_seat_rounded,
                              value: '${_assignments.length}',
                              label: 'مقاعد مستخدمة',
                              color: AppColors.primaryColor,
                            ),
                          ),
                          const SizedBox(width: 9),
                          Expanded(
                            child: _SeatMapStat(
                              icon: Icons.person_add_alt_1_rounded,
                              value: '${_unassignedStudents.length}',
                              label: 'دون مقعد',
                              color: teacherToolsAmber,
                            ),
                          ),
                        ],
                      ),
                      if (_unassignedStudents.isNotEmpty) ...[
                        const SizedBox(height: 18),
                        const TeacherToolSectionTitle(
                          title: 'طلاب دون مقاعد',
                          subtitle: 'اختر مقعدًا فارغًا لإضافة أحدهم',
                        ),
                        const SizedBox(height: 9),
                        Wrap(
                          spacing: 7,
                          runSpacing: 7,
                          children: _unassignedStudents
                              .map(
                                (student) => Chip(
                                  label: Text(
                                    compactStudentName(student.name),
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  avatar: TeacherToolsStudentAvatar(
                                    name: student.name,
                                    radius: 13,
                                  ),
                                  side: BorderSide.none,
                                  backgroundColor: const Color(0xFFF4F4F4),
                                ),
                              )
                              .toList(growable: false),
                        ),
                      ],
                    ],
                  ),
        bottomNavigationBar: SafeArea(
          top: false,
          minimum: const EdgeInsets.fromLTRB(18, 8, 18, 14),
          child: TeacherToolsPrimaryButton(
            label: 'حفظ مخطط المقاعد',
            icon: Icons.save_outlined,
            onPressed:
                _loading || _errorMessage != null || _saving ? null : _save,
          ),
        ),
      ),
    );
  }
}

class _GridSizeControl extends StatelessWidget {
  const _GridSizeControl({
    required this.label,
    required this.value,
    required this.onDecrease,
    required this.onIncrease,
  });

  final String label;
  final int value;
  final VoidCallback? onDecrease;
  final VoidCallback? onIncrease;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 9)),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _TinyControlButton(
                key: ValueKey('seat-grid-$label-decrease'),
                icon: Icons.remove_rounded,
                onPressed: onDecrease,
              ),
              SizedBox(
                width: 20,
                child: Text(
                  '$value',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              _TinyControlButton(
                key: ValueKey('seat-grid-$label-increase'),
                icon: Icons.add_rounded,
                onPressed: onIncrease,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TinyControlButton extends StatelessWidget {
  const _TinyControlButton({
    super.key,
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: Icon(
          icon,
          size: 16,
          color: onPressed == null
              ? const Color(0xFFC8C8C8)
              : AppColors.secondryColor,
        ),
      ),
    );
  }
}

class _TeacherDesk extends StatelessWidget {
  const _TeacherDesk();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 190,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.secondryColor,
          borderRadius: BorderRadius.circular(13),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.co_present_rounded, color: Colors.white, size: 20),
            SizedBox(width: 7),
            Text(
              'مكتب المعلم',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SeatCell extends StatelessWidget {
  const _SeatCell({
    required this.seatNumber,
    required this.student,
    required this.onTap,
  });

  final int seatNumber;
  final TeacherToolStudent? student;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: student == null ? Colors.white : const Color(0xFFE7F8F8),
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        borderRadius: BorderRadius.circular(13),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: student == null
                  ? const Color(0xFFD8E3E3)
                  : AppColors.primaryColor,
            ),
          ),
          child: student == null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.add_rounded,
                      color: Color(0xFF9AABAB),
                      size: 20,
                    ),
                    Text(
                      '$seatNumber',
                      style: const TextStyle(
                        color: Color(0xFF8A9999),
                        fontSize: 10,
                      ),
                    ),
                  ],
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final compact =
                        constraints.maxHeight < 54 || constraints.maxWidth < 54;
                    return Center(
                      child: Text(
                        compactStudentName(student!.name),
                        maxLines: compact ? 2 : 3,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.secondryColor,
                          fontSize: compact ? 9 : 11,
                          height: 1.2,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}

class _SeatMapStat extends StatelessWidget {
  const _SeatMapStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: color, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StudentPickerTile extends StatelessWidget {
  const _StudentPickerTile({
    required this.student,
    required this.trailing,
    required this.onTap,
  });

  final TeacherToolStudent student;
  final Widget trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      leading: TeacherToolsStudentAvatar(name: student.name, radius: 20),
      title: Text(
        compactStudentName(student.name),
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      subtitle: Text('الرقم ${student.number}'),
      trailing: trailing,
    );
  }
}
