import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/features/teacher_notes/data/models/teacher_note_model.dart';

import '../../../core/models/pagination_model.dart';
import '../data/repositories/teacher_notes_repo.dart';

final teacherNotesProvider = FutureProvider.autoDispose
    .family<PaginationModel<TeacherNoteModel>, int>((ref, page) async {
  return ref.read(teacherNotesRepoProvider).getTeacherNotes(page);
});
