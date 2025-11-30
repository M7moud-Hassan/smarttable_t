import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../data/models/exam_hall_model.dart';
import '../data/repositories/exam_halls_repo.dart';

final examHallsProvider = FutureProvider.autoDispose
    .family<List<ExamHallModel>, int>((ref, id) async {
  return ref.read(examHallsRepoProvider).getExamHalls(id);
});
