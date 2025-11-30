import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/features/school_table/data/models/teacher_table_model.dart';

import '../data/repositories/school_table_repo.dart';

final teacherTableProvider =
    FutureProvider.autoDispose<TeacherTableModel>((ref) async {
  return ref.read(schoolTableRepoProvider).getTeacherTable();
});
