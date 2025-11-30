import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/features/class_visits/data/models/class_visits_model.dart';

import '../../../core/models/pagination_model.dart';
import '../data/repositories/class_visits.dart';

final classVisitsProvider = FutureProvider.autoDispose
    .family<PaginationModel<ClassVisitsModel>, int>((ref, page) async {
  return ref.read(classVisitsRepoProvider).getClassVisits(page);
});
