import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/features/circulars/data/models/circulars_model.dart';

import '../../../core/models/pagination_model.dart';
import '../data/repositories/circulars_repo.dart';

final circularsProvider = FutureProvider.autoDispose
    .family<PaginationModel<CircularsModel>, int>((ref, page) async {
  return ref.read(circularsRepoProvider).getCirculars(page);
});
