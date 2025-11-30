import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/features/exams/data/models/exam_hall_group_model.dart';

import '../../../core/models/pagination_model.dart';
import '../data/repositories/exam_halls_repo.dart';

final examHallsGroupsProvider = FutureProvider.autoDispose
    .family<PaginationModel<ExamHallGroupModel>, int>((ref, page) async {
  return ref.read(examHallsRepoProvider).getExamHallsGroups(page);
});
