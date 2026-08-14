import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/features/administrative_actions/data/models/administrative_action_model.dart';
import 'package:smart_table_app/features/administrative_actions/data/repositories/administrative_actions_repository.dart';

final administrativeActionsProvider =
    FutureProvider.autoDispose<AdministrativeActionsPage>((ref) {
  return ref.read(administrativeActionsRepositoryProvider).getProcedures();
});

final administrativeActionDetailsProvider = FutureProvider.autoDispose
    .family<AdministrativeActionDetailModel, AdministrativeProcedureKey>(
        (ref, key) {
  return ref.read(administrativeActionsRepositoryProvider).getProcedure(key);
});

final administrativeActionReplyProvider = StateNotifierProvider.autoDispose<
    AdministrativeActionReplyNotifier, AsyncValue<void>>((ref) {
  return AdministrativeActionReplyNotifier(ref);
});

class AdministrativeActionReplyNotifier
    extends StateNotifier<AsyncValue<void>> {
  AdministrativeActionReplyNotifier(this._ref)
      : super(const AsyncValue.data(null));

  final Ref _ref;

  Future<bool> submit(
    AdministrativeProcedureKey key,
    String teacherReason,
  ) async {
    state = const AsyncValue.loading();
    try {
      await _ref
          .read(administrativeActionsRepositoryProvider)
          .submitTeacherReason(key, teacherReason);
      _ref.invalidate(administrativeActionsProvider);
      _ref.invalidate(administrativeActionDetailsProvider(key));
      state = const AsyncValue.data(null);
      return true;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return false;
    }
  }
}
