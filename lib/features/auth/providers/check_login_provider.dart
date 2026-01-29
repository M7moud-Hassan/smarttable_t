import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/utils/token_storage.dart';

final checkLoginProvider = FutureProvider<bool>((ref) async {
  final token = await ref.read(tokenStorageProvider).getToken();
  return token != null;
});
