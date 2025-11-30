import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/features/school_table/data/models/lesson_model.dart';

import '../data/repositories/waiting_class_repo.dart';

final waitingClassProvider =
    FutureProvider.autoDispose<List<LessonModel>>((ref) async {
  final waitingClasessRepo = ref.read(waitingClasessRepoProvider);
  return waitingClasessRepo.getWaitingClasess();
});
