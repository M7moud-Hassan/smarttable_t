import 'package:hooks_riverpod/hooks_riverpod.dart' show Provider;

import '../service/api_service.dart';

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService(ref);
});
