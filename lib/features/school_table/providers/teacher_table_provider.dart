import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/features/school_table/data/models/teacher_table_model.dart';

import '../data/repositories/school_table_repo.dart';

final teacherTableProvider =
    FutureProvider.autoDispose<TeacherTableModel>((ref) async {
  final tableData = await ref.read(schoolTableRepoProvider).getTeacherTable();

  // Filter days of week (Exclude Friday and Saturday)
  final filteredDays = tableData.tableInfo[0].daysOfWeek
      .where((day) => !day.name.contains('الجمعة') && !day.name.contains('السبت'))
      .toList();

  // Get the IDs of remaining allowed days
  final allowedDayIds = filteredDays.map((d) => d.id).toSet();

  // Filter lessons to only include those for allowed days
  final filteredLessons = tableData.tableInfo[0].lessons
      .where((lesson) => allowedDayIds.contains(lesson.dayId))
      .toList();

  // Update the data model with filtered lists
  tableData.tableInfo[0].daysOfWeek = filteredDays;
  tableData.tableInfo[0].lessons = filteredLessons;

  return tableData;
});
