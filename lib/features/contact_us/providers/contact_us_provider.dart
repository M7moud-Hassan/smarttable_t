import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/core/providers/request_response_provider.dart';

import '../../../core/constants/constants.dart';
import '../../../core/models/models.dart';
import '../data/repositories/contactus_repo.dart';

class ContactUsNotifier extends StateNotifier<bool> {
  ContactUsNotifier(this._ref) : super(false);

  final Ref _ref;

  Future<void> send(
      {required String name,
      required String phone,
      required String email,
      required String title,
      required String message}) async {
    try {
      _ref
          .read(requestResponseProvider.notifier)
          .update((state) => RequestResponseModel.loading());
      final response = await _ref.read(contactUsRepoProvider).contactUs(
            name: name,
            phone: phone,
            email: email,
            title: title,
            message: message,
          );

      _ref
          .read(requestResponseProvider.notifier)
          .update((state) => RequestResponseModel.success(
                actionOnDone: ActionOnDone.showSucessMessageAndPop,
                message: response,
              ));
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
}

final contactUsProvider = StateNotifierProvider<ContactUsNotifier, bool>(
  (ref) => ContactUsNotifier(ref),
);
