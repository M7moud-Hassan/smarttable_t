import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../models/request_response_state_model.dart';

final requestResponseProvider =
    StateProvider.autoDispose<RequestResponseModel>((ref) {
  return RequestResponseModel.init();
});
