import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/features/school_table/data/models/lesson_model.dart';

import '../data/models/substitute_model.dart';
import '../data/models/secure_class_request_model.dart';
import '../data/repositories/waiting_class_repo.dart';

typedef SecureClassRequestsQuery = ({String role, String? status});

final waitingClassProvider =
    FutureProvider.autoDispose<List<LessonModel>>((ref) async {
  final waitingClasessRepo = ref.read(waitingClasessRepoProvider);
  return waitingClasessRepo.getWaitingClasess();
});

final substitutesProvider = FutureProvider.family
    .autoDispose<List<SubstituteModel>, int>((ref, cellNumber) async {
  final waitingClasessRepo = ref.read(waitingClasessRepoProvider);
  return waitingClasessRepo.getSubstituteTeachers(cellNumber);
});

final secureClassRequestsProvider = FutureProvider.family
    .autoDispose<List<SecureClassRequestModel>, SecureClassRequestsQuery>(
        (ref, query) {
  return ref.read(waitingClasessRepoProvider).getSecureClassRequests(
        role: query.role,
        status: query.status,
      );
});
