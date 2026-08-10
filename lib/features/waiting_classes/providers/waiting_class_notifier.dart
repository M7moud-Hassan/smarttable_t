import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/core/constants/keys_enums.dart';
import 'package:smart_table_app/core/service/api_service.dart';
import 'package:smart_table_app/features/waiting_classes/providers/waiting_class_provider.dart';

import '../../../core/models/models.dart';
import '../../../core/providers/providers.dart';
import '../../home/providers/home_menu_provider.dart';
import '../../school_table/providers/teacher_table_provider.dart';
import '../data/repositories/waiting_class_repo.dart';

class WaitingClassNotifier extends StateNotifier<bool> {
  WaitingClassNotifier(this._ref) : super(false);
  final Ref _ref;

  acceptWaitingClass(String url, {bool fromTeacherTable = false}) async {
    final ApiService apiService = _ref.read(apiServiceProvider);
    try {
      _ref
          .read(requestResponseProvider.notifier)
          .update((state) => RequestResponseModel.loading());
      await apiService.generalGet(url);
      if (fromTeacherTable) {
        _ref.invalidate(teacherTableProvider);
      } else {
        _ref.invalidate(waitingClassProvider);
      }
      _ref.invalidate(homeMenuProvider);
      _ref
          .read(requestResponseProvider.notifier)
          .update((state) => RequestResponseModel.success());
    } on Exception catch (e) {
      _ref
          .read(requestResponseProvider.notifier)
          .update((state) => RequestResponseModel.error(exception: e));
    } finally {
      _ref
          .read(requestResponseProvider.notifier)
          .update((state) => RequestResponseModel.loading(loading: false));
    }
  }

  Future<bool> secureClassWithSubstitute(
    int cellNumber,
    int substituteId,
    String? note, {
    bool fromTeacherTable = false,
  }) async {
    final repo = _ref.read(waitingClasessRepoProvider);
    try {
      _ref
          .read(requestResponseProvider.notifier)
          .update((state) => RequestResponseModel.loading());
      await repo.createSecureClassRequest(cellNumber, substituteId, note);
      if (fromTeacherTable) {
        _ref.invalidate(teacherTableProvider);
      } else {
        _ref.invalidate(waitingClassProvider);
      }
      _ref.invalidate(secureClassRequestsProvider);
      _ref.invalidate(homeMenuProvider);
      _ref
          .read(requestResponseProvider.notifier)
          .update((state) => RequestResponseModel.success());
      return true;
    } on Exception catch (e) {
      _ref
          .read(requestResponseProvider.notifier)
          .update((state) => RequestResponseModel.error(exception: e));
      return false;
    } finally {
      _ref
          .read(requestResponseProvider.notifier)
          .update((state) => RequestResponseModel.loading(loading: false));
    }
  }

  Future<bool> cancelSecureClassRequest(int requestId) async {
    final repo = _ref.read(waitingClasessRepoProvider);
    try {
      _ref
          .read(requestResponseProvider.notifier)
          .update((state) => RequestResponseModel.loading());
      final message = await repo.cancelSecureClassRequest(requestId);
      _ref.invalidate(secureClassRequestsProvider);
      _ref.read(requestResponseProvider.notifier).update(
            (state) => RequestResponseModel.success(
              message: message,
              actionOnDone: ActionOnDone.showSucessMessage,
            ),
          );
      return true;
    } on Exception catch (e) {
      _ref
          .read(requestResponseProvider.notifier)
          .update((state) => RequestResponseModel.error(exception: e));
      return false;
    } finally {
      _ref
          .read(requestResponseProvider.notifier)
          .update((state) => RequestResponseModel.loading(loading: false));
    }
  }
}

final waitingClassNotifierProvider =
    StateNotifierProvider<WaitingClassNotifier, bool>((ref) {
  return WaitingClassNotifier(ref);
});
