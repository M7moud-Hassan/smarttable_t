import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/features/circulars/data/models/circulars_model.dart';

import '../../../core/models/pagination_model.dart';
import '../data/repositories/circulars_repo.dart';

final circularsProvider = FutureProvider.autoDispose
    .family<PaginationModel<CircularsModel>, int>((ref, page) async {
  return ref.read(circularsRepoProvider).getCirculars(page);
});

final circularSignProvider = StateNotifierProvider.autoDispose
    .family<CircularSignNotifier, AsyncValue<String?>, int>((ref, circularId) {
  return CircularSignNotifier(ref, circularId);
});

class CircularSignNotifier extends StateNotifier<AsyncValue<String?>> {
  CircularSignNotifier(this._ref, this._circularId)
      : super(const AsyncValue.data(null));

  final Ref _ref;
  final int _circularId;

  Future<bool> sign() async {
    if (state.isLoading) return false;
    state = const AsyncValue.loading();
    try {
      final message =
          await _ref.read(circularsRepoProvider).signCircular(_circularId);
      state = AsyncValue.data(message);
      _ref.invalidate(circularsProvider);
      return true;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return false;
    }
  }
}
